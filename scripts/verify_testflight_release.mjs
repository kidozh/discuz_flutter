#!/usr/bin/env node
// Read back the exact uploaded build and its TestFlight "What to Test" text.
// Uses only Node built-ins; credentials stay in memory and are never logged.
import {createSign} from 'node:crypto';
import {readFile, writeFile, mkdir} from 'node:fs/promises';
import {dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
import {parseArgs} from 'node:util';

export function createToken(issuer, keyId, privateKey) {
  const now = Math.floor(Date.now() / 1000);
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  const input = `${encode({alg: 'ES256', kid: keyId, typ: 'JWT'})}.${encode({iss: issuer, aud: 'appstoreconnect-v1', iat: now - 30, exp: now + 120})}`;
  const signer = createSign('SHA256');
  signer.update(input);
  signer.end();
  return `${input}.${signer.sign({key: privateKey, dsaEncoding: 'ieee-p1363'}).toString('base64url')}`;
}

export async function verifyRelease(api, {bundleId, version, buildNumber, notes, checkAvailable = false}) {
  if (!checkAvailable && !notes?.startsWith(`${version} (${buildNumber})\n\n`)) {
    throw new Error('TestFlight notes do not match the selected version and build.');
  }
  const apps = await api(`/apps?${new URLSearchParams({'filter[bundleId]': bundleId})}`);
  if (apps.data?.length !== 1) throw new Error('Expected exactly one App Store Connect app.');
  const app = apps.data[0];
  const builds = await api(`/builds?${new URLSearchParams({
    'filter[app]': app.id, 'filter[version]': buildNumber,
    'filter[preReleaseVersion.platform]': 'IOS', include: 'preReleaseVersion', limit: '200',
  })}`);
  if (checkAvailable) {
    if (builds.data?.length) throw new Error(`Build number ${buildNumber} already exists; choose a new build number before uploading.`);
    return {bundleId, version, buildNumber, available: true};
  }
  const matching = (builds.data ?? []).filter(build => {
    const id = build.relationships?.preReleaseVersion?.data?.id;
    return builds.included?.some(item => item.type === 'preReleaseVersions' && item.id === id && item.attributes?.version === version);
  });
  if (matching.length !== 1) throw new Error(`Cannot uniquely locate ${version} (${buildNumber}).`);
  const build = matching[0];
  if (build.attributes?.processingState !== 'VALID' || build.attributes?.expired) {
    throw new Error(`Build is not ready: ${build.attributes?.processingState}, expired=${build.attributes?.expired}.`);
  }
  const path = `/builds/${build.id}/betaBuildLocalizations`;
  const existing = (await api(path)).data ?? [];
  // Populate Chinese plus the app's fallback locale so testers can see notes
  // regardless of their device language. Both use the approved Chinese text.
  const locales = [...new Set(['zh-Hans', app.attributes?.primaryLocale].filter(Boolean))];
  for (const locale of locales) {
    const localization = existing.find(item => item.attributes?.locale === locale);
    if (localization?.attributes?.whatsNew === notes) continue;
    if (localization) {
      await api(`/betaBuildLocalizations/${localization.id}`, 'PATCH', {
        data: {type: 'betaBuildLocalizations', id: localization.id, attributes: {whatsNew: notes}},
      });
    } else {
      await api('/betaBuildLocalizations', 'POST', {data: {
        type: 'betaBuildLocalizations', attributes: {locale, whatsNew: notes},
        relationships: {build: {data: {type: 'builds', id: build.id}}},
      }});
    }
  }
  const actual = (await api(path)).data ?? [];
  for (const locale of locales) {
    if (!actual.some(item => item.attributes?.locale === locale && item.attributes?.whatsNew === notes)) {
      throw new Error(`TestFlight notes read-back failed for ${locale}.`);
    }
  }
  return {bundleId, appId: app.id, buildId: build.id, version, buildNumber,
    processingState: build.attributes.processingState, locales, notes, verifiedAt: new Date().toISOString()};
}

async function main() {
  const {values} = parseArgs({options: {
    'bundle-id': {type: 'string', default: 'com.kidozh.discuz-flutter'},
    version: {type: 'string'}, 'build-number': {type: 'string'},
    'notes-file': {type: 'string', default: 'build/ios/testflight-release-notes.txt'},
    output: {type: 'string', default: 'build/ios/testflight-verification.json'},
    'check-available': {type: 'boolean', default: false},
  }});
  if (!/^\d+\.\d+\.\d+$/.test(values.version ?? '') || !/^[1-9]\d*$/.test(values['build-number'] ?? '')) {
    throw new Error('Provide --version major.minor.patch and --build-number.');
  }
  const {APPSTORE_ISSUER_ID: issuer, APPSTORE_API_KEY_ID: keyId, APPSTORE_API_PRIVATE_KEY: privateKey} = process.env;
  if (!issuer || !keyId || !privateKey) throw new Error('Missing App Store Connect credentials.');
  const api = async (path, method = 'GET', body) => {
    const response = await fetch(`https://api.appstoreconnect.apple.com/v1${path}`, {
      method, headers: {Authorization: `Bearer ${createToken(issuer, keyId, privateKey)}`, 'Content-Type': 'application/json'},
      body: body ? JSON.stringify(body) : undefined, signal: AbortSignal.timeout(60000),
    });
    if (!response.ok) throw new Error(`App Store Connect ${method} ${path.split('?')[0]} returned ${response.status}: ${(await response.text()).slice(0, 1000)}`);
    return response.status === 204 ? null : response.json();
  };
  const result = await verifyRelease(api, {
    bundleId: values['bundle-id'], version: values.version, buildNumber: values['build-number'],
    notes: values['check-available'] ? undefined : (await readFile(values['notes-file'], 'utf8')).trim(),
    checkAvailable: values['check-available'],
  });
  if (!values['check-available']) {
    await mkdir(dirname(values.output), {recursive: true});
    await writeFile(values.output, `${JSON.stringify(result, null, 2)}\n`);
  }
  console.log(values['check-available'] ? `Build number ${result.buildNumber} is available.` : `Verified TestFlight ${result.version} (${result.buildNumber}), build ${result.buildId}, locales: ${result.locales.join(', ')}.`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(error => { console.error(error.message); process.exitCode = 1; });
}
