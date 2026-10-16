# Android 正文翻译

Android 使用 ML Kit Language Identification（17.0.6）识别正文语言，使用 ML Kit Translation（17.0.3）翻译；总结仍使用 Gemini Nano Prompt API，需要设备/AICore 支持。

`AndroidTranslationChannel` 在 MainActivity 随 Flutter engine 注册/释放，复用现有 `com.kidozh.discuz_flutter/translation` 协议（Dart 客户端暂时位于 apple_post_translation 包中）。正文统一经 PostHtmlTranslation 提取文本节点，保留图片、链接地址和排版。点按默认设备语言，再点还原；长按读取 ML Kit 支持的语言列表。Android 翻译不依赖 Nano 或 AI 设置开关。

语言包按需通过 Wi-Fi 下载，已下载后可离线使用。单片段最多等待 120 秒，失败显示提示，不自动改用生成式 AI。源/目标语言相同以及纯符号片段跳过翻译。Translator 在完成、失败、超时或引擎清理时关闭。

验证：Flutter 翻译正文/按钮测试与 Android debug APK 编译。模拟器已复现并修复 zh-CN 等地区标签被拒绝的问题。该模拟器仅有蜂窝连接，不满足 Wi-Fi 下载条件，集成测试在等待模型时超时，尚未验证实际译文。

官方资料：
- https://developers.google.com/ml-kit/language/translation/android
- https://developers.google.com/ml-kit/language/identification/android

自动翻译位于设置的常规分组末尾，默认开启；保留已保存的关闭选择。

语言识别按段落和换行组织文字，行内加粗、颜色、链接等样式不会把一句话拆成独立短词，空格和正文顺序也会保留。手动翻译为有足够文字的段落分别识别源语言，短标签或无法识别的段落沿用整帖语言，避免混合语言正文全部套用同一源语言。自动翻译遇到无法识别的短文本时保留原文。

ML Kit 离线模型适用于简单翻译，非英语语言之间通过英语中转，译文质量可能受影响。参见 https://developers.google.com/ml-kit/language/translation 。本次修复针对语言识别和分段问题，未更换翻译模型，实际译文质量仍需要在设备上验证。

## Google 翻译归属标注

Android 的翻译操作使用“使用 Google 翻译”（英文为 `Translate with Google`）。原有工具栏的紧凑图标在 Android 上改为正文前的文字操作，避免品牌名称被窄工具栏隐藏或裁切；长按仍可选择目标语言。

仅在 Android 实际显示 ML Kit 译文时，正文上方显示官方 `powered by Google Translate` 图。自动和手动翻译、普通正文及 sliver 正文共用这条路径；原文、请求中尚无译文以及失败状态不显示归属图。Apple 翻译和 AI 总结不会使用该标识。图片由官方归属素材包原样提取，使用 1x/2x/3x 原始文件和白色底板保证深浅主题下清楚可读；点击前往 Google Translate，不发送帖子正文。

帖子旁的信息按钮以及 Android 设置中的“Google 翻译说明”均可离线查看官方完整免责声明，并提供 Google Cloud Translation 链接。原始素材地址与使用规范记录在 `assets/translation/SOURCE.txt`。本次不涉及发布商店描述，下面的文案可在下次更新 Google Play 简介时使用：

> Android 正文翻译由 Google 翻译提供，使用设备上的 ML Kit 离线模型。首次使用可能需要下载语言包，随时可以切回原文。服务信息：https://cloud.google.com/translate

对应英文：

> Android post translation is powered by Google Translate using ML Kit on-device models. Language packs may need downloading before first use. The original post remains available. Service information: https://cloud.google.com/translate

依据：[ML Kit 使用要求](https://developers.google.com/ml-kit/language/translation/translation-terms)、[归属与品牌要求](https://docs.cloud.google.com/translate/attribution)。
