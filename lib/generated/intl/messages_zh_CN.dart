// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(discuz) => "成功添加 ${discuz} 论坛。";

  static String m1(placeholder) => "是否确认删除规则 ${placeholder}？删除后，此规则便无法找回。";

  static String m2(placeholder) => "删除 ${placeholder}";

  static String m3(placeholder) => "修改规则 ${placeholder}";

  static String m4(placeholder) => "智能规则 ${placeholder}";

  static String m5(osVersion) => "当前系统版本（${osVersion}）过低，请升级系统后重试。";

  static String m6(index) => "上传文件 No. ${index}";

  static String m7(time) => "上次修改时间： ${time}";

  static String m8(username) => "自动填充${username}的信息到登陆表单中。";

  static String m9(version, number) => "应用版本v${version}，序列${number}";

  static String m10(username) => "此内容由一个屏蔽用户${username}发送";

  static String m11(name) => "自定义 · ${name}";

  static String m12(day) => "${day}天前";

  static String m13(day) => "${day}天后";

  static String m14(account) => "成功移除账号 ${account}。";

  static String m15(account) => "成功删除论坛 ${account}。";

  static String m16(sitename) => "我们默认移除${sitename}的应用广告";

  static String m17(sitename) =>
      "欢迎使用谈坛访问${sitename}，在您浏览${sitename}的时候，我们不会展示应用内提供的广告。但论坛的帖子形式的软广告并不会被移除。";

  static String m18(key, content) => "${content}（${key}）";

  static String m19(filename) => "后台下载文件 ${filename} 中。";

  static String m20(discuz, discuzUrl) =>
      "我建议添加 ${discuz}（${discuzUrl}）到订阅频道获得定时的推送。";

  static String m21(discuz) => "收录${discuz}到订阅频道中";

  static String m22(discuz) => "通知我们收录${discuz}";

  static String m23(size) => "${size}逻辑像素";

  static String m24(size) => "${size}倍";

  static String m25(device, version) =>
      "--- 消息由 ${device} 的 [url=https://discuzhub.kidozh.com/]谈坛（v${version}）[/url]发出。";

  static String m26(device) => "消息由${device}发出。";

  static String m27(language) => "不支持${language}";

  static String m28(readAccess, star) => "阅读权限： ${readAccess}， 等级： ${star}";

  static String m29(hour) => "${hour}小时前";

  static String m30(hour) => "${hour}小时后";

  static String m31(uri) => "无法打开此链接 : ${uri}.";

  static String m32(name) => "${name}的Linux电脑";

  static String m33(name) => "${name}的MacOS设备";

  static String m34(min) => "${min}分钟前";

  static String m35(min) => "${min}分钟后";

  static String m36(discuz) => "${discuz}目前还没有任何订阅消息";

  static String m37(downloaded) => "已下载 ${downloaded} MB";

  static String m38(hour) => "${hour}小时";

  static String m39(pictureBedName) => "此服务由${pictureBedName}提供";

  static String m40(time) => "该投票于${time}过期.";

  static String m41(people) => "共有${people}人已投票.";

  static String m42(pos) => "第${pos}层";

  static String m43(discuz) => "${discuz}并未启用推送服务";

  static String m44(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} 发表于 ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m45(name) => "举报${name}的内容";

  static String m46(discuzName) => "成功向${discuzName}发送了举报信息，请等待管理员回应。";

  static String m47(username, discuzName) =>
      "用户 ${username} 已成功登录到 ${discuzName}。";

  static String m48(discuzName) => "登录至 ${discuzName}";

  static String m49(index) => "表情 ${index}";

  static String m50(name) => "关联游戏：${name}";

  static String m51(checked, allowed) => "投票 (${checked} / ${allowed})";

  static String m52(title) => "成功删除历史记录 ${title}.";

  static String m53(filename) => "成功下载文件： ${filename}。";

  static String m54(num) => "已同步所有${num}个收藏的帖子";

  static String m55(num) => "阅读权限 ${num}";

  static String m56(reply) => "${reply}回复";

  static String m57(view) => "${view}浏览";

  static String m58(username) => "用户 ${username} 已失效";

  static String m59(uid) => "用户编号： ${uid}";

  static String m60(user) => "查看${user}详情";

  static String m61(version) => "欢迎使用版本 ${version}";

  static String m62(name) => "${name}的Windows电脑";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accentColorPickerType": MessageLookupByLibrary.simpleMessage("强调色"),
    "account": MessageLookupByLibrary.simpleMessage("账号"),
    "acknowledgeAppSignatureAndAdDiminish":
        MessageLookupByLibrary.simpleMessage("感谢您使用带有应用标签的小尾巴。应用内的广告会被减少展示。"),
    "adExemptCondition": MessageLookupByLibrary.simpleMessage(
      "感谢您使用应用小尾巴，你可以选择一个论坛不显示其所有的广告。",
    ),
    "adExemptDescription": MessageLookupByLibrary.simpleMessage(
      "你可以额外选择一个论坛豁免广告。",
    ),
    "adExemptEmbeddedList": MessageLookupByLibrary.simpleMessage(
      "下列Discuz论坛已经内置于广告白名单中。",
    ),
    "adExemptNeedConfirm": MessageLookupByLibrary.simpleMessage("选择下列论坛免广告"),
    "adExemptNoNeedToConfirm": MessageLookupByLibrary.simpleMessage(
      "目前还没有需要免广告的论坛站点",
    ),
    "adExemptTitle": MessageLookupByLibrary.simpleMessage("免广告设置"),
    "adLoadingText": MessageLookupByLibrary.simpleMessage(
      "由Google提供的广告，与论坛无关。",
    ),
    "addAPhoto": MessageLookupByLibrary.simpleMessage("照片"),
    "addAuthentication": MessageLookupByLibrary.simpleMessage("添加到凭证集中"),
    "addDiscuzApiBrowseUnsuccessfully": MessageLookupByLibrary.simpleMessage(
      "无法识别论坛掌上论坛插件，请联系管理员开启本插件。",
    ),
    "addDiscuzApiParseUnsuccessfully": MessageLookupByLibrary.simpleMessage(
      "掌上论坛API插件未被正确配置，其返回了一个无法识别的错误，。",
    ),
    "addDiscuzApiSecurityChallengeBlocked":
        MessageLookupByLibrary.simpleMessage(
          "站点的安全策略拦截了API请求，无法正常添加论坛。请完成安全验证后重试，若问题持续存在请联系论坛管理员。",
        ),
    "addDiscuzSuccessfully": m0,
    "addDiscuzSuggestionAnnotation": MessageLookupByLibrary.simpleMessage(
      "反馈问题",
    ),
    "addDiscuzSuggestionDialogButtonTitle":
        MessageLookupByLibrary.simpleMessage("联系我们"),
    "addDiscuzSuggestionDialogDescription": MessageLookupByLibrary.simpleMessage(
      "除了统计来自用户使用的论坛，我们也非常希望得到您的反馈。您可以通过邮件向我们推荐论坛。如果您作为网站的管理员，不想让论坛出现在推荐界面，您也可以联系我们 （kidozh@gmail.com）。",
    ),
    "addDiscuzSuggestionDialogTitle": MessageLookupByLibrary.simpleMessage(
      "向我们推荐或者移除一个站点",
    ),
    "addDiscuzSuggestionStatement": MessageLookupByLibrary.simpleMessage(
      "谈坛是一个Discuz！的第三方客户端，我们和任何论坛都没有联系，也不提供任何担保。",
    ),
    "addDiscuzSuggestionTitle": MessageLookupByLibrary.simpleMessage("已知兼容论坛"),
    "addDiscuzSuggestionVerifiedDiscuz": MessageLookupByLibrary.simpleMessage(
      "的论坛已通过ICP备案。",
    ),
    "addDiscuzTitle": MessageLookupByLibrary.simpleMessage("添加Discuz! 论坛"),
    "addNewDiscuz": MessageLookupByLibrary.simpleMessage("添加一个论坛"),
    "adminBlockPost": MessageLookupByLibrary.simpleMessage("屏蔽"),
    "adminDeletePost": MessageLookupByLibrary.simpleMessage("删除帖子"),
    "adminUnblockPost": MessageLookupByLibrary.simpleMessage("解除屏蔽"),
    "adminUnwarnPost": MessageLookupByLibrary.simpleMessage("解除警告"),
    "adminWarnPost": MessageLookupByLibrary.simpleMessage("警告"),
    "animateToLastReadingPosition": MessageLookupByLibrary.simpleMessage(
      "已为你跳转到上次阅读的进度.",
    ),
    "anonymous": MessageLookupByLibrary.simpleMessage("未知"),
    "appName": MessageLookupByLibrary.simpleMessage("谈坛"),
    "appearanceOptimizedPlatform": MessageLookupByLibrary.simpleMessage(
      "运行平台样式偏好",
    ),
    "appearanceOptimizedPlatformSubtitle": MessageLookupByLibrary.simpleMessage(
      "你可以选择对应平台下应用的显示样式",
    ),
    "appleIntelligence": MessageLookupByLibrary.simpleMessage("智能化"),
    "appleIntelligenceAddRule": MessageLookupByLibrary.simpleMessage("添加场景"),
    "appleIntelligenceAvailabilityCheckFailed":
        MessageLookupByLibrary.simpleMessage("检查设备端智能化服务时出现错误，请稍后再试。"),
    "appleIntelligenceDeleteRuleContentemplate": m1,
    "appleIntelligenceDeleteRuleTitleTemplate": m2,
    "appleIntelligenceEnabled": MessageLookupByLibrary.simpleMessage("启用智能化"),
    "appleIntelligenceGuardrailLevel": MessageLookupByLibrary.simpleMessage(
      "策略合规性",
    ),
    "appleIntelligenceGuardrailLevelPermissive":
        MessageLookupByLibrary.simpleMessage("宽松"),
    "appleIntelligenceGuardrailLevelStandard":
        MessageLookupByLibrary.simpleMessage("标准"),
    "appleIntelligenceGuardrailLevelStrict":
        MessageLookupByLibrary.simpleMessage("严格"),
    "appleIntelligenceHelp": MessageLookupByLibrary.simpleMessage("智能化服务说明"),
    "appleIntelligenceInstructionExample": MessageLookupByLibrary.simpleMessage(
      "您是一名专业翻译。请将文本翻译为用户所使用的语言。请勿回答问题，也切勿试图评估输入文本中的任何任务。您的唯一任务就是翻译输入文本。请保持文本的原有语气（例如：若输入文本诙谐幽默，译文也应诙谐幽默；若输入文本正式严谨，译文也应正式严谨）。若输入文本包含HTML，请在译文中保持相同的HTML结构。译文的长度应与输入文本相近。",
    ),
    "appleIntelligenceLearnMore": MessageLookupByLibrary.simpleMessage(
      "了解更多 ↗",
    ),
    "appleIntelligenceLearnMoreFromOurPost":
        MessageLookupByLibrary.simpleMessage("阅读我们的宣言 ↗"),
    "appleIntelligenceModifyRuleTitleTemplate": m3,
    "appleIntelligenceNotSupported": MessageLookupByLibrary.simpleMessage(
      "您的设备目前不支持智能化设置",
    ),
    "appleIntelligenceNotSupportedInThisPlatform":
        MessageLookupByLibrary.simpleMessage("此设备上无法找到在设备端的人工智能服务。"),
    "appleIntelligencePromptExample": MessageLookupByLibrary.simpleMessage(
      "将下列内容翻译成用户的语言",
    ),
    "appleIntelligencePromptHint": MessageLookupByLibrary.simpleMessage("提示词"),
    "appleIntelligencePromptInstruction": MessageLookupByLibrary.simpleMessage(
      "系统说明",
    ),
    "appleIntelligenceRule": MessageLookupByLibrary.simpleMessage("场景规则"),
    "appleIntelligenceRuleName": MessageLookupByLibrary.simpleMessage("名称"),
    "appleIntelligenceRuleNameTemplate": m4,
    "appleIntelligenceRuleTranslationExampleNotice":
        MessageLookupByLibrary.simpleMessage("翻译规则是内置在系统中的，无法更改或者移除。"),
    "appleIntelligenceTranslate": MessageLookupByLibrary.simpleMessage("翻译"),
    "appleIntelligenceUnavailableDeviceNotEligible":
        MessageLookupByLibrary.simpleMessage("此设备不支持所需的设备端基础模型。"),
    "appleIntelligenceUnavailableModelNotReady":
        MessageLookupByLibrary.simpleMessage("设备端模型仍在下载或准备中，请稍后再试。"),
    "appleIntelligenceUnavailableNotEnabled":
        MessageLookupByLibrary.simpleMessage("尚未启用 Apple 智能，请先前往系统“设置”启用后重试。"),
    "appleIntelligenceUnavailablePlatformTooOld": m5,
    "appleIntelligenceUnavailableUnknown": MessageLookupByLibrary.simpleMessage(
      "暂时无法使用设备端智能化服务，请稍后再试。",
    ),
    "appleIntelligenceUseHistory": MessageLookupByLibrary.simpleMessage("使用历史"),
    "appleIntelligenceUseNotice": MessageLookupByLibrary.simpleMessage(
      "在帖子中使用翻译，或通过自定义场景让设备端模型处理文本。内容在本机处理，不会为此发送到云端模型；模型首次准备可能需要联网下载。生成结果可能有误，请核对重要信息。",
    ),
    "attachFile": m6,
    "attachmentUploadExceedingSizeDescription":
        MessageLookupByLibrary.simpleMessage("附件需要被压缩以满足限额"),
    "attachmentUploadExceedingSizeTitle": MessageLookupByLibrary.simpleMessage(
      "上传的附件超出了论坛限制大小",
    ),
    "authenticateBySystem": MessageLookupByLibrary.simpleMessage(
      "请验证您的身份以查看本地存储的保存密码。",
    ),
    "authenticationEmpty": MessageLookupByLibrary.simpleMessage(
      "在此设备上并无任何凭证信息。",
    ),
    "authenticationLastUpdateAt": m7,
    "authenticationLocked": MessageLookupByLibrary.simpleMessage("数据已锁定"),
    "authenticationRetry": MessageLookupByLibrary.simpleMessage("验证身份"),
    "authenticationSecurityAndroidContent": MessageLookupByLibrary.simpleMessage(
      "您的凭证数据经由AES 256位强加密于您的设备中并且永不会发送出本机。AES-256的解密私钥经由RSA算法加密，RSA键值信息仅存储于您设备中的密钥库系统中。只有通过了来自系统的验证，应用才能访问并解密您的这些数据用于自动填充功能。",
    ),
    "authenticationSecurityIosContent": MessageLookupByLibrary.simpleMessage(
      "您的凭证数据经由AES 256位强加密于您的设备中并且永不会发送出本机。AES-256的解密私钥仅存储于您设备中的安全飞地中。只有通过了来自系统的验证，应用才能访问并解密您的这些数据用于自动填充功能。",
    ),
    "authenticationSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "凭证仅存于本机",
    ),
    "authenticationStatusCannotAuthenticate":
        MessageLookupByLibrary.simpleMessage("您的设备并未有密码或者生物信息加密，因此无法认证您的身份。"),
    "authenticationStatusDeviceNotSupported":
        MessageLookupByLibrary.simpleMessage("您的设备不支持验证身份"),
    "authenticationStatusFailed": MessageLookupByLibrary.simpleMessage(
      "系统未能验证您的身份。请重试。",
    ),
    "authorizedSite": MessageLookupByLibrary.simpleMessage("已验证站点"),
    "autoFillUsername": m8,
    "autofillDialogSubtitle": MessageLookupByLibrary.simpleMessage(
      "选择用户名以自动填充登陆表格",
    ),
    "autofillDialogTitle": MessageLookupByLibrary.simpleMessage("自动填充"),
    "basicUse": MessageLookupByLibrary.simpleMessage("基本使用"),
    "basicUseDescribe": MessageLookupByLibrary.simpleMessage(
      "EasyRefresh的基本使用",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("签名"),
    "birthPlace": MessageLookupByLibrary.simpleMessage("出生地"),
    "blackAndWhiteColorPickerType": MessageLookupByLibrary.simpleMessage("黑白"),
    "blockUser": MessageLookupByLibrary.simpleMessage("屏蔽此用户"),
    "blockedPost": MessageLookupByLibrary.simpleMessage("此贴被屏蔽。"),
    "blockedUserList": MessageLookupByLibrary.simpleMessage("屏蔽用户列表"),
    "bobMinion": MessageLookupByLibrary.simpleMessage("Bob小黄人"),
    "bobMinionDescribe": MessageLookupByLibrary.simpleMessage("可爱的小黄人"),
    "bothColorPickerType": MessageLookupByLibrary.simpleMessage("示例色彩"),
    "brightnessDark": MessageLookupByLibrary.simpleMessage("深色"),
    "brightnessLight": MessageLookupByLibrary.simpleMessage("浅色"),
    "brightnessManualChangeDisabled": MessageLookupByLibrary.simpleMessage(
      "应用现在将仅跟随系统设置明暗模式，我们在下一个大版本中将会移除这个设置项。",
    ),
    "brokenCountDown": MessageLookupByLibrary.simpleMessage("无效的倒数指令"),
    "bugTestSubtitle": MessageLookupByLibrary.simpleMessage(
      "你可以通过邮箱kidozh@gmail.com向我们报告错误，我们非常感谢您的报告",
    ),
    "bugTestTitle": MessageLookupByLibrary.simpleMessage("可能包含一些BUG"),
    "buildDescription": MessageLookupByLibrary.simpleMessage(
      "由flutter驱动, 能够兼容多种平台。",
    ),
    "buildVersionDescription": m9,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelAdding": MessageLookupByLibrary.simpleMessage("取消"),
    "captchaRequired": MessageLookupByLibrary.simpleMessage("需要验证码"),
    "chatIconToolTip": MessageLookupByLibrary.simpleMessage("私聊"),
    "chatMessage": MessageLookupByLibrary.simpleMessage("信息"),
    "checkUserLoginStatus": MessageLookupByLibrary.simpleMessage(
      "正在检查用户登录状态。。。",
    ),
    "cheveretoApiDescription": MessageLookupByLibrary.simpleMessage(
      "Chevereto密钥可以由已经注册的用户生成。使用此密钥可以允许应用向您的图床上传照片并嵌入到论坛中。",
    ),
    "cheveretoApiKey": MessageLookupByLibrary.simpleMessage("密钥"),
    "cheveretoApiSetupGuide": MessageLookupByLibrary.simpleMessage(
      "1. 在浏览器中登录对应图床网站。\n2. 进入账号/API 设置，创建或复制 API 密钥。\n3. 将 API 密钥粘贴到此处。\n4. 点击“测试并保存”。应用会先上传一张极小的测试图片，测试通过后才会保存密钥。",
    ),
    "cheveretoApiSetupGuideTitle": MessageLookupByLibrary.simpleMessage("如何操作"),
    "cheveretoPictureBed": MessageLookupByLibrary.simpleMessage(
      "基于chevereto服务的",
    ),
    "chooseDiscuz": MessageLookupByLibrary.simpleMessage("选择一个论坛"),
    "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("主题颜色"),
    "chooseTypographyTheme": MessageLookupByLibrary.simpleMessage("文字排版主题"),
    "clearAllViewHistories": MessageLookupByLibrary.simpleMessage("清除历史记录"),
    "closeKeyboardTooltip": MessageLookupByLibrary.simpleMessage("收起键盘"),
    "collapseItem": MessageLookupByLibrary.simpleMessage("已折叠内容"),
    "colorAmber": MessageLookupByLibrary.simpleMessage("琥珀色"),
    "colorBlack": MessageLookupByLibrary.simpleMessage("黑色"),
    "colorBlue": MessageLookupByLibrary.simpleMessage("蓝色"),
    "colorBlueAccent": MessageLookupByLibrary.simpleMessage("蓝色"),
    "colorBlueGrey": MessageLookupByLibrary.simpleMessage("蓝灰色"),
    "colorBrown": MessageLookupByLibrary.simpleMessage("棕色"),
    "colorCyan": MessageLookupByLibrary.simpleMessage("青色"),
    "colorDeepOrange": MessageLookupByLibrary.simpleMessage("深橙色"),
    "colorDeepPurple": MessageLookupByLibrary.simpleMessage("深紫色"),
    "colorDeepPurpleAccent": MessageLookupByLibrary.simpleMessage("深紫色"),
    "colorGreen": MessageLookupByLibrary.simpleMessage("绿色"),
    "colorGrey": MessageLookupByLibrary.simpleMessage("灰色"),
    "colorIndigo": MessageLookupByLibrary.simpleMessage("靛青色"),
    "colorIndigoAccent": MessageLookupByLibrary.simpleMessage("靛青色"),
    "colorLightBlue": MessageLookupByLibrary.simpleMessage("浅蓝色"),
    "colorLightGreen": MessageLookupByLibrary.simpleMessage("浅绿色"),
    "colorLime": MessageLookupByLibrary.simpleMessage("青柠绿色"),
    "colorOrange": MessageLookupByLibrary.simpleMessage("橙色"),
    "colorPink": MessageLookupByLibrary.simpleMessage("粉色"),
    "colorPurple": MessageLookupByLibrary.simpleMessage("紫色"),
    "colorRed": MessageLookupByLibrary.simpleMessage("红色"),
    "colorTeal": MessageLookupByLibrary.simpleMessage("蓝绿色"),
    "colorYellow": MessageLookupByLibrary.simpleMessage("黄色"),
    "common": MessageLookupByLibrary.simpleMessage("常规"),
    "compactTypography": MessageLookupByLibrary.simpleMessage("紧凑文本段落"),
    "completeLoad": MessageLookupByLibrary.simpleMessage("完成加载"),
    "completeRefresh": MessageLookupByLibrary.simpleMessage("完成刷新"),
    "connectServerWhenAdding": MessageLookupByLibrary.simpleMessage(
      "正在连接论坛地址以验证兼容性。",
    ),
    "contactUsViaEmail": MessageLookupByLibrary.simpleMessage("邮件联系我们"),
    "contactUsViaWeibo": MessageLookupByLibrary.simpleMessage("在微博关注我们"),
    "contentPostByBlockUserTitle": m10,
    "continueAdding": MessageLookupByLibrary.simpleMessage("继续"),
    "continueToDo": MessageLookupByLibrary.simpleMessage("继续"),
    "continueToTest": MessageLookupByLibrary.simpleMessage("开始测试此版本"),
    "countDownEnd": MessageLookupByLibrary.simpleMessage("倒计时已过期。"),
    "countDownTimeZoneNotify": MessageLookupByLibrary.simpleMessage(
      "此倒计时很有可能是北京时间，如果您不处于东八区，那么此倒计时很有可能不准确",
    ),
    "credit": MessageLookupByLibrary.simpleMessage("积分"),
    "cupertinoStyle": MessageLookupByLibrary.simpleMessage("Cupertino"),
    "cupertinoStyleDescription": MessageLookupByLibrary.simpleMessage(
      "经典苹果风格控件，不启用自定义 Liquid Glass 效果。",
    ),
    "customColor": MessageLookupByLibrary.simpleMessage("自定义颜色"),
    "customColorNamed": m11,
    "customSignature": MessageLookupByLibrary.simpleMessage("自定义"),
    "customStatusTitle": MessageLookupByLibrary.simpleMessage("自定义头衔"),
    "dashboard": MessageLookupByLibrary.simpleMessage("看板"),
    "dataBackupInTestSubtitle": MessageLookupByLibrary.simpleMessage(
      "版本变更有可能会引发数据的丢失，因此请务必做好数据备份工作。",
    ),
    "dataBackupInTestTitle": MessageLookupByLibrary.simpleMessage("数据备份"),
    "day": MessageLookupByLibrary.simpleMessage("天"),
    "dayAgo": m12,
    "dayLater": m13,
    "deleteAccount": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteAccountSuccessfully": m14,
    "deleteDiscuzSuccessfully": m15,
    "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
      "清除历史记录是不可恢复的，确认要继续？",
    ),
    "deviceNameSignature": MessageLookupByLibrary.simpleMessage("使用设备名称"),
    "dhPushServiceTitle": MessageLookupByLibrary.simpleMessage("谈坛推送服务"),
    "dioErrorBadCertificate": MessageLookupByLibrary.simpleMessage("HTTPS证书错误"),
    "dioErrorBadResponse": MessageLookupByLibrary.simpleMessage("响应出现了问题"),
    "dioErrorCancel": MessageLookupByLibrary.simpleMessage("响应被取消"),
    "dioErrorConnectionError": MessageLookupByLibrary.simpleMessage("连接出错"),
    "dioErrorConnectionTimeout": MessageLookupByLibrary.simpleMessage("连接超时"),
    "dioErrorOther": MessageLookupByLibrary.simpleMessage("解析或者其他错误"),
    "dioErrorReceiveTimeout": MessageLookupByLibrary.simpleMessage("接收超时"),
    "dioErrorResponse": MessageLookupByLibrary.simpleMessage("服务器响应错误"),
    "dioErrorSendTimeout": MessageLookupByLibrary.simpleMessage("发送超时"),
    "disableFontCustomization": MessageLookupByLibrary.simpleMessage("停用自定义字体"),
    "disableFontCustomizationTitle": MessageLookupByLibrary.simpleMessage(
      "不再解析自定义字体的颜色，大小等信息",
    ),
    "discuzAuthenticationTitle": MessageLookupByLibrary.simpleMessage("密码与凭证"),
    "discuzInAdExemptBuiltInList": m16,
    "discuzInAdExemptBuiltInListDescription": m17,
    "discuzOperationMessage": m18,
    "discuzServerAddress": MessageLookupByLibrary.simpleMessage("论坛地址"),
    "discuzServerAddressHelperText": MessageLookupByLibrary.simpleMessage(
      "其通常就是论坛的地址",
    ),
    "discuzServerAddressHint": MessageLookupByLibrary.simpleMessage(
      "例如： https://bbs.nwpu.edu.cn",
    ),
    "displaySettingTitle": MessageLookupByLibrary.simpleMessage("显示"),
    "downloadAttachment": MessageLookupByLibrary.simpleMessage("下载附件"),
    "downloadingFiles": m19,
    "duplicatedPost": MessageLookupByLibrary.simpleMessage("重复发帖"),
    "dynamicSchemeVariant": MessageLookupByLibrary.simpleMessage("色调变体"),
    "dynamicSchemeVariantContentDescription":
        MessageLookupByLibrary.simpleMessage(
          "提供原始色调组合。其实与和谐色相近，但是与之不同的是一些界面的底色是主选色以确保与背景的对比。",
        ),
    "dynamicSchemeVariantContentKey": MessageLookupByLibrary.simpleMessage(
      "原色色调",
    ),
    "dynamicSchemeVariantExpressiveDescription":
        MessageLookupByLibrary.simpleMessage(
          "中饱和度的油画色调。这个色调会选择不同于主选色的颜色以提供色彩多样性。",
        ),
    "dynamicSchemeVariantExpressiveKey": MessageLookupByLibrary.simpleMessage(
      "鲜艳色调",
    ),
    "dynamicSchemeVariantFidelityDescription":
        MessageLookupByLibrary.simpleMessage("提供最接近色彩的和谐色调组合。"),
    "dynamicSchemeVariantFidelityKey": MessageLookupByLibrary.simpleMessage(
      "和谐色调",
    ),
    "dynamicSchemeVariantFidelityNotification":
        MessageLookupByLibrary.simpleMessage("和谐色调会提供足够的对比度以确保可读性和预定的视觉效果。"),
    "dynamicSchemeVariantFruitSaladDescription":
        MessageLookupByLibrary.simpleMessage("提供来自沙拉灵感的配色，色谱中会排除主选色。"),
    "dynamicSchemeVariantFruitSaladKey": MessageLookupByLibrary.simpleMessage(
      "沙拉色调",
    ),
    "dynamicSchemeVariantMonochromeDescription":
        MessageLookupByLibrary.simpleMessage("黑白配色。明度根据主选色所确定。"),
    "dynamicSchemeVariantMonochromeKey": MessageLookupByLibrary.simpleMessage(
      "单色色调",
    ),
    "dynamicSchemeVariantNeutralDescription":
        MessageLookupByLibrary.simpleMessage("略带色调的灰色配色。"),
    "dynamicSchemeVariantNeutralKey": MessageLookupByLibrary.simpleMessage(
      "中性色调",
    ),
    "dynamicSchemeVariantNotification": MessageLookupByLibrary.simpleMessage(
      "颜色可能因对比度不足影响可读性。",
    ),
    "dynamicSchemeVariantRainbowDescription":
        MessageLookupByLibrary.simpleMessage("色调将会来自不同的颜色，色谱中会排除主选色。"),
    "dynamicSchemeVariantRainbowKey": MessageLookupByLibrary.simpleMessage(
      "彩虹色调",
    ),
    "dynamicSchemeVariantTonalSpotDescription":
        MessageLookupByLibrary.simpleMessage("低饱和度的油画色调。"),
    "dynamicSchemeVariantTonalSpotKey": MessageLookupByLibrary.simpleMessage(
      "柔和色调",
    ),
    "dynamicSchemeVariantVibrantDescription":
        MessageLookupByLibrary.simpleMessage("高饱和度的油画色调。其会选择当前颜色档位中最为艳丽的色彩。"),
    "dynamicSchemeVariantVibrantKey": MessageLookupByLibrary.simpleMessage(
      "饱和色调",
    ),
    "easyRefreshClassicFooterArmedText": MessageLookupByLibrary.simpleMessage(
      "释放开始",
    ),
    "easyRefreshClassicFooterDragText": MessageLookupByLibrary.simpleMessage(
      "上拉加载",
    ),
    "easyRefreshClassicFooterFailedText": MessageLookupByLibrary.simpleMessage(
      "加载失败",
    ),
    "easyRefreshClassicFooterMessageText": MessageLookupByLibrary.simpleMessage(
      "最后更新于 %T",
    ),
    "easyRefreshClassicFooterNoMoreText": MessageLookupByLibrary.simpleMessage(
      "没有更多的内容了",
    ),
    "easyRefreshClassicFooterProcessedText":
        MessageLookupByLibrary.simpleMessage("加载成功"),
    "easyRefreshClassicFooterProcessingText":
        MessageLookupByLibrary.simpleMessage("加载中..."),
    "easyRefreshClassicFooterReadyText": MessageLookupByLibrary.simpleMessage(
      "加载中...",
    ),
    "easyRefreshClassicHeaderArmedText": MessageLookupByLibrary.simpleMessage(
      "释放开始",
    ),
    "easyRefreshClassicHeaderDragText": MessageLookupByLibrary.simpleMessage(
      "下拉刷新",
    ),
    "easyRefreshClassicHeaderFailedText": MessageLookupByLibrary.simpleMessage(
      "访问失败",
    ),
    "easyRefreshClassicHeaderMessageText": MessageLookupByLibrary.simpleMessage(
      "最后更新于 %T",
    ),
    "easyRefreshClassicHeaderNoMoreText": MessageLookupByLibrary.simpleMessage(
      "没有更多内容了",
    ),
    "easyRefreshClassicHeaderProcessedText":
        MessageLookupByLibrary.simpleMessage("成功加载"),
    "easyRefreshClassicHeaderProcessingText":
        MessageLookupByLibrary.simpleMessage("刷新中..."),
    "easyRefreshClassicHeaderReadyText": MessageLookupByLibrary.simpleMessage(
      "刷新中...",
    ),
    "editedPost": MessageLookupByLibrary.simpleMessage("已编辑"),
    "emailChannelBody": m20,
    "emailChannelFailed": MessageLookupByLibrary.simpleMessage(
      "在此设备上无法发送邮件。你可以发送此站点信息到kidozh@gmail.com以添加此频道到订阅列表中。",
    ),
    "emailChannelTitle": m21,
    "emailUsToAddChannel": m22,
    "emoijButtonTooltip": MessageLookupByLibrary.simpleMessage("插入表情"),
    "emptyForum": MessageLookupByLibrary.simpleMessage("当前板块列表为空。"),
    "emptyHistory": MessageLookupByLibrary.simpleMessage(
      "这里还没有历史记录。您未曾浏览论坛或者没有打开历史记录功能。",
    ),
    "emptyListDescription": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
    "emptyNotification": MessageLookupByLibrary.simpleMessage("当前通知列表为空。"),
    "emptyPosts": MessageLookupByLibrary.simpleMessage("目前没有贴文显示。"),
    "emptyScreenTitle": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
    "emptyThreads": MessageLookupByLibrary.simpleMessage("当前帖子列表为空。"),
    "emptyTrustHost": MessageLookupByLibrary.simpleMessage("你还没有信任一个主机地址。"),
    "emptyUser": MessageLookupByLibrary.simpleMessage("这里还没有用户。"),
    "error": MessageLookupByLibrary.simpleMessage("出错了"),
    "errorUserExpired": MessageLookupByLibrary.simpleMessage("用户登录信息已经失效。"),
    "extraFuncButtonTooltip": MessageLookupByLibrary.simpleMessage("更多功能"),
    "favoriteForum": MessageLookupByLibrary.simpleMessage("收藏的板块"),
    "favoriteIconTooltip": MessageLookupByLibrary.simpleMessage("收藏板块"),
    "favoriteThread": MessageLookupByLibrary.simpleMessage("收藏的帖子"),
    "favoriteThreadTooltip": MessageLookupByLibrary.simpleMessage("收藏帖子"),
    "favorites": MessageLookupByLibrary.simpleMessage("收藏"),
    "feedbackTitle": MessageLookupByLibrary.simpleMessage("触感"),
    "finishLoginInWeb": MessageLookupByLibrary.simpleMessage("完成登录"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "fontSizeInParagraph": MessageLookupByLibrary.simpleMessage("正文字体大小"),
    "fontSizeInParagraphUnit": m23,
    "fontSizeScaleParameter": MessageLookupByLibrary.simpleMessage("文本缩放比例"),
    "fontSizeScaleParameterUnit": m24,
    "forgetPassword": MessageLookupByLibrary.simpleMessage("忘记密码?"),
    "forumDisplayTitle": MessageLookupByLibrary.simpleMessage("显示板块"),
    "forumFilterSortByHeat": MessageLookupByLibrary.simpleMessage("最火人气"),
    "forumFilterSortByLastPost": MessageLookupByLibrary.simpleMessage("最新回复"),
    "forumFilterSortByNewPost": MessageLookupByLibrary.simpleMessage("最新发布"),
    "forumFilterSortByTitle": MessageLookupByLibrary.simpleMessage("排序方法"),
    "forumFilterSortByView": MessageLookupByLibrary.simpleMessage("最多查看"),
    "forumFilterSpecialTypeActivity": MessageLookupByLibrary.simpleMessage(
      "活动",
    ),
    "forumFilterSpecialTypeDebate": MessageLookupByLibrary.simpleMessage("辩论"),
    "forumFilterSpecialTypePoll": MessageLookupByLibrary.simpleMessage("投票"),
    "forumFilterSpecialTypeTitle": MessageLookupByLibrary.simpleMessage("功能类型"),
    "forumFilterStatusAll": MessageLookupByLibrary.simpleMessage("所有"),
    "forumFilterStatusDigest": MessageLookupByLibrary.simpleMessage("精华帖"),
    "forumFilterStatusHot": MessageLookupByLibrary.simpleMessage("热门贴"),
    "forumFilterStatusTitle": MessageLookupByLibrary.simpleMessage("主题状态"),
    "forumFilterTimeThisMonth": MessageLookupByLibrary.simpleMessage("这个月"),
    "forumFilterTimeThisQuarter": MessageLookupByLibrary.simpleMessage("本季度"),
    "forumFilterTimeThisWeek": MessageLookupByLibrary.simpleMessage("这周"),
    "forumFilterTimeThisYear": MessageLookupByLibrary.simpleMessage("今年"),
    "forumFilterTimeTitle": MessageLookupByLibrary.simpleMessage("时间过滤"),
    "forumFilterTimeToday": MessageLookupByLibrary.simpleMessage("今天"),
    "forumFilterTypeIdTitle": MessageLookupByLibrary.simpleMessage("主题分类"),
    "forumInformation": MessageLookupByLibrary.simpleMessage("板块信息"),
    "forumSortPosts": MessageLookupByLibrary.simpleMessage("过滤排序帖子"),
    "friendNumber": MessageLookupByLibrary.simpleMessage("好友数"),
    "fromAppSignature": m25,
    "fromDeviceSignature": m26,
    "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
    "gameComingSoon": MessageLookupByLibrary.simpleMessage("即将发售"),
    "gameFreeOfCharge": MessageLookupByLibrary.simpleMessage("免费"),
    "gameLanguageNotSupported": m27,
    "goToPushSetting": MessageLookupByLibrary.simpleMessage("开启推送"),
    "googleAdSubTitle": MessageLookupByLibrary.simpleMessage("由Google提供的广告"),
    "googleAdTitle": MessageLookupByLibrary.simpleMessage("广告"),
    "groupInfoDescription": m28,
    "habit": MessageLookupByLibrary.simpleMessage("爱好"),
    "hapticFeedbackTitle": MessageLookupByLibrary.simpleMessage("振动反馈"),
    "history": MessageLookupByLibrary.simpleMessage("历史"),
    "homepage": MessageLookupByLibrary.simpleMessage("个人主页"),
    "hostIsEmpty": MessageLookupByLibrary.simpleMessage("请选择一个已有的论坛。"),
    "hotThread": MessageLookupByLibrary.simpleMessage("最新热门"),
    "hour": MessageLookupByLibrary.simpleMessage("时"),
    "hourAgo": m29,
    "hourLater": m30,
    "httpBrowseWarn": MessageLookupByLibrary.simpleMessage("不安全的HTTP协议"),
    "iframeUrlNull": MessageLookupByLibrary.simpleMessage("无法解析嵌入视图的来源。"),
    "illegalContent": MessageLookupByLibrary.simpleMessage("违法内容"),
    "incognitoSubtitle": MessageLookupByLibrary.simpleMessage("某些功能可能不可用"),
    "incognitoTitle": MessageLookupByLibrary.simpleMessage("匿名模式"),
    "incorrectDiscuzAddress": MessageLookupByLibrary.simpleMessage("无效的论坛地址."),
    "index": MessageLookupByLibrary.simpleMessage("索引"),
    "inlineFramePage": MessageLookupByLibrary.simpleMessage("访问嵌入式页面"),
    "insertBoldText": MessageLookupByLibrary.simpleMessage("粗体文字"),
    "insertItalicText": MessageLookupByLibrary.simpleMessage("斜体文字"),
    "insertQuoteText": MessageLookupByLibrary.simpleMessage("引用文字"),
    "insertSignatureAtTheEndTitle": MessageLookupByLibrary.simpleMessage(
      "启用结尾签名",
    ),
    "interfaceBrightness": MessageLookupByLibrary.simpleMessage("显示模式"),
    "invalidCookie": MessageLookupByLibrary.simpleMessage(
      "暂时无法读取网页登录状态，请刷新登录页面后重试。",
    ),
    "ios": MessageLookupByLibrary.simpleMessage("iOS"),
    "iosColorSchemeSuggestions": MessageLookupByLibrary.simpleMessage(
      "由于底层质感设计API更新，您暂时无法调节部分部件的样式（其默认为紫色），但是您仍能够调节其他样式。",
    ),
    "iosDarkModeDisabledText": MessageLookupByLibrary.simpleMessage(
      "处于iOS运行平台偏好下，您的颜色模式将会跟随系统，不可以手动调节。",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keylolPortal": MessageLookupByLibrary.simpleMessage("其乐头条"),
    "largeRichText": MessageLookupByLibrary.simpleMessage(
      "欢迎使用DiscuzHub\n感谢您使用我们的产品和服务（下称“服务”）。\n您使用我们的服务即表示您已同意本条款。请<b>仔细</b>阅读。<br/>使用我们的服务并不让您拥有我们的服务或您所访问的内容的任何知识产权。除非您获得相关内容所有者的许可或通过其他方式获得法律的许可，否则您不得使用服务中的任何内容。本条款并未授予您使用我们服务中所用的任何商标或标志的权利。请勿删除、隐藏或更改我们服务上显示的或随服务一同显示的任何法律声明。\n请勿滥用我们的服务。您仅能在法律（包括适用的出口和再出口管制法律和法规）允许的范围内使用我们的服务。如果您不遵守我们的条款或政策，或者我们在调查可疑的不当行为，我们可以暂停或停止向您提供服务。\n",
    ),
    "largeRichTextDescription": MessageLookupByLibrary.simpleMessage(
      "摘取我们的使用政策",
    ),
    "lastActivityTime": MessageLookupByLibrary.simpleMessage("上次活动于"),
    "lastPostTime": MessageLookupByLibrary.simpleMessage("上次发帖时间"),
    "lastVisitTime": MessageLookupByLibrary.simpleMessage("上次访问时间"),
    "lawInformation": MessageLookupByLibrary.simpleMessage("法律信息"),
    "legalInformation": MessageLookupByLibrary.simpleMessage("法律信息"),
    "linkUnableToOpen": m31,
    "linuxDeviceName": m32,
    "liquidGlassStyle": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "liquidGlassStyleDescription": MessageLookupByLibrary.simpleMessage(
      "使用 iOS / iPadOS 26 及以上系统的原生玻璃控件。",
    ),
    "liquidGlassStyleUnavailable": MessageLookupByLibrary.simpleMessage(
      "需要 iOS / iPadOS 26 及以上。本设备不支持；已保存的选择将回退为 Cupertino。",
    ),
    "loadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "loadFinish": MessageLookupByLibrary.simpleMessage("加载完成"),
    "loadMore": MessageLookupByLibrary.simpleMessage("加载"),
    "loaded": MessageLookupByLibrary.simpleMessage("加载完成"),
    "loading": MessageLookupByLibrary.simpleMessage("正在加载..."),
    "loadingCaptchaInformation": MessageLookupByLibrary.simpleMessage(
      "正在加载验证码信息。。。",
    ),
    "loadingForumInformation": MessageLookupByLibrary.simpleMessage(
      "正在加载发表帖子的设置。。。",
    ),
    "loginByWebHttpWarn": MessageLookupByLibrary.simpleMessage(
      "您正在使用不安全的HTTP连接，此界面有可能被第三方所劫持。您在此界面输入的信息有可能泄露。强烈建议您使用HTTPS协议访问此界面。",
    ),
    "loginByWebMessage": MessageLookupByLibrary.simpleMessage(
      "请在网页中完成登录，当您在网页中完成了登录过程后，请轻触右上方的完成登录按钮完成账号录入操作。有时存在延迟情况，可能需要点击两次才能录入账号。",
    ),
    "loginByWebNotSupported": MessageLookupByLibrary.simpleMessage(
      "当前系统并不支持Webview登录",
    ),
    "loginByWebTitle": MessageLookupByLibrary.simpleMessage("使用网页登录提醒"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage("添加一个新的用户"),
    "loginTitle": MessageLookupByLibrary.simpleMessage("登录"),
    "macOSDeviceName": m33,
    "manageAccount": MessageLookupByLibrary.simpleMessage("管理账号"),
    "manageAccountTitle": MessageLookupByLibrary.simpleMessage("管理账号"),
    "manageDiscuz": MessageLookupByLibrary.simpleMessage("管理论坛"),
    "manualControl": MessageLookupByLibrary.simpleMessage("手动控制"),
    "manualControlDescribe": MessageLookupByLibrary.simpleMessage(
      "控制刷新和加载的完成时机",
    ),
    "materialBrightnessSwitchDisabledText":
        MessageLookupByLibrary.simpleMessage("在质感设计的界面下，应用界面将跟随系统深浅设置 。"),
    "materialDesign": MessageLookupByLibrary.simpleMessage("质感设计"),
    "materialStyleDescription": MessageLookupByLibrary.simpleMessage(
      "使用 Material Design 控件，适用于所有平台。",
    ),
    "me": MessageLookupByLibrary.simpleMessage("我"),
    "menuDrawerTitle": MessageLookupByLibrary.simpleMessage("菜单"),
    "menuIconTooltip": MessageLookupByLibrary.simpleMessage("菜单"),
    "minute": MessageLookupByLibrary.simpleMessage("分"),
    "minuteAgo": m34,
    "minuteLater": m35,
    "mobileTemplateNotFound": MessageLookupByLibrary.simpleMessage(
      "此界面更适合使用网页访问",
    ),
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "navigateToWebPage": MessageLookupByLibrary.simpleMessage("在网页中继续"),
    "networkFail": MessageLookupByLibrary.simpleMessage("连接服务器时出错。"),
    "networkFailed": MessageLookupByLibrary.simpleMessage("网络访问失败。"),
    "newThread": MessageLookupByLibrary.simpleMessage("最新发表"),
    "noAuthenticationFoundInApp": MessageLookupByLibrary.simpleMessage(
      "在此设备上未有存储的登陆凭证。",
    ),
    "noCaptachaRequired": MessageLookupByLibrary.simpleMessage("不需要验证码验证信息。"),
    "noDiscuzNotFound": MessageLookupByLibrary.simpleMessage(
      "此设备上并未添加任何一个论坛站点。",
    ),
    "noFavoriteThreadInDb": MessageLookupByLibrary.simpleMessage("还没有收藏一个帖子"),
    "noForumIsCachedSubtitle": MessageLookupByLibrary.simpleMessage(
      "请点击‘索引’，然后加载所有板块信息后，再回来看看？",
    ),
    "noForumIsCachedTitle": MessageLookupByLibrary.simpleMessage("在此设备上没有板块信息"),
    "noImagePicked": MessageLookupByLibrary.simpleMessage("您可能没有选择任何一张图片。"),
    "noMore": MessageLookupByLibrary.simpleMessage("没有更多数据"),
    "noSignature": MessageLookupByLibrary.simpleMessage("不使用签名"),
    "noSmileyFoundInDB": MessageLookupByLibrary.simpleMessage("要不使用一个表情包？"),
    "noSubscribeChannelProvided": m36,
    "notification": MessageLookupByLibrary.simpleMessage("通知"),
    "nullDiscuzScreenSubtitle": MessageLookupByLibrary.simpleMessage(
      "现在开始添加一个Discuz X论坛以开始使用谈坛。",
    ),
    "nullDiscuzScreenTitle": MessageLookupByLibrary.simpleMessage("从添加论坛开始"),
    "nullDiscuzSubTitle": MessageLookupByLibrary.simpleMessage("现在就添加一个论坛吗？"),
    "nullDiscuzTitle": MessageLookupByLibrary.simpleMessage("还没有指定一个论坛"),
    "ok": MessageLookupByLibrary.simpleMessage("确定"),
    "onDeviceAiAICoreDescription": MessageLookupByLibrary.simpleMessage(
      "AICore 与此功能所需的版本不兼容。请在受支持的真机上通过 Google Play 检查 AICore 更新，再返回重新检查；仅安装 AICore 无法让不支持的设备获得此能力。",
    ),
    "onDeviceAiAICoreTitle": MessageLookupByLibrary.simpleMessage(
      "需要 Android AICore",
    ),
    "onDeviceAiAndroidUnavailable": MessageLookupByLibrary.simpleMessage(
      "当前设备或系统配置尚未提供本应用所需的 Gemini Nano 模型。不代表所有 ML Kit 功能都不可用。请先查看官方支持设备列表；受支持的真机可更新系统和 AICore、联网等待配置就绪后重新检查。",
    ),
    "onDeviceAiBatteryQuota": MessageLookupByLibrary.simpleMessage(
      "已达到系统对本应用的模型使用配额，请稍后再试；重复检查不会重置配额。",
    ),
    "onDeviceAiCheckTimeoutDescription": MessageLookupByLibrary.simpleMessage(
      "Android AICore 在 15 秒内没有返回检测结果，尚无法确认模型是否可用。模拟器请改用受支持的真机；真机请检查系统和 AICore 更新后重新检查。",
    ),
    "onDeviceAiCheckTimeoutTitle": MessageLookupByLibrary.simpleMessage(
      "设备端服务未响应",
    ),
    "onDeviceAiChecking": MessageLookupByLibrary.simpleMessage("正在检查本机模型是否可用…"),
    "onDeviceAiCheckingAndroid": MessageLookupByLibrary.simpleMessage(
      "正在等待 Android AICore 返回状态，最多等待 15 秒。此步骤仅检测可用性，不是在下载模型。",
    ),
    "onDeviceAiDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "模型下载失败，请检查网络和可用存储空间后重试。",
    ),
    "onDeviceAiDownloadModel": MessageLookupByLibrary.simpleMessage("下载模型"),
    "onDeviceAiDownloadProgress": m37,
    "onDeviceAiDownloadingModel": MessageLookupByLibrary.simpleMessage(
      "正在下载模型…",
    ),
    "onDeviceAiEnableAndroid": MessageLookupByLibrary.simpleMessage(
      "启用 Gemini Nano",
    ),
    "onDeviceAiEnableApple": MessageLookupByLibrary.simpleMessage(
      "启用 Apple Foundation Models",
    ),
    "onDeviceAiForegroundRequired": MessageLookupByLibrary.simpleMessage(
      "系统仅允许应用在前台使用模型，请保持本应用在前台后重试。",
    ),
    "onDeviceAiModelDownloadDescription": MessageLookupByLibrary.simpleMessage(
      "设备已报告支持此模型，但所需文件尚未下载完成。点击“下载模型”后由 Android AICore 下载，建议使用 Wi-Fi；下载完成后才能启用智能化。",
    ),
    "onDeviceAiModelDownloadTitle": MessageLookupByLibrary.simpleMessage(
      "下载设备端模型",
    ),
    "onDeviceAiNameAndroid": MessageLookupByLibrary.simpleMessage(
      "Gemini Nano",
    ),
    "onDeviceAiNameApple": MessageLookupByLibrary.simpleMessage(
      "Apple Foundation Models",
    ),
    "onDeviceAiOpenGooglePlay": MessageLookupByLibrary.simpleMessage(
      "前往 Google Play",
    ),
    "onDeviceAiProviderAndroid": MessageLookupByLibrary.simpleMessage(
      "Android 使用 Gemini Nano，由系统服务 AICore 运行。需要 Google 支持的真机及可用的模型；普通 Android 模拟器不在官方支持范围内，安装 Gemini 应用或 Google Play 并不代表支持此功能。",
    ),
    "onDeviceAiProviderApple": MessageLookupByLibrary.simpleMessage(
      "Apple 设备使用系统提供的设备端基础模型，需要兼容设备、启用 Apple 智能并完成模型准备。",
    ),
    "onDeviceAiReadyDescription": MessageLookupByLibrary.simpleMessage(
      "本机模型已就绪。启用后可在帖子中使用翻译及自定义文本处理场景。",
    ),
    "onDeviceAiRequestFailed": MessageLookupByLibrary.simpleMessage(
      "设备端模型暂时无法完成此请求，请稍后再试。",
    ),
    "onDeviceAiRequestTooLarge": MessageLookupByLibrary.simpleMessage(
      "这篇帖子过长，超出了设备端模型的处理范围。",
    ),
    "onDeviceAiRetry": MessageLookupByLibrary.simpleMessage("重新检查"),
    "onDeviceAiServiceBusy": MessageLookupByLibrary.simpleMessage(
      "系统模型正在忙碌，请稍后点击“重新检查”。",
    ),
    "onDeviceAiSetupRequired": MessageLookupByLibrary.simpleMessage("需要设置"),
    "onDeviceAiStatusDownloading": MessageLookupByLibrary.simpleMessage("正在下载"),
    "onDeviceAiStorageDescription": MessageLookupByLibrary.simpleMessage(
      "请先释放一些设备存储空间，再下载或使用设备端模型。",
    ),
    "onDeviceAiStorageTitle": MessageLookupByLibrary.simpleMessage("存储空间不足"),
    "onDeviceAiSupportedDevices": MessageLookupByLibrary.simpleMessage(
      "查看 Google 支持的设备 ↗",
    ),
    "onDeviceAiSystemUpdateDescription": MessageLookupByLibrary.simpleMessage(
      "当前 Android 或 Apple 系统版本过低，无法使用设备端模型。请更新系统后重试。",
    ),
    "onDeviceAiSystemUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "需要更新系统",
    ),
    "onDeviceAiTemporarilyUnavailableDescription":
        MessageLookupByLibrary.simpleMessage("系统智能服务仍在准备或暂时繁忙，请保持设备联网并稍后重试。"),
    "onDeviceAiTemporarilyUnavailableTitle":
        MessageLookupByLibrary.simpleMessage("暂时不可用"),
    "onlineHours": m38,
    "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("在线时间"),
    "onlyViewAuthor": MessageLookupByLibrary.simpleMessage("只看作者 / 查看全部"),
    "openFileInExternalAppActionText": MessageLookupByLibrary.simpleMessage(
      "打开",
    ),
    "openFileInExternalAppContent": MessageLookupByLibrary.simpleMessage(
      "您成功下载了文件，您想现在打开它吗？",
    ),
    "openGameInSteam": MessageLookupByLibrary.simpleMessage("在Steam中打开"),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
    "openSoftwareSubtitle": MessageLookupByLibrary.simpleMessage(
      "我们的软件以MIT开源协议服务",
    ),
    "openSoftwareTitle": MessageLookupByLibrary.simpleMessage("开源软件"),
    "openSourceLicence": MessageLookupByLibrary.simpleMessage("开源软件许可"),
    "openViaInternalBrowser": MessageLookupByLibrary.simpleMessage("在内置浏览器打开"),
    "or": MessageLookupByLibrary.simpleMessage("或者"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
      "链接使用的域名与此论坛不一致，其很有可能不是论坛所有的。谨防钓鱼、木马和诈骗。",
    ),
    "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage("你正要打开外链"),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "passwordIsEmpty": MessageLookupByLibrary.simpleMessage("密码为空"),
    "passwordRecoveryCreate": MessageLookupByLibrary.simpleMessage("创建新密码库"),
    "passwordRecoveryMessage": MessageLookupByLibrary.simpleMessage(
      "旧密码库无法打开或迁移。是否创建一个新的空密码库？之后需要重新输入并保存密码。旧的加密数据会保留，但不再自动使用。",
    ),
    "passwordRecoveryTitle": MessageLookupByLibrary.simpleMessage("无法读取已保存的密码"),
    "passwordSaveFailed": MessageLookupByLibrary.simpleMessage(
      "可以继续登录，但本次密码未能保存。",
    ),
    "pictureBedActive": MessageLookupByLibrary.simpleMessage("已启用"),
    "pictureBedAgreeToService": MessageLookupByLibrary.simpleMessage("我同意"),
    "pictureBedApiKeyEmpty": MessageLookupByLibrary.simpleMessage(
      "请先输入 API 密钥。",
    ),
    "pictureBedDisabled": MessageLookupByLibrary.simpleMessage("已禁用"),
    "pictureBedImgloc": MessageLookupByLibrary.simpleMessage("imgloc.com"),
    "pictureBedNotPrepared": MessageLookupByLibrary.simpleMessage("未就绪，轻触以继续"),
    "pictureBedServiceNote": MessageLookupByLibrary.simpleMessage(
      "上述所有服务并非由谈坛（我们，第一方）或者您浏览的论坛，而是由第三方提供。根据我们的使用协议，我们并不担保和授权任何第三方服务，使用我们的服务也并不会自动授权、默许和担保您使用这些第三方服务。因此，您需要在使用服务前，同意他们的使用协议、隐私政策以及其他协议。您同样应当定时查看这些协议以防止政策变更给您带来的不便。最后，有些服务并非在中国展开，您需要注意其在中国的可使用性、可靠性以及相关的法律适用性。",
    ),
    "pictureBedTermsSubtitle": MessageLookupByLibrary.simpleMessage(
      "请注意，此服务并非由我们提供。根据我们的服务条款，使用我们的服务并不代表您获得了第三方服务的授权，并且我们并不对第三方服务做出任何承诺或者担保。在使用第三方服务前，您需要同意他们的服务条款以及隐私政策。",
    ),
    "pictureBedTermsTitle": m39,
    "pictureBedTestAndSave": MessageLookupByLibrary.simpleMessage("测试并保存"),
    "pictureBedTestFailed": MessageLookupByLibrary.simpleMessage(
      "图床 API 测试失败。",
    ),
    "pictureBedTestPassedAndSaved": MessageLookupByLibrary.simpleMessage(
      "图床 API 测试通过，已保存。",
    ),
    "pictureBedTestingApi": MessageLookupByLibrary.simpleMessage(
      "正在测试图床 API...",
    ),
    "pictureBedTitle": MessageLookupByLibrary.simpleMessage("图床"),
    "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[图片]"),
    "policy": MessageLookupByLibrary.simpleMessage("条款"),
    "pollExpireAt": m40,
    "pollNotAllowed": MessageLookupByLibrary.simpleMessage(
      "目前您无法参与投票。(显示的投中的选项与真实结果不符合)",
    ),
    "pollTitle": MessageLookupByLibrary.simpleMessage("投票（目前我们只支持单选）"),
    "pollVoterNumber": m41,
    "post": MessageLookupByLibrary.simpleMessage("发帖"),
    "postAuthorLabel": MessageLookupByLibrary.simpleMessage("楼主"),
    "postNumber": MessageLookupByLibrary.simpleMessage("回帖数"),
    "postPosition": m42,
    "postThread": MessageLookupByLibrary.simpleMessage("发帖"),
    "preparingPage": MessageLookupByLibrary.simpleMessage("正在准备此界面。"),
    "preventAbuseUser": MessageLookupByLibrary.simpleMessage(
      "请勿使用此应用发表令人反感的内容或其他滥用行为",
    ),
    "preventAbuseUserDescription": MessageLookupByLibrary.simpleMessage(
      "我们对于令人反感的内容（包含并不限于咒骂内容（包含粗俗用语）、违禁药品、歧视性语言、针对人类的暴力行为、宣扬或美化恐怖主义或与性相关的脏话）和滥用行为都没有容忍。我们也强烈反对使用本应用发表任何涉政言论及以及做出相应的行为。该约束作为最终用户协议的一部分，您必须同意此约束后使用本应用。",
    ),
    "primaryColorPickerType": MessageLookupByLibrary.simpleMessage("主要色"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私政策"),
    "privacyProtectSubtitle": MessageLookupByLibrary.simpleMessage(
      "轻轻的来正如我轻轻的走，我们不会搜集任何有关您的信息",
    ),
    "privacyProtectTitle": MessageLookupByLibrary.simpleMessage("隐私安全"),
    "privateMessage": MessageLookupByLibrary.simpleMessage("私信"),
    "progressButtonLoginFailed": MessageLookupByLibrary.simpleMessage("登陆失败"),
    "progressButtonLoginSuccess": MessageLookupByLibrary.simpleMessage("登陆成功！"),
    "progressButtonLogining": MessageLookupByLibrary.simpleMessage("登陆中..."),
    "progressButtonReplyFailed": MessageLookupByLibrary.simpleMessage("回帖失败"),
    "progressButtonReplySending": MessageLookupByLibrary.simpleMessage("回帖中"),
    "progressButtonReplySuccess": MessageLookupByLibrary.simpleMessage("回帖成功"),
    "publicMessage": MessageLookupByLibrary.simpleMessage("公共消息"),
    "publishAt": MessageLookupByLibrary.simpleMessage(" 发帖于 "),
    "pullToRefresh": MessageLookupByLibrary.simpleMessage("拉动刷新"),
    "pushChannel": MessageLookupByLibrary.simpleMessage("推送渠道"),
    "pushChannelAPN": MessageLookupByLibrary.simpleMessage("Apple 推送通知服务"),
    "pushChannelAPNs": MessageLookupByLibrary.simpleMessage("Apple推送通知服务"),
    "pushChannelFCM": MessageLookupByLibrary.simpleMessage("Firebase 云消息传递"),
    "pushChannelFirebase": MessageLookupByLibrary.simpleMessage("Firebase"),
    "pushChannelHMS": MessageLookupByLibrary.simpleMessage("华为推送服务"),
    "pushChannelXMI": MessageLookupByLibrary.simpleMessage("小米推送服务"),
    "pushDevice": MessageLookupByLibrary.simpleMessage("设备信息"),
    "pushDeviceNotInterfaceWithService": MessageLookupByLibrary.simpleMessage(
      "其他服务依然是正常的",
    ),
    "pushDeviceNotInterfaceWithServiceDescription":
        MessageLookupByLibrary.simpleMessage(
          "别担心，其他服务依然是正常运行的，您可以关注我们的开发者博客以获得支持设备的最新进展。",
        ),
    "pushDeviceNotSupported": MessageLookupByLibrary.simpleMessage(
      "您的设备无法接收推送",
    ),
    "pushDeviceNotSupportedDescription": MessageLookupByLibrary.simpleMessage(
      "在您的设备无法找到GMS或者APNs服务或者无法连接到FCM服务器注册令牌。我们目前仅支持带有GMS服务的Android以及苹果设备。",
    ),
    "pushHelpPages": MessageLookupByLibrary.simpleMessage("推送服务帮助"),
    "pushInformation": MessageLookupByLibrary.simpleMessage(
      "下列信息将在同意后直接发送给论坛服务器",
    ),
    "pushLocale": MessageLookupByLibrary.simpleMessage("语言偏好"),
    "pushNotification": MessageLookupByLibrary.simpleMessage("通知推送服务"),
    "pushNotificationDescription": MessageLookupByLibrary.simpleMessage(
      "推送通知服务仅当对应的Discuz站点启用了dhpush插件并且通过验证后才能开启。",
    ),
    "pushNotificationEnable": MessageLookupByLibrary.simpleMessage("开启推送通知服务"),
    "pushNotificationOff": MessageLookupByLibrary.simpleMessage("已禁用"),
    "pushNotificationOn": MessageLookupByLibrary.simpleMessage("开启"),
    "pushNotificationPermissionNotAuthorized":
        MessageLookupByLibrary.simpleMessage("未获得通知授权，请检查您是否允许授予应用通知权限。"),
    "pushNotificationSubmittedContent": MessageLookupByLibrary.simpleMessage(
      "推送服务依赖Firebase以及APNs，需要您的设备型号、操作系统类别以及偏好渠道等信息。您需要同意我们的推送服务使用条款和隐私政策后使用本服务。",
    ),
    "pushPackageId": MessageLookupByLibrary.simpleMessage("应用包名"),
    "pushPrivacyPolicy": MessageLookupByLibrary.simpleMessage("推送服务隐私政策"),
    "pushServiceEnableDescription": MessageLookupByLibrary.simpleMessage(
      "您是否想要打开推送通知功能以接收实时消息？",
    ),
    "pushServiceLimitedInChinaMainlandSubtitle":
        MessageLookupByLibrary.simpleMessage(
          "FCM在国内使用可能面临不稳定的情况，其次各家国产手机厂商针对应用接受FCM拉起有各种奇奇怪怪的“优化”。为了及时接收消息，我们建议您允许应用自启动。",
        ),
    "pushServiceLimitedInChinaMainlandTitle":
        MessageLookupByLibrary.simpleMessage("FCM在中国大陆地区可能使用受限"),
    "pushServiceNotEnabled": MessageLookupByLibrary.simpleMessage(
      "请打开通知服务以允许频道推送",
    ),
    "pushServiceOff": MessageLookupByLibrary.simpleMessage("推送服务并未开启，请开启后再试试？"),
    "pushServiceOnDescription": MessageLookupByLibrary.simpleMessage(
      "您现在就可以接收来自已授权论坛的推送啦~",
    ),
    "pushServiceSiteNotSupport": m43,
    "pushTermsOfService": MessageLookupByLibrary.simpleMessage("推送服务条款"),
    "pushThreadTitle": MessageLookupByLibrary.simpleMessage("发帖"),
    "pushThreadTitleHint": MessageLookupByLibrary.simpleMessage("帖子标题"),
    "pushToLoad": MessageLookupByLibrary.simpleMessage("拉动加载"),
    "pushToken": MessageLookupByLibrary.simpleMessage("Firebase令牌"),
    "recentNote": MessageLookupByLibrary.simpleMessage("最近的帖子"),
    "recordHistoryOffDescription": MessageLookupByLibrary.simpleMessage(
      "应用不会记录您的浏览历史",
    ),
    "recordHistoryOnDescription": MessageLookupByLibrary.simpleMessage(
      "应用将会记录您的浏览历史",
    ),
    "recordHistoryTitle": MessageLookupByLibrary.simpleMessage("历史记录"),
    "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
    "refreshFinish": MessageLookupByLibrary.simpleMessage("刷新完成"),
    "refreshed": MessageLookupByLibrary.simpleMessage("刷新完成"),
    "refreshing": MessageLookupByLibrary.simpleMessage("正在刷新..."),
    "registerAccountTime": MessageLookupByLibrary.simpleMessage("注册时间"),
    "registerPushTokenMessage": MessageLookupByLibrary.simpleMessage(
      "你可以现在开始注册你的设备到论坛中。此论坛需要满足推送服务要求。",
    ),
    "registerPushTokenTitle": MessageLookupByLibrary.simpleMessage("注册你的设备到论坛"),
    "releaseToLoad": MessageLookupByLibrary.simpleMessage("释放加载"),
    "releaseToRefresh": MessageLookupByLibrary.simpleMessage("释放刷新"),
    "relogin": MessageLookupByLibrary.simpleMessage("重新登陆"),
    "rememberPasswordInAppDetail": MessageLookupByLibrary.simpleMessage("了解详情"),
    "rememeberPasswordInApp": MessageLookupByLibrary.simpleMessage(
      "将登陆凭证在此设备中存储。",
    ),
    "replyPost": MessageLookupByLibrary.simpleMessage("回复"),
    "replyPostTrimMessage": m44,
    "reportContentTitle": m45,
    "reportDiscuzApiInformationToAnalytics":
        MessageLookupByLibrary.simpleMessage("向我们报告论坛API可用性"),
    "reportDiscuzApiInformationToAnalyticsDescription":
        MessageLookupByLibrary.simpleMessage(
          "我们会针对最常见的TOP10论坛进行针对优化，需要您的帮助来告诉我们论坛大致的分布。请放心，您的报告将由谷歌统计收集，且将会是匿名的，并不会与任何您的信息挂钩。我们非常感谢您的报告以帮助我们做得更好。",
        ),
    "reportDiscuzApiInformationToAnalyticsTitle":
        MessageLookupByLibrary.simpleMessage("帮助我们优化应用"),
    "reportIssue": MessageLookupByLibrary.simpleMessage("报告问题 · GitHub ↗"),
    "reportIssueHint": MessageLookupByLibrary.simpleMessage(
      "如果此问题持续出现，可前往 GitHub 提交 issue，说明操作步骤和遇到的现象。",
    ),
    "reportIssueOpenFailed": MessageLookupByLibrary.simpleMessage(
      "无法打开浏览器，请手动访问 https://github.com/kidozh/discuz_flutter/issues",
    ),
    "reportIssueSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "报告问题 · GitHub",
    ),
    "reportOtherReasonHint": MessageLookupByLibrary.simpleMessage("提供举报原因"),
    "reportSuccessfully": m46,
    "reportThreadTooltip": MessageLookupByLibrary.simpleMessage("举报不当内容"),
    "residentPlace": MessageLookupByLibrary.simpleMessage("居住地"),
    "responseStatusError404": MessageLookupByLibrary.simpleMessage(
      "404 - 请求内容已经不存在",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "revisedPost": MessageLookupByLibrary.simpleMessage("帖子审核后再编辑，以防重复加分。"),
    "sample": MessageLookupByLibrary.simpleMessage("示例"),
    "saveImageSuccessfully": MessageLookupByLibrary.simpleMessage(
      "成功保存图片至此设备中.",
    ),
    "savePictureToDevice": MessageLookupByLibrary.simpleMessage("保存图片至此设备"),
    "savedPasswordsUnavailable": MessageLookupByLibrary.simpleMessage(
      "暂时无法读取已保存的密码，原数据已保留。你可以手动输入账号和密码登录。",
    ),
    "savedSmileyTabTitle": MessageLookupByLibrary.simpleMessage("最近使用"),
    "second": MessageLookupByLibrary.simpleMessage("秒"),
    "securityChallengeTitle": MessageLookupByLibrary.simpleMessage("完成安全验证"),
    "securityTitle": MessageLookupByLibrary.simpleMessage("安全"),
    "seeAllReplies": MessageLookupByLibrary.simpleMessage("查看所有"),
    "selectColorAndShadeTitle": MessageLookupByLibrary.simpleMessage(
      "选择色彩以及光影",
    ),
    "selectColorShadeTitle": MessageLookupByLibrary.simpleMessage("选择色彩光影"),
    "selectColorTitle": MessageLookupByLibrary.simpleMessage("选择颜色"),
    "selectDiscuzIconTooltip": MessageLookupByLibrary.simpleMessage("选择论坛"),
    "selectUserNull": MessageLookupByLibrary.simpleMessage("未选中一个用户"),
    "send": MessageLookupByLibrary.simpleMessage("发送"),
    "sendImageWithVerificationNotice": MessageLookupByLibrary.simpleMessage(
      "需要手动填写验证码，填写完成后，最右侧发送按钮完成发送。",
    ),
    "sendReply": MessageLookupByLibrary.simpleMessage("回帖"),
    "sendReplyHint": MessageLookupByLibrary.simpleMessage("说些什么吧。"),
    "settingTitle": MessageLookupByLibrary.simpleMessage("设置"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "share": MessageLookupByLibrary.simpleMessage("分享"),
    "shortcut": MessageLookupByLibrary.simpleMessage("快速跳转"),
    "shortcutFidHint": MessageLookupByLibrary.simpleMessage("输入板块编号 (fid)"),
    "shortcutGo": MessageLookupByLibrary.simpleMessage("跳转"),
    "shortcutTidHint": MessageLookupByLibrary.simpleMessage("输入帖子编号 (tid)"),
    "shortcutUidHint": MessageLookupByLibrary.simpleMessage("输入用户编号 (uid)"),
    "showKeyboardTooltip": MessageLookupByLibrary.simpleMessage("切换到键盘"),
    "signInSuccessTitle": m47,
    "signInTitle": m48,
    "signInViaBrowser": MessageLookupByLibrary.simpleMessage("使用网页登录"),
    "signUp": MessageLookupByLibrary.simpleMessage("注册"),
    "signatureHint": MessageLookupByLibrary.simpleMessage("在此键入签名"),
    "signaturePreview": MessageLookupByLibrary.simpleMessage("预览"),
    "signatureStyle": MessageLookupByLibrary.simpleMessage("发帖签名样式"),
    "signatureSupportUS": MessageLookupByLibrary.simpleMessage("支持我们"),
    "signatureWithDisFly": MessageLookupByLibrary.simpleMessage("使用应用名称"),
    "signatureWithDisFlyDescription": MessageLookupByLibrary.simpleMessage(
      "您可以使用带有本应用后缀的小尾巴发帖支持本应用，您可以随时在设置中更换发帖小尾巴。",
    ),
    "siteDoesNotSupportPushService": MessageLookupByLibrary.simpleMessage(
      "该论坛未开启推送插件。",
    ),
    "sitePage": MessageLookupByLibrary.simpleMessage("主页"),
    "smileyLabel": m49,
    "sortThreadInAscendOrder": MessageLookupByLibrary.simpleMessage("从旧到新排列"),
    "sortThreadInDescendOrder": MessageLookupByLibrary.simpleMessage("从新到旧排列"),
    "spam": MessageLookupByLibrary.simpleMessage("恶意灌水"),
    "steamComingSoon": MessageLookupByLibrary.simpleMessage("即将推出"),
    "steamParentApp": m50,
    "steamPriceUnavailable": MessageLookupByLibrary.simpleMessage(
      "价格请查看 Steam 商店",
    ),
    "steamTypeDemo": MessageLookupByLibrary.simpleMessage("试玩版"),
    "steamTypeDlc": MessageLookupByLibrary.simpleMessage("追加内容（DLC）"),
    "steamTypeGame": MessageLookupByLibrary.simpleMessage("游戏"),
    "steamTypeMusic": MessageLookupByLibrary.simpleMessage("原声音乐"),
    "steamTypeOther": MessageLookupByLibrary.simpleMessage("Steam 内容"),
    "steamTypeSoftware": MessageLookupByLibrary.simpleMessage("软件"),
    "steamTypeVideo": MessageLookupByLibrary.simpleMessage("视频"),
    "stickyThread": MessageLookupByLibrary.simpleMessage("置顶帖"),
    "style": MessageLookupByLibrary.simpleMessage("样式"),
    "submitPoll": m51,
    "subscribe": MessageLookupByLibrary.simpleMessage("订阅"),
    "subscribeChannel": MessageLookupByLibrary.simpleMessage("订阅推送"),
    "subscribeChannelForMore": MessageLookupByLibrary.simpleMessage(
      "订阅此论坛频道获得实时的最新消息",
    ),
    "subscriptionSuccess": MessageLookupByLibrary.simpleMessage("成功同步至推送服务器"),
    "successfullyDeleteViewHistoryContent": m52,
    "successfullyDownloadFiles": m53,
    "syncSuccessfullyWithServer": m54,
    "systemStyleDescription": MessageLookupByLibrary.simpleMessage(
      "iOS 26 及以上使用 Liquid Glass，较早的 iOS 使用 Cupertino，其他平台使用质感设计。",
    ),
    "takeAPicture": MessageLookupByLibrary.simpleMessage("照相"),
    "tapToWipeAndRelogin": MessageLookupByLibrary.simpleMessage(
      "点击以移除此用户并重新登陆",
    ),
    "termsOfService": MessageLookupByLibrary.simpleMessage("使用条款"),
    "termsOfUseDescription": MessageLookupByLibrary.simpleMessage(
      "你需要同意我们的使用条款后使用本应用。",
    ),
    "testVersion": MessageLookupByLibrary.simpleMessage("公测版本"),
    "testVersionDescription": MessageLookupByLibrary.simpleMessage(
      "此版本具有最新的开发进展，同时也伴有一定的错误。当您使用时，请做好数据备份，以防数据丢失。",
    ),
    "testVersionNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "欢迎参与测试版本",
    ),
    "textFieldShouldNotBeEmpty": MessageLookupByLibrary.simpleMessage("此项不应为空"),
    "thread": MessageLookupByLibrary.simpleMessage("帖子"),
    "threadIsClosed": MessageLookupByLibrary.simpleMessage("此贴已关闭发帖。"),
    "threadReadAccess": m55,
    "threadReply": m56,
    "threadView": m57,
    "trashAd": MessageLookupByLibrary.simpleMessage("垃圾广告"),
    "trustHostActionText": MessageLookupByLibrary.simpleMessage("信任此域名"),
    "trustHostTitle": MessageLookupByLibrary.simpleMessage("主机域名白名单"),
    "typeSetting": MessageLookupByLibrary.simpleMessage("文本排版"),
    "typographyMaterial2014": MessageLookupByLibrary.simpleMessage("2014版质感设计"),
    "typographyMaterial2018": MessageLookupByLibrary.simpleMessage("2018版质感设计"),
    "typographyMaterial2021": MessageLookupByLibrary.simpleMessage("2021版质感设计"),
    "typographySystem": MessageLookupByLibrary.simpleMessage("默认排版"),
    "unableToAuthenticate": MessageLookupByLibrary.simpleMessage(
      "系统未能验证您的身份，自动填充失败。",
    ),
    "unableToVerifyAuthStatus": MessageLookupByLibrary.simpleMessage(
      "无法验证登陆状态",
    ),
    "unblockContent": MessageLookupByLibrary.simpleMessage("恢复显示内容"),
    "unblockUser": MessageLookupByLibrary.simpleMessage("解除屏蔽"),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unfavoriteIconTooltip": MessageLookupByLibrary.simpleMessage("取消收藏板块"),
    "unfavoriteThreadTooltip": MessageLookupByLibrary.simpleMessage("取消收藏帖子"),
    "updateAt": MessageLookupByLibrary.simpleMessage("更新于 %T"),
    "upgrade_notification_subtitle": MessageLookupByLibrary.simpleMessage(
      "由于使用人数过少，我们已经停用了推送通知功能。",
    ),
    "upgrade_notification_title": MessageLookupByLibrary.simpleMessage("服务终止"),
    "uploadCompressedImageToServer": MessageLookupByLibrary.simpleMessage(
      "发送压缩图片",
    ),
    "uploadImageError1": MessageLookupByLibrary.simpleMessage("不支持此类扩展名."),
    "uploadImageError10": MessageLookupByLibrary.simpleMessage("非法操作"),
    "uploadImageError11": MessageLookupByLibrary.simpleMessage(
      "今日您已无法上传那么大的附件",
    ),
    "uploadImageError2": MessageLookupByLibrary.simpleMessage(
      "服务器限制无法上传那么大的附件",
    ),
    "uploadImageError3": MessageLookupByLibrary.simpleMessage(
      "用户组限制无法上传那么大的附件",
    ),
    "uploadImageError4": MessageLookupByLibrary.simpleMessage("不支持此类扩展名"),
    "uploadImageError5": MessageLookupByLibrary.simpleMessage(
      "文件类型限制无法上传那么大的附件",
    ),
    "uploadImageError6": MessageLookupByLibrary.simpleMessage("今日您已无法上传更多的附件"),
    "uploadImageError7": MessageLookupByLibrary.simpleMessage("请选择图片文件"),
    "uploadImageError8": MessageLookupByLibrary.simpleMessage("附件文件无法保存"),
    "uploadImageError9": MessageLookupByLibrary.simpleMessage("没有合法的文件被上传"),
    "uploadImageErrorNegative1": MessageLookupByLibrary.simpleMessage(
      "内部服务器错误",
    ),
    "uploadImageFailed": MessageLookupByLibrary.simpleMessage("上传图片失败"),
    "uploadImageSuccessfully": MessageLookupByLibrary.simpleMessage(
      "文件已经成功上传至服务器",
    ),
    "uploadImageToServerDialogTitle": MessageLookupByLibrary.simpleMessage(
      "向论坛上传图片",
    ),
    "uploadImageUnknownError": MessageLookupByLibrary.simpleMessage(
      "上传文件时遇到了一个未知错误。",
    ),
    "uploadRawImageToServer": MessageLookupByLibrary.simpleMessage("发送原始图片"),
    "uploadTokenSuccessful": MessageLookupByLibrary.simpleMessage(
      "您的设备令牌已经成功传入到论坛中。",
    ),
    "uploadTokenUnsuccessful": MessageLookupByLibrary.simpleMessage(
      "无法添加您的设备到论坛推送系统中。",
    ),
    "uploadingImageToServer": MessageLookupByLibrary.simpleMessage(
      "向服务器传输数据中。。。",
    ),
    "useGoogleAnalyticsContent": MessageLookupByLibrary.simpleMessage(
      "本应用使用谷歌统计收集所有必要信息以减少崩溃次数、完成推送服务以及优化应用。",
    ),
    "useGoogleAnalyticsTitle": MessageLookupByLibrary.simpleMessage("谷歌统计已开启"),
    "useMaterial3NoSubtitle": MessageLookupByLibrary.simpleMessage(
      "应用会使用 Material 2 的外观。",
    ),
    "useMaterial3Title": MessageLookupByLibrary.simpleMessage("使用Material 3属性"),
    "useMaterial3YesSubtitle": MessageLookupByLibrary.simpleMessage(
      "迁移到 Material 3 的组件将使用 Material 3 的新颜色、排版和其他功能。",
    ),
    "useThinFont": MessageLookupByLibrary.simpleMessage("细体文字"),
    "userCredit": MessageLookupByLibrary.simpleMessage("积分"),
    "userExpiredSubtitle": MessageLookupByLibrary.simpleMessage(
      "当前用户授权已过期，你需要重新登录以重新激活此用户。",
    ),
    "userExpiredTitle": m58,
    "userIdTitle": m59,
    "userPost": MessageLookupByLibrary.simpleMessage("回复"),
    "userProfile": MessageLookupByLibrary.simpleMessage("用户中心"),
    "userProfileTitle": MessageLookupByLibrary.simpleMessage("用户信息"),
    "userThread": MessageLookupByLibrary.simpleMessage("发帖"),
    "usernameIsEmpty": MessageLookupByLibrary.simpleMessage("用户名为空"),
    "viewAuthorInfo": MessageLookupByLibrary.simpleMessage("查看用户详情"),
    "viewHistory": MessageLookupByLibrary.simpleMessage("浏览历史"),
    "viewPicture": MessageLookupByLibrary.simpleMessage("预览图片"),
    "viewPrivacyPolicy": MessageLookupByLibrary.simpleMessage("查看隐私政策"),
    "viewPushServiceHomePage": MessageLookupByLibrary.simpleMessage(
      "关于推送服务 ↗️",
    ),
    "viewThreadTitle": MessageLookupByLibrary.simpleMessage("查看帖子"),
    "viewThreadTwoPaneText": MessageLookupByLibrary.simpleMessage(
      "点击左侧的帖子以查看内容。",
    ),
    "viewUserInfo": m60,
    "warnedPost": MessageLookupByLibrary.simpleMessage("此贴被警告。"),
    "watchPictureInFullScreen": MessageLookupByLibrary.simpleMessage("查看大图"),
    "websiteNotLogined": MessageLookupByLibrary.simpleMessage(
      "在网页中没有完成登录，请登陆后点击右上方登录按钮完成录入。",
    ),
    "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
      "谈坛是支持Discuz X论坛的第三方客户端，欢迎使用我们的服务。",
    ),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("你好"),
    "welcomeVersionTitle": m61,
    "wheelColorPickerType": MessageLookupByLibrary.simpleMessage("轮抽选色"),
    "windowsDeviceName": m62,
    "workProcedure": MessageLookupByLibrary.simpleMessage("推送服务是如何工作的？"),
    "writeStorageDenied": MessageLookupByLibrary.simpleMessage("无法获得写入权限。"),
  };
}
