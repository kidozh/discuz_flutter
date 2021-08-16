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

  static String m1(day) => "${day} days ago";

  static String m2(day) => "${day} days later";

  static String m3(account) => "Delete account ${account} successfully.";

  static String m4(account) => "Delete discuz ${account} successfully.";

  static String m5(filename) => "Downloading file: ${filename} in background.";

  static String m6(size) => "${size} pt";

  static String m7(size) => "x ${size}";

  static String m8(readAccess, star) =>
      "Read Access: ${readAccess} and Star: ${star}";

  static String m9(hour) => "${hour} hours ago";

  static String m10(hour) => "${hour} hours later";

  static String m11(uri) => "Unable to open the uri: ${uri}.";

  static String m12(min) => "${min} minutes ago";

  static String m13(min) => "${min} minutes later";

  static String m14(hour) => "${hour} hour(s).";

  static String m15(time) => "Poll will expire at ${time}.";

  static String m16(people) => "${people} have voted.";

  static String m17(pos) => "# ${pos}";

  static String m18(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} posted at ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m19(username, discuzName) =>
      "User ${username} sign in at ${discuzName} successfully.";

  static String m20(discuzName) => "Sign in at ${discuzName}";

  static String m21(index) => "Smiley #${index}";

  static String m22(checked, allowed) => "Submit (${checked} / ${allowed})";

  static String m23(title) => "Successfully remove view history ${title}.";

  static String m24(filename) => "Successfully download file: ${filename}.";

  static String m25(username) => "User ${username} expired";

  static String m26(uid) => "UserId ${uid}";

  static String m27(user) => "View ${user}\'s profile.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "addDiscuzSuccessfully": m0,
        "addDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("Add a discuz! BBS"),
        "addNewDiscuz":
            MessageLookupByLibrary.simpleMessage("Add a new Discuz! forum"),
        "anonymous": MessageLookupByLibrary.simpleMessage("A"),
        "appName": MessageLookupByLibrary.simpleMessage("Discuzhao"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("Platform preference"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose the app appearance on preferred platform."),
        "basicUse": MessageLookupByLibrary.simpleMessage("Basic"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("Basic use of EasyRefresh"),
        "bio": MessageLookupByLibrary.simpleMessage("Bio"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("Birth place"),
        "blockedPost":
            MessageLookupByLibrary.simpleMessage("The post is blocked."),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob minion"),
        "bobMinionDescribe":
            MessageLookupByLibrary.simpleMessage("Cute yellow Minions"),
        "brightnessDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "brightnessLight": MessageLookupByLibrary.simpleMessage("Light"),
        "buildDescription": MessageLookupByLibrary.simpleMessage(
            "Built with flutter, made with ♥, run on multiple platforms."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captchaRequired":
            MessageLookupByLibrary.simpleMessage("Captcha required."),
        "chatMessage": MessageLookupByLibrary.simpleMessage("Chat"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("Choose a BBS"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("Theme color"),
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
        "credit": MessageLookupByLibrary.simpleMessage("Credit"),
        "customStatusTitle":
            MessageLookupByLibrary.simpleMessage("Custom title"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "dayAgo": m1,
        "dayLater": m2,
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccountSuccessfully": m3,
        "deleteDiscuzSuccessfully": m4,
        "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
            "Clearing operation is irrecoverable, please take care."),
        "discuzServerAddress":
            MessageLookupByLibrary.simpleMessage("The Discuz\'s address"),
        "discuzServerAddressHelperText": MessageLookupByLibrary.simpleMessage(
            "It usually is the address discuz serves."),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("eg. https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("Display"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadingFiles": m5,
        "emptyListDescription":
            MessageLookupByLibrary.simpleMessage("The content is empty"),
        "emptyScreenTitle":
            MessageLookupByLibrary.simpleMessage("The content here is empty."),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
        "fontSizeInParagraph":
            MessageLookupByLibrary.simpleMessage("Font size in paragraph"),
        "fontSizeInParagraphUnit": m6,
        "fontSizeScaleParameter": MessageLookupByLibrary.simpleMessage(
            "Scale parameter in typesetting"),
        "fontSizeScaleParameterUnit": m7,
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
        "googleAdSubTitle": MessageLookupByLibrary.simpleMessage(
            "Advertisement provided by Google"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("AD"),
        "groupInfoDescription": m8,
        "habit": MessageLookupByLibrary.simpleMessage("Habits"),
        "homepage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "hourAgo": m9,
        "hourLater": m10,
        "httpBrowseWarn":
            MessageLookupByLibrary.simpleMessage("HTTP protocol warning"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage(
            "You will browse the forum in incognito mode"),
        "incognitoTitle":
            MessageLookupByLibrary.simpleMessage("Incognito mode"),
        "incorrectDiscuzAddress":
            MessageLookupByLibrary.simpleMessage("Invalid discuz address."),
        "index": MessageLookupByLibrary.simpleMessage("Index"),
        "interfaceBrightness":
            MessageLookupByLibrary.simpleMessage("Interface Brightness"),
        "ios": MessageLookupByLibrary.simpleMessage("iOS"),
        "justNow": MessageLookupByLibrary.simpleMessage("Just Now"),
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
        "linkUnableToOpen": m11,
        "loadFailed": MessageLookupByLibrary.simpleMessage("Load failed"),
        "loadFinish": MessageLookupByLibrary.simpleMessage("Load completed"),
        "loadMore": MessageLookupByLibrary.simpleMessage("LoadMore"),
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
        "materialDesign":
            MessageLookupByLibrary.simpleMessage("Material Design"),
        "me": MessageLookupByLibrary.simpleMessage("Me"),
        "minuteAgo": m12,
        "minuteLater": m13,
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "noMore": MessageLookupByLibrary.simpleMessage("No more"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "nullDiscuzSubTitle": MessageLookupByLibrary.simpleMessage(
            "Why not consider add a discuz forum?"),
        "nullDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("No Discuz! BBS is selected"),
        "ok": MessageLookupByLibrary.simpleMessage("ok"),
        "onlineHours": m14,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("Online Time"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("Open"),
        "openFileInExternalAppContent": MessageLookupByLibrary.simpleMessage(
            "File downloads successfully. Do you want to open it now?"),
        "openInBrowser":
            MessageLookupByLibrary.simpleMessage("Open in browser"),
        "openSourceLicence":
            MessageLookupByLibrary.simpleMessage("Open source licence"),
        "openViaInternalBrowser":
            MessageLookupByLibrary.simpleMessage("Open Website in webview"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "Host of the link is not the same as the BBS. It would be dangerous to browse."),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage(
            "The link doesn\'t belong to the BBS"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[Pic]"),
        "policy": MessageLookupByLibrary.simpleMessage("Our policy"),
        "pollExpireAt": m15,
        "pollVoterNumber": m16,
        "postAuthorLabel": MessageLookupByLibrary.simpleMessage("OP"),
        "postNumber": MessageLookupByLibrary.simpleMessage("Post number"),
        "postPosition": m17,
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
        "publicMessage": MessageLookupByLibrary.simpleMessage("Public"),
        "publishAt": MessageLookupByLibrary.simpleMessage(" published at "),
        "pullToRefresh":
            MessageLookupByLibrary.simpleMessage("Pull to refresh"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("Push to load"),
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
        "replyPostTrimMessage": m18,
        "residentPlace": MessageLookupByLibrary.simpleMessage("Resident place"),
        "retry": MessageLookupByLibrary.simpleMessage("retry"),
        "revisedPost": MessageLookupByLibrary.simpleMessage(
            "The post is revised to prevent duplicated scoring."),
        "sample": MessageLookupByLibrary.simpleMessage("Sample"),
        "saveImageSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Save Image to device successfully."),
        "savePictureToDevice": MessageLookupByLibrary.simpleMessage("Save"),
        "selectUserNull": MessageLookupByLibrary.simpleMessage(
            "No user is currently activated"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendReply": MessageLookupByLibrary.simpleMessage("Send"),
        "sendReplyHint": MessageLookupByLibrary.simpleMessage("Say something"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "signInSuccessTitle": m19,
        "signInTitle": m20,
        "signInViaBrowser":
            MessageLookupByLibrary.simpleMessage("Sign in by web"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "smileyLabel": m21,
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "submitPoll": m22,
        "successfullyDeleteViewHistoryContent": m23,
        "successfullyDownloadFiles": m24,
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "trustHostActionText":
            MessageLookupByLibrary.simpleMessage("Trust this host"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("Trusted host"),
        "unableToVerifyAuthStatus": MessageLookupByLibrary.simpleMessage(
            "Unable to verify your auth status"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "updateAt": MessageLookupByLibrary.simpleMessage("Update at %T"),
        "userExpiredSubtitle": MessageLookupByLibrary.simpleMessage(
            "The current user is expired, some function may not work."),
        "userExpiredTitle": m25,
        "userIdTitle": m26,
        "userProfile": MessageLookupByLibrary.simpleMessage("User Profile"),
        "userProfileTitle":
            MessageLookupByLibrary.simpleMessage("User Profiles"),
        "viewAuthorInfo":
            MessageLookupByLibrary.simpleMessage("View author\'s profile"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
        "viewThreadTitle":
            MessageLookupByLibrary.simpleMessage("View a thread"),
        "viewUserInfo": m27,
        "warnedPost":
            MessageLookupByLibrary.simpleMessage("The post is warned."),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("Full display"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage(
            "Write storage permission denied.")
      };
}
