import assert from 'node:assert/strict';
import test from 'node:test';
import {supersedeAppStoreRelease} from '../scripts/supersede_app_store_release.mjs';

const release = {version: '2.0.21', build: '179'};
const receipt = {appId: 'app', buildId: 'new-build'};

function fixture({state = 'WAITING_FOR_REVIEW', build = '178', shared = false, alreadyRenamed = false, cancellationPending = false} = {}) {
  const record = {id: 'version', attributes: {
    versionString: alreadyRenamed ? release.version : '2.0.20', appVersionState: state,
  }};
  const review = {id: 'review', attributes: {state: state === 'WAITING_FOR_REVIEW' ? state : 'CANCELED'}};
  let linked = build ? {id: 'old-build'} : null;
  const writes = [];
  const api = async (path, method = 'GET', body) => {
    if (method !== 'GET') writes.push({path, method, body});
    const url = new URL(path, 'https://example.test');
    if (url.pathname === '/apps/app/appStoreVersions') {
      return {data: url.searchParams.get('filter[versionString]') === record.attributes.versionString ? [record] : []};
    }
    if (path === '/appStoreVersions/version/relationships/build') {
      if (method === 'PATCH') linked = body.data;
      return {data: linked};
    }
    if (path === '/builds/old-build') return {data: {attributes: {version: build}}};
    if (url.pathname === '/apps/app/reviewSubmissions') return {data: [review]};
    if (url.pathname === '/reviewSubmissions/review/items') return {data: [
      {relationships: {appStoreVersion: {data: {id: 'version'}}}},
      ...(shared ? [{relationships: {inAppEvent: {data: {id: 'other-item'}}}}] : []),
    ]};
    if (path === '/reviewSubmissions/review' && method === 'PATCH') {
      assert.equal(body.data.attributes.canceled, true);
      if (!cancellationPending) {
        review.attributes.state = 'CANCELED';
        record.attributes.appVersionState = 'DEVELOPER_REJECTED';
      }
      return {data: review};
    }
    if (path === '/appStoreVersions/version') {
      if (method === 'PATCH') Object.assign(record.attributes, body.data.attributes);
      return {data: record};
    }
    throw new Error(`Unexpected ${method} ${path}`);
  };
  return {api, writes, record};
}

test('replaces only the selected pending version after Apple makes it editable', async () => {
  const f = fixture();
  await supersedeAppStoreRelease(f.api, release, receipt, '2.0.20+178');
  assert.deepEqual(f.writes.map(write => write.path), [
    '/reviewSubmissions/review', '/appStoreVersions/version/relationships/build', '/appStoreVersions/version',
  ]);
  assert.equal(f.writes[1].body.data, null);
  assert.equal(f.record.attributes.versionString, '2.0.21');
  assert.equal(f.record.attributes.appVersionState, 'DEVELOPER_REJECTED');
});

for (const [name, options, error] of [
  ['a different pending build', {build: '177'}, /build does not match/],
  ['a shared review submission', {shared: true}, /other items/],
  ['a version already being reviewed', {state: 'IN_REVIEW'}, /while it is IN_REVIEW/],
]) {
  test(`refuses ${name} before making any changes`, async () => {
    const f = fixture(options);
    await assert.rejects(supersedeAppStoreRelease(f.api, release, receipt, '2.0.20+178'), error);
    assert.equal(f.writes.length, 0);
  });
}

test('refuses a non-older version or build without any API requests', async () => {
  for (const selected of ['2.0.21+178', '2.0.22+178', '2.0.20+179', '2.0.20']) {
    await assert.rejects(supersedeAppStoreRelease(() => assert.fail('No API request expected'), release, receipt, selected));
  }
});

test('reruns leave an already renamed target for the normal exact-build submission checks', async () => {
  const f = fixture({alreadyRenamed: true});
  await supersedeAppStoreRelease(f.api, release, receipt, '2.0.20+178');
  assert.equal(f.writes.length, 0);
});

test('resumes after the old build was detached without canceling another review', async () => {
  const f = fixture({state: 'DEVELOPER_REJECTED', build: null});
  await supersedeAppStoreRelease(f.api, release, receipt, '2.0.20+178');
  assert.deepEqual(f.writes.map(write => write.path), ['/appStoreVersions/version']);
});

test('does not detach or rename a build before Apple confirms review withdrawal', async () => {
  const f = fixture({cancellationPending: true});
  await assert.rejects(supersedeAppStoreRelease(f.api, release, receipt, '2.0.20+178', {poll: async () => {}}), /not yet.*editable/);
  assert.deepEqual(f.writes.map(write => write.path), ['/reviewSubmissions/review']);
});
