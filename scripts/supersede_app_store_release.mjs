import {setTimeout as delay} from 'node:timers/promises';

const editable = new Set(['PREPARE_FOR_SUBMISSION', 'READY_FOR_REVIEW', 'DEVELOPER_REJECTED']);

// Only a specifically selected, older pending build may be replaced. Normal
// release uploads never opt in to withdrawing an existing review submission.
export async function supersedeAppStoreRelease(api, release, receipt, expected, {poll = () => delay(5000)} = {}) {
  const match = /^(\d+\.\d+\.\d+)\+([1-9]\d*)$/.exec(expected);
  if (!match) throw new Error('Specify the pending App Store release as version+build.');
  const [, oldVersion, oldBuild] = match;
  const before = oldVersion.split('.').map(Number);
  const after = release.version.split('.').map(Number);
  const different = before.findIndex((part, index) => part !== after[index]);
  if (different < 0 || before[different] >= after[different] || Number(oldBuild) >= Number(release.build)) {
    throw new Error('Only an older version and build may be superseded.');
  }
  const versions = `/apps/${receipt.appId}/appStoreVersions`;
  const query = version => `${versions}?${new URLSearchParams({'filter[platform]': 'IOS', 'filter[versionString]': version})}`;
  if ((await api(query(release.version))).data.length) return;
  const {data: previous} = await api(query(oldVersion));
  if (previous.length !== 1) throw new Error('Cannot uniquely identify the pending App Store version.');
  let record = previous[0];
  const path = `/appStoreVersions/${record.id}`;
  let state = record.attributes.appVersionState;
  if (['READY_FOR_DISTRIBUTION', 'READY_FOR_SALE'].includes(state)) return;
  if (state !== 'WAITING_FOR_REVIEW' && !editable.has(state)) {
    throw new Error(`Cannot supersede ${oldVersion} while it is ${state}.`);
  }
  const buildPath = `${path}/relationships/build`;
  const {data: linked} = await api(buildPath);
  if (linked) {
    const {data: build} = await api(`/builds/${linked.id}`);
    if (build.attributes.version !== oldBuild) throw new Error('Pending App Store build does not match the selected replacement.');
  } else if (state === 'WAITING_FOR_REVIEW') {
    throw new Error('The pending review has no expected build.');
  }

  const {data: submissions} = await api(`/apps/${receipt.appId}/reviewSubmissions?filter[platform]=IOS&limit=50`);
  const matching = [];
  for (const submission of submissions) {
    if (['COMPLETE', 'CANCELED'].includes(submission.attributes.state)) continue;
    const {data: items} = await api(`/reviewSubmissions/${submission.id}/items?include=appStoreVersion`);
    if (!items.some(item => item.relationships?.appStoreVersion?.data?.id === record.id)) continue;
    if (items.length !== 1 || Object.entries(items[0].relationships ?? {}).some(([key, value]) =>
      key !== 'appStoreVersion' && value.data && (!Array.isArray(value.data) || value.data.length))) {
      throw new Error('The pending review contains other items; it cannot be replaced automatically.');
    }
    matching.push(submission);
  }
  if (matching.length > 1 || (state === 'WAITING_FOR_REVIEW' && matching.length !== 1)) {
    throw new Error('Cannot uniquely identify the pending review submission.');
  }
  if (matching.some(submission => !['WAITING_FOR_REVIEW', 'READY_FOR_REVIEW'].includes(submission.attributes.state))) {
    throw new Error('The pending review state changed; inspect it before replacing the version.');
  }
  const waiting = matching.find(submission => submission.attributes.state === 'WAITING_FOR_REVIEW');
  if (waiting) {
    await api(`/reviewSubmissions/${waiting.id}`, 'PATCH', {data: {
      type: 'reviewSubmissions', id: waiting.id, attributes: {canceled: true},
    }});
    for (let attempt = 0; attempt < 24; attempt++) {
      record = (await api(path)).data;
      state = record.attributes.appVersionState;
      if (editable.has(state)) break;
      await poll();
    }
  }
  if (!editable.has(state)) throw new Error('Apple has not yet made the withdrawn version editable.');
  if (linked) await api(buildPath, 'PATCH', {data: null});
  await api(path, 'PATCH', {data: {
    type: 'appStoreVersions', id: record.id, attributes: {versionString: release.version},
  }});
  const {data: updated} = await api(path);
  if (updated.attributes.versionString !== release.version || !editable.has(updated.attributes.appVersionState)) {
    throw new Error('Could not verify the replacement App Store version.');
  }
  console.log(`App Store pending ${oldVersion} (${oldBuild}) replaced with ${release.version} (${release.build}); ready to submit.`);
}
