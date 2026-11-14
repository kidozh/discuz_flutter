import {openAsBlob} from 'node:fs';
import {appendFile, readFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {setTimeout as delay} from 'node:timers/promises';

const packagePath = '/androidpublisher/v3/applications/com.kidozh.discuz_flutter';
const production = `${packagePath}/tracks/production/releases`;
const submitted = new Set(['IN_REVIEW', 'APPROVED_NOT_PUBLISHED', 'PUBLISHED']);

export async function submitGooglePlay(api, {version, build, notes}, bundle, {poll = () => delay(5000)} = {}) {
  const getReleases = async () => (await api(production)).releases ?? [];
  const stateFor = releases => releases.find(release =>
    release.activeArtifacts?.some(artifact => String(artifact.versionCode) === build),
  )?.releaseLifecycleState?.replace('RELEASE_LIFECYCLE_STATE_', '');
  const releases = await getReleases();
  const current = stateFor(releases);
  if (submitted.has(current)) return current;
  if (current && current !== 'DRAFT') {
    throw new Error(`Google Play build ${build} is ${current}; review it in Play Console.`);
  }
  if (releases.some(release =>
    release.activeArtifacts?.some(artifact => Number(artifact.versionCode) > Number(build)))) {
    throw new Error(`Google Play production already has a newer build than ${build}.`);
  }
  const unfinished = ['IN_REVIEW', 'NOT_SENT_FOR_REVIEW', 'APPROVED_NOT_PUBLISHED', 'DRAFT'];
  if (releases.some(release =>
    unfinished.includes(release.releaseLifecycleState?.replace('RELEASE_LIFECYCLE_STATE_', '')) &&
    !release.activeArtifacts?.some(artifact => String(artifact.versionCode) === build))) {
    throw new Error('Google Play production has another unfinished release. Review it before rerunning this job.');
  }

  const {id} = await api(`${packagePath}/edits`, 'POST', {});
  if (!id) throw new Error('Google Play did not create a release edit.');
  const edit = `${packagePath}/edits/${encodeURIComponent(id)}`;
  const track = `${edit}/tracks/production`;
  const active = (await api(track)).releases ?? [];
  if (active.some(release => ['inProgress', 'halted'].includes(release.status))) {
    throw new Error('Google Play production has an unfinished staged rollout. Review it before rerunning this job.');
  }

  const {bundles = []} = await api(`${edit}/bundles`);
  const existing = bundles.find(existing => String(existing.versionCode) === build);
  const hash = createHash('sha256');
  for await (const chunk of bundle.stream()) hash.update(chunk);
  const expectedHash = hash.digest('hex');
  const uploaded = existing ?? await api(`/upload${edit}/bundles?uploadType=media`, 'POST', bundle);
  if (String(uploaded.versionCode) !== build || uploaded.sha256?.toLowerCase() !== expectedHash) {
    throw new Error(`Google Play build ${build} does not match the signed release AAB.`);
  }

  await api(track, 'PUT', {track: 'production', releases: [{
    name: `${build} (${version})`, versionCodes: [build], status: 'completed',
    releaseNotes: [{language: 'zh-CN', text: notes}],
  }]});
  await api(`${edit}:validate`, 'POST');
  await api(`${edit}:commit?changesInReviewBehavior=ERROR_IF_IN_REVIEW`, 'POST');
  let state;
  for (let attempt = 0; attempt < 12; attempt++) {
    state = stateFor(await getReleases());
    if (submitted.has(state)) return state;
    if (state === 'NOT_APPROVED') throw new Error(`Google Play build ${build} was not approved.`);
    await poll();
  }
  throw new Error(`Google Play committed the edit for ${build}, but review is not confirmed (${state ?? 'no status yet'}). Check Play Console or rerun this job.`);
}

async function main() {
  const [metadataPath, bundlePath] = process.argv.slice(2);
  const token = process.env.PLAY_ACCESS_TOKEN;
  if (!token) throw new Error('Missing Google Play access token.');
  const release = JSON.parse(await readFile(metadataPath, 'utf8'));
  const bundle = await openAsBlob(bundlePath, {type: 'application/octet-stream'});
  const api = async (path, method = 'GET', payload) => {
    const media = payload instanceof Blob;
    const response = await fetch(`https://androidpublisher.googleapis.com${path}`, {
      method,
      headers: {Authorization: `Bearer ${token}`, 'Content-Type': media ? payload.type : 'application/json'},
      body: media ? payload : JSON.stringify(payload),
      signal: AbortSignal.timeout(media ? 600000 : 60000),
    });
    if (!response.ok) {
      throw new Error(`Google Play ${method} ${path.split('?')[0]} failed (${response.status}): ${(await response.text()).slice(0, 1500)}`);
    }
    return response.status === 204 ? null : response.json();
  };
  const state = await submitGooglePlay(api, release, bundle);
  const message = `Google Play production ${release.version} (${release.build}): ${state}`;
  console.log(message);
  if (process.env.GITHUB_STEP_SUMMARY) await appendFile(process.env.GITHUB_STEP_SUMMARY, `${message}\n`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(error => { console.error(error.message); process.exitCode = 1; });
}
