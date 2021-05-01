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

  static String m0(filename) => "后台下载文件 ${filename} 中。";

  static String m1(uri) => "无法打开此链接 : ${uri}.";

  static String m2(pos) => "第${pos}层";

  static String m3(username, discuzName) =>
      "用户 ${username} 已成功登录到 ${discuzName}。";

  static String m4(discuzName) => "登录至 ${discuzName}";

  static String m5(filename) => "成功下载文件： ${filename}。";

  static String m6(username) => "用户 ${username} 已失效";

  static String m7(uid) => "用户编号： ${uid}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "account": MessageLookupByLibrary.simpleMessage("账号"),
        "addNewDiscuz": MessageLookupByLibrary.simpleMessage("添加一个论坛"),
        "aliPay": MessageLookupByLibrary.simpleMessage("支付宝"),
        "anonymous": MessageLookupByLibrary.simpleMessage("未知"),
        "appName": MessageLookupByLibrary.simpleMessage("谈坛"),
        "autoLoad": MessageLookupByLibrary.simpleMessage("自动加载"),
        "autoLoadDescribe": MessageLookupByLibrary.simpleMessage("滑到底部自动刷新"),
        "ballPulseDescribe": MessageLookupByLibrary.simpleMessage("球脉冲样式"),
        "basicUse": MessageLookupByLibrary.simpleMessage("基本使用"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("EasyRefresh的基本使用"),
        "bezierCircleDescribe": MessageLookupByLibrary.simpleMessage("弹出圆圈"),
        "bezierHourGlassDescribe":
            MessageLookupByLibrary.simpleMessage("弹出HourGlass"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob小黄人"),
        "bobMinionDescribe": MessageLookupByLibrary.simpleMessage("可爱的小黄人"),
        "bottomBouncing": MessageLookupByLibrary.simpleMessage("底部回弹"),
        "bottomBouncingDescribe": MessageLookupByLibrary.simpleMessage("底部可越界"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chatPage": MessageLookupByLibrary.simpleMessage("聊天页面"),
        "chatPageDescribe": MessageLookupByLibrary.simpleMessage("模仿聊天页面"),
        "chengdu": MessageLookupByLibrary.simpleMessage("中国 - 成都"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("选择一个论坛"),
        "city": MessageLookupByLibrary.simpleMessage("城市"),
        "classic": MessageLookupByLibrary.simpleMessage("经典样式"),
        "classicDescribe": MessageLookupByLibrary.simpleMessage("经典(默认)风格"),
        "completeLoad": MessageLookupByLibrary.simpleMessage("完成加载"),
        "completeRefresh": MessageLookupByLibrary.simpleMessage("完成刷新"),
        "controlFinish": MessageLookupByLibrary.simpleMessage("控制结束"),
        "controlFinishDescribe":
            MessageLookupByLibrary.simpleMessage("使用控制器结束异步任务"),
        "cupertinoDescribe": MessageLookupByLibrary.simpleMessage("ios风格"),
        "customScrollViewDescribe":
            MessageLookupByLibrary.simpleMessage("带头部折叠的列表，监听器示例"),
        "dashboard": MessageLookupByLibrary.simpleMessage("看板"),
        "deliveryDescribe": MessageLookupByLibrary.simpleMessage("气球快递"),
        "direction": MessageLookupByLibrary.simpleMessage("方向"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("下载附件"),
        "downloadingFiles": m0,
        "email": MessageLookupByLibrary.simpleMessage("邮箱"),
        "emptyWidget": MessageLookupByLibrary.simpleMessage("空视图"),
        "emptyWidgetDescribe":
            MessageLookupByLibrary.simpleMessage("没有数据时显示空视图"),
        "error": MessageLookupByLibrary.simpleMessage("出错了"),
        "firstRefresh": MessageLookupByLibrary.simpleMessage("首次刷新"),
        "firstRefreshDescribe": MessageLookupByLibrary.simpleMessage("首次刷新视图"),
        "floatView": MessageLookupByLibrary.simpleMessage("浮动视图"),
        "floatViewDescribe":
            MessageLookupByLibrary.simpleMessage("顶部或底部视图浮动在列表上"),
        "forgetPassword": MessageLookupByLibrary.simpleMessage("忘记密码?"),
        "forumDisplayTitle": MessageLookupByLibrary.simpleMessage("显示板块"),
        "github": MessageLookupByLibrary.simpleMessage("Github"),
        "googleAdSubTitle":
            MessageLookupByLibrary.simpleMessage("由Google提供的广告"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("广告"),
        "hangzhou": MessageLookupByLibrary.simpleMessage("中国 - 杭州"),
        "headerFloat": MessageLookupByLibrary.simpleMessage("Header浮动"),
        "headerFloatDescribe":
            MessageLookupByLibrary.simpleMessage("Header显示在列表之上"),
        "horizontal": MessageLookupByLibrary.simpleMessage("水平"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage("某些功能可能不可用"),
        "incognitoTitle": MessageLookupByLibrary.simpleMessage("匿名模式"),
        "index": MessageLookupByLibrary.simpleMessage("索引"),
        "infiniteLoad": MessageLookupByLibrary.simpleMessage("无限加载"),
        "infiniteLoadDescribe":
            MessageLookupByLibrary.simpleMessage("滑动到底部自动触发加载"),
        "joinDiscussion": MessageLookupByLibrary.simpleMessage("加入讨论"),
        "joinDiscussionDescribe":
            MessageLookupByLibrary.simpleMessage("加入QQ群554981921,进行讨论"),
        "linkHeader": MessageLookupByLibrary.simpleMessage("Header连接器"),
        "linkHeaderDescribeDescribe":
            MessageLookupByLibrary.simpleMessage("使用连接器自定义Header"),
        "linkUnableToOpen": m1,
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
        "loginSubtitle": MessageLookupByLibrary.simpleMessage("添加一个新的用户"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("登录"),
        "manageAccount": MessageLookupByLibrary.simpleMessage("管理账号"),
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
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("打开"),
        "openFileInExternalAppContent":
            MessageLookupByLibrary.simpleMessage("您成功下载了文件，您想现在打开它吗？"),
        "openInBrowser": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
        "or": MessageLookupByLibrary.simpleMessage("或者"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "链接使用的域名与此论坛不一致，其很有可能不是论坛所有的。谨防钓鱼、木马和诈骗。"),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage("你正要打开外链"),
        "password": MessageLookupByLibrary.simpleMessage("密码"),
        "payPal": MessageLookupByLibrary.simpleMessage("PayPal"),
        "phoenixDescribe": MessageLookupByLibrary.simpleMessage("金色校园"),
        "phone": MessageLookupByLibrary.simpleMessage("电话"),
        "postPosition": m2,
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
        "publishAt": MessageLookupByLibrary.simpleMessage(" 发帖于 "),
        "pullToRefresh": MessageLookupByLibrary.simpleMessage("拉动刷新"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("拉动加载"),
        "qqGroup": MessageLookupByLibrary.simpleMessage("QQ群"),
        "qqPay": MessageLookupByLibrary.simpleMessage("QQ钱包"),
        "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
        "refreshFinish": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshSwitch": MessageLookupByLibrary.simpleMessage("刷新开关"),
        "refreshSwitchDescribe": MessageLookupByLibrary.simpleMessage("是否开启刷新"),
        "refreshed": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshing": MessageLookupByLibrary.simpleMessage("正在刷新..."),
        "releaseToLoad": MessageLookupByLibrary.simpleMessage("释放加载"),
        "releaseToRefresh": MessageLookupByLibrary.simpleMessage("释放刷新"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "reverse": MessageLookupByLibrary.simpleMessage("反向"),
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
        "signInSuccessTitle": m3,
        "signInTitle": m4,
        "signInViaBrowser": MessageLookupByLibrary.simpleMessage("使用网页登录"),
        "signUp": MessageLookupByLibrary.simpleMessage("注册"),
        "spaceDescribe": MessageLookupByLibrary.simpleMessage("Flare动画 - 星空"),
        "star": MessageLookupByLibrary.simpleMessage("Star 项目"),
        "style": MessageLookupByLibrary.simpleMessage("样式"),
        "successfullyDownloadFiles": m5,
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
        "topBouncing": MessageLookupByLibrary.simpleMessage("顶部回弹"),
        "topBouncingDescribe": MessageLookupByLibrary.simpleMessage("顶部可越界"),
        "updateAt": MessageLookupByLibrary.simpleMessage("更新于 %T"),
        "userExpiredSubtitle":
            MessageLookupByLibrary.simpleMessage("当前用户授权已过期，你需要重新登录以重新激活此用户。"),
        "userExpiredTitle": m6,
        "userIdTitle": m7,
        "userProfile": MessageLookupByLibrary.simpleMessage("个人中心"),
        "userProfileDescribe":
            MessageLookupByLibrary.simpleMessage("带回弹效果的个人中心"),
        "vertical": MessageLookupByLibrary.simpleMessage("垂直"),
        "vibration": MessageLookupByLibrary.simpleMessage("震动"),
        "vibrationDescribe": MessageLookupByLibrary.simpleMessage("触发震动反馈"),
        "viewThreadTitle": MessageLookupByLibrary.simpleMessage("查看帖子"),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("查看大图"),
        "weiXinPay": MessageLookupByLibrary.simpleMessage("微信钱包"),
        "welcomeToSecondFloor": MessageLookupByLibrary.simpleMessage("欢迎来到二楼"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage("无法获得写入权限。")
      };
}
