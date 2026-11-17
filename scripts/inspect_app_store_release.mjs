import {appStoreApi} from './verify_testflight_release.mjs';

const api = appStoreApi();
const {data: apps} = await api('/apps?filter[bundleId]=com.kidozh.discuz-flutter');
if (apps.length !== 1) throw new Error('Expected exactly one App Store app.');
const app = apps[0];
const {data: versions, included = []} = await api(`/apps/${app.id}/appStoreVersions?filter[platform]=IOS&include=build&limit=20`);
const {data: submissions} = await api(`/apps/${app.id}/reviewSubmissions?filter[platform]=IOS&limit=20`);
const active = [];
for (const submission of submissions) {
  if (['COMPLETE', 'CANCELED'].includes(submission.attributes.state)) continue;
  const {data: items} = await api(`/reviewSubmissions/${submission.id}/items?include=appStoreVersion`);
  active.push({id: submission.id, ...submission.attributes, items: items.map(item => ({
    id: item.id, attributes: item.attributes, relationships: item.relationships,
  }))});
}
console.log(JSON.stringify({appId: app.id, versions: versions.map(version => ({
  id: version.id, ...version.attributes,
  build: included.find(item => item.type === 'builds' && item.id === version.relationships?.build?.data?.id),
})), submissions: active}, null, 2));
