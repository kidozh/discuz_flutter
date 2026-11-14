import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import test from 'node:test';
import {submitAppStore, submitExternalTestFlight} from '../scripts/submit_app_store.mjs';
import {submitGooglePlay} from '../scripts/submit_google_play.mjs';
import {verifyRelease} from '../scripts/verify_testflight_release.mjs';

const release = {version: '2.0.19', build: '177', notes: '修复图片选择权限。'};
const receipt = {appId: 'app', buildId: 'apple-build'};
const file = new Blob(['signed bundle']);
const sha256 = createHash('sha256').update('signed bundle').digest('hex');
const packagePath = '/androidpublisher/v3/applications/com.kidozh.discuz_flutter';
const production = `${packagePath}/tracks/production/releases`;
const edit = `${packagePath}/edits/edit`;

function expectRequests(steps) {
  return async (path, method = 'GET', body) => {
    const step = steps.shift();
    assert.ok(step, `Unexpected ${method} ${path}`);
    const [expectedMethod, expectedPath, response, checkBody] = step;
    assert.equal(method, expectedMethod);
    if (typeof expectedPath === 'string') assert.equal(path, expectedPath);
    else assert.match(path, expectedPath);
    checkBody?.(body);
    return response;
  };
}

test('Play verifies the signed AAB and requires evidence of review after committing the edit', async () => {
  const requests = [
    ['GET', production, {}],
    ['POST', `${packagePath}/edits`, {id: 'edit'}],
    ['GET', `${edit}/tracks/production`, {releases: [{status: 'completed'}]}],
    ['GET', `${edit}/bundles`, {}],
    ['POST', `/upload${edit}/bundles?uploadType=media`, {versionCode: 177, sha256}, body => assert.equal(body, file)],
    ['PUT', `${edit}/tracks/production`, {}, body => {
      assert.deepEqual(body.releases[0].versionCodes, ['177']);
      assert.equal(body.releases[0].status, 'completed');
      assert.equal(body.releases[0].releaseNotes[0].text, release.notes);
    }],
    ['POST', `${edit}:validate`, {}],
    ['POST', `${edit}:commit?changesInReviewBehavior=ERROR_IF_IN_REVIEW`, {id: 'edit'}],
    ['GET', production, {}],
    ['GET', production, {releases: [{
      activeArtifacts: [{versionCode: 177}], releaseLifecycleState: 'RELEASE_LIFECYCLE_STATE_IN_REVIEW',
    }]}],
  ];
  assert.equal(await submitGooglePlay(expectRequests(requests), release, file, {poll: async () => {}}), 'IN_REVIEW');
  assert.equal(requests.length, 0);
});

test('Play refuses to replace another build already in review', async () => {
  const api = expectRequests([['GET', production, {releases: [{
    activeArtifacts: [{versionCode: 176}], releaseLifecycleState: 'RELEASE_LIFECYCLE_STATE_IN_REVIEW',
  }]}]]);
  await assert.rejects(submitGooglePlay(api, release, file), /another unfinished release/);
});

test('App Store resumes a draft for exactly this build without creating a second submission', async () => {
  const requests = [
    ['GET', /\/apps\/app\/appStoreVersions\?/, {data: [{id: 'version', attributes: {appVersionState: 'READY_FOR_REVIEW'}}]}],
    ['GET', '/appStoreVersions/version/relationships/build', {data: {id: 'apple-build'}}],
    ['GET', '/appStoreVersions/version/appStoreVersionLocalizations?limit=50', {data: [{
      id: 'zh', type: 'appStoreVersionLocalizations', attributes: {locale: 'zh-Hans', whatsNew: release.notes},
    }]}],
    ['GET', /\/apps\/app\/reviewSubmissions\?/, {data: [{id: 'review', attributes: {state: 'READY_FOR_REVIEW'}}]}],
    ['GET', '/reviewSubmissions/review/items?include=appStoreVersion', {data: [{
      relationships: {appStoreVersion: {data: {id: 'version'}}},
    }]}],
    ['PATCH', '/reviewSubmissions/review', {data: {attributes: {state: 'WAITING_FOR_REVIEW', submittedDate: '2026-11-14'}}},
      body => assert.equal(body.data.attributes.submitted, true)],
  ];
  assert.equal(await submitAppStore(expectRequests(requests), release, receipt), 'WAITING_FOR_REVIEW');
  assert.equal(requests.length, 0);
});

test('TestFlight assigns the verified build to its external group before review', async () => {
  const requests = [
    ['GET', '/apps/app/betaGroups?limit=100', {data: [{id: 'group', attributes: {isInternalGroup: false}}]}],
    ['GET', '/builds/apple-build/buildBetaDetail', {data: {attributes: {externalBuildState: 'READY_FOR_BETA_SUBMISSION'}}}],
    ['GET', '/betaGroups/group/builds?limit=200', {data: []}],
    ['POST', '/betaGroups/group/relationships/builds', null, body => assert.equal(body.data[0].id, 'apple-build')],
    ['GET', '/betaAppReviewSubmissions?filter[build]=apple-build', {data: []}],
    ['POST', '/betaAppReviewSubmissions', {data: {attributes: {betaReviewState: 'WAITING_FOR_REVIEW'}}},
      body => assert.equal(body.data.relationships.build.data.id, 'apple-build')],
  ];
  assert.equal(await submitExternalTestFlight(expectRequests(requests), receipt, 'group'), 'WAITING_FOR_REVIEW');
  assert.equal(requests.length, 0);
});

test('an IPA received by Apple is reused even before it appears in the TestFlight build list', async () => {
  const requests = [
    ['GET', /\/apps\?/, {data: [{id: 'app'}]}],
    ['GET', /\/builds\?/, {data: []}],
    ['GET', /\/apps\/app\/buildUploads\?/, {data: [{attributes: {
      platform: 'IOS', cfBundleShortVersionString: release.version,
      cfBundleVersion: release.build, state: {state: 'PROCESSING'},
    }}]}],
  ];
  const status = await verifyRelease(expectRequests(requests), {
    version: release.version, buildNumber: release.build, bundleId: 'bundle', checkAvailable: true, reuseExisting: true,
  });
  assert.equal(status.available, false);
  assert.equal(requests.length, 0);
});
