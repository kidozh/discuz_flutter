# 商店素材

## Google Play · 简体中文

`google-play/2026-10/zh-CN/` 提供 1 张 **1024×500 置顶大图**和 8 张 **1080×1920 手机截图**，均为无透明通道的 24 位 RGB PNG。手机截图在独立 Android 模拟器采集，使用生产 Material 界面和「日常小馆」原创样例场景。

上传选用 `store/`；纯界面备选在 `upload-originals/phone/`，两套手机截图选择其中一套。`index.html` 和 `overview.png` 用于预览，`sources/` 为可编辑 SVG，`alt-text-zh-CN.txt` 提供中文替代文本。上传包为 `tantan-google-play-zh-CN-upload.zip`，含原图及可编辑源文件的完整包为 `tantan-google-play-zh-CN-full.zip`。详见目录内 `README.txt` 和 `google-play/capture/README.txt`。

## App Store · 简体中文

最新生活论坛版位于 `app-store/2026-10/zh-Hans/screenshots-life-v3/`，提供 9 个功能主题的原生截图、带标题 RGB PNG、可编辑 SVG 和高清预览页面。配套压缩包为 `tantan-app-store-zh-Hans-life-v3.zip`。

「日常小馆」为虚构生活社区，帖子、昵称、回复和头像均为原创样例；三张生活配图由内置 imagegen 生成。摘要为人工编写的示例结果，仅通过独立营销截图入口展示现有总结界面的完成状态，没有新增或修改正式 App 功能。制作与复现方式见 `capture/README.txt`。

上传使用新版本的 `store/`（带标题）或 `upload-originals/`（无标题），同一尺寸选择其中一套。`previews/` 和 `overview.png` 仅供浏览。`manifest.json`、`validation.json` 和 `ocr-review.json` 保存来源、尺寸、像素和文字检查记录。

手表版位于 `app-store/2026-10/zh-Hans/watch-life-v1/`：8 个主题，统一 416×496，同时提供原生截图和同风格标题版。建议优先上传 `upload-originals/`，保留手表界面的文字阅读空间；独立上传包为 `tantan-app-store-watch-upload-zh-Hans-v1.zip`，完整包为 `tantan-app-store-watch-zh-Hans-v1.zip`。制作方式见 `capture/watch/README.txt`。

原始 2.0.8 素材保留如下，避免与新版混用：

`app-store/2026-10/zh-Hans/` 保存中文素材清单、原图校验信息、展示图生成脚本及高清预览页面。完整 PNG、可编辑 SVG 和 ZIP 作为 GitHub Release 的 `tantan-app-store-zh-Hans.zip` 附件分发，避免在 Git 历史中重复保存大型媒体。

将 ZIP 解压到对应目录，即可使用其中的 `index.html`、`viewer.html` 和 `build_assets.cjs`。19 组截图的采集版本为 2.0.8+164，具体机型、分辨率和采集日期见 `manifest.json`。`upload-originals/` 和 `store/` 可用于上传；`previews/` 仅用于缩略预览。
