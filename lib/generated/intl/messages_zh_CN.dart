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

  static String m1(index) => "上传文件 No. ${index}";

  static String m2(version, number) => "应用版本v${version}，序列${number}";

  static String m3(username) => "此内容由一个屏蔽用户${username}发送";

  static String m4(day) => "${day}天前";

  static String m5(day) => "${day}天后";

  static String m6(account) => "成功移除账号 ${account}。";

  static String m7(account) => "成功删除论坛 ${account}。";

  static String m8(key, content) => "${content}（${key}）";

  static String m9(filename) => "后台下载文件 ${filename} 中。";

  static String m10(size) => "${size}逻辑像素";

  static String m11(size) => "${size}倍";

  static String m12(device) => "消息由${device}发出。";

  static String m13(readAccess, star) => "阅读权限： ${readAccess}， 等级： ${star}";

  static String m14(hour) => "${hour}小时前";

  static String m15(hour) => "${hour}小时后";

  static String m16(uri) => "无法打开此链接 : ${uri}.";

  static String m17(name) => "${name}的Linux电脑";

  static String m18(name) => "${name}的MacOS设备";

  static String m19(min) => "${min}分钟前";

  static String m20(min) => "${min}分钟后";

  static String m21(hour) => "${hour}小时";

  static String m22(time) => "该投票将于${time}过期.";

  static String m23(people) => "共有${people}人已投票.";

  static String m24(pos) => "第${pos}层";

  static String m25(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} 发表于 ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m26(name) => "举报${name}的内容";

  static String m27(discuzName) => "成功向${discuzName}发送了举报信息，请等待管理员回应。";

  static String m28(username, discuzName) =>
      "用户 ${username} 已成功登录到 ${discuzName}。";

  static String m29(discuzName) => "登录至 ${discuzName}";

  static String m30(index) => "表情 ${index}";

  static String m31(checked, allowed) => "投票 (${checked} / ${allowed})";

  static String m32(title) => "成功删除历史记录 ${title}.";

  static String m33(filename) => "成功下载文件： ${filename}。";

  static String m34(num) => "已同步所有${num}个收藏的帖子";

  static String m35(num) => "阅读权限 ${num}";

  static String m36(username) => "用户 ${username} 已失效";

  static String m37(uid) => "用户编号： ${uid}";

  static String m38(user) => "查看${user}详情";

  static String m39(name) => "${name}的Windows电脑";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("账号"),
        "addAPhoto": MessageLookupByLibrary.simpleMessage("照片"),
        "addDiscuzSuccessfully": m0,
        "addDiscuzTitle": MessageLookupByLibrary.simpleMessage("添加Discuz! 论坛"),
        "addNewDiscuz": MessageLookupByLibrary.simpleMessage("添加一个论坛"),
        "anonymous": MessageLookupByLibrary.simpleMessage("未知"),
        "appName": MessageLookupByLibrary.simpleMessage("谈坛"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("运行平台样式偏好"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage("你可以选择对应平台下应用的显示样式"),
        "attachFile": m1,
        "authorizedSite": MessageLookupByLibrary.simpleMessage("已验证站点"),
        "basicUse": MessageLookupByLibrary.simpleMessage("基本使用"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("EasyRefresh的基本使用"),
        "bio": MessageLookupByLibrary.simpleMessage("签名"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("出生地"),
        "blockUser": MessageLookupByLibrary.simpleMessage("屏蔽此用户"),
        "blockedPost": MessageLookupByLibrary.simpleMessage("此贴被屏蔽。"),
        "blockedUserList": MessageLookupByLibrary.simpleMessage("屏蔽用户列表"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob小黄人"),
        "bobMinionDescribe": MessageLookupByLibrary.simpleMessage("可爱的小黄人"),
        "brightnessDark": MessageLookupByLibrary.simpleMessage("深色"),
        "brightnessLight": MessageLookupByLibrary.simpleMessage("浅色"),
        "brokenCountDown": MessageLookupByLibrary.simpleMessage("无效的倒数指令"),
        "bugTestSubtitle": MessageLookupByLibrary.simpleMessage(
            "你可以通过邮箱kidozh@gmail.com向我们报告错误，我们非常感谢您的报告"),
        "bugTestTitle": MessageLookupByLibrary.simpleMessage("可能包含一些BUG"),
        "buildDescription":
            MessageLookupByLibrary.simpleMessage("由flutter驱动, 能够兼容多种平台。"),
        "buildVersionDescription": m2,
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("取消"),
        "captchaRequired": MessageLookupByLibrary.simpleMessage("需要验证码"),
        "chatMessage": MessageLookupByLibrary.simpleMessage("信息"),
        "checkUserLoginStatus":
            MessageLookupByLibrary.simpleMessage("正在检查用户登录状态。。。"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("选择一个论坛"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("主题颜色"),
        "clearAllViewHistories": MessageLookupByLibrary.simpleMessage("清除历史记录"),
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
        "completeLoad": MessageLookupByLibrary.simpleMessage("完成加载"),
        "completeRefresh": MessageLookupByLibrary.simpleMessage("完成刷新"),
        "connectServerWhenAdding":
            MessageLookupByLibrary.simpleMessage("正在连接论坛地址以验证兼容性。"),
        "contentPostByBlockUserTitle": m3,
        "continueAdding": MessageLookupByLibrary.simpleMessage("继续"),
        "continueToDo": MessageLookupByLibrary.simpleMessage("继续"),
        "continueToTest": MessageLookupByLibrary.simpleMessage("开始测试此版本"),
        "countDownEnd": MessageLookupByLibrary.simpleMessage("倒计时已过期。"),
        "countDownTimeZoneNotify": MessageLookupByLibrary.simpleMessage(
            "此倒计时很有可能是北京时间，如果您不处于东八区，那么此倒计时很有可能不准确"),
        "credit": MessageLookupByLibrary.simpleMessage("积分"),
        "customSignature": MessageLookupByLibrary.simpleMessage("自定义"),
        "customStatusTitle": MessageLookupByLibrary.simpleMessage("自定义头衔"),
        "dashboard": MessageLookupByLibrary.simpleMessage("看板"),
        "dataBackupInTestSubtitle": MessageLookupByLibrary.simpleMessage(
            "版本变更有可能会引发数据的丢失，因此请务必做好数据备份工作。"),
        "dataBackupInTestTitle": MessageLookupByLibrary.simpleMessage("数据备份"),
        "day": MessageLookupByLibrary.simpleMessage("天"),
        "dayAgo": m4,
        "dayLater": m5,
        "deleteAccount": MessageLookupByLibrary.simpleMessage("删除"),
        "deleteAccountSuccessfully": m6,
        "deleteDiscuzSuccessfully": m7,
        "deleteViewHistoryWarnContent":
            MessageLookupByLibrary.simpleMessage("清除历史记录是不可恢复的，确认要继续？"),
        "deviceNameSignature": MessageLookupByLibrary.simpleMessage("使用设备名称"),
        "disableFontCustomization":
            MessageLookupByLibrary.simpleMessage("停用自定义字体"),
        "disableFontCustomizationTitle":
            MessageLookupByLibrary.simpleMessage("不再解析自定义字体的颜色，大小等信息"),
        "discuzOperationMessage": m8,
        "discuzServerAddress": MessageLookupByLibrary.simpleMessage("论坛地址"),
        "discuzServerAddressHelperText":
            MessageLookupByLibrary.simpleMessage("其通常就是论坛的地址"),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("例如： https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("显示"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("下载附件"),
        "downloadingFiles": m9,
        "duplicatedPost": MessageLookupByLibrary.simpleMessage("重复发帖"),
        "easyRefreshClassicFooterArmedText":
            MessageLookupByLibrary.simpleMessage("释放开始"),
        "easyRefreshClassicFooterDragText":
            MessageLookupByLibrary.simpleMessage("上拉加载"),
        "easyRefreshClassicFooterFailedText":
            MessageLookupByLibrary.simpleMessage("加载失败"),
        "easyRefreshClassicFooterMessageText":
            MessageLookupByLibrary.simpleMessage("最后更新于 %T"),
        "easyRefreshClassicFooterNoMoreText":
            MessageLookupByLibrary.simpleMessage("没有更多的内容了"),
        "easyRefreshClassicFooterProcessedText":
            MessageLookupByLibrary.simpleMessage("加载成功"),
        "easyRefreshClassicFooterProcessingText":
            MessageLookupByLibrary.simpleMessage("加载中..."),
        "easyRefreshClassicFooterReadyText":
            MessageLookupByLibrary.simpleMessage("加载中..."),
        "easyRefreshClassicHeaderArmedText":
            MessageLookupByLibrary.simpleMessage("释放开始"),
        "easyRefreshClassicHeaderDragText":
            MessageLookupByLibrary.simpleMessage("下拉刷新"),
        "easyRefreshClassicHeaderFailedText":
            MessageLookupByLibrary.simpleMessage("访问失败"),
        "easyRefreshClassicHeaderMessageText":
            MessageLookupByLibrary.simpleMessage("最后更新于 %T"),
        "easyRefreshClassicHeaderNoMoreText":
            MessageLookupByLibrary.simpleMessage("没有更多内容了"),
        "easyRefreshClassicHeaderProcessedText":
            MessageLookupByLibrary.simpleMessage("成功加载"),
        "easyRefreshClassicHeaderProcessingText":
            MessageLookupByLibrary.simpleMessage("刷新中..."),
        "easyRefreshClassicHeaderReadyText":
            MessageLookupByLibrary.simpleMessage("刷新中..."),
        "editedPost": MessageLookupByLibrary.simpleMessage("已编辑"),
        "emptyListDescription": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
        "emptyScreenTitle": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
        "error": MessageLookupByLibrary.simpleMessage("出错了"),
        "favoriteForum": MessageLookupByLibrary.simpleMessage("收藏的板块"),
        "favoriteThread": MessageLookupByLibrary.simpleMessage("收藏的帖子"),
        "favorites": MessageLookupByLibrary.simpleMessage("收藏"),
        "finishLoginInWeb": MessageLookupByLibrary.simpleMessage("完成登录"),
        "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "fontSizeInParagraph": MessageLookupByLibrary.simpleMessage("正文字体大小"),
        "fontSizeInParagraphUnit": m10,
        "fontSizeScaleParameter":
            MessageLookupByLibrary.simpleMessage("文本缩放比例"),
        "fontSizeScaleParameterUnit": m11,
        "forgetPassword": MessageLookupByLibrary.simpleMessage("忘记密码?"),
        "forumDisplayTitle": MessageLookupByLibrary.simpleMessage("显示板块"),
        "forumFilterSortByHeat": MessageLookupByLibrary.simpleMessage("最火人气"),
        "forumFilterSortByLastPost":
            MessageLookupByLibrary.simpleMessage("最新回复"),
        "forumFilterSortByNewPost":
            MessageLookupByLibrary.simpleMessage("最新发布"),
        "forumFilterSortByTitle": MessageLookupByLibrary.simpleMessage("排序方法"),
        "forumFilterSortByView": MessageLookupByLibrary.simpleMessage("最多查看"),
        "forumFilterSpecialTypeActivity":
            MessageLookupByLibrary.simpleMessage("活动"),
        "forumFilterSpecialTypeDebate":
            MessageLookupByLibrary.simpleMessage("辩论"),
        "forumFilterSpecialTypePoll":
            MessageLookupByLibrary.simpleMessage("投票"),
        "forumFilterSpecialTypeTitle":
            MessageLookupByLibrary.simpleMessage("功能类型"),
        "forumFilterStatusAll": MessageLookupByLibrary.simpleMessage("所有"),
        "forumFilterStatusDigest": MessageLookupByLibrary.simpleMessage("精华帖"),
        "forumFilterStatusHot": MessageLookupByLibrary.simpleMessage("热门贴"),
        "forumFilterStatusTitle": MessageLookupByLibrary.simpleMessage("主题状态"),
        "forumFilterTimeThisMonth": MessageLookupByLibrary.simpleMessage("这个月"),
        "forumFilterTimeThisQuarter":
            MessageLookupByLibrary.simpleMessage("本季度"),
        "forumFilterTimeThisWeek": MessageLookupByLibrary.simpleMessage("这周"),
        "forumFilterTimeThisYear": MessageLookupByLibrary.simpleMessage("今年"),
        "forumFilterTimeTitle": MessageLookupByLibrary.simpleMessage("时间过滤"),
        "forumFilterTimeToday": MessageLookupByLibrary.simpleMessage("今天"),
        "forumFilterTypeIdTitle": MessageLookupByLibrary.simpleMessage("主题分类"),
        "forumInformation": MessageLookupByLibrary.simpleMessage("板块信息"),
        "forumSortPosts": MessageLookupByLibrary.simpleMessage("过滤排序帖子"),
        "friendNumber": MessageLookupByLibrary.simpleMessage("好友数"),
        "fromDeviceSignature": m12,
        "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
        "googleAdSubTitle":
            MessageLookupByLibrary.simpleMessage("由Google提供的广告"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("广告"),
        "groupInfoDescription": m13,
        "habit": MessageLookupByLibrary.simpleMessage("爱好"),
        "homepage": MessageLookupByLibrary.simpleMessage("个人主页"),
        "hotThread": MessageLookupByLibrary.simpleMessage("最新热门"),
        "hour": MessageLookupByLibrary.simpleMessage("时"),
        "hourAgo": m14,
        "hourLater": m15,
        "httpBrowseWarn": MessageLookupByLibrary.simpleMessage("不安全的HTTP协议"),
        "iframeUrlNull": MessageLookupByLibrary.simpleMessage("无法解析嵌入视图的来源。"),
        "illegalContent": MessageLookupByLibrary.simpleMessage("违法内容"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage("某些功能可能不可用"),
        "incognitoTitle": MessageLookupByLibrary.simpleMessage("匿名模式"),
        "incorrectDiscuzAddress":
            MessageLookupByLibrary.simpleMessage("无效的论坛地址."),
        "index": MessageLookupByLibrary.simpleMessage("索引"),
        "insertBoldText": MessageLookupByLibrary.simpleMessage("粗体文字"),
        "insertItalicText": MessageLookupByLibrary.simpleMessage("斜体文字"),
        "insertQuoteText": MessageLookupByLibrary.simpleMessage("引用文字"),
        "insertSignatureAtTheEndTitle":
            MessageLookupByLibrary.simpleMessage("启用结尾签名"),
        "interfaceBrightness": MessageLookupByLibrary.simpleMessage("显示模式"),
        "invalidCookie": MessageLookupByLibrary.simpleMessage(
            "服务器的响应中包含一个或多个含有错误字符的Cookie,无法解析Cookie,无法登录."),
        "ios": MessageLookupByLibrary.simpleMessage("iOS"),
        "iosDarkModeDisabledText": MessageLookupByLibrary.simpleMessage(
            "处于iOS运行平台偏好下，您的颜色模式将会跟随系统，不可以手动调节。"),
        "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
        "largeRichText": MessageLookupByLibrary.simpleMessage(
            "欢迎使用DiscuzHub\n感谢您使用我们的产品和服务（下称“服务”）。\n您使用我们的服务即表示您已同意本条款。请<b>仔细</b>阅读。<br/>使用我们的服务并不让您拥有我们的服务或您所访问的内容的任何知识产权。除非您获得相关内容所有者的许可或通过其他方式获得法律的许可，否则您不得使用服务中的任何内容。本条款并未授予您使用我们服务中所用的任何商标或标志的权利。请勿删除、隐藏或更改我们服务上显示的或随服务一同显示的任何法律声明。\n请勿滥用我们的服务。您仅能在法律（包括适用的出口和再出口管制法律和法规）允许的范围内使用我们的服务。如果您不遵守我们的条款或政策，或者我们在调查可疑的不当行为，我们可以暂停或停止向您提供服务。\n"),
        "largeRichTextDescription":
            MessageLookupByLibrary.simpleMessage("摘取我们的使用政策"),
        "lastActivityTime": MessageLookupByLibrary.simpleMessage("上次活动于"),
        "lastPostTime": MessageLookupByLibrary.simpleMessage("上次发帖时间"),
        "lastVisitTime": MessageLookupByLibrary.simpleMessage("上次访问时间"),
        "lawInformation": MessageLookupByLibrary.simpleMessage("法律信息"),
        "legalInformation": MessageLookupByLibrary.simpleMessage("法律信息"),
        "linkUnableToOpen": m16,
        "linuxDeviceName": m17,
        "loadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
        "loadFinish": MessageLookupByLibrary.simpleMessage("加载完成"),
        "loadMore": MessageLookupByLibrary.simpleMessage("加载"),
        "loaded": MessageLookupByLibrary.simpleMessage("加载完成"),
        "loading": MessageLookupByLibrary.simpleMessage("正在加载..."),
        "loadingCaptchaInformation":
            MessageLookupByLibrary.simpleMessage("正在加载验证码信息。。。"),
        "loadingForumInformation":
            MessageLookupByLibrary.simpleMessage("正在加载发表帖子的设置。。。"),
        "loginByWebHttpWarn": MessageLookupByLibrary.simpleMessage(
            "您正在使用不安全的HTTP连接，此界面有可能被第三方所劫持。您在此界面输入的信息有可能泄露。强烈建议您使用HTTPS协议访问此界面。"),
        "loginByWebMessage": MessageLookupByLibrary.simpleMessage(
            "请在网页中完成登录，当您在网页中完成了登录过程后，请轻触右上方的完成登录按钮完成账号录入操作。有时存在延迟情况，可能需要点击两次才能录入账号。"),
        "loginByWebNotSupported":
            MessageLookupByLibrary.simpleMessage("当前系统并不支持Webview登录"),
        "loginByWebTitle": MessageLookupByLibrary.simpleMessage("使用网页登录提醒"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage("添加一个新的用户"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("登录"),
        "macOSDeviceName": m18,
        "manageAccount": MessageLookupByLibrary.simpleMessage("管理账号"),
        "manageAccountTitle": MessageLookupByLibrary.simpleMessage("管理账号"),
        "manageDiscuz": MessageLookupByLibrary.simpleMessage("管理论坛"),
        "manualControl": MessageLookupByLibrary.simpleMessage("手动控制"),
        "manualControlDescribe":
            MessageLookupByLibrary.simpleMessage("控制刷新和加载的完成时机"),
        "materialDesign": MessageLookupByLibrary.simpleMessage("质感设计"),
        "me": MessageLookupByLibrary.simpleMessage("我"),
        "minute": MessageLookupByLibrary.simpleMessage("分"),
        "minuteAgo": m19,
        "minuteLater": m20,
        "more": MessageLookupByLibrary.simpleMessage("更多"),
        "networkFail": MessageLookupByLibrary.simpleMessage("连接服务器时出错。"),
        "networkFailed": MessageLookupByLibrary.simpleMessage("网络访问失败。"),
        "newThread": MessageLookupByLibrary.simpleMessage("最新发表"),
        "noCaptachaRequired":
            MessageLookupByLibrary.simpleMessage("不需要验证码验证信息。"),
        "noFavoriteThreadInDb":
            MessageLookupByLibrary.simpleMessage("还没有收藏一个帖子"),
        "noImagePicked": MessageLookupByLibrary.simpleMessage("您可能没有选择任何一张图片。"),
        "noMore": MessageLookupByLibrary.simpleMessage("没有更多数据"),
        "noSignature": MessageLookupByLibrary.simpleMessage("不使用签名"),
        "noSmileyFoundInDB": MessageLookupByLibrary.simpleMessage("要不使用一个表情包？"),
        "notification": MessageLookupByLibrary.simpleMessage("通知"),
        "nullDiscuzSubTitle":
            MessageLookupByLibrary.simpleMessage("现在就添加一个论坛吗？"),
        "nullDiscuzTitle": MessageLookupByLibrary.simpleMessage("还没有指定一个论坛"),
        "ok": MessageLookupByLibrary.simpleMessage("确定"),
        "onlineHours": m21,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("在线时间"),
        "onlyViewAuthor": MessageLookupByLibrary.simpleMessage("只看作者"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("打开"),
        "openFileInExternalAppContent":
            MessageLookupByLibrary.simpleMessage("您成功下载了文件，您想现在打开它吗？"),
        "openInBrowser": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
        "openSoftwareSubtitle":
            MessageLookupByLibrary.simpleMessage("我们的软件以MIT开源协议服务"),
        "openSoftwareTitle": MessageLookupByLibrary.simpleMessage("开源软件"),
        "openSourceLicence": MessageLookupByLibrary.simpleMessage("开源软件许可"),
        "openViaInternalBrowser":
            MessageLookupByLibrary.simpleMessage("在内置浏览器打开"),
        "or": MessageLookupByLibrary.simpleMessage("或者"),
        "other": MessageLookupByLibrary.simpleMessage("其他"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "链接使用的域名与此论坛不一致，其很有可能不是论坛所有的。谨防钓鱼、木马和诈骗。"),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage("你正要打开外链"),
        "password": MessageLookupByLibrary.simpleMessage("密码"),
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[图片]"),
        "policy": MessageLookupByLibrary.simpleMessage("条款"),
        "pollExpireAt": m22,
        "pollVoterNumber": m23,
        "post": MessageLookupByLibrary.simpleMessage("发帖"),
        "postAuthorLabel": MessageLookupByLibrary.simpleMessage("楼主"),
        "postNumber": MessageLookupByLibrary.simpleMessage("回帖数"),
        "postPosition": m24,
        "preparingPage": MessageLookupByLibrary.simpleMessage("正在准备此界面。"),
        "preventAbuseUser":
            MessageLookupByLibrary.simpleMessage("请勿使用此应用发表令人反感的内容或其他滥用行为"),
        "preventAbuseUserDescription": MessageLookupByLibrary.simpleMessage(
            "我们对于令人反感的内容（包含并不限于咒骂内容（包含粗俗用语）、违禁药品、歧视性语言、针对人类的暴力行为、宣扬或美化恐怖主义或与性相关的脏话）和滥用行为都没有容忍。我们也强烈反对使用本应用发表任何涉政言论及以及做出相应的行为。该约束作为最终用户协议的一部分，您必须同意此约束后使用本应用。"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私政策"),
        "privacyProtectSubtitle":
            MessageLookupByLibrary.simpleMessage("轻轻的来正如我轻轻的走，我们不会搜集任何有关您的信息"),
        "privacyProtectTitle": MessageLookupByLibrary.simpleMessage("隐私安全"),
        "privateMessage": MessageLookupByLibrary.simpleMessage("私信"),
        "progressButtonLoginFailed":
            MessageLookupByLibrary.simpleMessage("登陆失败"),
        "progressButtonLoginSuccess":
            MessageLookupByLibrary.simpleMessage("登陆成功！"),
        "progressButtonLogining":
            MessageLookupByLibrary.simpleMessage("登陆中..."),
        "progressButtonReplyFailed":
            MessageLookupByLibrary.simpleMessage("回帖失败"),
        "progressButtonReplySending":
            MessageLookupByLibrary.simpleMessage("回帖中"),
        "progressButtonReplySuccess":
            MessageLookupByLibrary.simpleMessage("回帖成功"),
        "publicMessage": MessageLookupByLibrary.simpleMessage("公共消息"),
        "publishAt": MessageLookupByLibrary.simpleMessage(" 发帖于 "),
        "pullToRefresh": MessageLookupByLibrary.simpleMessage("拉动刷新"),
        "pushChannel": MessageLookupByLibrary.simpleMessage("推送渠道"),
        "pushChannelAPNs": MessageLookupByLibrary.simpleMessage("Apple推送通知服务"),
        "pushChannelFirebase": MessageLookupByLibrary.simpleMessage("Firebase"),
        "pushDevice": MessageLookupByLibrary.simpleMessage("设备信息"),
        "pushDeviceNotInterfaceWithService":
            MessageLookupByLibrary.simpleMessage("其他服务依然是正常的"),
        "pushDeviceNotInterfaceWithServiceDescription":
            MessageLookupByLibrary.simpleMessage(
                "别担心，其他服务依然是正常运行的，您可以关注我们的开发者博客以获得支持设备的最新进展。"),
        "pushDeviceNotSupported":
            MessageLookupByLibrary.simpleMessage("您的设备无法接收推送"),
        "pushDeviceNotSupportedDescription": MessageLookupByLibrary.simpleMessage(
            "在您的设备无法找到GMS或者APNs服务或者无法连接到FCM服务器注册令牌。我们目前仅支持带有GMS服务的Android以及苹果设备。"),
        "pushHelpPages": MessageLookupByLibrary.simpleMessage("推送服务帮助"),
        "pushInformation":
            MessageLookupByLibrary.simpleMessage("下列信息将在同意后直接发送给论坛服务器"),
        "pushNotification": MessageLookupByLibrary.simpleMessage("通知推送服务"),
        "pushNotificationDescription": MessageLookupByLibrary.simpleMessage(
            "推送通知服务仅当对应的Discuz站点启用了dhpush插件并且通过验证后才能开启。"),
        "pushNotificationEnable":
            MessageLookupByLibrary.simpleMessage("开启推送通知服务"),
        "pushNotificationOff": MessageLookupByLibrary.simpleMessage("已禁用"),
        "pushNotificationOn": MessageLookupByLibrary.simpleMessage("开启"),
        "pushNotificationPermissionNotAuthorized":
            MessageLookupByLibrary.simpleMessage("未获得通知授权，请检查您是否允许授予应用通知权限。"),
        "pushNotificationSubmittedContent": MessageLookupByLibrary.simpleMessage(
            "推送服务依赖Firebase以及APNs，需要您的设备型号、操作系统类别以及偏好渠道等信息。您需要同意我们的推送服务使用条款和隐私政策后使用本服务。"),
        "pushPackageId": MessageLookupByLibrary.simpleMessage("应用包名"),
        "pushThreadTitle": MessageLookupByLibrary.simpleMessage("发帖"),
        "pushThreadTitleHint": MessageLookupByLibrary.simpleMessage("帖子标题"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("拉动加载"),
        "pushToken": MessageLookupByLibrary.simpleMessage("Firebase令牌"),
        "recentNote": MessageLookupByLibrary.simpleMessage("最近的帖子"),
        "recordHistoryOffDescription":
            MessageLookupByLibrary.simpleMessage("应用不会记录您的浏览历史"),
        "recordHistoryOnDescription":
            MessageLookupByLibrary.simpleMessage("应用将会记录您的浏览历史"),
        "recordHistoryTitle": MessageLookupByLibrary.simpleMessage("历史记录"),
        "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
        "refreshFinish": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshed": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshing": MessageLookupByLibrary.simpleMessage("正在刷新..."),
        "registerAccountTime": MessageLookupByLibrary.simpleMessage("注册时间"),
        "releaseToLoad": MessageLookupByLibrary.simpleMessage("释放加载"),
        "releaseToRefresh": MessageLookupByLibrary.simpleMessage("释放刷新"),
        "relogin": MessageLookupByLibrary.simpleMessage("重新登陆"),
        "replyPost": MessageLookupByLibrary.simpleMessage("回复"),
        "replyPostTrimMessage": m25,
        "reportContentTitle": m26,
        "reportOtherReasonHint": MessageLookupByLibrary.simpleMessage("提供举报原因"),
        "reportSuccessfully": m27,
        "residentPlace": MessageLookupByLibrary.simpleMessage("居住地"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "revisedPost": MessageLookupByLibrary.simpleMessage("帖子审核后再编辑，以防重复加分。"),
        "sample": MessageLookupByLibrary.simpleMessage("示例"),
        "saveImageSuccessfully":
            MessageLookupByLibrary.simpleMessage("成功保存图片至此设备中."),
        "savePictureToDevice": MessageLookupByLibrary.simpleMessage("保存图片至此设备"),
        "savedSmileyTabTitle": MessageLookupByLibrary.simpleMessage("最近使用"),
        "second": MessageLookupByLibrary.simpleMessage("秒"),
        "seeAllReplies": MessageLookupByLibrary.simpleMessage("查看所有"),
        "selectUserNull": MessageLookupByLibrary.simpleMessage("未选中一个用户"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "sendImageWithVerificationNotice": MessageLookupByLibrary.simpleMessage(
            "需要手动填写验证码，填写完成后，最右侧发送按钮完成发送。"),
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
        "signInSuccessTitle": m28,
        "signInTitle": m29,
        "signInViaBrowser": MessageLookupByLibrary.simpleMessage("使用网页登录"),
        "signUp": MessageLookupByLibrary.simpleMessage("注册"),
        "signatureHint": MessageLookupByLibrary.simpleMessage("在此键入签名"),
        "signatureStyle": MessageLookupByLibrary.simpleMessage("发帖签名样式"),
        "siteDoesNotSupportPushService":
            MessageLookupByLibrary.simpleMessage("该论坛未开启推送插件。"),
        "sitePage": MessageLookupByLibrary.simpleMessage("主页"),
        "smileyLabel": m30,
        "spam": MessageLookupByLibrary.simpleMessage("恶意灌水"),
        "style": MessageLookupByLibrary.simpleMessage("样式"),
        "submitPoll": m31,
        "successfullyDeleteViewHistoryContent": m32,
        "successfullyDownloadFiles": m33,
        "syncSuccessfullyWithServer": m34,
        "takeAPicture": MessageLookupByLibrary.simpleMessage("照相"),
        "tapToWipeAndRelogin":
            MessageLookupByLibrary.simpleMessage("点击以移除此用户并重新登陆"),
        "termsOfService": MessageLookupByLibrary.simpleMessage("使用条款"),
        "termsOfUseDescription":
            MessageLookupByLibrary.simpleMessage("你需要同意我们的使用条款后使用本应用。"),
        "testVersion": MessageLookupByLibrary.simpleMessage("公测版本"),
        "testVersionDescription": MessageLookupByLibrary.simpleMessage(
            "此版本具有最新的开发进展，同时也伴有一定的错误。当您使用时，请做好数据备份，以防数据丢失。"),
        "testVersionNotificationTitle":
            MessageLookupByLibrary.simpleMessage("欢迎参与测试版本"),
        "threadIsClosed": MessageLookupByLibrary.simpleMessage("此贴已关闭发帖。"),
        "threadReadAccess": m35,
        "trashAd": MessageLookupByLibrary.simpleMessage("垃圾广告"),
        "trustHostActionText": MessageLookupByLibrary.simpleMessage("信任此域名"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("主机域名白名单"),
        "typeSetting": MessageLookupByLibrary.simpleMessage("文本排版"),
        "unableToVerifyAuthStatus":
            MessageLookupByLibrary.simpleMessage("无法验证登陆状态"),
        "unblockContent": MessageLookupByLibrary.simpleMessage("恢复显示内容"),
        "unblockUser": MessageLookupByLibrary.simpleMessage("解除屏蔽"),
        "undo": MessageLookupByLibrary.simpleMessage("撤销"),
        "updateAt": MessageLookupByLibrary.simpleMessage("更新于 %T"),
        "upgrade_notification_subtitle": MessageLookupByLibrary.simpleMessage(
            "此次升级包含常规的功能更新、问题修复以及界面样式更改。可以正常兼容升级。"),
        "upgrade_notification_title":
            MessageLookupByLibrary.simpleMessage("升级提醒"),
        "uploadCompressedImageToServer":
            MessageLookupByLibrary.simpleMessage("适当压缩的图片（推荐）"),
        "uploadImageError1": MessageLookupByLibrary.simpleMessage("不支持此类扩展名."),
        "uploadImageError10": MessageLookupByLibrary.simpleMessage("非法操作"),
        "uploadImageError11":
            MessageLookupByLibrary.simpleMessage("今日您已无法上传那么大的附件"),
        "uploadImageError2":
            MessageLookupByLibrary.simpleMessage("服务器限制无法上传那么大的附件"),
        "uploadImageError3":
            MessageLookupByLibrary.simpleMessage("用户组限制无法上传那么大的附件"),
        "uploadImageError4": MessageLookupByLibrary.simpleMessage("不支持此类扩展名"),
        "uploadImageError5":
            MessageLookupByLibrary.simpleMessage("文件类型限制无法上传那么大的附件"),
        "uploadImageError6":
            MessageLookupByLibrary.simpleMessage("今日您已无法上传更多的附件"),
        "uploadImageError7": MessageLookupByLibrary.simpleMessage("请选择图片文件"),
        "uploadImageError8": MessageLookupByLibrary.simpleMessage("附件文件无法保存"),
        "uploadImageError9": MessageLookupByLibrary.simpleMessage("没有合法的文件被上传"),
        "uploadImageErrorNegative1":
            MessageLookupByLibrary.simpleMessage("内部服务器错误"),
        "uploadImageFailed": MessageLookupByLibrary.simpleMessage("上传图片失败"),
        "uploadImageSuccessfully":
            MessageLookupByLibrary.simpleMessage("文件已经成功上传至服务器"),
        "uploadImageToServerDialogTitle":
            MessageLookupByLibrary.simpleMessage("向论坛上传图片"),
        "uploadImageUnknownError":
            MessageLookupByLibrary.simpleMessage("上传文件时遇到了一个未知错误。"),
        "uploadRawImageToServer":
            MessageLookupByLibrary.simpleMessage("原始图片（可能因为太大被服务器拒绝）"),
        "uploadTokenSuccessful":
            MessageLookupByLibrary.simpleMessage("您的设备令牌已经成功传入到论坛中。"),
        "uploadTokenUnsuccessful":
            MessageLookupByLibrary.simpleMessage("无法添加您的设备到论坛推送系统中。"),
        "uploadingImageToServer":
            MessageLookupByLibrary.simpleMessage("向服务器传输数据中。。。"),
        "useMaterial3NoSubtitle":
            MessageLookupByLibrary.simpleMessage("应用会使用 Material 2 的外观。"),
        "useMaterial3Title":
            MessageLookupByLibrary.simpleMessage("使用Material 3属性"),
        "useMaterial3YesSubtitle": MessageLookupByLibrary.simpleMessage(
            "迁移到 Material 3 的组件将使用 Material 3 的新颜色、排版和其他功能。"),
        "userCredit": MessageLookupByLibrary.simpleMessage("积分"),
        "userExpiredSubtitle":
            MessageLookupByLibrary.simpleMessage("当前用户授权已过期，你需要重新登录以重新激活此用户。"),
        "userExpiredTitle": m36,
        "userIdTitle": m37,
        "userPost": MessageLookupByLibrary.simpleMessage("回复"),
        "userProfile": MessageLookupByLibrary.simpleMessage("用户中心"),
        "userProfileTitle": MessageLookupByLibrary.simpleMessage("用户信息"),
        "userThread": MessageLookupByLibrary.simpleMessage("发帖"),
        "viewAuthorInfo": MessageLookupByLibrary.simpleMessage("查看用户详情"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("浏览历史"),
        "viewThreadTitle": MessageLookupByLibrary.simpleMessage("查看帖子"),
        "viewUserInfo": m38,
        "warnedPost": MessageLookupByLibrary.simpleMessage("此贴被警告。"),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("查看大图"),
        "websiteNotLogined": MessageLookupByLibrary.simpleMessage(
            "在网页中没有完成登录，请登陆后点击右上方登录按钮完成录入。"),
        "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
            "欢迎使用我们的服务，我们基于Discuz！移动插件为您服务。"),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("你好"),
        "windowsDeviceName": m39,
        "workProcedure": MessageLookupByLibrary.simpleMessage("推送服务是如何工作的？"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage("无法获得写入权限。")
      };
}
