# 发布正式版

1. 更新 `pubspec.yaml` 的版本和构建号，填写 `docs/releases/<版本>.md` 和 `docs/testflight-release-notes.txt`。正式版说明的标题以 `版本号 (构建号)` 结尾，正文开头的 Markdown 列表会用作两个商店的简体中文更新说明。Google Play 限制为 500 字符。
2. 把改动合入 `master`，等普通 CI 通过。在 GitHub Releases 选中该提交对应的 `v版本+构建号` tag，然后发布正式 Release。例如 `v2.0.19+177`。可先保存草稿。
3. 检查 GitHub Actions 的 `Build & Release` 和 `Upload iOS to App Store Connect`。前者附上 GitHub 下载文件并提交 Google Play 正式版，后者上传 iOS、核对 TestFlight 说明、提交现有外测组和 App Store 正式版。预发行版、草稿、普通 commit 和单独推送 tag 都不触发商店提交。

Google Play 沿用 Play Console 的发布设置，提交时选择 100% 正式版。App Store 新建版本时沿用上个已发布版本的自动发布选项，原先是手动或定时的应用继续使用手动发布。审核状态见 [Play Console](https://play.google.com/console/u/0/developers/4975597316788261391/app/4974797315807573581/publishing) 和 [App Store Connect](https://appstoreconnect.apple.com/apps/1601703772)。

材料或网络故障修复后，在原 Release 的 Actions 运行中重跑失败的作业。Apple 已接收的相同构建会重新核对 TestFlight 文案并继续提审。Google Play 若发现相同构建已送审，会报告现有状态。如果 Play Console 还有未送审的改动，先检查该页面里的改动范围。Google 的 API 一次提交应用的全部待审更改，工作流保护已在审核的提交。正式版 `2.0.18 (176)` 及更早的构建仍以各商店历史记录为准。

## Google Play 一次性授权

使用有管理员权限的 Google Cloud 项目，启用 Android Publisher、IAM、IAM Credentials 和 Security Token Service。专用服务账号通过 GitHub OIDC 获取短期凭据。

```sh
PLAY_PROJECT_ID='disflyandroid'
PLAY_PROJECT_NUMBER=$(gcloud projects describe "$PLAY_PROJECT_ID" --format='value(projectNumber)')
PLAY_ACCOUNT="disfly-play-release@${PLAY_PROJECT_ID}.iam.gserviceaccount.com"
gcloud services enable androidpublisher.googleapis.com iam.googleapis.com \
  iamcredentials.googleapis.com sts.googleapis.com --project "$PLAY_PROJECT_ID"
gcloud iam service-accounts create disfly-play-release --project "$PLAY_PROJECT_ID" \
  --display-name='DisFly Google Play releases'
gcloud iam workload-identity-pools create github-play --project "$PLAY_PROJECT_ID" \
  --location=global --display-name='DisFly GitHub releases'
gcloud iam workload-identity-pools providers create-oidc github --project "$PLAY_PROJECT_ID" \
  --location=global --workload-identity-pool=github-play --display-name='GitHub Actions' \
  --issuer-uri='https://token.actions.githubusercontent.com/' \
  --attribute-mapping='google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id,attribute.event_name=assertion.event_name,attribute.ref=assertion.ref,attribute.workflow_ref=assertion.workflow_ref' \
  --attribute-condition="attribute.repository_owner_id == '11661760' && attribute.repository_id == '358940287' && attribute.event_name == 'release' && attribute.ref.startsWith('refs/tags/v') && attribute.workflow_ref == 'kidozh/discuz_flutter/.github/workflows/main.yml@' + attribute.ref"
gcloud iam service-accounts add-iam-policy-binding "$PLAY_ACCOUNT" --project "$PLAY_PROJECT_ID" \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/${PLAY_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-play/attribute.repository_id/358940287"
```

在 [Play Console 的「用户和权限」](https://play.google.com/console/u/0/developers/4975597316788261391/users-and-permissions) 邀请 `PLAY_ACCOUNT`，应用权限只选「谈坛」(`com.kidozh.discuz_flutter`)，授予查看应用信息及「发布正式版、排除设备和使用 Play 应用签名」。在 [GitHub Actions 仓库变量](https://github.com/kidozh/discuz_flutter/settings/variables/actions) 加入以下两项。

| 变量 | 值 |
| --- | --- |
| `PLAY_SERVICE_ACCOUNT` | `disfly-play-release@<项目 ID>.iam.gserviceaccount.com` |
| `PLAY_WORKLOAD_IDENTITY_PROVIDER` | `projects/<项目编号>/locations/global/workloadIdentityPools/github-play/providers/github` |

> [Google Play API 授权](https://developers.google.com/android-publisher/getting_started) · [Google Cloud OIDC 配置](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)

## iOS 发布环境

复用现有的 `APPSTORE_ISSUER_ID`、`APPSTORE_API_KEY_ID`、`APPSTORE_API_PRIVATE_KEY` 及签名证书。默认使用带 iOS 27.1+ SDK 的 `xcode-27` 托管 runner。若需使用自托管 runner，设置仓库变量 `APPSTORE_RUNNER` 为对应标签。`APPSTORE_XCODE_VERSION` 可指定托管 runner 的 Xcode 版本。若调整 TestFlight 外测组，在仓库设置 `TESTFLIGHT_EXTERNAL_GROUP_ID` 为同一应用的组 ID。

App Store Connect 工作流还可以手动运行以重新核对已有构建的 TestFlight 更新说明。此入口只处理已有构建的说明。
