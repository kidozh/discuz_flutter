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

  static String m2(time) => "Last update at ${time}";

  static String m3(username) => "Auto fill ${username} to the form.";

  static String m4(version, number) => "Build ver. ${version}, num ${number}";

  static String m5(username) =>
      "This content is posted from block user ${username}";

  static String m6(day) => "${day} days ago";

  static String m7(day) => "${day} days later";

  static String m8(account) => "Delete account ${account} successfully.";

  static String m9(account) => "Delete discuz ${account} successfully.";

  static String m10(sitename) => "${sitename} is in AD exempt list";

  static String m11(sitename) =>
      "The inner AD is invisible when browsing ${sitename}. \nThanks for choosing DisFly.";

  static String m12(key, content) => "${content}(${key})";

  static String m13(filename) => "Downloading file: ${filename} in background.";

  static String m14(discuz, discuzUrl) =>
      "I hereby would like to add ${discuz}(${discuzUrl}) to subscription list";

  static String m15(discuz) => "Add ${discuz} to subscription list";

  static String m16(discuz) => "Notify us ${discuz}";

  static String m17(size) => "${size} pt";

  static String m18(size) => "x ${size}";

  static String m19(device, version) =>
      "- Sent by ${device}\'s [url=https://discuzhub.kidozh.com/]DisFly[/url] v${version}.";

  static String m20(device) => "Sent by ${device}.";

  static String m21(language) => "Not support ${language}";

  static String m22(readAccess, star) =>
      "Read Access: ${readAccess} and Star: ${star}";

  static String m23(hour) => "${hour} hours ago";

  static String m24(hour) => "${hour} hours later";

  static String m25(uri) => "Unable to open the uri: ${uri}.";

  static String m26(name) => "${name}\'s Linux device";

  static String m27(name) => "${name}\'s MacOS device";

  static String m28(min) => "${min} minutes ago";

  static String m29(min) => "${min} minutes later";

  static String m30(discuz) =>
      "No subscription channel exists for ${discuz} now.";

  static String m31(hour) => "${hour} hour(s).";

  static String m32(pictureBedName) => "Service provided by ${pictureBedName}";

  static String m33(time) => "Poll will expire at ${time}.";

  static String m34(people) => "${people} have voted.";

  static String m35(pos) => "# ${pos}";

  static String m36(discuz) => "${discuz} may not support push service";

  static String m37(pid, ptid, author, fullTimeString, trimMessage) =>
      "[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=${pid}&ptid=${ptid}]${author} posted at ${fullTimeString}[/url][/size]\n${trimMessage}[/quote]";

  static String m38(name) => "Report ${name}";

  static String m39(discuzName) => "Report to the ${discuzName} Successfully";

  static String m40(username, discuzName) =>
      "User ${username} sign in at ${discuzName} successfully.";

  static String m41(discuzName) => "Sign in at ${discuzName}";

  static String m42(index) => "Smiley #${index}";

  static String m43(checked, allowed) => "Submit (${checked} / ${allowed})";

  static String m44(title) => "Successfully remove view history ${title}.";

  static String m45(filename) => "Successfully download file: ${filename}.";

  static String m46(num) =>
      "All ${num} favorite threads are synced from the server.";

  static String m47(num) => "RP ${num}";

  static String m48(reply) => "${reply} replies";

  static String m49(view) => "${view} views";

  static String m50(username) => "User ${username} expired";

  static String m51(uid) => "UserId ${uid}";

  static String m52(user) => "View ${user}\'s profile.";

  static String m53(name) => "${name}\'s Windows device";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accentColorPickerType": MessageLookupByLibrary.simpleMessage("Accent"),
        "account": MessageLookupByLibrary.simpleMessage("Username"),
        "acknowledgeAppSignatureAndAdDiminish":
            MessageLookupByLibrary.simpleMessage(
                "Thank you for letting our app heard by more people. The number of inline app will be reduced to appreciate your assistance."),
        "adExemptCondition": MessageLookupByLibrary.simpleMessage(
            "As a gift, you can opt one discuz forum out of advertisement."),
        "adExemptDescription": MessageLookupByLibrary.simpleMessage(
            "You can choose one discuz to exempt its advertisement by App."),
        "adExemptEmbeddedList": MessageLookupByLibrary.simpleMessage(
            "The following discuz forums have already been exempted out of advertisement."),
        "adExemptNeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Choose one discuz to exempt AD"),
        "adExemptNoNeedToConfirm": MessageLookupByLibrary.simpleMessage(
            "There is no discuz forum needs to opt out of advertisement"),
        "adExemptTitle": MessageLookupByLibrary.simpleMessage("AD exempt"),
        "adLoadingText":
            MessageLookupByLibrary.simpleMessage("AD provided by Google"),
        "addAPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
        "addAuthentication": MessageLookupByLibrary.simpleMessage("Add"),
        "addDiscuzApiBrowseUnsuccessfully":
            MessageLookupByLibrary.simpleMessage(
                "Unable to recognise the discuz!"),
        "addDiscuzApiParseUnsuccessfully": MessageLookupByLibrary.simpleMessage(
            "The mobile plugin is not recognisable."),
        "addDiscuzSuccessfully": m0,
        "addDiscuzSuggestionAnnotation":
            MessageLookupByLibrary.simpleMessage("Feedback"),
        "addDiscuzSuggestionDialogButtonTitle":
            MessageLookupByLibrary.simpleMessage("Tell us your voice"),
        "addDiscuzSuggestionDialogDescription":
            MessageLookupByLibrary.simpleMessage(
                "We love to hear your suggestion. If you would like to recommend or hide a Discuz site, you are welcomed to contact us via email (kidozh@gmail.com)."),
        "addDiscuzSuggestionDialogTitle":
            MessageLookupByLibrary.simpleMessage("Have any suggestion?"),
        "addDiscuzSuggestionStatement": MessageLookupByLibrary.simpleMessage(
            "Disfly is a third-party app for Discuz ! forum site. We have no relation with any Discuz forum."),
        "addDiscuzSuggestionTitle":
            MessageLookupByLibrary.simpleMessage("Are you looking for"),
        "addDiscuzSuggestionVerifiedDiscuz":
            MessageLookupByLibrary.simpleMessage(
                " of discuz has ICP license from MIIT."),
        "addDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("Add a discuz! BBS"),
        "addNewDiscuz": MessageLookupByLibrary.simpleMessage("Add a Discuz"),
        "adminBlockPost": MessageLookupByLibrary.simpleMessage("Block"),
        "adminDeletePost": MessageLookupByLibrary.simpleMessage("Delete"),
        "adminUnblockPost": MessageLookupByLibrary.simpleMessage("Unblock"),
        "adminUnwarnPost": MessageLookupByLibrary.simpleMessage("Redo warn"),
        "adminWarnPost": MessageLookupByLibrary.simpleMessage("Warn"),
        "animateToLastReadingPosition": MessageLookupByLibrary.simpleMessage(
            "Scroll to last read position."),
        "anonymous": MessageLookupByLibrary.simpleMessage("A"),
        "appName": MessageLookupByLibrary.simpleMessage("DisFly"),
        "appearanceOptimizedPlatform":
            MessageLookupByLibrary.simpleMessage("Platform preference"),
        "appearanceOptimizedPlatformSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose the app appearance on preferred platform."),
        "attachFile": m1,
        "attachmentUploadExceedingSizeDescription":
            MessageLookupByLibrary.simpleMessage(
                "The attachment shall be compressed to be accepted by the forum."),
        "attachmentUploadExceedingSizeTitle":
            MessageLookupByLibrary.simpleMessage("The attachment is too large"),
        "authenticateBySystem": MessageLookupByLibrary.simpleMessage(
            "Please authenticate to query saved password."),
        "authenticationEmpty": MessageLookupByLibrary.simpleMessage(
            "No authentication found in this device."),
        "authenticationLastUpdateAt": m2,
        "authenticationLocked":
            MessageLookupByLibrary.simpleMessage("The data is locked"),
        "authenticationRetry":
            MessageLookupByLibrary.simpleMessage("Authenticate"),
        "authenticationSecurityAndroidContent":
            MessageLookupByLibrary.simpleMessage(
                "Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 secret key is encrypted with RSA and RSA key is stored in Android Keystore system. Only after authentication from the system, your data is accessible to DisFly."),
        "authenticationSecurityIosContent": MessageLookupByLibrary.simpleMessage(
            "Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 private key is stored at keychain of the system. Only after authentication from the system, your data is accessible to DisFly."),
        "authenticationSecurityTitle":
            MessageLookupByLibrary.simpleMessage("Secure at your device"),
        "authenticationStatusCannotAuthenticate":
            MessageLookupByLibrary.simpleMessage(
                "Your device is not enrolled in any authentication method."),
        "authenticationStatusDeviceNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Your device is not supported."),
        "authenticationStatusFailed": MessageLookupByLibrary.simpleMessage(
            "Could not pass system\'s authentication."),
        "authorizedSite":
            MessageLookupByLibrary.simpleMessage("Authorized site"),
        "autoFillUsername": m3,
        "autofillDialogSubtitle": MessageLookupByLibrary.simpleMessage(
            "Select the username to fill the login form"),
        "autofillDialogTitle": MessageLookupByLibrary.simpleMessage("Autofill"),
        "basicUse": MessageLookupByLibrary.simpleMessage("Basic"),
        "basicUseDescribe":
            MessageLookupByLibrary.simpleMessage("Basic use of EasyRefresh"),
        "bio": MessageLookupByLibrary.simpleMessage("Bio"),
        "birthPlace": MessageLookupByLibrary.simpleMessage("Birth place"),
        "blackAndWhiteColorPickerType":
            MessageLookupByLibrary.simpleMessage("Black & White"),
        "blockUser": MessageLookupByLibrary.simpleMessage("Block user"),
        "blockedPost":
            MessageLookupByLibrary.simpleMessage("The post is blocked."),
        "blockedUserList":
            MessageLookupByLibrary.simpleMessage("Blocked user list"),
        "bobMinion": MessageLookupByLibrary.simpleMessage("Bob minion"),
        "bobMinionDescribe":
            MessageLookupByLibrary.simpleMessage("Cute yellow Minions"),
        "bothColorPickerType": MessageLookupByLibrary.simpleMessage("Both"),
        "brightnessDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "brightnessLight": MessageLookupByLibrary.simpleMessage("Light"),
        "brightnessManualChangeDisabled": MessageLookupByLibrary.simpleMessage(
            "App now will follow the system appearance according to design discipline."),
        "brokenCountDown":
            MessageLookupByLibrary.simpleMessage("Invalid count down timer"),
        "bugTestSubtitle": MessageLookupByLibrary.simpleMessage(
            "You can directly email us via kidozh@gmail.com. Thank you for your help!"),
        "bugTestTitle":
            MessageLookupByLibrary.simpleMessage("Sometimes bug exists"),
        "buildDescription": MessageLookupByLibrary.simpleMessage(
            "Built with flutter, made with ♥, run on multiple platforms."),
        "buildVersionDescription": m4,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelAdding": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captchaRequired":
            MessageLookupByLibrary.simpleMessage("Captcha required."),
        "chatIconToolTip":
            MessageLookupByLibrary.simpleMessage("Chat with him / her"),
        "chatMessage": MessageLookupByLibrary.simpleMessage("Chat"),
        "checkUserLoginStatus":
            MessageLookupByLibrary.simpleMessage("Check user status..."),
        "cheveretoApiDescription": MessageLookupByLibrary.simpleMessage(
            "The chevereto API key is created by user and usually started with chv_, where you can upload your picture to the hosting site."),
        "cheveretoApiKey": MessageLookupByLibrary.simpleMessage("API Key"),
        "cheveretoPictureBed":
            MessageLookupByLibrary.simpleMessage("Chevereto"),
        "chooseDiscuz": MessageLookupByLibrary.simpleMessage("Choose a BBS"),
        "chooseThemeTitle": MessageLookupByLibrary.simpleMessage("Theme color"),
        "chooseTypographyTheme":
            MessageLookupByLibrary.simpleMessage("Typography theme"),
        "clearAllViewHistories":
            MessageLookupByLibrary.simpleMessage("Clear all histories"),
        "closeKeyboardTooltip":
            MessageLookupByLibrary.simpleMessage("Close the keyboard"),
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
        "compactTypography":
            MessageLookupByLibrary.simpleMessage("Compact paragraph"),
        "completeLoad": MessageLookupByLibrary.simpleMessage("Load done"),
        "completeRefresh": MessageLookupByLibrary.simpleMessage("Refresh done"),
        "connectServerWhenAdding": MessageLookupByLibrary.simpleMessage(
            "Connect to BBS server for verification."),
        "contactUsViaEmail":
            MessageLookupByLibrary.simpleMessage("Contact us (Email)"),
        "contactUsViaWeibo":
            MessageLookupByLibrary.simpleMessage("Contact us (Weibo)"),
        "contentPostByBlockUserTitle": m5,
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
        "dayAgo": m6,
        "dayLater": m7,
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccountSuccessfully": m8,
        "deleteDiscuzSuccessfully": m9,
        "deleteViewHistoryWarnContent": MessageLookupByLibrary.simpleMessage(
            "Clearing operation is irrecoverable, please take care."),
        "deviceNameSignature":
            MessageLookupByLibrary.simpleMessage("Use device name"),
        "dhPushServiceTitle":
            MessageLookupByLibrary.simpleMessage("DH Push service"),
        "dioErrorBadCertificate":
            MessageLookupByLibrary.simpleMessage("Bad certificate"),
        "dioErrorBadResponse":
            MessageLookupByLibrary.simpleMessage("Bad response"),
        "dioErrorCancel":
            MessageLookupByLibrary.simpleMessage("Response cancelled."),
        "dioErrorConnectionError":
            MessageLookupByLibrary.simpleMessage("Connection error"),
        "dioErrorConnectionTimeout":
            MessageLookupByLibrary.simpleMessage("Connection timeout."),
        "dioErrorOther": MessageLookupByLibrary.simpleMessage("Error."),
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
        "discuzAuthenticationTitle":
            MessageLookupByLibrary.simpleMessage("Password & Authentication"),
        "discuzInAdExemptBuiltInList": m10,
        "discuzInAdExemptBuiltInListDescription": m11,
        "discuzOperationMessage": m12,
        "discuzServerAddress":
            MessageLookupByLibrary.simpleMessage("The Discuz\'s address"),
        "discuzServerAddressHelperText": MessageLookupByLibrary.simpleMessage(
            "It usually is the address discuz serves."),
        "discuzServerAddressHint":
            MessageLookupByLibrary.simpleMessage("eg. https://bbs.nwpu.edu.cn"),
        "displaySettingTitle": MessageLookupByLibrary.simpleMessage("Display"),
        "downloadAttachment": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadingFiles": m13,
        "duplicatedPost":
            MessageLookupByLibrary.simpleMessage("Duplicated Posts"),
        "dynamicSchemeVariant":
            MessageLookupByLibrary.simpleMessage("Scheme variant"),
        "dynamicSchemeVariantContentDescription":
            MessageLookupByLibrary.simpleMessage(
                "Tokens and palettes match the seed color."),
        "dynamicSchemeVariantContentKey":
            MessageLookupByLibrary.simpleMessage("Content"),
        "dynamicSchemeVariantExpressiveDescription":
            MessageLookupByLibrary.simpleMessage(
                "Pastel colors, medium chroma palettes."),
        "dynamicSchemeVariantExpressiveKey":
            MessageLookupByLibrary.simpleMessage("Expressive"),
        "dynamicSchemeVariantFidelityDescription":
            MessageLookupByLibrary.simpleMessage(
                "Pastel palettes with a low chroma."),
        "dynamicSchemeVariantFidelityKey":
            MessageLookupByLibrary.simpleMessage("Fidelity"),
        "dynamicSchemeVariantFidelityNotification":
            MessageLookupByLibrary.simpleMessage(
                "\'Fidelity\' is a feature that adjusts tones in these cases to produce the intended visual results without harming visual contrast."),
        "dynamicSchemeVariantFruitSaladDescription":
            MessageLookupByLibrary.simpleMessage("A playful theme."),
        "dynamicSchemeVariantFruitSaladKey":
            MessageLookupByLibrary.simpleMessage("FruitSalad"),
        "dynamicSchemeVariantMonochromeDescription":
            MessageLookupByLibrary.simpleMessage(
                "Gray scale color, no chroma."),
        "dynamicSchemeVariantMonochromeKey":
            MessageLookupByLibrary.simpleMessage("Monochrome"),
        "dynamicSchemeVariantNeutralDescription":
            MessageLookupByLibrary.simpleMessage(
                "Close to grayscale, a hint of chroma."),
        "dynamicSchemeVariantNeutralKey":
            MessageLookupByLibrary.simpleMessage("Neutral"),
        "dynamicSchemeVariantNotification": MessageLookupByLibrary.simpleMessage(
            "In some cases, the tones can prevent colors from appearing as intended, such as when a color is too light to offer enough contrast for accessibility."),
        "dynamicSchemeVariantRainbowDescription":
            MessageLookupByLibrary.simpleMessage("A playful theme."),
        "dynamicSchemeVariantRainbowKey":
            MessageLookupByLibrary.simpleMessage("Rainbow"),
        "dynamicSchemeVariantTonalSpotDescription":
            MessageLookupByLibrary.simpleMessage(
                "Pastel palettes with a low chroma."),
        "dynamicSchemeVariantTonalSpotKey":
            MessageLookupByLibrary.simpleMessage("Tonal"),
        "dynamicSchemeVariantVibrantDescription":
            MessageLookupByLibrary.simpleMessage(
                "Pastel colors, high chroma palettes."),
        "dynamicSchemeVariantVibrantKey":
            MessageLookupByLibrary.simpleMessage("Vibrant"),
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
        "emailChannelBody": m14,
        "emailChannelFailed": MessageLookupByLibrary.simpleMessage(
            "Could not find mail app in this device. You could email us (kidozh@gmail.com) to add this site to the subscription list."),
        "emailChannelTitle": m15,
        "emailUsToAddChannel": m16,
        "emoijButtonTooltip":
            MessageLookupByLibrary.simpleMessage("Insert smiley emoij"),
        "emptyForum": MessageLookupByLibrary.simpleMessage("No fourm here"),
        "emptyHistory": MessageLookupByLibrary.simpleMessage(
            "No history found in your device. Have you ever browse anything or never open the history recording in the setting?"),
        "emptyListDescription":
            MessageLookupByLibrary.simpleMessage("The content is empty"),
        "emptyNotification": MessageLookupByLibrary.simpleMessage(
            "You haven\'t recieved any notification."),
        "emptyPosts": MessageLookupByLibrary.simpleMessage(
            "No post is currently listed."),
        "emptyScreenTitle":
            MessageLookupByLibrary.simpleMessage("The content here is empty."),
        "emptyThreads": MessageLookupByLibrary.simpleMessage(
            "No thread is posted here, look around?"),
        "emptyTrustHost": MessageLookupByLibrary.simpleMessage(
            "You haven\'t trusted any hosts."),
        "emptyUser": MessageLookupByLibrary.simpleMessage("No user here."),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorUserExpired": MessageLookupByLibrary.simpleMessage(
            "User authentication expired."),
        "extraFuncButtonTooltip":
            MessageLookupByLibrary.simpleMessage("More functions"),
        "favoriteForum":
            MessageLookupByLibrary.simpleMessage("Favorite forums"),
        "favoriteIconTooltip":
            MessageLookupByLibrary.simpleMessage("Favorite forum"),
        "favoriteThread":
            MessageLookupByLibrary.simpleMessage("Favorite threads"),
        "favoriteThreadTooltip":
            MessageLookupByLibrary.simpleMessage("Favorite thread"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "feedbackTitle": MessageLookupByLibrary.simpleMessage("Haptic"),
        "finishLoginInWeb": MessageLookupByLibrary.simpleMessage("Finish"),
        "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
        "fontSizeInParagraph":
            MessageLookupByLibrary.simpleMessage("Font size in paragraph"),
        "fontSizeInParagraphUnit": m17,
        "fontSizeScaleParameter": MessageLookupByLibrary.simpleMessage(
            "Scale parameter in typesetting"),
        "fontSizeScaleParameterUnit": m18,
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
        "fromAppSignature": m19,
        "fromDeviceSignature": m20,
        "fuchsia": MessageLookupByLibrary.simpleMessage("Fuchsia"),
        "gameComingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
        "gameFreeOfCharge": MessageLookupByLibrary.simpleMessage("Free"),
        "gameLanguageNotSupported": m21,
        "goToPushSetting":
            MessageLookupByLibrary.simpleMessage("Enable push service"),
        "googleAdSubTitle": MessageLookupByLibrary.simpleMessage(
            "Advertisement provided by Google"),
        "googleAdTitle": MessageLookupByLibrary.simpleMessage("AD"),
        "groupInfoDescription": m22,
        "habit": MessageLookupByLibrary.simpleMessage("Habits"),
        "hapticFeedbackTitle":
            MessageLookupByLibrary.simpleMessage("Vibration feedback"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "homepage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "hostIsEmpty":
            MessageLookupByLibrary.simpleMessage("Host is empty in the form."),
        "hotThread": MessageLookupByLibrary.simpleMessage("Popular"),
        "hour": MessageLookupByLibrary.simpleMessage("H"),
        "hourAgo": m23,
        "hourLater": m24,
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
        "inlineFramePage": MessageLookupByLibrary.simpleMessage("Inline frame"),
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
        "iosColorSchemeSuggestions": MessageLookupByLibrary.simpleMessage(
            "Due to the incompatibility brought by the upgrade of Material Design, the default color scheme app adopt is purple now but you can still customize some of them."),
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
        "linkUnableToOpen": m25,
        "linuxDeviceName": m26,
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
        "macOSDeviceName": m27,
        "manageAccount": MessageLookupByLibrary.simpleMessage("Manage account"),
        "manageAccountTitle":
            MessageLookupByLibrary.simpleMessage("Manage accounts"),
        "manageDiscuz": MessageLookupByLibrary.simpleMessage("Manage BBS"),
        "manualControl": MessageLookupByLibrary.simpleMessage("Manual control"),
        "manualControlDescribe": MessageLookupByLibrary.simpleMessage(
            "Control the timing of completion of refresh and load"),
        "materialBrightnessSwitchDisabledText":
            MessageLookupByLibrary.simpleMessage(
                "In the material setting, App\'s brightness will follow the system without any options to offer."),
        "materialDesign":
            MessageLookupByLibrary.simpleMessage("Material Design"),
        "me": MessageLookupByLibrary.simpleMessage("Me"),
        "menuDrawerTitle": MessageLookupByLibrary.simpleMessage("Menu"),
        "menuIconTooltip": MessageLookupByLibrary.simpleMessage("Menu"),
        "minute": MessageLookupByLibrary.simpleMessage("M"),
        "minuteAgo": m28,
        "minuteLater": m29,
        "mobileTemplateNotFound": MessageLookupByLibrary.simpleMessage(
            "This page is optimized for web view."),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "navigateToWebPage": MessageLookupByLibrary.simpleMessage("Go to web."),
        "networkFail": MessageLookupByLibrary.simpleMessage(
            "Error in connecting with the server."),
        "networkFailed":
            MessageLookupByLibrary.simpleMessage("Network failed."),
        "newThread": MessageLookupByLibrary.simpleMessage("New"),
        "noAuthenticationFoundInApp": MessageLookupByLibrary.simpleMessage(
            "No authentication is found in this device."),
        "noCaptachaRequired":
            MessageLookupByLibrary.simpleMessage("No captcha needed."),
        "noDiscuzNotFound": MessageLookupByLibrary.simpleMessage(
            "No discuz site is added to this device."),
        "noFavoriteThreadInDb": MessageLookupByLibrary.simpleMessage(
            "No favorite thread is stored in your device"),
        "noForumIsCachedSubtitle": MessageLookupByLibrary.simpleMessage(
            "Could you please open index page once to get a cache of all forums?"),
        "noForumIsCachedTitle":
            MessageLookupByLibrary.simpleMessage("No forum is cached"),
        "noImagePicked":
            MessageLookupByLibrary.simpleMessage("No Image picked"),
        "noMore": MessageLookupByLibrary.simpleMessage("No more"),
        "noSignature": MessageLookupByLibrary.simpleMessage("No signature"),
        "noSmileyFoundInDB": MessageLookupByLibrary.simpleMessage(
            "Try to use the first smiley?"),
        "noSubscribeChannelProvided": m30,
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "nullDiscuzScreenSubtitle": MessageLookupByLibrary.simpleMessage(
            "Add discuz ! now to Disfly to enjoy the app."),
        "nullDiscuzScreenTitle":
            MessageLookupByLibrary.simpleMessage("Let\'s get started"),
        "nullDiscuzSubTitle": MessageLookupByLibrary.simpleMessage(
            "Why not consider add a discuz forum?"),
        "nullDiscuzTitle":
            MessageLookupByLibrary.simpleMessage("No Discuz! BBS is selected"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "onlineHours": m31,
        "onlineHoursTitle": MessageLookupByLibrary.simpleMessage("Online Time"),
        "onlyViewAuthor":
            MessageLookupByLibrary.simpleMessage("OP mode / View all"),
        "openFileInExternalAppActionText":
            MessageLookupByLibrary.simpleMessage("Open"),
        "openFileInExternalAppContent": MessageLookupByLibrary.simpleMessage(
            "File downloads successfully. Do you want to open it now?"),
        "openGameInSteam":
            MessageLookupByLibrary.simpleMessage("View in Steam"),
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
        "passwordIsEmpty": MessageLookupByLibrary.simpleMessage(
            "Password is empty in the form"),
        "pictureBedActive": MessageLookupByLibrary.simpleMessage("Active"),
        "pictureBedAgreeToService":
            MessageLookupByLibrary.simpleMessage("Agree"),
        "pictureBedDisabled": MessageLookupByLibrary.simpleMessage("Disabled"),
        "pictureBedImgloc": MessageLookupByLibrary.simpleMessage("imgloc.com"),
        "pictureBedNotPrepared": MessageLookupByLibrary.simpleMessage(
            "Not ready, click to continue"),
        "pictureBedSMMS": MessageLookupByLibrary.simpleMessage("SM.MS"),
        "pictureBedServiceNote": MessageLookupByLibrary.simpleMessage(
            "These service are not provided by us but the 3rd party service. We exclude any warranties or obligation to them. Some of them are not operated in China and you shall carefully watch their policy change to accommodate your use."),
        "pictureBedTermsSubtitle": MessageLookupByLibrary.simpleMessage(
            "This service is not provided by us but the 3rd party services and we exclude all warranties for it. Using our service does not mean you are granted with 3rd party service as mentioned in our terms. You shall agree to their terms before using 3rd party service."),
        "pictureBedTermsTitle": m32,
        "pictureBedTitle":
            MessageLookupByLibrary.simpleMessage("Image hosting website"),
        "pictureTagInMessage": MessageLookupByLibrary.simpleMessage("[Pic]"),
        "policy": MessageLookupByLibrary.simpleMessage("Our policy"),
        "pollExpireAt": m33,
        "pollNotAllowed": MessageLookupByLibrary.simpleMessage(
            "You can\'t join in the polls."),
        "pollTitle":
            MessageLookupByLibrary.simpleMessage("Poll (single selection)"),
        "pollVoterNumber": m34,
        "post": MessageLookupByLibrary.simpleMessage("Post"),
        "postAuthorLabel": MessageLookupByLibrary.simpleMessage("OP"),
        "postNumber": MessageLookupByLibrary.simpleMessage("Post number"),
        "postPosition": m35,
        "postThread": MessageLookupByLibrary.simpleMessage("Post thread"),
        "preparingPage":
            MessageLookupByLibrary.simpleMessage("Preparing the page."),
        "preventAbuseUser": MessageLookupByLibrary.simpleMessage(
            "No objectionable content and abusive action"),
        "preventAbuseUserDescription": MessageLookupByLibrary.simpleMessage(
            "There is no tolerance for objectionable content and abusive users"),
        "primaryColorPickerType":
            MessageLookupByLibrary.simpleMessage("Primary"),
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
        "pushChannelAPN": MessageLookupByLibrary.simpleMessage(
            "Apple push notification service"),
        "pushChannelAPNs": MessageLookupByLibrary.simpleMessage(
            "Apple Push Notification service"),
        "pushChannelFCM":
            MessageLookupByLibrary.simpleMessage("Firebase cloud messaging"),
        "pushChannelFirebase": MessageLookupByLibrary.simpleMessage("Firebase"),
        "pushChannelHMS": MessageLookupByLibrary.simpleMessage("HMS Push"),
        "pushChannelXMI": MessageLookupByLibrary.simpleMessage("Xiaomi push"),
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
        "pushLocale": MessageLookupByLibrary.simpleMessage("Locale"),
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
        "pushPrivacyPolicy": MessageLookupByLibrary.simpleMessage(
            "Privacy policy of push services"),
        "pushServiceEnableDescription": MessageLookupByLibrary.simpleMessage(
            "Do you wish to enable push service to receive the updated information?"),
        "pushServiceLimitedInChinaMainlandSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "The Firebase Cloud Messaging service is limited in China Mainland. To ensure a prompt notification, you are advised to turn on the auto-restart or add DisFly to the except list."),
        "pushServiceLimitedInChinaMainlandTitle":
            MessageLookupByLibrary.simpleMessage("FCM limited availability"),
        "pushServiceNotEnabled": MessageLookupByLibrary.simpleMessage(
            "Please enable push service to enable this function."),
        "pushServiceOff":
            MessageLookupByLibrary.simpleMessage("The push service is not on."),
        "pushServiceOnDescription": MessageLookupByLibrary.simpleMessage(
            "You are now able to get the updated information from supported Discuz."),
        "pushServiceSiteNotSupport": m36,
        "pushTermsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of push services"),
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
        "registerPushTokenMessage": MessageLookupByLibrary.simpleMessage(
            "Do you wish to register your device to the forum so that you can receive a updated push."),
        "registerPushTokenTitle": MessageLookupByLibrary.simpleMessage(
            "Register your device to the forum"),
        "releaseToLoad":
            MessageLookupByLibrary.simpleMessage("Release to load"),
        "releaseToRefresh":
            MessageLookupByLibrary.simpleMessage("Release to refresh"),
        "relogin": MessageLookupByLibrary.simpleMessage("relogin"),
        "rememberPasswordInAppDetail":
            MessageLookupByLibrary.simpleMessage("View details"),
        "rememeberPasswordInApp": MessageLookupByLibrary.simpleMessage(
            "Remember password to device."),
        "replyPost": MessageLookupByLibrary.simpleMessage("Reply"),
        "replyPostTrimMessage": m37,
        "reportContentTitle": m38,
        "reportDiscuzApiInformationToAnalytics":
            MessageLookupByLibrary.simpleMessage("Report availability to us"),
        "reportDiscuzApiInformationToAnalyticsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Your report to this site is truly important to us. Our app is optimised for Discuz! forum, and it is important for us to know which our app should be optimised for. The report itself is anonymous and we will not record any information related with you."),
        "reportDiscuzApiInformationToAnalyticsTitle":
            MessageLookupByLibrary.simpleMessage("Report availability to us"),
        "reportOtherReasonHint":
            MessageLookupByLibrary.simpleMessage("Type to report other reason"),
        "reportSuccessfully": m39,
        "reportThreadTooltip":
            MessageLookupByLibrary.simpleMessage("Report the post"),
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
        "securityTitle": MessageLookupByLibrary.simpleMessage("Security"),
        "seeAllReplies":
            MessageLookupByLibrary.simpleMessage("View all replies"),
        "selectColorAndShadeTitle":
            MessageLookupByLibrary.simpleMessage("Select color and shade"),
        "selectColorShadeTitle":
            MessageLookupByLibrary.simpleMessage("Select color shade"),
        "selectColorTitle":
            MessageLookupByLibrary.simpleMessage("Select color"),
        "selectDiscuzIconTooltip":
            MessageLookupByLibrary.simpleMessage("Select discuz forum"),
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
        "signInSuccessTitle": m40,
        "signInTitle": m41,
        "signInViaBrowser":
            MessageLookupByLibrary.simpleMessage("Sign in by web"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signatureHint": MessageLookupByLibrary.simpleMessage(
            "Input signature for every post"),
        "signaturePreview": MessageLookupByLibrary.simpleMessage("Preview"),
        "signatureStyle":
            MessageLookupByLibrary.simpleMessage("Signature style"),
        "signatureSupportUS":
            MessageLookupByLibrary.simpleMessage("Support us"),
        "signatureWithDisFly":
            MessageLookupByLibrary.simpleMessage("Use app signature"),
        "signatureWithDisFlyDescription": MessageLookupByLibrary.simpleMessage(
            "You can support us by adding the app information to your post signature. You may opt it out any time in the setting."),
        "siteDoesNotSupportPushService": MessageLookupByLibrary.simpleMessage(
            "The site may not install DHP Service."),
        "sitePage": MessageLookupByLibrary.simpleMessage("Homepage"),
        "smileyLabel": m42,
        "sortThreadInAscendOrder":
            MessageLookupByLibrary.simpleMessage("Sort thread in ascent order"),
        "sortThreadInDescendOrder": MessageLookupByLibrary.simpleMessage(
            "Sort thread in descent order"),
        "spam": MessageLookupByLibrary.simpleMessage("Spam"),
        "stickyThread": MessageLookupByLibrary.simpleMessage("Pinned thread"),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "submitPoll": m43,
        "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
        "subscribeChannel":
            MessageLookupByLibrary.simpleMessage("Push subscription"),
        "subscribeChannelForMore": MessageLookupByLibrary.simpleMessage(
            "Subscribe to the channels to get updates."),
        "subscriptionSuccess": MessageLookupByLibrary.simpleMessage(
            "Subscription change successful."),
        "successfullyDeleteViewHistoryContent": m44,
        "successfullyDownloadFiles": m45,
        "syncSuccessfullyWithServer": m46,
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
        "thread": MessageLookupByLibrary.simpleMessage("Thread"),
        "threadIsClosed":
            MessageLookupByLibrary.simpleMessage("Thread is closed."),
        "threadReadAccess": m47,
        "threadReply": m48,
        "threadView": m49,
        "trashAd": MessageLookupByLibrary.simpleMessage("Trash Advertisement"),
        "trustHostActionText":
            MessageLookupByLibrary.simpleMessage("Trust this host"),
        "trustHostTitle": MessageLookupByLibrary.simpleMessage("Trusted host"),
        "typeSetting": MessageLookupByLibrary.simpleMessage("Typesetting"),
        "typographyMaterial2014":
            MessageLookupByLibrary.simpleMessage("Material 2014"),
        "typographyMaterial2018":
            MessageLookupByLibrary.simpleMessage("Material 2018"),
        "typographyMaterial2021":
            MessageLookupByLibrary.simpleMessage("Material 2021"),
        "typographySystem":
            MessageLookupByLibrary.simpleMessage("Typography default"),
        "unableToAuthenticate": MessageLookupByLibrary.simpleMessage(
            "Doesn\'t get authentication from the system and auto fill failed."),
        "unableToVerifyAuthStatus": MessageLookupByLibrary.simpleMessage(
            "Unable to verify your auth status"),
        "unblockContent":
            MessageLookupByLibrary.simpleMessage("Unblock content"),
        "unblockUser": MessageLookupByLibrary.simpleMessage("Unblock user"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "unfavoriteIconTooltip":
            MessageLookupByLibrary.simpleMessage("Unfavorite forum"),
        "unfavoriteThreadTooltip":
            MessageLookupByLibrary.simpleMessage("Unfavorite thread"),
        "updateAt": MessageLookupByLibrary.simpleMessage("Update at %T"),
        "upgrade_notification_subtitle": MessageLookupByLibrary.simpleMessage(
            "Due to ongoing incidences, push notification service has been terminated."),
        "upgrade_notification_title":
            MessageLookupByLibrary.simpleMessage("Service termination"),
        "uploadCompressedImageToServer":
            MessageLookupByLibrary.simpleMessage("Send compressed image"),
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
        "useGoogleAnalyticsContent": MessageLookupByLibrary.simpleMessage(
            "The app use Google analytics to collect only basic information and we will not track your account according to our privacy policy."),
        "useGoogleAnalyticsTitle":
            MessageLookupByLibrary.simpleMessage("Google analytics used"),
        "useMaterial3NoSubtitle": MessageLookupByLibrary.simpleMessage(
            "App will use the Material 2 look and feel."),
        "useMaterial3Title":
            MessageLookupByLibrary.simpleMessage("Use Material You design"),
        "useMaterial3YesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Components that have been migrated to Material 3 will use new colors, typography and other features of Material 3."),
        "useThinFont": MessageLookupByLibrary.simpleMessage("Thin font"),
        "userCredit": MessageLookupByLibrary.simpleMessage("Credits"),
        "userExpiredSubtitle": MessageLookupByLibrary.simpleMessage(
            "The current user is expired, some function may not work."),
        "userExpiredTitle": m50,
        "userIdTitle": m51,
        "userPost": MessageLookupByLibrary.simpleMessage("Posts"),
        "userProfile": MessageLookupByLibrary.simpleMessage("User Profile"),
        "userProfileTitle":
            MessageLookupByLibrary.simpleMessage("User Profiles"),
        "userThread": MessageLookupByLibrary.simpleMessage("Threads"),
        "usernameIsEmpty": MessageLookupByLibrary.simpleMessage(
            "Username is empty in the form"),
        "viewAuthorInfo":
            MessageLookupByLibrary.simpleMessage("View author\'s profile"),
        "viewHistory": MessageLookupByLibrary.simpleMessage("View History"),
        "viewPicture": MessageLookupByLibrary.simpleMessage("Preview"),
        "viewPrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("View our privacy policy"),
        "viewPushServiceHomePage":
            MessageLookupByLibrary.simpleMessage("About push service ↗️"),
        "viewThreadTitle": MessageLookupByLibrary.simpleMessage("View thread"),
        "viewThreadTwoPaneText": MessageLookupByLibrary.simpleMessage(
            "Click thread to view posts inside."),
        "viewUserInfo": m52,
        "warnedPost":
            MessageLookupByLibrary.simpleMessage("The post is warned."),
        "watchPictureInFullScreen":
            MessageLookupByLibrary.simpleMessage("Full display"),
        "websiteNotLogined": MessageLookupByLibrary.simpleMessage(
            "You haven\'t login in the website, please try after you actually login."),
        "welcomeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Welcome to use our Services."),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("Welcome"),
        "wheelColorPickerType": MessageLookupByLibrary.simpleMessage("Wheel"),
        "windowsDeviceName": m53,
        "workProcedure":
            MessageLookupByLibrary.simpleMessage("How does push service work?"),
        "writeStorageDenied": MessageLookupByLibrary.simpleMessage(
            "Write storage permission denied.")
      };
}
