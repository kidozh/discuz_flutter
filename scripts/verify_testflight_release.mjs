#!/usr/bin/env node
// Read back the exact uploaded build and its TestFlight "What to Test" text.
// Uses only Node built-ins; credentials stay in memory and are never logged.
import {createSign} from 'node:crypto';
import {appendFile, readFile, writeFile, mkdir} from 'node:fs/promises';
import {dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
import {parseArgs} from 'node:util';

export class BuildPendingError extends Error {}

export function createToken(issuer, keyId, privateKey) {
  const now = Math.floor(Date.now() / 1000);
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  const input = `${encode({alg: 'ES256', kid: keyId, typ: 'JWT'})}.${encode({iss: issuer, aud: 'appstoreconnect-v1', iat: now - 30, exp: now + 120})}`;
  const signer = createSign('SHA256');
  signer.update(input);
  signer.end();
  return `${input}.${signer.sign({key: privateKey, dsaEncoding: 'ieee-p1363'}).toString('base64url')}`;
}

export async function verifyRelease(api, {bundleId, version, buildNumber, notes, checkAvailable = false, reuseExisting = false, repairBuildId}) {
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
  const matching = [];
  const observed = [];
  for (const build of builds.data ?? []) {
    const id = build.relationships?.preReleaseVersion?.data?.id;
    let train = builds.included?.find(item => item.type === 'preReleaseVersions' && item.id === id);
    if (!train) train = (await api(`/builds/${build.id}/preReleaseVersion`)).data;
    observed.push({buildId: build.id, buildNumber: build.attributes?.version, version: train?.attributes?.version});
    if (train?.attributes?.version === version && build.attributes?.version === buildNumber) matching.push(build);
  }
  if (checkAvailable) {
    if (reuseExisting) {
      if (matching.length > 1 || matching.some(build =>
        build.attributes?.expired || !['VALID', 'PROCESSING'].includes(build.attributes?.processingState))) {
        throw new Error(`Build ${version} (${buildNumber}) exists but cannot be reused.`);
      }
      if (matching.length) return {bundleId, version, buildNumber, available: false};
      const uploadQuery = new URLSearchParams({
        'filter[cfBundleVersion]': buildNumber, 'filter[cfBundleShortVersionString]': version,
      });
      const uploads = await api(`/apps/${app.id}/buildUploads?${uploadQuery}`);
      const states = (uploads.data ?? []).filter(({attributes}) =>
        attributes?.cfBundleShortVersionString === version && attributes?.cfBundleVersion === buildNumber &&
        attributes?.platform === 'IOS').map(({attributes}) => attributes.state?.state);
      if (states.some(state => ['PROCESSING', 'COMPLETE'].includes(state))) {
        return {bundleId, version, buildNumber, available: false};
      }
      if (states.includes('FAILED')) throw new Error(`Build ${version} (${buildNumber}) failed Apple processing.`);
    }
    if (matching.length) {
      const states = matching.map(build => `${build.id}: ${build.attributes?.processingState}`).join(', ');
      throw new Error(`Build ${version} (${buildNumber}) already exists (${states}); choose a new build number before uploading.`);
    }
    return {bundleId, version, buildNumber, available: true};
  }
  if (matching.length === 0) {
    const versions = (builds.included ?? []).map(item => ({id: item.id, type: item.type, version: item.attributes?.version}));
    throw new BuildPendingError(`Build ${version} (${buildNumber}) is not visible yet. Candidates: ${JSON.stringify(observed)}; versions: ${JSON.stringify(versions)}.`);
  }
  if (matching.length !== 1) throw new Error(`Cannot uniquely locate ${version} (${buildNumber}).`);
  const build = matching[0];
  if (build.attributes?.processingState === 'PROCESSING' && !build.attributes?.expired) {
    throw new BuildPendingError(`Build ${version} (${buildNumber}) is still processing.`);
  }
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
  let repairedPreviousBuild;
  if (repairBuildId && repairBuildId !== build.id) {
    if (!/^[0-9a-f-]{36}$/i.test(repairBuildId)) throw new Error('Invalid previous build identifier.');
    const previous = (await api(`/builds/${repairBuildId}`)).data;
    const previousTrain = (await api(`/builds/${repairBuildId}/preReleaseVersion`)).data;
    const previousVersion = previousTrain.attributes?.version;
    const previousNumber = previous.attributes?.version;
    if (!previousVersion || !previousNumber) {
      throw new Error('Cannot resolve the previous build version.');
    }
    const previousPath = `/builds/${repairBuildId}/betaBuildLocalizations`;
    const previousNotes = (await api(previousPath)).data ?? [];
    const incorrect = previousNotes.filter(item => item.attributes?.whatsNew === notes);
    const corrected = `${previousVersion} (${previousNumber})\n\n此为历史构建。本次图片编辑、设置外观和论坛首页等改进的更新说明对应 ${version} (${buildNumber})，请在 TestFlight 中查看相应版本。`;
    for (const item of incorrect) {
      await api(`/betaBuildLocalizations/${item.id}`, 'PATCH', {data: {
        type: 'betaBuildLocalizations', id: item.id, attributes: {whatsNew: corrected},
      }});
    }
    const readBack = (await api(previousPath)).data ?? [];
    for (const item of incorrect) {
      if (!readBack.some(row => row.id === item.id && row.attributes?.whatsNew === corrected)) {
        throw new Error('Historical build correction did not persist.');
      }
    }
    repairedPreviousBuild = {buildId: repairBuildId, version: previousVersion, buildNumber: previousNumber,
      locales: incorrect.map(item => item.attributes.locale), notes: incorrect.length ? corrected : undefined};
  }
  return {bundleId, appId: app.id, buildId: build.id, version, buildNumber,
    processingState: build.attributes.processingState, locales, notes, observedBuilds: observed,
    repairedPreviousBuild, verifiedAt: new Date().toISOString()};
}

export async function waitForRelease(api, options, {attempts = 60, sleep = () => new Promise(resolve => setTimeout(resolve, 30000)), onPending = () => {}} = {}) {
  for (let attempt = 0; attempt < attempts; attempt++) {
    try { return await verifyRelease(api, options); }
    catch (error) {
      if (!(error instanceof BuildPendingError) || attempt === attempts - 1) throw error;
      onPending(error.message);
      await sleep();
    }
  }
}

export function appStoreApi({APPSTORE_ISSUER_ID: issuer, APPSTORE_API_KEY_ID: keyId, APPSTORE_API_PRIVATE_KEY: privateKey} = process.env) {
  if (!issuer || !keyId || !privateKey) throw new Error('Missing App Store Connect credentials.');
  return async (path, method = 'GET', body) => {
    const response = await fetch(`https://api.appstoreconnect.apple.com/v1${path}`, {
      method, headers: {Authorization: `Bearer ${createToken(issuer, keyId, privateKey)}`, 'Content-Type': 'application/json'},
      body: body ? JSON.stringify(body) : undefined, signal: AbortSignal.timeout(60000),
    });
    if (!response.ok) throw new Error(`App Store Connect ${method} ${path.split('?')[0]} returned ${response.status}: ${(await response.text()).slice(0, 1000)}`);
    return response.status === 204 ? null : response.json();
  };
}

async function main() {
  const {values} = parseArgs({options: {
    'bundle-id': {type: 'string', default: 'com.kidozh.discuz-flutter'},
    version: {type: 'string'}, 'build-number': {type: 'string'},
    'notes-file': {type: 'string', default: 'build/ios/testflight-release-notes.txt'},
    output: {type: 'string', default: 'build/ios/testflight-verification.json'},
    'check-available': {type: 'boolean', default: false},
    'reuse-existing': {type: 'boolean', default: false},
    'wait-for-processing': {type: 'boolean', default: false},
    'repair-build-id': {type: 'string', default: ''},
  }});
  if (!/^\d+\.\d+\.\d+$/.test(values.version ?? '') || !/^[1-9]\d*$/.test(values['build-number'] ?? '')) {
    throw new Error('Provide --version major.minor.patch and --build-number.');
  }
  const api = appStoreApi();
  const options = {
    bundleId: values['bundle-id'], version: values.version, buildNumber: values['build-number'],
    notes: values['check-available'] ? undefined : (await readFile(values['notes-file'], 'utf8')).trim(),
    checkAvailable: values['check-available'],
    reuseExisting: values['reuse-existing'],
    repairBuildId: values['repair-build-id'],
  };
  const result = values['wait-for-processing'] && !values['check-available']
    ? await waitForRelease(api, options, {onPending: message => console.log(message)})
    : await verifyRelease(api, options);
  if (values['check-available']) {
    if (process.env.GITHUB_OUTPUT) {
      await appendFile(process.env.GITHUB_OUTPUT, `exists=${!result.available}\n`);
    }
    console.log(`Build ${result.version} (${result.buildNumber}) ${result.available ? 'is available' : 'already exists'}.`);
  } else {
    await mkdir(dirname(values.output), {recursive: true});
    await writeFile(values.output, `${JSON.stringify(result, null, 2)}\n`);
    console.log(`Verified TestFlight ${result.version} (${result.buildNumber}), build ${result.buildId}, locales: ${result.locales.join(', ')}.`);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(error => { console.error(error.message); process.exitCode = 1; });
}
