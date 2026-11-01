import {generateKeyPairSync, verify} from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';
import {createToken, verifyRelease, waitForRelease} from '../scripts/verify_testflight_release.mjs';

const options = {bundleId: 'com.example.app', version: '2.0.11', buildNumber: '168', notes: '2.0.11 (168)\n\n图片编辑改进。'};
function fixture({state = 'VALID', wrongVersion = false, ignoreWrites = false} = {}) {
  const localizations = [{id: 'en', attributes: {locale: 'en-US', whatsNew: 'outdated'}}];
  const calls = [];
  const api = async (path, method = 'GET', body) => {
    calls.push({path, method, body});
    if (path.startsWith('/apps?')) return {data: [{id: 'app', attributes: {primaryLocale: 'en-US'}}]};
    if (path.startsWith('/builds?')) return {
      data: [{id: 'build', attributes: {version: options.buildNumber, processingState: typeof state === 'function' ? state() : state, expired: false}, relationships: {preReleaseVersion: {data: {id: 'version'}}}}],
      included: [{type: 'preReleaseVersions', id: 'version', attributes: {version: wrongVersion ? '2.0.10' : options.version}}],
    };
    if (path === '/builds/build/betaBuildLocalizations') return {data: structuredClone(localizations)};
    if (method === 'POST') {
      if (!ignoreWrites) localizations.push({id: 'zh', attributes: body.data.attributes});
      return {};
    }
    if (method === 'PATCH') {
      if (!ignoreWrites) localizations.find(item => item.id === body.data.id).attributes.whatsNew = body.data.attributes.whatsNew;
      return {};
    }
    throw new Error(`Unexpected request: ${path}`);
  };
  return {api, calls};
}

test('JWT uses a valid ES256 P1363 signature without third-party packages', () => {
  const {privateKey, publicKey} = generateKeyPairSync('ec', {namedCurve: 'P-256'});
  const token = createToken('issuer', 'key', privateKey);
  const [header, payload, signature] = token.split('.');
  assert.equal(JSON.parse(Buffer.from(header, 'base64url')).alg, 'ES256');
  assert.equal(JSON.parse(Buffer.from(payload, 'base64url')).aud, 'appstoreconnect-v1');
  assert(verify('SHA256', Buffer.from(`${header}.${payload}`), {key: publicKey, dsaEncoding: 'ieee-p1363'}, Buffer.from(signature, 'base64url')));
});
test('creates Chinese notes, updates fallback locale, then reads both back', async () => {
  const {api, calls} = fixture();
  const result = await verifyRelease(api, options);
  assert.deepEqual(result.locales, ['zh-Hans', 'en-US']);
  assert.equal(result.buildId, 'build');
  assert.equal(calls.filter(call => call.path === '/builds/build/betaBuildLocalizations').length, 2);
});
for (const setting of [{state: 'PROCESSING'}, {state: 'INVALID'}, {wrongVersion: true}]) {
  test(`rejects an unready or wrong build ${JSON.stringify(setting)}`, async () => {
    const {api, calls} = fixture(setting);
    await assert.rejects(verifyRelease(api, options));
    assert(calls.every(call => call.method === 'GET'));
  });
}
test('rejects stale notes before making an API call', async () => {
  const {api, calls} = fixture();
  await assert.rejects(verifyRelease(api, {...options, notes: '2.0.10 (167)\n\n旧内容'}));
  assert.equal(calls.length, 0);
});
test('fails when Apple does not return the written notes', async () => {
  await assert.rejects(verifyRelease(fixture({ignoreWrites: true}).api, options), /read-back/);
});
test('preflight rejects a duplicate build without changing metadata', async () => {
  const {api, calls} = fixture();
  await assert.rejects(verifyRelease(api, {...options, checkAvailable: true}), /already exists/);
  assert(calls.every(call => call.method === 'GET'));
});
test('preflight allows the same build number in an older version train', async () => {
  const {api, calls} = fixture({wrongVersion: true});
  const result = await verifyRelease(api, {...options, checkAvailable: true});
  assert.equal(result.available, true);
  assert(calls.every(call => call.method === 'GET'));
});
test('waits for the exact target build to finish processing before writing notes', async () => {
  let checks = 0;
  let sleeps = 0;
  const {api} = fixture({state: () => ++checks === 1 ? 'PROCESSING' : 'VALID'});
  const result = await waitForRelease(api, options, {attempts: 2, sleep: async () => { sleeps++; }});
  assert.equal(result.processingState, 'VALID');
  assert.equal(sleeps, 1);
});
test('wait polling does not retry a terminal invalid build', async () => {
  let sleeps = 0;
  await assert.rejects(waitForRelease(fixture({state: 'INVALID'}).api, options, {attempts: 2, sleep: async () => { sleeps++; }}));
  assert.equal(sleeps, 0);
});
test('resolves a build version directly when the included relationship is missing', async () => {
  const {api} = fixture();
  const wrapped = async (path, method, body) => {
    if (path === '/builds/build/preReleaseVersion') return {data: {attributes: {version: options.version}}};
    const response = await api(path, method, body);
    if (path.startsWith('/builds?')) delete response.included;
    return response;
  };
  const result = await verifyRelease(wrapped, options);
  assert.equal(result.buildId, 'build');
});
test('rejects a lookalike build number even if the API returns it for a filter', async () => {
  const {api, calls} = fixture();
  const wrapped = async (path, method, body) => {
    const response = await api(path, method, body);
    if (path.startsWith('/builds?')) response.data[0].attributes.version = '1680';
    return response;
  };
  await assert.rejects(verifyRelease(wrapped, options), /not visible/);
  assert(calls.every(call => call.method === 'GET'));
});
test('corrects only an explicitly selected older build containing the misplaced notes', async () => {
  const {api} = fixture();
  const oldId = 'f0fbc4be-58b4-408d-9480-9b99ceec48eb';
  const oldNotes = [{id: 'old-zh', attributes: {locale: 'zh-Hans', whatsNew: options.notes}}];
  const wrapped = async (path, method = 'GET', body) => {
    if (path === `/builds/${oldId}`) return {data: {attributes: {version: options.buildNumber}}};
    if (path === `/builds/${oldId}/preReleaseVersion`) return {data: {attributes: {version: '2.0.10'}}};
    if (path === `/builds/${oldId}/betaBuildLocalizations`) return {data: structuredClone(oldNotes)};
    if (path === '/betaBuildLocalizations/old-zh' && method === 'PATCH') {
      oldNotes[0].attributes.whatsNew = body.data.attributes.whatsNew;
      return {};
    }
    return api(path, method, body);
  };
  const result = await verifyRelease(wrapped, {...options, repairBuildId: oldId});
  assert.equal(result.repairedPreviousBuild.version, '2.0.10');
  assert.match(oldNotes[0].attributes.whatsNew, /^2\.0\.10 \(168\)/);
  assert.match(oldNotes[0].attributes.whatsNew, /历史构建/);
});
