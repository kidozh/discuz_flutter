# Android 正文翻译

Android 使用 ML Kit Language Identification（17.0.6）识别正文语言，使用 ML Kit Translation（17.0.3）翻译；总结仍使用 Gemini Nano Prompt API，需要设备/AICore 支持。

`AndroidTranslationChannel` 在 MainActivity 随 Flutter engine 注册/释放，复用现有 `com.kidozh.discuz_flutter/translation` 协议（Dart 客户端暂时位于 apple_post_translation 包中）。正文统一经 PostHtmlTranslation 提取文本节点，保留图片、链接地址和排版。点按默认设备语言，再点还原；长按读取 ML Kit 支持的语言列表。Android 翻译不依赖 Nano 或 AI 设置开关。

语言包按需通过 Wi-Fi 下载，已下载后可离线使用。单片段最多等待 120 秒，失败显示提示，不自动改用生成式 AI。源/目标语言相同以及纯符号片段跳过翻译。Translator 在完成、失败、超时或引擎清理时关闭。

验证：Flutter 翻译正文/按钮测试与 Android debug APK 编译。模拟器已复现并修复 zh-CN 等地区标签被拒绝的问题。该模拟器仅有蜂窝连接，不满足 Wi-Fi 下载条件，集成测试在等待模型时超时，尚未验证实际译文。

官方资料：
- https://developers.google.com/ml-kit/language/translation/android
- https://developers.google.com/ml-kit/language/identification/android

自动翻译位于设置的常规分组末尾，默认开启；保留已保存的关闭选择。
