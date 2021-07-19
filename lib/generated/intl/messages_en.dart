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

  static String m0(discuz) => "Add ${discuz} to your device successfully.";

  static String m1(account) => "Delete account ${account} successfully.";

  static String m2(account) => "Delete discuz ${account} successfully.";

  static String m3(filename) => "Downloading file: ${filename} in background.";

  static String m4(size) => "${size} pt";

  static String m5(size) => "x ${size}";

  static String m6(readAccess, star) =>
      "Read Access: ${readAccess} and Star: ${star}";

  static String m7(uri) => "Unable to open the uri: ${uri}.";

  static String m8(hour) => "${hour} hour(s).";

  static String m9(time) => "Poll will expire at ${time}.";

  static String m10(people) => "${people} have voted.";

  static String m11(pos) => "# ${pos}";

  static String m12(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} posted at ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m13(username, discuzName) =>
      "User ${username} sign in at ${discuzName} successfully.";

  static String m14(discuzName) => "Sign in at ${discuzName}";

  static String m15(checked, allowed) => "Submit (${checked} / ${allowed})";

  static String m16(title) => "Successfully remove view history ${title}.";

  static String m17(filename) => "Successfully download file: ${filename}.";

  static String m18(username) => "User ${username} expired";

  static String m19(uid) => "UserId ${uid}";

  static String m20(user) => "View ${user}\'s profile.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "addDiscuzSuccessfully": m0,
        "addDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("Add a discuz! BBS"),
        "addNewDiscuz":
            MessageLookupByLibrary.simpleMessage("Add a new Discuz! forum"),
        "aliPay": MessageLookupByLibrary.simpleMessage("AliPay"),
        "android": MessageLookupByLibrary.simpleMessage(
            "Android / Harmony OS(compatible)"),
        "anonymous": MessageLookupByLibrary.simpleMessage("A"),
        "appName": MessageLookupByLibrary.simpleMessage("Discuzhao"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("Platform preference"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose the app appearance on preferred platform."),
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
        "bio": MessageLookupByLibrary.simpleMessage("Bio"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("Birth place"),
        "blockedPost":
            MessageLookupByLibrary.simpleMessage("The post is blocked."),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob minion"),
        "bobMinionDescribe":
            MessageLookupByLibrary.simpleMessage("Cute yellow Minions"),
        "bottomBouncing":
            MessageLookupByLibrary.simpleMessage("Bottom bouncing"),
        "bottomBouncingDescribe":
            MessageLookupByLibrary.simpleMessage("Bottom can be crossed"),
        "buildDescription": MessageLookupByLibrary.simpleMessage(
            "Built with flutter, made with ♥, run on multiple platforms."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captchaRequired":
            MessageLookupByLibrary.simpleMessage("Captcha required."),
        "chatMessage": MessageLookupByLibrary.simpleMessage("Chat"),
        "chatPage": MessageLookupByLibrary.simpleMessage("Chat page"),
        "chatPageDescribe":
            MessageLookupByLibrary.simpleMessage("Chat page example"),
        "chengdu": MessageLookupByLibrary.simpleMessage("China - ChengDu"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("Choose a BBS"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("Theme color"),
        "city": MessageLookupByLibrary.simpleMessage("City"),
        "classic": MessageLookupByLibrary.simpleMessage("Classic"),
        "classicDescribe":
            MessageLookupByLibrary.simpleMessage("Classic and default"),
        "clearAllViewHistories":
            MessageLookupByLibrary.simpleMessage("Clear all histories"),
        "colorAmber": MessageLookupByLibrary.simpleMessage("Amber"),
        "colorBlack": MessageLookupByLibrary.simpleMessage("Black"),
        "colorBlue": MessageLookupByLibrary.simpleMessage("Blue"),
        "colorBlueAccent": MessageLookupByLibrary.simpleMessage("Blue Accent"),
        "colorBlueGrey": MessageLookupByLibrary.simpleMessage("Blue Grey"),
        "colorBrown": MessageLookupByLibrary.simpleMessage("Brown"),
        "colorCyan": MessageLookupByLibrary.simpleMessage("Cyan"),
        "colorDeepOrange": MessageLookupByLibrary.simpleMessage("Deep orange"),
        "colorDeepPurple": MessageLookupByLibrary.simpleMessage("Deep purple"),
        "colorDeepPurpleAccent":
            MessageLookupByLibrary.simpleMessage("Deep purple accent"),
        "colorGreen": MessageLookupByLibrary.simpleMessage("Green"),
        "colorGrey": MessageLookupByLibrary.simpleMessage("Grey"),
        "colorIndigo": MessageLookupByLibrary.simpleMessage("Indigo"),
        "colorIndigoAccent":
            MessageLookupByLibrary.simpleMessage("Indigo accent"),
        "colorLightBlue": MessageLookupByLibrary.simpleMessage("Light blue"),
        "colorLightGreen": MessageLookupByLibrary.simpleMessage("Light green"),
        "colorLime": MessageLookupByLibrary.simpleMessage("Lime"),
        "colorOrange": MessageLookupByLibrary.simpleMessage("Orange"),
        "colorPink": MessageLookupByLibrary.simpleMessage("Pink"),
        "colorPurple": MessageLookupByLibrary.simpleMessage("Purple"),
        "colorRed": MessageLookupByLibrary.simpleMessage("Red"),
        "colorTeal": MessageLookupByLibrary.simpleMessage("Teal"),
        "colorYellow": MessageLookupByLibrary.simpleMessage("Yellow"),
        "common": MessageLookupByLibrary.simpleMessage("Common"),
        "completeLoad": MessageLookupByLibrary.simpleMessage("Load done"),
        "completeRefresh": MessageLookupByLibrary.simpleMessage("Refresh done"),
        "connectServerWhenAdding": MessageLookupByLibrary.simpleMessage(
            "Connect to BBS server for verification."),
        "continueAdding": MessageLookupByLibrary.simpleMessage("Continue"),
        "controlFinish": MessageLookupByLibrary.simpleMessage("Control finish"),
        "controlFinishDescribe": MessageLookupByLibrary.simpleMessage(
            "Using Controller to End Asynchronous Tasks"),
        "credit": MessageLookupByLibrary.simpleMessage("Credit"),
        "cupertinoDescribe": MessageLookupByLibrary.simpleMessage("ios style"),
        "customScrollViewDescribe": MessageLookupByLibrary.simpleMessage(
            "List with AppBar Folding, listener example"),
        "customStatusTitle":
            MessageLookupByLibrary.simpleMessage("Custom title"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccountSuccessfully": m1,
        "deleteDiscuzSuccessfully": m2,
        "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
            "Clearing operation is irrecoverable, please take care."),
        "deliveryDescribe":
            MessageLookupByLibrary.simpleMessage("Express balloon"),
        "direction": MessageLookupByLibrary.simpleMessage("Direction"),
        "discuzServerAddress":
            MessageLookupByLibrary.simpleMessage("The Discuz\'s address"),
        "discuzServerAddressHelperText": MessageLookupByLibrary.simpleMessage(
            "It usually is the address discuz serves."),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("eg. https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("Display"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadingFiles": m3,
        "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "emptyListDescription":
            MessageLookupByLibrary.simpleMessage("The content is empty"),
        "emptyScreenTitle":
            MessageLookupByLibrary.simpleMessage("The content here is empty."),
        "emptyWidget": MessageLookupByLibrary.simpleMessage("Empty widget"),
        "emptyWidgetDescribe": MessageLookupByLibrary.simpleMessage(
            "Show empty widget when there is no data"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "firstRefresh": MessageLookupByLibrary.simpleMessage("First refresh"),
        "firstRefreshDescribe":
            MessageLookupByLibrary.simpleMessage("First refresh widget"),
        "floatView": MessageLookupByLibrary.simpleMessage("Floating view"),
        "floatViewDescribe": MessageLookupByLibrary.simpleMessage(
            "At the top or bottom view floating on the list"),
        "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
        "fontSizeInParagraph":
            MessageLookupByLibrary.simpleMessage("Font size in paragraph"),
        "fontSizeInParagraphUnit": m4,
        "fontSizeScaleParameter": MessageLookupByLibrary.simpleMessage(
            "Scale parameter in typesetting"),
        "fontSizeScaleParameterUnit": m5,
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
        "friendNumber": MessageLookupByLibrary.simpleMessage("Friends"),
        "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
        "github": MessageLookupByLibrary.simpleMessage("Github"),
        "googleAdSubTitle": MessageLookupByLibrary.simpleMessage(
            "Advertisement provided by Google"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("AD"),
        "groupInfoDescription": m6,
        "habit": MessageLookupByLibrary.simpleMessage("Habits"),
        "hangzhou": MessageLookupByLibrary.simpleMessage("China - HangZhou"),
        "headerFloat": MessageLookupByLibrary.simpleMessage("Header float"),
        "headerFloatDescribe": MessageLookupByLibrary.simpleMessage(
            "Header is displayed on the list"),
        "homepage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "horizontal": MessageLookupByLibrary.simpleMessage("Horizontal"),
        "httpBrowseWarn":
            MessageLookupByLibrary.simpleMessage("HTTP protocol warning"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage(
            "You will browse the forum in incognito mode"),
        "incognitoTitle":
            MessageLookupByLibrary.simpleMessage("Incognito mode"),
        "incorrectDiscuzAddress":
            MessageLookupByLibrary.simpleMessage("Invalid discuz address."),
        "index": MessageLookupByLibrary.simpleMessage("Index"),
        "infiniteLoad": MessageLookupByLibrary.simpleMessage("Infinite load"),
        "infiniteLoadDescribe": MessageLookupByLibrary.simpleMessage(
            "Slide to bottom trigger loading"),
        "ios": MessageLookupByLibrary.simpleMessage("iOS"),
        "joinDiscussion":
            MessageLookupByLibrary.simpleMessage("Join the discussion"),
        "joinDiscussionDescribe":
            MessageLookupByLibrary.simpleMessage("Join the QQ group 554981921"),
        "largeRichText": MessageLookupByLibrary.simpleMessage(
            "Welcome to Discuzhub<br/>Thanks for using our products and <a href=\"https://discuzhub.kidozh.com/en/term_of_use/\">services</a> (“Services”).<br/>By using our Services, you are agreeing to these terms. Please read them <b>carefully</b>.<br/>Our Services are very diverse, so sometimes additional terms or product requirements (including age requirements) may apply. Additional terms will be available with the relevant Services, and those additional terms become part of your agreement with us if you use those Services"),
        "largeRichTextDescription": MessageLookupByLibrary.simpleMessage(
            "Comes From Our Term of Services"),
        "lastActivityTime":
            MessageLookupByLibrary.simpleMessage("Last active at"),
        "lastPostTime": MessageLookupByLibrary.simpleMessage("Last post at"),
        "lastVisitTime": MessageLookupByLibrary.simpleMessage("Last visit at"),
        "legalInformation":
            MessageLookupByLibrary.simpleMessage("Legal information"),
        "linkHeader": MessageLookupByLibrary.simpleMessage("Header linker"),
        "linkHeaderDescribeDescribe": MessageLookupByLibrary.simpleMessage(
            "Customize Header with linker"),
        "linkUnableToOpen": m7,
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
        "onlineHours": m8,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("Online Time"),
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
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[Pic]"),
        "policy": MessageLookupByLibrary.simpleMessage("Our policy"),
        "pollExpireAt": m9,
        "pollVoterNumber": m10,
        "postAuthorLabel": MessageLookupByLibrary.simpleMessage("OP"),
        "postNumber": MessageLookupByLibrary.simpleMessage("Post number"),
        "postPosition": m11,
        "preparingPage":
            MessageLookupByLibrary.simpleMessage("Preparing the page."),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "privateMessage": MessageLookupByLibrary.simpleMessage("Private"),
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
        "publicMessage": MessageLookupByLibrary.simpleMessage("Public"),
        "publishAt": MessageLookupByLibrary.simpleMessage(" published at "),
        "pullToRefresh":
            MessageLookupByLibrary.simpleMessage("Pull to refresh"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("Push to load"),
        "qqGroup": MessageLookupByLibrary.simpleMessage("QQ group"),
        "qqPay": MessageLookupByLibrary.simpleMessage("QQ Pay"),
        "recentNote": MessageLookupByLibrary.simpleMessage("Recent note"),
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
        "registerAccountTime":
            MessageLookupByLibrary.simpleMessage("Register at"),
        "releaseToLoad":
            MessageLookupByLibrary.simpleMessage("Release to load"),
        "releaseToRefresh":
            MessageLookupByLibrary.simpleMessage("Release to refresh"),
        "relogin": MessageLookupByLibrary.simpleMessage("relogin"),
        "replyPost": MessageLookupByLibrary.simpleMessage("Reply"),
        "replyPostTrimMessage": m12,
        "residentPlace": MessageLookupByLibrary.simpleMessage("Resident place"),
        "retry": MessageLookupByLibrary.simpleMessage("retry"),
        "reverse": MessageLookupByLibrary.simpleMessage("reverse"),
        "revisedPost": MessageLookupByLibrary.simpleMessage(
            "The post is revised to prevent duplicated scoring."),
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
        "signInSuccessTitle": m13,
        "signInTitle": m14,
        "signInViaBrowser":
            MessageLookupByLibrary.simpleMessage("Sign in by web"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "spaceDescribe":
            MessageLookupByLibrary.simpleMessage("Flare animation - Space"),
        "star": MessageLookupByLibrary.simpleMessage("Star project"),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "submitPoll": m15,
        "successfullyDeleteViewHistoryContent": m16,
        "successfullyDownloadFiles": m17,
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
        "userExpiredTitle": m18,
        "userIdTitle": m19,
        "userProfile": MessageLookupByLibrary.simpleMessage("User Profile"),
        "userProfileDescribe": MessageLookupByLibrary.simpleMessage(
            "User Profile with the springback effect"),
        "userProfileTitle":
            MessageLookupByLibrary.simpleMessage("User Profiles"),
        "vertical": MessageLookupByLibrary.simpleMessage("Vertical"),
        "vibration": MessageLookupByLibrary.simpleMessage("vibration"),
        "vibrationDescribe": MessageLookupByLibrary.simpleMessage(
            "Triggered vibration feedback"),
        "viewAuthorInfo":
            MessageLookupByLibrary.simpleMessage("View author\'s profile"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
        "viewThreadTitle":
            MessageLookupByLibrary.simpleMessage("View a thread"),
        "viewUserInfo": m20,
        "warnedPost":
            MessageLookupByLibrary.simpleMessage("The post is warned."),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("Full display"),
        "weiXinPay": MessageLookupByLibrary.simpleMessage("WeiXin Pay"),
        "welcomeToSecondFloor":
            MessageLookupByLibrary.simpleMessage("Welcome to second floor"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage(
            "Write storage permission denied.")
      };
}
