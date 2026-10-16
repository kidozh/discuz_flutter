# iPhone Duo 适配

应用代码已补齐尺寸变化、真实折痕、安全区域和弹窗适配。完整屏幕运行仍要求使用 **iOS 27.1 SDK / Xcode 27.1 或更新版本**构建；iOS 26 的最低部署版本无需提高。使用旧 SDK 构建的应用在 Duo 上会进入系统兼容缩放模式。

依据：[Apple：Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/)、[Apple：Strike a pose with your app on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463/)。

## 已完成

- 在 `PlatformApp` 的 Navigator 上方接入 `AppFoldableProvider`，读取原生 size class、折叠状态和 reserved regions。将有效折痕与摄像头遮挡桥接到 Flutter `MediaQuery.displayFeatures`。普通设备保持原有系统特征。修正插件首次查询铰链尚未返回时停止监听的问题，并在窗口变化和回到前台时刷新尺寸类别。
- 删除按宽高比和屏幕尺寸模拟铰链的代码。布局使用当前窗口的实际约束和系统 size class：compact 保持单栏，regular 在两侧至少能容纳 300/340 逻辑像素时提供双栏；没有原生 size class 的平台使用 720 的宽度断点。
- 部分展开时按真实折痕位置布局，支持偏离屏幕中心的折痕及上下分区。平放时不将无效折痕作为障碍。过窄区域采用单栏，并保留真实折痕两侧的边界。
- 两侧页面持续挂载。展开、收起、旋转、缩放及选择帖子不再通过重建页面或延迟 100ms 来刷新，滚动位置和输入状态可以保留；隐藏页面停止 ticker，并隔离焦点。
- 每个区域获得本地尺寸、键盘和安全区域数据，保留并转换摄像头坐标。页面保护左右不对称系统区域，背景继续铺满窗口。键盘由页面自己的 scaffold 处理，避免双重缩小。
- 右侧有独立 Navigator，承载帖子、菜单、设置、用户资料、私信及其后续页面。返回时先退回右侧上一页，再回到帖子列表。保留首页 TabBar 和两种精简帖子卡片。
- 对话框和菜单按触发位置选择折痕一侧，内部 MediaQuery 也使用该侧的实际宽度。旋转或折叠后，在布局完成时重新读取触发位置，更新原有路由的 anchor，避免弹层跑到列表一侧，并保留弹层中的输入。Sheet 最大宽度为 640，内部内容使用这个受限宽度；避让键盘并消费一次键盘 inset。移除 Steam 信息 Sheet 按整屏宽度重复添加的横向留白。
- 回复目标由帖子页面自己的 Provider 管理。进入帖子时不再从 initState 通知全局 Provider，消除 `setState() or markNeedsBuild() called during build`，并避免新打开的帖子清空上一页面的回复目标。
- 私信气泡和个人资料顶部装饰改用控件实际宽度。
- 向 App Store/Xcode Cloud 发布前检查 SDK；归档完成后再检查 `.app` 中的 `DTSDKName`，避免将最低部署版本或宿主 Xcode 版本误当成构建 SDK。

## 右侧导航

首页和版块列表的详情区使用持久 Navigator。帖子中的设置、作者资料及资料页的私信等后续页面会在右侧逐层打开；首页菜单也在右侧展示，菜单内的管理、历史、收藏、设置等页面沿用同一页面栈。头像、用户链接、私信列表、历史及收藏的帖子入口统一通过 `pushDetailPage` 选择详情区。没有分栏宿主时，该入口沿用原页面的 Navigator。

即使未选择帖子，也可以在详情区打开页面。收起为单屏后显示当前详情页面，展开后恢复左侧列表和右侧当前页面，两侧滚动和详情输入状态持续保留。系统返回和 iOS 返回手势优先处理右侧子页面。选择新帖子，或重新点击当前帖子，会退出原详情子页面并显示所选正文；重选当前帖子保留其原有草稿。切换论坛或账号同样会清理旧的详情子页面。

左右两栏各有语义边界，防止右侧 Navigator 的路由遮罩把左侧列表从辅助功能树中移除。详情区内进入版块列表时使用单个列表页面，避免在右侧再次嵌套分栏。

## 构建

```sh
# 多个 Xcode 并存时，为当前终端指定包含 27.1 SDK 的工具链。
# 示例为下载目录中的 RC；也可换成安装到 Applications 的实际路径。
export DEVELOPER_DIR="${HOME}/Downloads/Xcode.app/Contents/Developer"
python3 scripts/check_iphone_duo.py --require-duo
flutter pub get --enforce-lockfile
(cd ios && pod install)
flutter test
# 仅检查编译；实际运行使用 flutter run 的正常部署/签名流程。
flutter build ios --simulator --debug --no-codesign
flutter run --debug -d <Duo模拟器UUID>
```

独立预检读取 `xcrun` 输出，Xcode 构建阶段通过 `--sdk-version "$SDK_VERSION"` 检查实际构建 SDK；测试也可用这个参数覆盖 SDK。验证已构建应用可执行：

```sh
python3 scripts/check_iphone_duo.py --require-duo \
  --app build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
```

CocoaPods 使用 iOS 27.1 SDK 时会为 `foldable` 开启 `FOLDABLE_NATIVE_API`，使用 SDK 类型检查原生接口；旧 SDK 保留插件的运行时兼容路径。切换 Xcode 后重新执行 `pod install`，确保缓存的 Pods 工程使用新 SDK 对应的编译条件。

### 防止本地构建回退到旧 SDK

2026-10-16 检查发现：Duo 模拟器虽然运行 iOS 27.1，实际安装的 Runner 及 `Runner.debug.dylib` 都记录为使用 27.0 SDK 构建。系统的 `xcode-select` 仍指向 `/Applications/Xcode.app`（27.0），此前命令中的 `DEVELOPER_DIR` 只对当次终端有效；Android Studio 的 `main.dart` 配置没有这个变量，后续运行会覆盖之前的 27.1 安装包。这是不同运行入口选择了不同工具链。

本机 Android Studio 的 `main.dart` 运行配置已指定 `DEVELOPER_DIR=/Users/zhangjiduo/Downloads/Xcode.app/Contents/Developer`。终端运行仍须使用上面的 `export`；系统级 `xcode-select` 切换需要管理员权限。`DEVELOPER_DIR` 指定的目录必须一直存在，移动或升级 Xcode 后应同步更新运行配置。

`scripts/check_ios_toolchain.sh` 已接入 Podfile 和 Runner 的 Flutter 构建阶段，默认要求 27.1+。Xcode 构建时检查实际 `SDK_VERSION`，避免只检查终端的 SDK；旧 SDK 会明确报错，不能再静默生成兼容模式包。普通兼容性 CI 显式设置 `REQUIRE_IPHONE_DUO=0`，App Store 和 Xcode Cloud 沿用各自的严格构建设置。需要有意构建兼容模式包时，CocoaPods 和 Flutter 两步都须显式设置这个变量。

本次重新执行 27.1 环境下的 `pod install` 和正常 `flutter run --debug`，已安装包确认记录 `iphonesimulator27.1` / `27A9275`；Runner 与 `Runner.debug.dylib` 的 Mach-O SDK 都为 27.1，模拟器内的 Runner 与构建产物一致。展开时右侧状态栏黑条消失，左边原先的额外留白缩小，列表与所选帖子正文均正常显示。启动及打开含 Steam 卡片的帖子未发现运行异常。构建预检测试 7 项、分栏/弹层/导航/紧凑列表测试 42 项通过。本次未修改 SafeArea 或强制减少系统安全区域。

App Store workflow 的 `xcode_version` 可选择已安装的 Xcode，`runner` 可指定具有新 SDK 的 macOS runner 标签，`require_duo` 默认开启。当前 GitHub 托管 runner 若没有新 SDK，检查会阻止上传；可配置安装了 Xcode 27.1+ 的 runner。显式关闭 `require_duo` 可发布兼容模式包。

Xcode Cloud 在 App Store Connect 的 Environment 中选择 Xcode 27.1+，默认也严格检查 SDK。仅构建旧 SDK 兼容包时，将环境变量 `REQUIRE_IPHONE_DUO` 设为 `0`。普通 iOS CI 保留兼容性构建，并报告 SDK 能力。

## 验证边界

开发机安装了两套工具链：`/Applications/Xcode.app` 为 27.0，下载目录中的 `Xcode.app` 为 27.1 RC（27A9275）。默认 `xcode-select` 仍选择 27.0；本次通过 `DEVELOPER_DIR` 选择 RC，27.1 SDK 检查、启用原生 API 的编译及正常 Flutter 运行流程已通过。已安装 iOS 27.1 运行时，并通过 RC 配套 Device Hub 在独立的 `Codex Discuz Duo` 模拟器执行以下验证。

| 场景 | 结果 |
| --- | --- |
| 首页启动、选择帖子、返回按钮 | 通过，保留首页顶部 TabBar |
| 半展开启动、选择含正文和 Steam 卡片的帖子 | 通过，左右分栏正常显示 |
| 半展开 → 关闭 → 展开 | 所选帖子保留；关闭为单栏，展开恢复双栏，列表未重置到顶部 |
| 半展开时旋转 | 从左右分栏切换为上下分栏，所选帖子保留 |
| 上下分栏打开帖子菜单、Steam 信息 Sheet | 菜单和 Sheet 位于详情所在的下方区域 |
| Steam 信息 Sheet 打开后旋转 | 修复旧 anchor 导致弹层跑到列表一侧的问题，复测弹层随详情移动到右侧 |
| 帖子 → 设置 → 看板顺序 | 设置及子页面仅显示在右侧，左侧列表和 TabBar 持续显示 |
| 设置子页面 → 关闭 → 逐层返回 | 收起后仍停在设置子页面，返回设置首页，再恢复原帖 |
| 作者头像 → 用户资料 | 用户资料及论坛要求登录的提示在右侧展示；完整资料数据需登录验证 |
| 左侧菜单入口 | 菜单在右侧展示，左侧列表仍可操作；选择另一篇帖子退出旧的子页面栈 |
| 设置中重新点击左侧已选帖子 | 冷启动最终版本后复测通过，退出设置并恢复同一帖子正文 |
| 两栏辅助功能 | 右侧导航期间，左侧按钮和列表仍出现在模拟器的辅助功能树中 |

修复版重新启动后，以上路径的日志未出现 `No instance of S present`、`Unhandled Exception` 或构建期间通知异常。启动时的推送初始化也已执行。

当时的最终版本通过 27.1 RC 编译及冷启动；后续 IDE 运行曾用 27.0 SDK 包覆盖安装。当前安装包应按上面的 SDK 检查流程重新核实，不能从模拟器运行时版本推断构建 SDK。

截至 2026-10-15，完整 Flutter 测试 **473 项通过**，SDK 检查脚本的 Python 测试 **4 项通过**。静态分析无 error，仍有 2146 条存量 warning/info。回归测试覆盖折叠时草稿、滚动及回复目标保留，嵌套帖子之间的回复隔离，LTR/RTL 边缘返回，以及三个界面样式下弹层旋转定位和输入状态保留。新增 7 项导航测试覆盖右侧页面栈、空详情区入口、折叠保持层级、系统返回、重选帖子、iOS 子页面返回手势、两栏语义隔离及普通页面的导航回退。

首次使用 27.0 配套 Device Hub 查看 Duo 时，显示和姿态控制不完整；27.1 RC 的对应应用位于 `Xcode.app/Contents/Applications/DeviceHub.app`。后续姿态验证使用这套 Device Hub。

启动时的推送注册不再依赖 UI 本地化，设备与包信息的读取异常纳入处理。新增回归测试覆盖无本地化的根 context、后台读取、已销毁的 context 和异步读取期间的 UI 销毁。

编译检查产生的包可能缺少运行时所需的 Keychain 授权，直接安装这种包会在加密缓存初始化阶段失败；实际设备验证使用 `flutter run` 或 Xcode 的正常运行流程。不能通过清除缓存或重新生成已有加密数据库的密钥来绕过授权失败。

以下需要进一步手动或真机验证，不能由本次游客模拟器流程代替：

1. 登录后的真实发帖/回复草稿、登录状态和键盘在折叠、旋转及窗口切换中的保留。模拟器未登录；草稿与键盘避让已有控件测试覆盖。
   用户资料已验证右侧路由及游客权限提示，完整资料、私信数据仍需登录账号验证。
2. 摄像头启用后的 occlusion 更新、不同窗口尺寸和动态系统区域；所有支持方向的完整组合。
3. 系统较大字体、VoiceOver 和真机边缘返回手势。Device Hub 的鼠标拖动未能确认边缘返回；已确认返回按钮，LTR/RTL 手势回归测试通过。
4. 真机签名包的完整屏幕运行、原生导航栏与 Liquid Glass 控件，以及从 TestFlight/App Store 安装后的行为。
