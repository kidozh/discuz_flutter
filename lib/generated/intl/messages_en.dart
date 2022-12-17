// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(discuz) => "Add ${discuz} to your device successfully.";

  static String m1(index) => "Upload #${index}";

  static String m2(version, number) => "Build ver. ${version}, num ${number}";

  static String m3(username) =>
      "This content is posted from block user ${username}";

  static String m4(day) => "${day} days ago";

  static String m5(day) => "${day} days later";

  static String m6(account) => "Delete account ${account} successfully.";

  static String m7(account) => "Delete discuz ${account} successfully.";

  static String m8(key, content) => "${content}(${key})";

  static String m9(filename) => "Downloading file: ${filename} in background.";

  static String m10(size) => "${size} pt";

  static String m11(size) => "x ${size}";

  static String m12(device) => "Sent by ${device}.";

  static String m13(readAccess, star) =>
      "Read Access: ${readAccess} and Star: ${star}";

  static String m14(hour) => "${hour} hours ago";

  static String m15(hour) => "${hour} hours later";

  static String m16(uri) => "Unable to open the uri: ${uri}.";

  static String m17(name) => "${name}\'s Linux device";

  static String m18(name) => "${name}\'s MacOS device";

  static String m19(min) => "${min} minutes ago";

  static String m20(min) => "${min} minutes later";

  static String m21(hour) => "${hour} hour(s).";

  static String m22(time) => "Poll will expire at ${time}.";

  static String m23(people) => "${people} have voted.";

  static String m24(pos) => "# ${pos}";

  static String m25(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} posted at ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m26(name) => "Report ${name}";

  static String m27(discuzName) => "Report to the ${discuzName} Successfully";

  static String m28(username, discuzName) =>
      "User ${username} sign in at ${discuzName} successfully.";

  static String m29(discuzName) => "Sign in at ${discuzName}";

  static String m30(index) => "Smiley #${index}";

  static String m31(checked, allowed) => "Submit (${checked} / ${allowed})";

  static String m32(title) => "Successfully remove view history ${title}.";

  static String m33(filename) => "Successfully download file: ${filename}.";

  static String m34(num) =>
      "All ${num} favorite threads are synced from the server.";

  static String m35(num) => "RP ${num}";

  static String m36(username) => "User ${username} expired";

  static String m37(uid) => "UserId ${uid}";

  static String m38(user) => "View ${user}\'s profile.";

  static String m39(name) => "${name}\'s Windows device";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "adLoadingText":
            MessageLookupByLibrary.simpleMessage("AD provided by Google"),
        "addAPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
        "addDiscuzSuccessfully": m0,
        "addDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("Add a discuz! BBS"),
        "addNewDiscuz":
            MessageLookupByLibrary.simpleMessage("Add a new Discuz! site"),
        "anonymous": MessageLookupByLibrary.simpleMessage("A"),
        "appName": MessageLookupByLibrary.simpleMessage("DisFly"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("Platform preference"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose the app appearance on preferred platform."),
        "attachFile": m1,
        "authorizedSite":
            MessageLookupByLibrary.simpleMessage("Authorized site"),
        "basicUse": MessageLookupByLibrary.simpleMessage("Basic"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("Basic use of EasyRefresh"),
        "bio": MessageLookupByLibrary.simpleMessage("Bio"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("Birth place"),
        "blockUser": MessageLookupByLibrary.simpleMessage("Block user"),
        "blockedPost":
            MessageLookupByLibrary.simpleMessage("The post is blocked."),
        "blockedUserList":
            MessageLookupByLibrary.simpleMessage("Blocked user list"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob minion"),
        "bobMinionDescribe":
            MessageLookupByLibrary.simpleMessage("Cute yellow Minions"),
        "brightnessDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "brightnessLight": MessageLookupByLibrary.simpleMessage("Light"),
        "brokenCountDown":
            MessageLookupByLibrary.simpleMessage("Invalid count down timer"),
        "bugTestSubtitle": MessageLookupByLibrary.simpleMessage(
            "You can directly email us via kidozh@gmail.com. Thank you for your help!"),
        "bugTestTitle":
            MessageLookupByLibrary.simpleMessage("Sometimes bug exists"),
        "buildDescription": MessageLookupByLibrary.simpleMessage(
            "Built with flutter, made with ♥, run on multiple platforms."),
        "buildVersionDescription": m2,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captchaRequired":
            MessageLookupByLibrary.simpleMessage("Captcha required."),
        "chatMessage": MessageLookupByLibrary.simpleMessage("Chat"),
        "checkUserLoginStatus":
            MessageLookupByLibrary.simpleMessage("Check user status..."),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("Choose a BBS"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("Theme color"),
        "clearAllViewHistories":
            MessageLookupByLibrary.simpleMessage("Clear all histories"),
        "collapseItem":
            MessageLookupByLibrary.simpleMessage("Collapse content"),
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
        "contactUsViaEmail":
            MessageLookupByLibrary.simpleMessage("Contact us (Email)"),
        "contactUsViaWeibo":
            MessageLookupByLibrary.simpleMessage("Contact us (Weibo)"),
        "contentPostByBlockUserTitle": m3,
        "continueAdding": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueToDo": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueToTest":
            MessageLookupByLibrary.simpleMessage("Continue to take a bite"),
        "countDownEnd":
            MessageLookupByLibrary.simpleMessage("The count down is finished."),
        "countDownTimeZoneNotify": MessageLookupByLibrary.simpleMessage(
            "This count down timezone shall be in Asia/Shanghai and might differ from your timezone"),
        "credit": MessageLookupByLibrary.simpleMessage("Credit"),
        "customSignature": MessageLookupByLibrary.simpleMessage("Custom"),
        "customStatusTitle":
            MessageLookupByLibrary.simpleMessage("Custom title"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "dataBackupInTestSubtitle": MessageLookupByLibrary.simpleMessage(
            "The version is not permanent and your data may get lost in upgrading process."),
        "dataBackupInTestTitle":
            MessageLookupByLibrary.simpleMessage("Data backup"),
        "day": MessageLookupByLibrary.simpleMessage("D"),
        "dayAgo": m4,
        "dayLater": m5,
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccountSuccessfully": m6,
        "deleteDiscuzSuccessfully": m7,
        "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
            "Clearing operation is irrecoverable, please take care."),
        "deviceNameSignature":
            MessageLookupByLibrary.simpleMessage("Use device name"),
        "dioErrorCancel":
            MessageLookupByLibrary.simpleMessage("Response cancelled."),
        "dioErrorConnectionTimeout":
            MessageLookupByLibrary.simpleMessage("Connection timeout."),
        "dioErrorOther": MessageLookupByLibrary.simpleMessage("Parse error."),
        "dioErrorReceiveTimeout":
            MessageLookupByLibrary.simpleMessage("Receive timeout."),
        "dioErrorResponse":
            MessageLookupByLibrary.simpleMessage("Response error."),
        "dioErrorSendTimeout":
            MessageLookupByLibrary.simpleMessage("Send timeout."),
        "disableFontCustomization":
            MessageLookupByLibrary.simpleMessage("Disable custom font"),
        "disableFontCustomizationTitle": MessageLookupByLibrary.simpleMessage(
            "Ignore all customized font information"),
        "discuzOperationMessage": m8,
        "discuzServerAddress":
            MessageLookupByLibrary.simpleMessage("The Discuz\'s address"),
        "discuzServerAddressHelperText": MessageLookupByLibrary.simpleMessage(
            "It usually is the address discuz serves."),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("eg. https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("Display"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadingFiles": m9,
        "duplicatedPost":
            MessageLookupByLibrary.simpleMessage("Duplicated Posts"),
        "easyRefreshClassicFooterArmedText":
            MessageLookupByLibrary.simpleMessage("Release ready"),
        "easyRefreshClassicFooterDragText":
            MessageLookupByLibrary.simpleMessage("Pull to load"),
        "easyRefreshClassicFooterFailedText":
            MessageLookupByLibrary.simpleMessage("Failed"),
        "easyRefreshClassicFooterMessageText":
            MessageLookupByLibrary.simpleMessage("Last updated at %T"),
        "easyRefreshClassicFooterNoMoreText":
            MessageLookupByLibrary.simpleMessage("No more"),
        "easyRefreshClassicFooterProcessedText":
            MessageLookupByLibrary.simpleMessage("Succeeded"),
        "easyRefreshClassicFooterProcessingText":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "easyRefreshClassicFooterReadyText":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "easyRefreshClassicHeaderArmedText":
            MessageLookupByLibrary.simpleMessage("Release ready"),
        "easyRefreshClassicHeaderDragText":
            MessageLookupByLibrary.simpleMessage("Pull to refresh"),
        "easyRefreshClassicHeaderFailedText":
            MessageLookupByLibrary.simpleMessage("Failed"),
        "easyRefreshClassicHeaderMessageText":
            MessageLookupByLibrary.simpleMessage("Last updated at %T"),
        "easyRefreshClassicHeaderNoMoreText":
            MessageLookupByLibrary.simpleMessage("No more"),
        "easyRefreshClassicHeaderProcessedText":
            MessageLookupByLibrary.simpleMessage("Succeeded"),
        "easyRefreshClassicHeaderProcessingText":
            MessageLookupByLibrary.simpleMessage("Refreshing..."),
        "easyRefreshClassicHeaderReadyText":
            MessageLookupByLibrary.simpleMessage("Refreshing..."),
        "editedPost": MessageLookupByLibrary.simpleMessage("Edited"),
        "emptyForum": MessageLookupByLibrary.simpleMessage("No fourm here"),
        "emptyHistory": MessageLookupByLibrary.simpleMessage(
            "No history is found in your device. Have you ever browse anything or never open the history recording in the setting?"),
        "emptyListDescription":
            MessageLookupByLibrary.simpleMessage("The content is empty"),
        "emptyNotification":
            MessageLookupByLibrary.simpleMessage("No notification here."),
        "emptyPosts": MessageLookupByLibrary.simpleMessage(
            "No post is currently listed."),
        "emptyScreenTitle":
            MessageLookupByLibrary.simpleMessage("The content here is empty."),
        "emptyThreads": MessageLookupByLibrary.simpleMessage(
            "No thread is currently fetched."),
        "emptyTrustHost": MessageLookupByLibrary.simpleMessage(
            "You haven\'t trusted any hosts."),
        "emptyUser": MessageLookupByLibrary.simpleMessage("No user here."),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorUserExpired": MessageLookupByLibrary.simpleMessage(
            "User authentication expired."),
        "favoriteForum":
            MessageLookupByLibrary.simpleMessage("Favorite forums"),
        "favoriteThread":
            MessageLookupByLibrary.simpleMessage("Favorite threads"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "finishLoginInWeb": MessageLookupByLibrary.simpleMessage("Finish"),
        "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
        "fontSizeInParagraph":
            MessageLookupByLibrary.simpleMessage("Font size in paragraph"),
        "fontSizeInParagraphUnit": m10,
        "fontSizeScaleParameter": MessageLookupByLibrary.simpleMessage(
            "Scale parameter in typesetting"),
        "fontSizeScaleParameterUnit": m11,
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
        "forumFilterStatusHot": MessageLookupByLibrary.simpleMessage("Popular"),
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
        "forumInformation": MessageLookupByLibrary.simpleMessage("Forum info."),
        "forumSortPosts":
            MessageLookupByLibrary.simpleMessage("Filter and sort"),
        "friendNumber": MessageLookupByLibrary.simpleMessage("Friends"),
        "fromDeviceSignature": m12,
        "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
        "googleAdSubTitle": MessageLookupByLibrary.simpleMessage(
            "Advertisement provided by Google"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("AD"),
        "groupInfoDescription": m13,
        "habit": MessageLookupByLibrary.simpleMessage("Habits"),
        "homepage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "hotThread": MessageLookupByLibrary.simpleMessage("Popular"),
        "hour": MessageLookupByLibrary.simpleMessage("H"),
        "hourAgo": m14,
        "hourLater": m15,
        "httpBrowseWarn":
            MessageLookupByLibrary.simpleMessage("HTTP protocol warning"),
        "iframeUrlNull": MessageLookupByLibrary.simpleMessage(
            "Can\'t parse URL in the iframe."),
        "illegalContent":
            MessageLookupByLibrary.simpleMessage("Illegal Content"),
        "incognitoSubtitle": MessageLookupByLibrary.simpleMessage(
            "You will browse the forum in incognito mode"),
        "incognitoTitle":
            MessageLookupByLibrary.simpleMessage("Incognito mode"),
        "incorrectDiscuzAddress":
            MessageLookupByLibrary.simpleMessage("Invalid discuz address."),
        "index": MessageLookupByLibrary.simpleMessage("Index"),
        "insertBoldText": MessageLookupByLibrary.simpleMessage("Bold"),
        "insertItalicText": MessageLookupByLibrary.simpleMessage("Italic"),
        "insertQuoteText": MessageLookupByLibrary.simpleMessage("Quote"),
        "insertSignatureAtTheEndTitle":
            MessageLookupByLibrary.simpleMessage("Enable signature"),
        "interfaceBrightness":
            MessageLookupByLibrary.simpleMessage("Brightness"),
        "invalidCookie": MessageLookupByLibrary.simpleMessage(
            "Invalid cookie from response."),
        "ios": MessageLookupByLibrary.simpleMessage("iOS"),
        "iosDarkModeDisabledText": MessageLookupByLibrary.simpleMessage(
            "Display mode can not be adjusted manually when running on iOS platform mode."),
        "justNow": MessageLookupByLibrary.simpleMessage("Just Now"),
        "largeRichText": MessageLookupByLibrary.simpleMessage(
            "Welcome to Discuzhub<br/>Thanks for using our products and <a href=\"https://discuzhub.kidozh.com/en/term_of_use/\">services</a> (“Services”).<br/>By using our Services, you are agreeing to these terms. Please read them <b>carefully</b>.<br/>Our Services are very diverse, so sometimes additional terms or product requirements (including age requirements) may apply. Additional terms will be available with the relevant Services, and those additional terms become part of your agreement with us if you use those Services"),
        "largeRichTextDescription": MessageLookupByLibrary.simpleMessage(
            "Comes From Our Term of Services"),
        "lastActivityTime":
            MessageLookupByLibrary.simpleMessage("Last active at"),
        "lastPostTime": MessageLookupByLibrary.simpleMessage("Last post at"),
        "lastVisitTime": MessageLookupByLibrary.simpleMessage("Last visit at"),
        "lawInformation":
            MessageLookupByLibrary.simpleMessage("Law information"),
        "legalInformation":
            MessageLookupByLibrary.simpleMessage("Legal information"),
        "linkUnableToOpen": m16,
        "linuxDeviceName": m17,
        "loadFailed": MessageLookupByLibrary.simpleMessage("Load failed"),
        "loadFinish": MessageLookupByLibrary.simpleMessage("Load completed"),
        "loadMore": MessageLookupByLibrary.simpleMessage("LoadMore"),
        "loaded": MessageLookupByLibrary.simpleMessage("Load completed"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loadingCaptchaInformation": MessageLookupByLibrary.simpleMessage(
            "Loading captcha information."),
        "loadingForumInformation": MessageLookupByLibrary.simpleMessage(
            "Loading configuration for publish a thread in the forum."),
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
        "macOSDeviceName": m18,
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
        "minute": MessageLookupByLibrary.simpleMessage("M"),
        "minuteAgo": m19,
        "minuteLater": m20,
        "mobileTemplateNotFound": MessageLookupByLibrary.simpleMessage(
            "This page is optimized for web view."),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "navigateToWebPage": MessageLookupByLibrary.simpleMessage("Go to web."),
        "networkFail": MessageLookupByLibrary.simpleMessage(
            "Error in connecting with the server."),
        "networkFailed":
            MessageLookupByLibrary.simpleMessage("Network failed."),
        "newThread": MessageLookupByLibrary.simpleMessage("New"),
        "noCaptachaRequired":
            MessageLookupByLibrary.simpleMessage("No captcha needed."),
        "noFavoriteThreadInDb": MessageLookupByLibrary.simpleMessage(
            "No favorite thread is stored in your device"),
        "noImagePicked":
            MessageLookupByLibrary.simpleMessage("No Image picked"),
        "noMore": MessageLookupByLibrary.simpleMessage("No more"),
        "noSignature": MessageLookupByLibrary.simpleMessage("No signature"),
        "noSmileyFoundInDB": MessageLookupByLibrary.simpleMessage(
            "Try to use the first smiley?"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "nullDiscuzSubTitle": MessageLookupByLibrary.simpleMessage(
            "Why not consider add a discuz forum?"),
        "nullDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("No Discuz! BBS is selected"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "onlineHours": m21,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("Online Time"),
        "onlyViewAuthor": MessageLookupByLibrary.simpleMessage("OP mode"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("Open"),
        "openFileInExternalAppContent": MessageLookupByLibrary.simpleMessage(
            "File downloads successfully. Do you want to open it now?"),
        "openInBrowser":
            MessageLookupByLibrary.simpleMessage("Open in browser"),
        "openSoftwareSubtitle": MessageLookupByLibrary.simpleMessage(
            "Our service is open sourced with MIT license"),
        "openSoftwareTitle":
            MessageLookupByLibrary.simpleMessage("Open software"),
        "openSourceLicence":
            MessageLookupByLibrary.simpleMessage("Open source licence"),
        "openViaInternalBrowser":
            MessageLookupByLibrary.simpleMessage("Open Website in webview"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "outerlinkOpenMessage": MessageLookupByLibrary.simpleMessage(
            "Host of the link is not the same as the BBS. It would be dangerous to browse."),
        "outerlinkOpenTitle": MessageLookupByLibrary.simpleMessage(
            "The link doesn\'t belong to the BBS"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[Pic]"),
        "policy": MessageLookupByLibrary.simpleMessage("Our policy"),
        "pollExpireAt": m22,
        "pollNotAllowed": MessageLookupByLibrary.simpleMessage(
            "You can\'t join in the polls."),
        "pollTitle":
            MessageLookupByLibrary.simpleMessage("Poll (single selection)"),
        "pollVoterNumber": m23,
        "post": MessageLookupByLibrary.simpleMessage("Post"),
        "postAuthorLabel": MessageLookupByLibrary.simpleMessage("OP"),
        "postNumber": MessageLookupByLibrary.simpleMessage("Post number"),
        "postPosition": m24,
        "preparingPage":
            MessageLookupByLibrary.simpleMessage("Preparing the page."),
        "preventAbuseUser": MessageLookupByLibrary.simpleMessage(
            "No objectionable content and abusive action"),
        "preventAbuseUserDescription": MessageLookupByLibrary.simpleMessage(
            "There is no tolerance for objectionable content and abusive users"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "privacyProtectSubtitle":
            MessageLookupByLibrary.simpleMessage("Nothing is collected by us"),
        "privacyProtectTitle":
            MessageLookupByLibrary.simpleMessage("Privacy protection"),
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
        "pushChannel": MessageLookupByLibrary.simpleMessage("Channel"),
        "pushChannelAPNs": MessageLookupByLibrary.simpleMessage(
            "Apple Push Notification service"),
        "pushChannelFirebase": MessageLookupByLibrary.simpleMessage("Firebase"),
        "pushDevice": MessageLookupByLibrary.simpleMessage("Device type"),
        "pushDeviceNotInterfaceWithService":
            MessageLookupByLibrary.simpleMessage(
                "Other service functions normally"),
        "pushDeviceNotInterfaceWithServiceDescription":
            MessageLookupByLibrary.simpleMessage(
                "Other functions not relied on push service still works."),
        "pushDeviceNotSupported": MessageLookupByLibrary.simpleMessage(
            "Device not supported or network failed to connect with Google."),
        "pushDeviceNotSupportedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Cannot find GMS or APNs service in your device."),
        "pushHelpPages": MessageLookupByLibrary.simpleMessage("Helps"),
        "pushInformation":
            MessageLookupByLibrary.simpleMessage("Pushed information"),
        "pushNotification":
            MessageLookupByLibrary.simpleMessage("Push notification service"),
        "pushNotificationDescription": MessageLookupByLibrary.simpleMessage(
            "Push notification is only enabled when dhpush is enabled in the Discuz site."),
        "pushNotificationEnable": MessageLookupByLibrary.simpleMessage(
            "Enable Push notification service"),
        "pushNotificationOff": MessageLookupByLibrary.simpleMessage("Off"),
        "pushNotificationOn": MessageLookupByLibrary.simpleMessage("On"),
        "pushNotificationPermissionNotAuthorized":
            MessageLookupByLibrary.simpleMessage(
                "Push permission not authorized."),
        "pushNotificationSubmittedContent": MessageLookupByLibrary.simpleMessage(
            "Push service relies on Firebase and APNs, which needs token, device information. You should agree with terms of service and privacy policy of push service to use it."),
        "pushPackageId": MessageLookupByLibrary.simpleMessage("Package ID"),
        "pushThreadTitle": MessageLookupByLibrary.simpleMessage("Publish"),
        "pushThreadTitleHint": MessageLookupByLibrary.simpleMessage("Title"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("Push to load"),
        "pushToken": MessageLookupByLibrary.simpleMessage("Firebase token"),
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
        "replyPostTrimMessage": m25,
        "reportContentTitle": m26,
        "reportOtherReasonHint":
            MessageLookupByLibrary.simpleMessage("Type to report other reason"),
        "reportSuccessfully": m27,
        "residentPlace": MessageLookupByLibrary.simpleMessage("Resident place"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "revisedPost": MessageLookupByLibrary.simpleMessage(
            "The post is revised to prevent duplicated scoring."),
        "sample": MessageLookupByLibrary.simpleMessage("Sample"),
        "saveImageSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Save Image to device successfully."),
        "savePictureToDevice": MessageLookupByLibrary.simpleMessage("Save"),
        "savedSmileyTabTitle":
            MessageLookupByLibrary.simpleMessage("Recently used"),
        "second": MessageLookupByLibrary.simpleMessage("S"),
        "seeAllReplies":
            MessageLookupByLibrary.simpleMessage("View all replies"),
        "selectUserNull": MessageLookupByLibrary.simpleMessage(
            "No user is currently activated"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendImageWithVerificationNotice": MessageLookupByLibrary.simpleMessage(
            "Captcha required in reply. Please fill the captcha then send it by pushing the button."),
        "sendReply": MessageLookupByLibrary.simpleMessage("Send"),
        "sendReplyHint": MessageLookupByLibrary.simpleMessage("Say something"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shortcut": MessageLookupByLibrary.simpleMessage("Shortcut"),
        "shortcutFidHint":
            MessageLookupByLibrary.simpleMessage("Input forum id (fid)"),
        "shortcutGo": MessageLookupByLibrary.simpleMessage("Go"),
        "shortcutTidHint":
            MessageLookupByLibrary.simpleMessage("Input thread id (tid)"),
        "shortcutUidHint":
            MessageLookupByLibrary.simpleMessage("Input user id (uid)"),
        "signInSuccessTitle": m28,
        "signInTitle": m29,
        "signInViaBrowser":
            MessageLookupByLibrary.simpleMessage("Sign in by web"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signatureHint": MessageLookupByLibrary.simpleMessage(
            "Input signature for every post"),
        "signatureStyle":
            MessageLookupByLibrary.simpleMessage("Signature style"),
        "siteDoesNotSupportPushService": MessageLookupByLibrary.simpleMessage(
            "The site may not install DHP Service."),
        "sitePage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "smileyLabel": m30,
        "spam": MessageLookupByLibrary.simpleMessage("Spam"),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "submitPoll": m31,
        "successfullyDeleteViewHistoryContent": m32,
        "successfullyDownloadFiles": m33,
        "syncSuccessfullyWithServer": m34,
        "takeAPicture": MessageLookupByLibrary.simpleMessage("Shot"),
        "tapToWipeAndRelogin": MessageLookupByLibrary.simpleMessage(
            "Tap to wipe out and re-login user"),
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "termsOfUseDescription": MessageLookupByLibrary.simpleMessage(
            "You should agree to terms of services before using the application."),
        "testVersion": MessageLookupByLibrary.simpleMessage("Beta Test"),
        "testVersionDescription": MessageLookupByLibrary.simpleMessage(
            "The final product will be changed according to latest development."),
        "testVersionNotificationTitle":
            MessageLookupByLibrary.simpleMessage("Take a bite on beta test"),
        "threadIsClosed":
            MessageLookupByLibrary.simpleMessage("Thread is closed."),
        "threadReadAccess": m35,
        "trashAd": MessageLookupByLibrary.simpleMessage("Trash Advertisement"),
        "trustHostActionText":
            MessageLookupByLibrary.simpleMessage("Trust this host"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("Trusted host"),
        "typeSetting": MessageLookupByLibrary.simpleMessage("Typesetting"),
        "unableToVerifyAuthStatus": MessageLookupByLibrary.simpleMessage(
            "Unable to verify your auth status"),
        "unblockContent":
            MessageLookupByLibrary.simpleMessage("Unblock content"),
        "unblockUser": MessageLookupByLibrary.simpleMessage("Unblock user"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "updateAt": MessageLookupByLibrary.simpleMessage("Update at %T"),
        "upgrade_notification_subtitle": MessageLookupByLibrary.simpleMessage(
            "Update includes bug fix, function add and interface change."),
        "upgrade_notification_title":
            MessageLookupByLibrary.simpleMessage("Safe update"),
        "uploadCompressedImageToServer": MessageLookupByLibrary.simpleMessage(
            "Send compressed image(Recommended)"),
        "uploadImageError1": MessageLookupByLibrary.simpleMessage(
            "The file extension is not supported."),
        "uploadImageError10":
            MessageLookupByLibrary.simpleMessage("Invalid operation."),
        "uploadImageError11": MessageLookupByLibrary.simpleMessage(
            "You can not upload any large files like this today."),
        "uploadImageError2": MessageLookupByLibrary.simpleMessage(
            "Your file size excesses the server limit."),
        "uploadImageError3": MessageLookupByLibrary.simpleMessage(
            "The file size excesses your group limit."),
        "uploadImageError4": MessageLookupByLibrary.simpleMessage(
            "Your file type is not supported."),
        "uploadImageError5": MessageLookupByLibrary.simpleMessage(
            "The file size excesses file type limit."),
        "uploadImageError6": MessageLookupByLibrary.simpleMessage(
            "You can not upload any files today."),
        "uploadImageError7":
            MessageLookupByLibrary.simpleMessage("The file is not an image."),
        "uploadImageError8": MessageLookupByLibrary.simpleMessage(
            "The file can not be stored in the server."),
        "uploadImageError9":
            MessageLookupByLibrary.simpleMessage("Invalid upload method."),
        "uploadImageErrorNegative1":
            MessageLookupByLibrary.simpleMessage("Internal Server Error"),
        "uploadImageFailed":
            MessageLookupByLibrary.simpleMessage("Upload image failed"),
        "uploadImageSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Upload file to server sucessfully."),
        "uploadImageToServerDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Upload the file to Discuz server."),
        "uploadImageUnknownError": MessageLookupByLibrary.simpleMessage(
            "Encounter a unresolved issue when uploading the file"),
        "uploadRawImageToServer":
            MessageLookupByLibrary.simpleMessage("Send raw image"),
        "uploadTokenSuccessful": MessageLookupByLibrary.simpleMessage(
            "Upload your token to discuz successfully."),
        "uploadTokenUnsuccessful": MessageLookupByLibrary.simpleMessage(
            "Unable to upload your token."),
        "uploadingImageToServer": MessageLookupByLibrary.simpleMessage(
            "Upload the file to the server..."),
        "useMaterial3NoSubtitle": MessageLookupByLibrary.simpleMessage(
            "App will use the Material 2 look and feel."),
        "useMaterial3Title":
            MessageLookupByLibrary.simpleMessage("Use Material You design"),
        "useMaterial3YesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Components that have been migrated to Material 3 will use new colors, typography and other features of Material 3."),
        "userCredit": MessageLookupByLibrary.simpleMessage("Credits"),
        "userExpiredSubtitle": MessageLookupByLibrary.simpleMessage(
            "The current user is expired, some function may not work."),
        "userExpiredTitle": m36,
        "userIdTitle": m37,
        "userPost": MessageLookupByLibrary.simpleMessage("Posts"),
        "userProfile": MessageLookupByLibrary.simpleMessage("User Profile"),
        "userProfileTitle":
            MessageLookupByLibrary.simpleMessage("User Profiles"),
        "userThread": MessageLookupByLibrary.simpleMessage("Threads"),
        "viewAuthorInfo":
            MessageLookupByLibrary.simpleMessage("View author\'s profile"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
        "viewThreadTitle":
            MessageLookupByLibrary.simpleMessage("View a thread"),
        "viewUserInfo": m38,
        "warnedPost":
            MessageLookupByLibrary.simpleMessage("The post is warned."),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("Full display"),
        "websiteNotLogined": MessageLookupByLibrary.simpleMessage(
            "You haven\'t login in the website, please try after you actually login."),
        "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Welcome to use our Services."),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("Welcome"),
        "windowsDeviceName": m39,
        "workProcedure":
            MessageLookupByLibrary.simpleMessage("How does push service work?"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage(
            "Write storage permission denied.")
      };
}
