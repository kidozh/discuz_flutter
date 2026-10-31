# Apple Watch 配套应用

Apple Watch 第一版使用 SwiftUI（watchOS 10 起），通过 WatchConnectivity
连接现有 Flutter iPhone 应用。Wear OS 留待后续实现。

## 功能

- 同步手机当前选择的论坛、账号、提醒未读数（普通提醒与帖子提醒之和）及私信未读数。
- 查看最多 8 条热帖的标题、作者、回复数和纯文本摘要。
- 打开提醒或私信页面时，由 iPhone 加载最多 8 条提醒或会话预览。
- 默认在手表内阅读帖子全文、分页回复、提醒关联帖子和完整私信会话；长文分段传输，不截断全文。
- 在手表使用系统键盘或听写输入最多 1,000 字的帖子回复或私信，确认后发送。
- “在 iPhone 继续”是备用入口，用于图片附件、验证码或复杂编辑。
- 断连时显示 WatchConnectivity 保存的最近一次内容和同步时间。
- 支持英文、简体中文、系统字号及内容隐私遮盖。

“在 iPhone 继续”需要手机应用可通过 WatchConnectivity 联系到；它不会强制将手机应用切到前台。
手表提示内容准备好后，用户打开 iPhone 上的谈坛即可继续。
正常文字阅读与回复不切换手机页面。首次选择论坛、登录账号仍在手机完成；
手表请求使用配对手机上的认证接口，需要手机应用已初始化且 WatchConnectivity 可达。
本版不是可脱离 iPhone 独立联网登录的 watchOS 应用。

## 同步与阅读状态

手机启动、切换论坛或账号、回到前台、手表连接状态变化时更新同步状态。
安装手表应用后，手机在前台每两分钟刷新热帖和未读数；手表也可手动刷新。
未安装手表应用时，不启动额外论坛请求。后台刷新与传输时机由系统调度，
本实现不承诺持续后台轮询或即时消息到达。

自动刷新只使用 `hotthread` 接口。`mynotelist` 和 `mypm` 仅在用户主动打开或刷新
对应手表页面时调用。不同论坛可能在打开提醒列表时标为已读，手表页面会提示这一点。
本次不新增独立的 watchOS APNs 推送通道；系统层面的 iPhone 通知镜像仍取决于用户的手表通知设置。

账号密码、Cookie、`auth`、`saltkey`、`formhash` 均留在 iPhone。
手表只接收清理过 HTML 的展示数据；全文按页、按段传输，单次保持在 WatchConnectivity 大小限制内。
发送前由手机重新获取 formhash、验证当前账号与回复权限。验证码或权限不足时显示失败，不绕过论坛规则。
同一发送请求去重，连接超时或响应无法确认时不自动重发，保留草稿并提示先检查内容。
切换账号或登录失效时清空预览，并丢弃此前仍在执行的请求；离线手表将在重新连接并收到新状态后清空旧内容。

## 工程与运行

- iPhone 通道：`ios/Runner/AppleWatchBridge.swift`。
- Flutter 同步服务：`lib/utility/apple_watch_companion.dart`。
- 全文与回复代理：`lib/utility/apple_watch_reader.dart`。
- watchOS 应用：`ios/DiscuzWatch/`，共享 scheme 为 `DiscuzWatch`。
- Bundle ID：`com.kidozh.discuz-flutter.watchkitapp`，配套手机 ID 为
  `com.kidozh.discuz-flutter`。
- 手表版本和 build number 继承 `ios/Flutter/Generated.xcconfig` 中 Flutter 的版本设置。

用 Xcode 打开 `ios/Runner.xcworkspace`，选择 `DiscuzWatch` scheme 和配对的 Apple Watch
运行目标。先运行 iPhone 应用并选择论坛、登录，再打开手表应用。
`Runner` target 已依赖并嵌入 `DiscuzWatch.app`，正常手机归档会包含手表应用。

Flutter 识别到手表配套应用后，模拟器构建需要指定 iPhone 模拟器 ID，
例如 `flutter run -d <iPhone-simulator-id>`。只编译手表可使用：

```sh
xcodebuild -project ios/Runner.xcodeproj -scheme DiscuzWatch \
  -configuration Debug -destination 'generic/platform=watchOS Simulator' \
  -derivedDataPath /tmp/discuz-watch-build CODE_SIGNING_ALLOWED=NO build
```

项目原有 iPhone Duo 构建检查要求 Xcode 27.1+。
如需在较早 SDK 验证兼容构建，可按已有机制仅对本次命令设置 `REQUIRE_IPHONE_DUO=0`。
此开关不改变项目的正式工具链要求。

### iOS 启动与 Keychain 权限

iPhone 应用启动时从 Keychain 读取加密私信缓存的密钥。安装运行的包必须保留
`Runner/Runner.entitlements` 中的默认 Keychain 组；使用 Xcode 的正常签名流程。
`CODE_SIGNING_ALLOWED=NO` 只用于编译检查，不可将其 iPhone 产物作为可运行包安装，
否则模拟器会缺少应用标识与模拟权限，报 `PlatformException` / Keychain `-34018`。
仅在编译后补一次 `codesign` 不能替代 Xcode 为模拟器写入权限段的过程。

安装前或正式归档后检查：

```sh
python3 scripts/check_ios_keychain.py --app <Runner.app路径>
```

已有加密缓存时，必须保留密钥和应用数据，修正签名后覆盖安装。
不要通过清空 Keychain、卸载应用或重置加密密钥绕过启动错误。

## 发布与验收

已在配对的 iOS 27.0 / watchOS 27.0、42mm 手表模拟器验证启动、真实 WatchConnectivity 同步、
未读数、提醒与私信预览、手机备用跳转、账号切换清理、长文分段、全文阅读和手表内帖子回复。
手表内系统键盘输入、发送确认及私信发送也已通过，合成服务器各记录一次帖子回复和私信提交。
断网时保留已加载内容，登录失效时退出旧私信页面并清空内容。Keylol 游客热帖接口返回要求登录，
真实账号下的论坛行为仍需在 TestFlight / 真机验收。
私信及写入使用 `integration_test/apple_watch_pairing_qa.dart` 的本地合成论坛，未向真实论坛发送测试消息。
19 项 Flutter 同步、隐私、全文阅读与回复回归测试通过，另有加密密钥保留及签名检查测试。
模拟器整包使用 Xcode 27.0 和 `REQUIRE_IPHONE_DUO=0`；正式归档使用 Xcode 27.1。

真机运行及发布前，需要为新增 Bundle ID 配置 Apple Developer 签名和 provisioning profile。
`ios/ExportOptions.plist` 包含手机和手表的手动签名配置。GitHub 的 App Store 发布流程
分别下载两个 Bundle ID 的有效分发 profile，再通过
`scripts/configure_ios_distribution_signing.py` 配置两个 Release target 和导出设置，
使用实际下载的 UUID，避免手表误用开发签名或缺少导出 profile。
本地 Xcode 自动签名归档可用 `-allowProvisioningUpdates CODE_SIGN_STYLE=Automatic`，
配合现有开发者账号生成所需的手机与手表 profile。归档包含二者，上传为同一个 iOS 构建。

2026-10-17 已使用 Xcode 27.1 导出并成功上传 2.0.9（166）到 App Store Connect，Apple 已接收并开始处理。
本地 IPA 与归档位于 `build/ios/watch-release-166/`，其发行签名、默认 Keychain 组、内嵌手表及版本号已检查。

发布前在真实配对设备验收：首次同步、刷新热帖、打开提醒与私信、各页面继续到手机、
退出登录、切换论坛及账号、登录过期、断开与恢复连接。
手表模拟器单独启动只能验证界面和构建；端到端同步需要已配对并运行手机端的设备。

```sh
flutter test --no-pub test/apple_watch_companion_test.dart test/apple_watch_reader_test.dart
flutter analyze --no-pub lib/utility/apple_watch_companion.dart \
  lib/widget/apple_watch_companion_host.dart test/apple_watch_companion_test.dart
```
