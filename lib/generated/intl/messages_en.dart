// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(account) => "Delete account ${account} successfully.";

  static String m1(account) => "Delete discuz ${account} successfully.";

  static String m2(filename) => "Downloading file: ${filename} in background.";

  static String m3(uri) => "Unable to open the uri: ${uri}.";

  static String m4(time) => "Poll will expire at ${time}.";

  static String m5(people) => "${people} have voted.";

  static String m6(pos) => "# ${pos}";

  static String m7(username, discuzName) =>
      "User ${username} sign in at ${discuzName} successfully.";

  static String m8(discuzName) => "Sign in at ${discuzName}";

  static String m9(checked, allowed) => "Submit (${checked} / ${allowed})";

  static String m10(title) => "Successfully remove view history ${title}.";

  static String m11(filename) => "Successfully download file: ${filename}.";

  static String m12(username) => "User ${username} expired";

  static String m13(uid) => "UserId ${uid}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "addNewDiscuz":
            MessageLookupByLibrary.simpleMessage("Add a new Discuz! forum"),
        "aliPay": MessageLookupByLibrary.simpleMessage("AliPay"),
        "anonymous": MessageLookupByLibrary.simpleMessage("A"),
        "appName": MessageLookupByLibrary.simpleMessage("Discuzhao"),
        "autoLoad": MessageLookupByLibrary.simpleMessage("Auto load"),
        "autoLoadDescribe": MessageLookupByLibrary.simpleMessage(
            "Automatically refresh the slide to the bottom"),
        "ballPulseDescribe":
            MessageLookupByLibrary.simpleMessage("Ball pulse style"),
        "basicUse": MessageLookupByLibrary.simpleMessage("Basic"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("Basic use of EasyRefresh"),
        "bezierCircleDescribe":
            MessageLookupByLibrary.simpleMessage("Popup circle style"),
        "bezierHourGlassDescribe":
            MessageLookupByLibrary.simpleMessage("Popup HourGlass style"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob minion"),
        "bobMinionDescribe":
            MessageLookupByLibrary.simpleMessage("Cute yellow Minions"),
        "bottomBouncing":
            MessageLookupByLibrary.simpleMessage("Bottom bouncing"),
        "bottomBouncingDescribe":
            MessageLookupByLibrary.simpleMessage("Bottom can be crossed"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captchaRequired":
            MessageLookupByLibrary.simpleMessage("Captcha required."),
        "chatPage": MessageLookupByLibrary.simpleMessage("Chat page"),
        "chatPageDescribe":
            MessageLookupByLibrary.simpleMessage("Chat page example"),
        "chengdu": MessageLookupByLibrary.simpleMessage("China - ChengDu"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("Choose a BBS"),
        "city": MessageLookupByLibrary.simpleMessage("City"),
        "classic": MessageLookupByLibrary.simpleMessage("Classic"),
        "classicDescribe":
            MessageLookupByLibrary.simpleMessage("Classic and default"),
        "clearAllViewHistories":
            MessageLookupByLibrary.simpleMessage("Clear all histories"),
        "common": MessageLookupByLibrary.simpleMessage("Common"),
        "completeLoad": MessageLookupByLibrary.simpleMessage("Load done"),
        "completeRefresh": MessageLookupByLibrary.simpleMessage("Refresh done"),
        "controlFinish": MessageLookupByLibrary.simpleMessage("Control finish"),
        "controlFinishDescribe": MessageLookupByLibrary.simpleMessage(
            "Using Controller to End Asynchronous Tasks"),
        "cupertinoDescribe": MessageLookupByLibrary.simpleMessage("ios style"),
        "customScrollViewDescribe": MessageLookupByLibrary.simpleMessage(
            "List with AppBar Folding, listener example"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccountSuccessfully": m0,
        "deleteDiscuzSuccessfully": m1,
        "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
            "Clearing operation is irrecoverable, please take care."),
        "deliveryDescribe":
            MessageLookupByLibrary.simpleMessage("Express balloon"),
        "direction": MessageLookupByLibrary.simpleMessage("Direction"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadingFiles": m2,
        "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "emptyListDescription":
            MessageLookupByLibrary.simpleMessage("The content is empty"),
        "emptyWidget": MessageLookupByLibrary.simpleMessage("Empty widget"),
        "emptyWidgetDescribe": MessageLookupByLibrary.simpleMessage(
            "Show empty widget when there is no data"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "firstRefresh": MessageLookupByLibrary.simpleMessage("First refresh"),
        "firstRefreshDescribe":
            MessageLookupByLibrary.simpleMessage("First refresh widget"),
        "floatView": MessageLookupByLibrary.simpleMessage("Floating view"),
        "floatViewDescribe": MessageLookupByLibrary.simpleMessage(
            "At the top or bottom view floating on the list"),
        "forgetPassword":
            MessageLookupByLibrary.simpleMessage("Forget password?"),
        "forumDisplayTitle":
            MessageLookupByLibrary.simpleMessage("Display a forum"),
        "forumFilterSortByHeat": MessageLookupByLibrary.simpleMessage("Heat"),
        "forumFilterSortByLastPost":
            MessageLookupByLibrary.simpleMessage("Last post"),
        "forumFilterSortByNewPost":
            MessageLookupByLibrary.simpleMessage("New post"),
        "forumFilterSortByTitle":
            MessageLookupByLibrary.simpleMessage("Sort by"),
        "forumFilterSortByView": MessageLookupByLibrary.simpleMessage("View"),
        "forumFilterSpecialTypeActivity":
            MessageLookupByLibrary.simpleMessage("Activity"),
        "forumFilterSpecialTypeDebate":
            MessageLookupByLibrary.simpleMessage("Debate"),
        "forumFilterSpecialTypePoll":
            MessageLookupByLibrary.simpleMessage("Poll"),
        "forumFilterSpecialTypeTitle":
            MessageLookupByLibrary.simpleMessage("Special Thread"),
        "forumFilterStatusAll": MessageLookupByLibrary.simpleMessage("All"),
        "forumFilterStatusDigest":
            MessageLookupByLibrary.simpleMessage("Digest"),
        "forumFilterStatusHot": MessageLookupByLibrary.simpleMessage("Hot"),
        "forumFilterStatusTitle":
            MessageLookupByLibrary.simpleMessage("Thread Status"),
        "forumFilterTimeThisMonth":
            MessageLookupByLibrary.simpleMessage("This month"),
        "forumFilterTimeThisQuarter":
            MessageLookupByLibrary.simpleMessage("This quarter"),
        "forumFilterTimeThisWeek":
            MessageLookupByLibrary.simpleMessage("This week"),
        "forumFilterTimeThisYear":
            MessageLookupByLibrary.simpleMessage("This year"),
        "forumFilterTimeTitle":
            MessageLookupByLibrary.simpleMessage("Time Filter"),
        "forumFilterTimeToday": MessageLookupByLibrary.simpleMessage("Today"),
        "forumFilterTypeIdTitle":
            MessageLookupByLibrary.simpleMessage("Category"),
        "github": MessageLookupByLibrary.simpleMessage("Github"),
        "googleAdSubTitle": MessageLookupByLibrary.simpleMessage(
            "Advertisement provided by Google"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("AD"),
        "hangzhou": MessageLookupByLibrary.simpleMessage("China - HangZhou"),
        "headerFloat": MessageLookupByLibrary.simpleMessage("Header float"),
        "headerFloatDescribe": MessageLookupByLibrary.simpleMessage(
            "Header is displayed on the list"),
        "horizontal": MessageLookupByLibrary.simpleMessage("Horizontal"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage(
            "You will browse the forum in incognito mode"),
        "incognitoTitle":
            MessageLookupByLibrary.simpleMessage("Incognito mode"),
        "index": MessageLookupByLibrary.simpleMessage("Index"),
        "infiniteLoad": MessageLookupByLibrary.simpleMessage("Infinite load"),
        "infiniteLoadDescribe": MessageLookupByLibrary.simpleMessage(
            "Slide to bottom trigger loading"),
        "joinDiscussion":
            MessageLookupByLibrary.simpleMessage("Join the discussion"),
        "joinDiscussionDescribe":
            MessageLookupByLibrary.simpleMessage("Join the QQ group 554981921"),
        "linkHeader": MessageLookupByLibrary.simpleMessage("Header linker"),
        "linkHeaderDescribeDescribe": MessageLookupByLibrary.simpleMessage(
            "Customize Header with linker"),
        "linkUnableToOpen": m3,
        "listDirection": MessageLookupByLibrary.simpleMessage("List direction"),
        "listEmbed": MessageLookupByLibrary.simpleMessage("List embed"),
        "listEmbedDescribe": MessageLookupByLibrary.simpleMessage(
            "Use the connector to set the Header and Footer positions"),
        "listReverse": MessageLookupByLibrary.simpleMessage("List reverse"),
        "loadFailed": MessageLookupByLibrary.simpleMessage("Load failed"),
        "loadFinish": MessageLookupByLibrary.simpleMessage("Load completed"),
        "loadMore": MessageLookupByLibrary.simpleMessage("LoadMore"),
        "loadSwitch": MessageLookupByLibrary.simpleMessage("Load switch"),
        "loadSwitchDescribe":
            MessageLookupByLibrary.simpleMessage("Whether to turn on load"),
        "loaded": MessageLookupByLibrary.simpleMessage("Load completed"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loginByWebHttpWarn": MessageLookupByLibrary.simpleMessage(
            "Please be aware that you are browsing a HTTP-served webpage, and it may be modified by a third-party entity. You should take caution in sending your information via the protocol. Consider using HTTPS for safety."),
        "loginByWebMessage": MessageLookupByLibrary.simpleMessage(
            "Please login via webpage then press the floating button on bottom-right to save the authentication to the device."),
        "loginByWebNotSupported": MessageLookupByLibrary.simpleMessage(
            "Current operation system doesn\'t support webview."),
        "loginByWebTitle":
            MessageLookupByLibrary.simpleMessage("How to login by web?"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage("Add a new user"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("Login"),
        "manageAccount": MessageLookupByLibrary.simpleMessage("Manage account"),
        "manageAccountTitle":
            MessageLookupByLibrary.simpleMessage("Manage accounts"),
        "manageDiscuz": MessageLookupByLibrary.simpleMessage("Manage BBS"),
        "manualControl": MessageLookupByLibrary.simpleMessage("Manual control"),
        "manualControlDescribe": MessageLookupByLibrary.simpleMessage(
            "Control the timing of completion of refresh and load"),
        "materialDescribe": MessageLookupByLibrary.simpleMessage(
            "Material design, Android style"),
        "me": MessageLookupByLibrary.simpleMessage("Me"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "moreStyle": MessageLookupByLibrary.simpleMessage("More style"),
        "moreStyleDescribe": MessageLookupByLibrary.simpleMessage(
            "Come soon! You can also refer to the source code customization"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nestedScrollViewDescribe":
            MessageLookupByLibrary.simpleMessage("NestedScrollView example"),
        "noBald": MessageLookupByLibrary.simpleMessage("Has not the bald"),
        "noData": MessageLookupByLibrary.simpleMessage("No data"),
        "noMore": MessageLookupByLibrary.simpleMessage("No more"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "nullDiscuzSubTitle": MessageLookupByLibrary.simpleMessage(
            "Why not consider add a discuz forum?"),
        "nullDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("No Discuz! BBS is selected"),
        "ok": MessageLookupByLibrary.simpleMessage("ok"),
        "old": MessageLookupByLibrary.simpleMessage("Old"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("Open"),
        "openFileInExternalAppContent": MessageLookupByLibrary.simpleMessage(
            "File downloads successfully. Do you want to open it now?"),
        "openInBrowser":
            MessageLookupByLibrary.simpleMessage("Open in browser"),
        "openSourceLicence":
            MessageLookupByLibrary.simpleMessage("Open source licence"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "Host of the link is not the same as the BBS. It would be dangerous to browse."),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage(
            "The link doesn\'t belong to the BBS"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "payPal": MessageLookupByLibrary.simpleMessage("PayPal"),
        "phoenixDescribe":
            MessageLookupByLibrary.simpleMessage("Golden campus"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "policy": MessageLookupByLibrary.simpleMessage("Our policy"),
        "pollExpireAt": m4,
        "pollVoterNumber": m5,
        "postPosition": m6,
        "preparingPage":
            MessageLookupByLibrary.simpleMessage("Preparing the page."),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "progressButtonLoginFailed":
            MessageLookupByLibrary.simpleMessage("Login Failed"),
        "progressButtonLoginSuccess":
            MessageLookupByLibrary.simpleMessage("Login Success"),
        "progressButtonLogining":
            MessageLookupByLibrary.simpleMessage("Sigining in..."),
        "progressButtonReplyFailed":
            MessageLookupByLibrary.simpleMessage("Failed"),
        "progressButtonReplySending":
            MessageLookupByLibrary.simpleMessage("Sending"),
        "progressButtonReplySuccess":
            MessageLookupByLibrary.simpleMessage("Success"),
        "projectAddress":
            MessageLookupByLibrary.simpleMessage("Project address"),
        "publishAt": MessageLookupByLibrary.simpleMessage(" published at "),
        "pullToRefresh":
            MessageLookupByLibrary.simpleMessage("Pull to refresh"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("Push to load"),
        "qqGroup": MessageLookupByLibrary.simpleMessage("QQ group"),
        "qqPay": MessageLookupByLibrary.simpleMessage("QQ Pay"),
        "recordHistoryOffDescription": MessageLookupByLibrary.simpleMessage(
            "App Won\'t record your browser history"),
        "recordHistoryOnDescription": MessageLookupByLibrary.simpleMessage(
            "App will record your browser history"),
        "recordHistoryTitle":
            MessageLookupByLibrary.simpleMessage("Record history"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "refreshFailed": MessageLookupByLibrary.simpleMessage("Refresh failed"),
        "refreshFinish":
            MessageLookupByLibrary.simpleMessage("Refresh completed"),
        "refreshSwitch": MessageLookupByLibrary.simpleMessage("Refresh switch"),
        "refreshSwitchDescribe":
            MessageLookupByLibrary.simpleMessage("Whether to turn on refresh"),
        "refreshed": MessageLookupByLibrary.simpleMessage("Refresh completed"),
        "refreshing": MessageLookupByLibrary.simpleMessage("Refreshing..."),
        "releaseToLoad":
            MessageLookupByLibrary.simpleMessage("Release to load"),
        "releaseToRefresh":
            MessageLookupByLibrary.simpleMessage("Release to refresh"),
        "relogin": MessageLookupByLibrary.simpleMessage("relogin"),
        "retry": MessageLookupByLibrary.simpleMessage("retry"),
        "reverse": MessageLookupByLibrary.simpleMessage("reverse"),
        "sample": MessageLookupByLibrary.simpleMessage("Sample"),
        "saveImageSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Save Image to device successfully."),
        "savePictureToDevice": MessageLookupByLibrary.simpleMessage("Save"),
        "scrollBar": MessageLookupByLibrary.simpleMessage("ScrollBar"),
        "scrollBarDescribe": MessageLookupByLibrary.simpleMessage(
            "Add a scroll bar to the list"),
        "secondFloor": MessageLookupByLibrary.simpleMessage("Second floor"),
        "secondFloorDescribe": MessageLookupByLibrary.simpleMessage(
            "Imitate the second floor of Taobao"),
        "selectUserNull": MessageLookupByLibrary.simpleMessage(
            "No user is currently activated"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendReply": MessageLookupByLibrary.simpleMessage("Send"),
        "sendReplyHint": MessageLookupByLibrary.simpleMessage("Say something"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "signInSuccessTitle": m7,
        "signInTitle": m8,
        "signInViaBrowser":
            MessageLookupByLibrary.simpleMessage("Sign in by web"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "spaceDescribe":
            MessageLookupByLibrary.simpleMessage("Flare animation - Space"),
        "star": MessageLookupByLibrary.simpleMessage("Star project"),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "submitPoll": m9,
        "successfullyDeleteViewHistoryContent": m10,
        "successfullyDownloadFiles": m11,
        "supportAuthor":
            MessageLookupByLibrary.simpleMessage("Support the author"),
        "supportAuthorDescribe": MessageLookupByLibrary.simpleMessage(
            "Your support is my biggest motivation"),
        "swiperDescribe": MessageLookupByLibrary.simpleMessage(
            "Swiper example, resolve sliding conflicts"),
        "tabViewWidgetDescribe": MessageLookupByLibrary.simpleMessage(
            "List and Grid consist of TabBarView"),
        "taskIndependence":
            MessageLookupByLibrary.simpleMessage("Task independence"),
        "taskIndependenceDescribe": MessageLookupByLibrary.simpleMessage(
            "Refresh and load tasks are not affected by each other"),
        "taurusDescribe":
            MessageLookupByLibrary.simpleMessage("Rushing into the sky"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "topBouncing": MessageLookupByLibrary.simpleMessage("Top bouncing"),
        "topBouncingDescribe":
            MessageLookupByLibrary.simpleMessage("Top can be crossed"),
        "trustHostActionText":
            MessageLookupByLibrary.simpleMessage("Trust this host"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("Trusted host"),
        "unableToVerifyAuthStatus": MessageLookupByLibrary.simpleMessage(
            "Unable to verify your auth status"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "updateAt": MessageLookupByLibrary.simpleMessage("Update at %T"),
        "userExpiredSubtitle": MessageLookupByLibrary.simpleMessage(
            "The current user is expired, some function may not work."),
        "userExpiredTitle": m12,
        "userIdTitle": m13,
        "userProfile": MessageLookupByLibrary.simpleMessage("User Profile"),
        "userProfileDescribe": MessageLookupByLibrary.simpleMessage(
            "User Profile with the springback effect"),
        "vertical": MessageLookupByLibrary.simpleMessage("Vertical"),
        "vibration": MessageLookupByLibrary.simpleMessage("vibration"),
        "vibrationDescribe": MessageLookupByLibrary.simpleMessage(
            "Triggered vibration feedback"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
        "viewThreadTitle":
            MessageLookupByLibrary.simpleMessage("View a thread"),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("Full display"),
        "weiXinPay": MessageLookupByLibrary.simpleMessage("WeiXin Pay"),
        "welcomeToSecondFloor":
            MessageLookupByLibrary.simpleMessage("Welcome to second floor"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage(
            "Write storage permission denied.")
      };
}
