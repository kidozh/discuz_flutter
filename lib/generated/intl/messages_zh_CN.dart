// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(discuz) => "成功添加 ${discuz} 论坛。";

  static String m1(account) => "成功移除账号 ${account}。";

  static String m2(account) => "成功删除论坛 ${account}。";

  static String m3(filename) => "后台下载文件 ${filename} 中。";

  static String m4(size) => "${size}逻辑像素";

  static String m5(size) => "${size}倍";

  static String m6(readAccess, star) => "阅读权限： ${readAccess}， 等级： ${star}";

  static String m7(uri) => "无法打开此链接 : ${uri}.";

  static String m8(hour) => "${hour}小时";

  static String m9(time) => "该投票将于${time}过期.";

  static String m10(people) => "共有${people}人已投票.";

  static String m11(pos) => "第${pos}层";

  static String m12(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} 发表于 ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m13(username, discuzName) =>
      "用户 ${username} 已成功登录到 ${discuzName}。";

  static String m14(discuzName) => "登录至 ${discuzName}";

  static String m15(checked, allowed) => "投票 (${checked} / ${allowed})";

  static String m16(title) => "成功删除历史记录 ${title}.";

  static String m17(filename) => "成功下载文件： ${filename}。";

  static String m18(username) => "用户 ${username} 已失效";

  static String m19(uid) => "用户编号： ${uid}";

  static String m20(user) => "查看${user}详情";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "account": MessageLookupByLibrary.simpleMessage("账号"),
        "addDiscuzSuccessfully": m0,
        "addDiscuzTitle": MessageLookupByLibrary.simpleMessage("添加Discuz! 论坛"),
        "addNewDiscuz": MessageLookupByLibrary.simpleMessage("添加一个论坛"),
        "aliPay": MessageLookupByLibrary.simpleMessage("支付宝"),
        "android": MessageLookupByLibrary.simpleMessage("Android或者兼容鸿蒙操作系统"),
        "anonymous": MessageLookupByLibrary.simpleMessage("未知"),
        "appName": MessageLookupByLibrary.simpleMessage("谈坛"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("运行平台样式偏好"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage("你可以选择对应平台下应用的显示样式"),
        "autoLoad": MessageLookupByLibrary.simpleMessage("自动加载"),
        "autoLoadDescribe": MessageLookupByLibrary.simpleMessage("滑到底部自动刷新"),
        "ballPulseDescribe": MessageLookupByLibrary.simpleMessage("球脉冲样式"),
        "basicUse": MessageLookupByLibrary.simpleMessage("基本使用"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("EasyRefresh的基本使用"),
        "bezierCircleDescribe": MessageLookupByLibrary.simpleMessage("弹出圆圈"),
        "bezierHourGlassDescribe":
            MessageLookupByLibrary.simpleMessage("弹出HourGlass"),
        "bio": MessageLookupByLibrary.simpleMessage("签名"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("出生地"),
        "blockedPost": MessageLookupByLibrary.simpleMessage("此贴被屏蔽。"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob小黄人"),
        "bobMinionDescribe": MessageLookupByLibrary.simpleMessage("可爱的小黄人"),
        "bottomBouncing": MessageLookupByLibrary.simpleMessage("底部回弹"),
        "bottomBouncingDescribe": MessageLookupByLibrary.simpleMessage("底部可越界"),
        "buildDescription":
            MessageLookupByLibrary.simpleMessage("由flutter驱动, 能够兼容多种平台。"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("取消"),
        "captchaRequired": MessageLookupByLibrary.simpleMessage("需要验证码"),
        "chatMessage": MessageLookupByLibrary.simpleMessage("信息"),
        "chatPage": MessageLookupByLibrary.simpleMessage("聊天页面"),
        "chatPageDescribe": MessageLookupByLibrary.simpleMessage("模仿聊天页面"),
        "chengdu": MessageLookupByLibrary.simpleMessage("中国 - 成都"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("选择一个论坛"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("主题颜色"),
        "city": MessageLookupByLibrary.simpleMessage("城市"),
        "classic": MessageLookupByLibrary.simpleMessage("经典样式"),
        "classicDescribe": MessageLookupByLibrary.simpleMessage("经典(默认)风格"),
        "clearAllViewHistories": MessageLookupByLibrary.simpleMessage("清除历史记录"),
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
        "continueAdding": MessageLookupByLibrary.simpleMessage("继续"),
        "controlFinish": MessageLookupByLibrary.simpleMessage("控制结束"),
        "controlFinishDescribe":
            MessageLookupByLibrary.simpleMessage("使用控制器结束异步任务"),
        "credit": MessageLookupByLibrary.simpleMessage("积分"),
        "cupertinoDescribe": MessageLookupByLibrary.simpleMessage("ios风格"),
        "customScrollViewDescribe":
            MessageLookupByLibrary.simpleMessage("带头部折叠的列表，监听器示例"),
        "customStatusTitle": MessageLookupByLibrary.simpleMessage("自定义头衔"),
        "dashboard": MessageLookupByLibrary.simpleMessage("看板"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("删除"),
        "deleteAccountSuccessfully": m1,
        "deleteDiscuzSuccessfully": m2,
        "deleteViewHistoryWarnContent":
            MessageLookupByLibrary.simpleMessage("清除历史记录是不可恢复的，确认要继续？"),
        "deliveryDescribe": MessageLookupByLibrary.simpleMessage("气球快递"),
        "direction": MessageLookupByLibrary.simpleMessage("方向"),
        "discuzServerAddress": MessageLookupByLibrary.simpleMessage("论坛地址"),
        "discuzServerAddressHelperText":
            MessageLookupByLibrary.simpleMessage("其通常就是论坛的地址"),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("例如： https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("显示"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("下载附件"),
        "downloadingFiles": m3,
        "email": MessageLookupByLibrary.simpleMessage("邮箱"),
        "emptyListDescription": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
        "emptyScreenTitle": MessageLookupByLibrary.simpleMessage("当前列表为空。"),
        "emptyWidget": MessageLookupByLibrary.simpleMessage("空视图"),
        "emptyWidgetDescribe":
            MessageLookupByLibrary.simpleMessage("没有数据时显示空视图"),
        "error": MessageLookupByLibrary.simpleMessage("出错了"),
        "favorites": MessageLookupByLibrary.simpleMessage("收藏"),
        "firstRefresh": MessageLookupByLibrary.simpleMessage("首次刷新"),
        "firstRefreshDescribe": MessageLookupByLibrary.simpleMessage("首次刷新视图"),
        "floatView": MessageLookupByLibrary.simpleMessage("浮动视图"),
        "floatViewDescribe":
            MessageLookupByLibrary.simpleMessage("顶部或底部视图浮动在列表上"),
        "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "fontSizeInParagraph": MessageLookupByLibrary.simpleMessage("正文字体大小"),
        "fontSizeInParagraphUnit": m4,
        "fontSizeScaleParameter":
            MessageLookupByLibrary.simpleMessage("文本缩放比例"),
        "fontSizeScaleParameterUnit": m5,
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
        "friendNumber": MessageLookupByLibrary.simpleMessage("好友数"),
        "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
        "github": MessageLookupByLibrary.simpleMessage("Github"),
        "googleAdSubTitle":
            MessageLookupByLibrary.simpleMessage("由Google提供的广告"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("广告"),
        "groupInfoDescription": m6,
        "habit": MessageLookupByLibrary.simpleMessage("爱好"),
        "hangzhou": MessageLookupByLibrary.simpleMessage("中国 - 杭州"),
        "headerFloat": MessageLookupByLibrary.simpleMessage("Header浮动"),
        "headerFloatDescribe":
            MessageLookupByLibrary.simpleMessage("Header显示在列表之上"),
        "homepage": MessageLookupByLibrary.simpleMessage("个人主页"),
        "horizontal": MessageLookupByLibrary.simpleMessage("水平"),
        "httpBrowseWarn": MessageLookupByLibrary.simpleMessage("不安全的HTTP协议"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage("某些功能可能不可用"),
        "incognitoTitle": MessageLookupByLibrary.simpleMessage("匿名模式"),
        "incorrectDiscuzAddress":
            MessageLookupByLibrary.simpleMessage("无效的论坛地址."),
        "index": MessageLookupByLibrary.simpleMessage("索引"),
        "infiniteLoad": MessageLookupByLibrary.simpleMessage("无限加载"),
        "infiniteLoadDescribe":
            MessageLookupByLibrary.simpleMessage("滑动到底部自动触发加载"),
        "ios": MessageLookupByLibrary.simpleMessage("iOS"),
        "joinDiscussion": MessageLookupByLibrary.simpleMessage("加入讨论"),
        "joinDiscussionDescribe":
            MessageLookupByLibrary.simpleMessage("加入QQ群554981921,进行讨论"),
        "largeRichText": MessageLookupByLibrary.simpleMessage(
            "欢迎使用DiscuzHub\n感谢您使用我们的产品和服务（下称“服务”）。\n您使用我们的服务即表示您已同意本条款。请"),
        "largeRichTextDescription":
            MessageLookupByLibrary.simpleMessage("摘取我们的使用政策"),
        "lastActivityTime": MessageLookupByLibrary.simpleMessage("上次活动于"),
        "lastPostTime": MessageLookupByLibrary.simpleMessage("上次发帖时间"),
        "lastVisitTime": MessageLookupByLibrary.simpleMessage("上次访问时间"),
        "legalInformation": MessageLookupByLibrary.simpleMessage("法律信息"),
        "linkHeader": MessageLookupByLibrary.simpleMessage("Header连接器"),
        "linkHeaderDescribeDescribe":
            MessageLookupByLibrary.simpleMessage("使用连接器自定义Header"),
        "linkUnableToOpen": m7,
        "listDirection": MessageLookupByLibrary.simpleMessage("列表方向"),
        "listEmbed": MessageLookupByLibrary.simpleMessage("列表嵌入"),
        "listEmbedDescribe":
            MessageLookupByLibrary.simpleMessage("使用连接器设置Header和Footer位置"),
        "listReverse": MessageLookupByLibrary.simpleMessage("列表反向"),
        "loadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
        "loadFinish": MessageLookupByLibrary.simpleMessage("加载完成"),
        "loadMore": MessageLookupByLibrary.simpleMessage("加载"),
        "loadSwitch": MessageLookupByLibrary.simpleMessage("加载开关"),
        "loadSwitchDescribe": MessageLookupByLibrary.simpleMessage("是否开启加载"),
        "loaded": MessageLookupByLibrary.simpleMessage("加载完成"),
        "loading": MessageLookupByLibrary.simpleMessage("正在加载..."),
        "loginByWebHttpWarn": MessageLookupByLibrary.simpleMessage(
            "您正在使用不安全的HTTP连接，此界面有可能被第三方所劫持。您在此界面输入的信息有可能泄露。强烈建议您使用HTTPS协议访问此界面。"),
        "loginByWebMessage": MessageLookupByLibrary.simpleMessage(
            "请在网页中完成登录，当您在网页中完成了登录过程后，请轻触右下方的浮动按钮完成账号录入操作。有时存在延迟情况，可能需要点击两次才能录入账号。"),
        "loginByWebNotSupported":
            MessageLookupByLibrary.simpleMessage("当前系统并不支持Webview登录"),
        "loginByWebTitle": MessageLookupByLibrary.simpleMessage("使用网页登录提醒"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage("添加一个新的用户"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("登录"),
        "manageAccount": MessageLookupByLibrary.simpleMessage("管理账号"),
        "manageAccountTitle": MessageLookupByLibrary.simpleMessage("管理账号"),
        "manageDiscuz": MessageLookupByLibrary.simpleMessage("管理论坛"),
        "manualControl": MessageLookupByLibrary.simpleMessage("手动控制"),
        "manualControlDescribe":
            MessageLookupByLibrary.simpleMessage("控制刷新和加载的完成时机"),
        "materialDescribe":
            MessageLookupByLibrary.simpleMessage("质感设计,Android样式"),
        "me": MessageLookupByLibrary.simpleMessage("我"),
        "more": MessageLookupByLibrary.simpleMessage("更多"),
        "moreStyle": MessageLookupByLibrary.simpleMessage("更多样式"),
        "moreStyleDescribe":
            MessageLookupByLibrary.simpleMessage("会越来越多哦!你也可以参考源码自定义"),
        "name": MessageLookupByLibrary.simpleMessage("名字"),
        "nestedScrollViewDescribe":
            MessageLookupByLibrary.simpleMessage("NestedScrollView示例"),
        "noBald": MessageLookupByLibrary.simpleMessage("没到秃头的年龄"),
        "noData": MessageLookupByLibrary.simpleMessage("没有数据"),
        "noMore": MessageLookupByLibrary.simpleMessage("没有更多数据"),
        "notification": MessageLookupByLibrary.simpleMessage("通知"),
        "nullDiscuzSubTitle":
            MessageLookupByLibrary.simpleMessage("现在就添加一个论坛吗？"),
        "nullDiscuzTitle": MessageLookupByLibrary.simpleMessage("还没有指定一个论坛"),
        "ok": MessageLookupByLibrary.simpleMessage("好"),
        "old": MessageLookupByLibrary.simpleMessage("年龄"),
        "onlineHours": m8,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("在线时间"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("打开"),
        "openFileInExternalAppContent":
            MessageLookupByLibrary.simpleMessage("您成功下载了文件，您想现在打开它吗？"),
        "openInBrowser": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
        "openSourceLicence": MessageLookupByLibrary.simpleMessage("开源软件许可"),
        "or": MessageLookupByLibrary.simpleMessage("或者"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "链接使用的域名与此论坛不一致，其很有可能不是论坛所有的。谨防钓鱼、木马和诈骗。"),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage("你正要打开外链"),
        "password": MessageLookupByLibrary.simpleMessage("密码"),
        "payPal": MessageLookupByLibrary.simpleMessage("PayPal"),
        "phoenixDescribe": MessageLookupByLibrary.simpleMessage("金色校园"),
        "phone": MessageLookupByLibrary.simpleMessage("电话"),
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[图片]"),
        "policy": MessageLookupByLibrary.simpleMessage("条款"),
        "pollExpireAt": m9,
        "pollVoterNumber": m10,
        "postNumber": MessageLookupByLibrary.simpleMessage("回帖数"),
        "postPosition": m11,
        "preparingPage": MessageLookupByLibrary.simpleMessage("正在准备此界面。"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私政策"),
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
        "projectAddress": MessageLookupByLibrary.simpleMessage("项目地址"),
        "publicMessage": MessageLookupByLibrary.simpleMessage("公共消息"),
        "publishAt": MessageLookupByLibrary.simpleMessage(" 发帖于 "),
        "pullToRefresh": MessageLookupByLibrary.simpleMessage("拉动刷新"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("拉动加载"),
        "qqGroup": MessageLookupByLibrary.simpleMessage("QQ群"),
        "qqPay": MessageLookupByLibrary.simpleMessage("QQ钱包"),
        "recentNote": MessageLookupByLibrary.simpleMessage("最近的帖子"),
        "recordHistoryOffDescription":
            MessageLookupByLibrary.simpleMessage("应用不会记录您的浏览历史"),
        "recordHistoryOnDescription":
            MessageLookupByLibrary.simpleMessage("应用将会记录您的浏览历史"),
        "recordHistoryTitle": MessageLookupByLibrary.simpleMessage("历史记录"),
        "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
        "refreshFinish": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshSwitch": MessageLookupByLibrary.simpleMessage("刷新开关"),
        "refreshSwitchDescribe": MessageLookupByLibrary.simpleMessage("是否开启刷新"),
        "refreshed": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshing": MessageLookupByLibrary.simpleMessage("正在刷新..."),
        "registerAccountTime": MessageLookupByLibrary.simpleMessage("注册时间"),
        "releaseToLoad": MessageLookupByLibrary.simpleMessage("释放加载"),
        "releaseToRefresh": MessageLookupByLibrary.simpleMessage("释放刷新"),
        "relogin": MessageLookupByLibrary.simpleMessage("重新登陆"),
        "replyPost": MessageLookupByLibrary.simpleMessage("回复"),
        "replyPostTrimMessage": m12,
        "residentPlace": MessageLookupByLibrary.simpleMessage("居住地"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "reverse": MessageLookupByLibrary.simpleMessage("反向"),
        "revisedPost": MessageLookupByLibrary.simpleMessage("帖子审核后再编辑，以防重复加分。"),
        "sample": MessageLookupByLibrary.simpleMessage("示例"),
        "saveImageSuccessfully":
            MessageLookupByLibrary.simpleMessage("成功保存图片至此设备中."),
        "savePictureToDevice": MessageLookupByLibrary.simpleMessage("保存图片至此设备"),
        "scrollBar": MessageLookupByLibrary.simpleMessage("滚动条"),
        "scrollBarDescribe": MessageLookupByLibrary.simpleMessage("为列表添加滚动条"),
        "secondFloor": MessageLookupByLibrary.simpleMessage("二楼"),
        "secondFloorDescribe": MessageLookupByLibrary.simpleMessage("模仿淘宝二楼"),
        "selectUserNull": MessageLookupByLibrary.simpleMessage("未选中一个用户"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "sendReply": MessageLookupByLibrary.simpleMessage("回帖"),
        "sendReplyHint": MessageLookupByLibrary.simpleMessage("说些什么吧。"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("设置"),
        "signInSuccessTitle": m13,
        "signInTitle": m14,
        "signInViaBrowser": MessageLookupByLibrary.simpleMessage("使用网页登录"),
        "signUp": MessageLookupByLibrary.simpleMessage("注册"),
        "spaceDescribe": MessageLookupByLibrary.simpleMessage("Flare动画 - 星空"),
        "star": MessageLookupByLibrary.simpleMessage("Star 项目"),
        "style": MessageLookupByLibrary.simpleMessage("样式"),
        "submitPoll": m15,
        "successfullyDeleteViewHistoryContent": m16,
        "successfullyDownloadFiles": m17,
        "supportAuthor": MessageLookupByLibrary.simpleMessage("支持作者"),
        "supportAuthorDescribe":
            MessageLookupByLibrary.simpleMessage("你的支持是我最大的动力"),
        "swiperDescribe":
            MessageLookupByLibrary.simpleMessage("Swiper示例，解决滑动冲突"),
        "tabViewWidgetDescribe":
            MessageLookupByLibrary.simpleMessage("List和Grid组成的TabBarView"),
        "taskIndependence": MessageLookupByLibrary.simpleMessage("任务独立"),
        "taskIndependenceDescribe":
            MessageLookupByLibrary.simpleMessage("刷新和加载任务互不受影响(不推荐)"),
        "taurusDescribe": MessageLookupByLibrary.simpleMessage("冲上云霄"),
        "termsOfService": MessageLookupByLibrary.simpleMessage("使用条款"),
        "topBouncing": MessageLookupByLibrary.simpleMessage("顶部回弹"),
        "topBouncingDescribe": MessageLookupByLibrary.simpleMessage("顶部可越界"),
        "trustHostActionText": MessageLookupByLibrary.simpleMessage("信任此域名"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("主机域名白名单"),
        "unableToVerifyAuthStatus":
            MessageLookupByLibrary.simpleMessage("无法验证登陆状态"),
        "undo": MessageLookupByLibrary.simpleMessage("撤销"),
        "updateAt": MessageLookupByLibrary.simpleMessage("更新于 %T"),
        "userExpiredSubtitle":
            MessageLookupByLibrary.simpleMessage("当前用户授权已过期，你需要重新登录以重新激活此用户。"),
        "userExpiredTitle": m18,
        "userIdTitle": m19,
        "userProfile": MessageLookupByLibrary.simpleMessage("个人中心"),
        "userProfileDescribe":
            MessageLookupByLibrary.simpleMessage("带回弹效果的个人中心"),
        "userProfileTitle": MessageLookupByLibrary.simpleMessage("用户信息"),
        "vertical": MessageLookupByLibrary.simpleMessage("垂直"),
        "vibration": MessageLookupByLibrary.simpleMessage("震动"),
        "vibrationDescribe": MessageLookupByLibrary.simpleMessage("触发震动反馈"),
        "viewAuthorInfo": MessageLookupByLibrary.simpleMessage("查看用户详情"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("浏览历史"),
        "viewThreadTitle": MessageLookupByLibrary.simpleMessage("查看帖子"),
        "viewUserInfo": m20,
        "warnedPost": MessageLookupByLibrary.simpleMessage("此贴被警告。"),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("查看大图"),
        "weiXinPay": MessageLookupByLibrary.simpleMessage("微信钱包"),
        "welcomeToSecondFloor": MessageLookupByLibrary.simpleMessage("欢迎来到二楼"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage("无法获得写入权限。")
      };
}
