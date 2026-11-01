import {generateKeyPairSync, verify} from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';
import {createToken, verifyRelease} from '../scripts/verify_testflight_release.mjs';

const options = {bundleId: 'com.example.app', version: '2.0.11', buildNumber: '168', notes: '2.0.11 (168)\n\n图片编辑改进。'};
function fixture({state = 'VALID', wrongVersion = false, ignoreWrites = false} = {}) {
  const localizations = [{id: 'en', attributes: {locale: 'en-US', whatsNew: 'outdated'}}];
  const calls = [];
  const api = async (path, method = 'GET', body) => {
    calls.push({path, method, body});
    if (path.startsWith('/apps?')) return {data: [{id: 'app', attributes: {primaryLocale: 'en-US'}}]};
    if (path.startsWith('/builds?')) return {
      data: [{id: 'build', attributes: {processingState: state, expired: false}, relationships: {preReleaseVersion: {data: {id: 'version'}}}}],
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
