import {appendFile, readFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {appStoreApi} from './verify_testflight_release.mjs';

const relation = (type, id) => ({data: {type, id}});
const submittedStates = new Set([
  'WAITING_FOR_REVIEW', 'IN_REVIEW', 'PENDING_APPLE_RELEASE', 'PENDING_DEVELOPER_RELEASE',
  'PROCESSING_FOR_DISTRIBUTION', 'READY_FOR_DISTRIBUTION', 'READY_FOR_SALE',
]);

export async function submitAppStore(api, {version, notes}, {appId, buildId}) {
  const query = new URLSearchParams({'filter[platform]': 'IOS', 'filter[versionString]': version});
  const versions = `/apps/${appId}/appStoreVersions`;
  let [record] = (await api(`${versions}?${query}`)).data;
  if (!record) {
    const previous = (await api(`${versions}?filter[platform]=IOS&limit=20`)).data;
    const released = previous.find(({attributes}) =>
      ['READY_FOR_DISTRIBUTION', 'READY_FOR_SALE'].includes(attributes.appVersionState));
    record = (await api('/appStoreVersions', 'POST', {data: {
      type: 'appStoreVersions',
      attributes: {
        platform: 'IOS', versionString: version,
        releaseType: released?.attributes.releaseType === 'AFTER_APPROVAL' ? 'AFTER_APPROVAL' : 'MANUAL',
        copyright: released?.attributes.copyright ?? '2021 kidozh',
      },
      relationships: {app: relation('apps', appId)},
    }})).data;
  }

  const path = `/appStoreVersions/${record.id}`;
  const buildPath = `${path}/relationships/build`;
  const linked = (await api(buildPath)).data?.id;
  const state = record.attributes.appVersionState;
  if (linked && linked !== buildId) throw new Error(`App Store ${version} is linked to a different build.`);
  if (linked === buildId && submittedStates.has(state)) return state;
  if (!['PREPARE_FOR_SUBMISSION', 'READY_FOR_REVIEW'].includes(state)) {
    throw new Error(`App Store ${version} requires attention in App Store Connect (${state}).`);
  }
  if (!linked) await api(buildPath, 'PATCH', relation('builds', buildId));

  const localizations = (await api(`${path}/appStoreVersionLocalizations?limit=50`)).data;
  const chinese = localizations.find(({attributes}) => attributes.locale === 'zh-Hans');
  if (!chinese) throw new Error('The App Store version has no zh-Hans localization. Configure it in App Store Connect.');
  if (chinese.attributes.whatsNew !== notes) {
    const {id, type} = chinese;
    await api(`/appStoreVersionLocalizations/${id}`, 'PATCH', {data: {id, type, attributes: {whatsNew: notes}}});
  }

  const {data: submissions} = await api(`/apps/${appId}/reviewSubmissions?filter[platform]=IOS&limit=50`);
  const drafts = submissions.filter(submission => submission.attributes.state === 'READY_FOR_REVIEW');
  const draftItems = await Promise.all(drafts.map(async draft => ({draft,
    items: (await api(`/reviewSubmissions/${draft.id}/items?include=appStoreVersion`)).data,
  })));
  const matching = draftItems.find(({items}) => items.some(item => item.relationships?.appStoreVersion?.data?.id === record.id));
  if (matching && matching.items.length !== 1) {
    throw new Error('This version shares a review draft with other items. Review the draft in App Store Connect.');
  }
  let draft = matching?.draft;
  if (!draft) {
    draft = draftItems.find(({items}) => items.length === 0)?.draft;
    if (!draft) {
      draft = (await api('/reviewSubmissions', 'POST', {data: {
        type: 'reviewSubmissions', attributes: {platform: 'IOS'}, relationships: {app: relation('apps', appId)},
      }})).data;
    }
    await api('/reviewSubmissionItems', 'POST', {data: {
      type: 'reviewSubmissionItems', relationships: {
        reviewSubmission: relation('reviewSubmissions', draft.id),
        appStoreVersion: relation('appStoreVersions', record.id),
      },
    }});
  }
  const submission = (await api(`/reviewSubmissions/${draft.id}`, 'PATCH', {data: {
    type: 'reviewSubmissions', id: draft.id, attributes: {submitted: true},
  }})).data;
  if (!submission.attributes.submittedDate) throw new Error('Apple did not confirm the App Store review submission.');
  return submission.attributes.state;
}

export async function submitExternalTestFlight(api, {appId, buildId}, groupId) {
  const groups = (await api(`/apps/${appId}/betaGroups?limit=100`)).data;
  const group = groups.find(group => !group.attributes.isInternalGroup && group.id === groupId);
  if (!group) throw new Error('The configured TestFlight group must be an external group for this app.');

  const detailPath = `/builds/${buildId}/buildBetaDetail`;
  const {data: detail} = await api(detailPath);
  if (['BETA_REJECTED', 'EXPIRED', 'INVALID_BINARY', 'MISSING_EXPORT_COMPLIANCE'].includes(detail.attributes.externalBuildState)) {
    throw new Error(`TestFlight requires attention (${detail.attributes.externalBuildState}).`);
  }
  const groupPath = `/betaGroups/${group.id}`;
  const assigned = (await api(`${groupPath}/builds?limit=200`)).data;
  if (!assigned.some(build => build.id === buildId)) {
    await api(`${groupPath}/relationships/builds`, 'POST', {data: [{type: 'builds', id: buildId}]});
  }

  const {data: [existing]} = await api(`/betaAppReviewSubmissions?filter[build]=${buildId}`);
  if (existing) {
    if (existing.attributes.betaReviewState === 'REJECTED') throw new Error('Apple rejected the TestFlight build.');
    return existing.attributes.betaReviewState;
  }
  const {data: submission} = await api('/betaAppReviewSubmissions', 'POST', {data: {
    type: 'betaAppReviewSubmissions', relationships: {build: relation('builds', buildId)},
  }});
  return submission.attributes.betaReviewState;
}

async function main() {
  const [releaseFile, receiptFile] = process.argv.slice(2);
  const [release, receipt] = await Promise.all([releaseFile, receiptFile].map(async file =>
    JSON.parse(await readFile(file, 'utf8'))));
  if (receipt.version !== release.version || receipt.buildNumber !== release.build || receipt.processingState !== 'VALID') {
    throw new Error('TestFlight verification must match the release version and build.');
  }
  const api = appStoreApi();
  const group = process.env.TESTFLIGHT_EXTERNAL_GROUP_ID || 'd309f462-a5ed-4cbf-bbbe-1e92d6ccb731';
  const results = await Promise.allSettled([
    submitAppStore(api, release, receipt),
    submitExternalTestFlight(api, receipt, group),
  ]);
  const lines = results.map((result, index) => {
    const label = ['App Store', 'TestFlight external'][index];
    return `${label}: ${result.status === 'fulfilled' ? result.value : result.reason.message}`;
  });
  console.log(lines.join('\n'));
  if (process.env.GITHUB_STEP_SUMMARY) {
    await appendFile(process.env.GITHUB_STEP_SUMMARY, lines.map(line => `- ${line}\n`).join(''));
  }
  if (results.some(result => result.status === 'rejected')) process.exitCode = 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(error => { console.error(error.message); process.exitCode = 1; });
}
