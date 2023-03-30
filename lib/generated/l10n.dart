// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `DisFly`
  String get appName {
    return Intl.message(
      'DisFly',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Sample`
  String get sample {
    return Intl.message(
      'Sample',
      name: 'sample',
      desc: '',
      args: [],
    );
  }

  /// `Style`
  String get style {
    return Intl.message(
      'Style',
      name: 'style',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get basicUse {
    return Intl.message(
      'Basic',
      name: 'basicUse',
      desc: '',
      args: [],
    );
  }

  /// `Basic use of EasyRefresh`
  String get basicUseDescribe {
    return Intl.message(
      'Basic use of EasyRefresh',
      name: 'basicUseDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Manual control`
  String get manualControl {
    return Intl.message(
      'Manual control',
      name: 'manualControl',
      desc: '',
      args: [],
    );
  }

  /// `Control the timing of completion of refresh and load`
  String get manualControlDescribe {
    return Intl.message(
      'Control the timing of completion of refresh and load',
      name: 'manualControlDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `LoadMore`
  String get loadMore {
    return Intl.message(
      'LoadMore',
      name: 'loadMore',
      desc: '',
      args: [],
    );
  }

  /// `Pull to refresh`
  String get pullToRefresh {
    return Intl.message(
      'Pull to refresh',
      name: 'pullToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Release to refresh`
  String get releaseToRefresh {
    return Intl.message(
      'Release to refresh',
      name: 'releaseToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing...`
  String get refreshing {
    return Intl.message(
      'Refreshing...',
      name: 'refreshing',
      desc: '',
      args: [],
    );
  }

  /// `Refresh completed`
  String get refreshFinish {
    return Intl.message(
      'Refresh completed',
      name: 'refreshFinish',
      desc: '',
      args: [],
    );
  }

  /// `Refresh failed`
  String get refreshFailed {
    return Intl.message(
      'Refresh failed',
      name: 'refreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Refresh completed`
  String get refreshed {
    return Intl.message(
      'Refresh completed',
      name: 'refreshed',
      desc: '',
      args: [],
    );
  }

  /// `Push to load`
  String get pushToLoad {
    return Intl.message(
      'Push to load',
      name: 'pushToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Release to load`
  String get releaseToLoad {
    return Intl.message(
      'Release to load',
      name: 'releaseToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Load completed`
  String get loadFinish {
    return Intl.message(
      'Load completed',
      name: 'loadFinish',
      desc: '',
      args: [],
    );
  }

  /// `Load completed`
  String get loaded {
    return Intl.message(
      'Load completed',
      name: 'loaded',
      desc: '',
      args: [],
    );
  }

  /// `Load failed`
  String get loadFailed {
    return Intl.message(
      'Load failed',
      name: 'loadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Refresh done`
  String get completeRefresh {
    return Intl.message(
      'Refresh done',
      name: 'completeRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Load done`
  String get completeLoad {
    return Intl.message(
      'Load done',
      name: 'completeLoad',
      desc: '',
      args: [],
    );
  }

  /// `No more`
  String get noMore {
    return Intl.message(
      'No more',
      name: 'noMore',
      desc: '',
      args: [],
    );
  }

  /// `Update at %T`
  String get updateAt {
    return Intl.message(
      'Update at %T',
      name: 'updateAt',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get me {
    return Intl.message(
      'Me',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `Bob minion`
  String get bobMinion {
    return Intl.message(
      'Bob minion',
      name: 'bobMinion',
      desc: '',
      args: [],
    );
  }

  /// `Cute yellow Minions`
  String get bobMinionDescribe {
    return Intl.message(
      'Cute yellow Minions',
      name: 'bobMinionDescribe',
      desc: '',
      args: [],
    );
  }

  /// `A`
  String get anonymous {
    return Intl.message(
      'A',
      name: 'anonymous',
      desc: '',
      args: [],
    );
  }

  /// ` published at `
  String get publishAt {
    return Intl.message(
      ' published at ',
      name: 'publishAt',
      desc: '',
      args: [],
    );
  }

  /// `Display a forum`
  String get forumDisplayTitle {
    return Intl.message(
      'Display a forum',
      name: 'forumDisplayTitle',
      desc: '',
      args: [],
    );
  }

  /// `View a thread`
  String get viewThreadTitle {
    return Intl.message(
      'View a thread',
      name: 'viewThreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `# {pos}`
  String postPosition(Object pos) {
    return Intl.message(
      '# $pos',
      name: 'postPosition',
      desc: '',
      args: [pos],
    );
  }

  /// `Index`
  String get index {
    return Intl.message(
      'Index',
      name: 'index',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Add a new Discuz! site`
  String get addNewDiscuz {
    return Intl.message(
      'Add a new Discuz! site',
      name: 'addNewDiscuz',
      desc: '',
      args: [],
    );
  }

  /// `No Discuz! BBS is selected`
  String get nullDiscuzTitle {
    return Intl.message(
      'No Discuz! BBS is selected',
      name: 'nullDiscuzTitle',
      desc: '',
      args: [],
    );
  }

  /// `Why not consider add a discuz forum?`
  String get nullDiscuzSubTitle {
    return Intl.message(
      'Why not consider add a discuz forum?',
      name: 'nullDiscuzSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Choose a BBS`
  String get chooseDiscuz {
    return Intl.message(
      'Choose a BBS',
      name: 'chooseDiscuz',
      desc: '',
      args: [],
    );
  }

  /// `AD`
  String get googleAdTitle {
    return Intl.message(
      'AD',
      name: 'googleAdTitle',
      desc: '',
      args: [],
    );
  }

  /// `Advertisement provided by Google`
  String get googleAdSubTitle {
    return Intl.message(
      'Advertisement provided by Google',
      name: 'googleAdSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingTitle {
    return Intl.message(
      'Settings',
      name: 'settingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginTitle {
    return Intl.message(
      'Login',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a new user`
  String get loginSubtitle {
    return Intl.message(
      'Add a new user',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Incognito mode`
  String get incognitoTitle {
    return Intl.message(
      'Incognito mode',
      name: 'incognitoTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will browse the forum in incognito mode`
  String get incognitoSubtitle {
    return Intl.message(
      'You will browse the forum in incognito mode',
      name: 'incognitoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `User {username} expired`
  String userExpiredTitle(Object username) {
    return Intl.message(
      'User $username expired',
      name: 'userExpiredTitle',
      desc: '',
      args: [username],
    );
  }

  /// `The current user is expired, some function may not work.`
  String get userExpiredSubtitle {
    return Intl.message(
      'The current user is expired, some function may not work.',
      name: 'userExpiredSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get sendReply {
    return Intl.message(
      'Send',
      name: 'sendReply',
      desc: '',
      args: [],
    );
  }

  /// `Sending`
  String get progressButtonReplySending {
    return Intl.message(
      'Sending',
      name: 'progressButtonReplySending',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get progressButtonReplyFailed {
    return Intl.message(
      'Failed',
      name: 'progressButtonReplyFailed',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get progressButtonReplySuccess {
    return Intl.message(
      'Success',
      name: 'progressButtonReplySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Sigining in...`
  String get progressButtonLogining {
    return Intl.message(
      'Sigining in...',
      name: 'progressButtonLogining',
      desc: '',
      args: [],
    );
  }

  /// `Login Failed`
  String get progressButtonLoginFailed {
    return Intl.message(
      'Login Failed',
      name: 'progressButtonLoginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Login Success`
  String get progressButtonLoginSuccess {
    return Intl.message(
      'Login Success',
      name: 'progressButtonLoginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `UserId {uid}`
  String userIdTitle(Object uid) {
    return Intl.message(
      'UserId $uid',
      name: 'userIdTitle',
      desc: '',
      args: [uid],
    );
  }

  /// `Say something`
  String get sendReplyHint {
    return Intl.message(
      'Say something',
      name: 'sendReplyHint',
      desc: '',
      args: [],
    );
  }

  /// `Sign in at {discuzName}`
  String signInTitle(Object discuzName) {
    return Intl.message(
      'Sign in at $discuzName',
      name: 'signInTitle',
      desc: '',
      args: [discuzName],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Forget password?`
  String get forgetPassword {
    return Intl.message(
      'Forget password?',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Sign in by web`
  String get signInViaBrowser {
    return Intl.message(
      'Sign in by web',
      name: 'signInViaBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `User {username} sign in at {discuzName} successfully.`
  String signInSuccessTitle(Object username, Object discuzName) {
    return Intl.message(
      'User $username sign in at $discuzName successfully.',
      name: 'signInSuccessTitle',
      desc: '',
      args: [username, discuzName],
    );
  }

  /// `No user is currently activated`
  String get selectUserNull {
    return Intl.message(
      'No user is currently activated',
      name: 'selectUserNull',
      desc: '',
      args: [],
    );
  }

  /// `Unable to open the uri: {uri}.`
  String linkUnableToOpen(Object uri) {
    return Intl.message(
      'Unable to open the uri: $uri.',
      name: 'linkUnableToOpen',
      desc: '',
      args: [uri],
    );
  }

  /// `The link doesn't belong to the BBS`
  String get outerlinkOpenTitle {
    return Intl.message(
      'The link doesn\'t belong to the BBS',
      name: 'outerlinkOpenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Host of the link is not the same as the BBS. It would be dangerous to browse.`
  String get outerlinkOpenMessage {
    return Intl.message(
      'Host of the link is not the same as the BBS. It would be dangerous to browse.',
      name: 'outerlinkOpenMessage',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get savePictureToDevice {
    return Intl.message(
      'Save',
      name: 'savePictureToDevice',
      desc: '',
      args: [],
    );
  }

  /// `Open in browser`
  String get openInBrowser {
    return Intl.message(
      'Open in browser',
      name: 'openInBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Write storage permission denied.`
  String get writeStorageDenied {
    return Intl.message(
      'Write storage permission denied.',
      name: 'writeStorageDenied',
      desc: '',
      args: [],
    );
  }

  /// `Save Image to device successfully.`
  String get saveImageSuccessfully {
    return Intl.message(
      'Save Image to device successfully.',
      name: 'saveImageSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get downloadAttachment {
    return Intl.message(
      'Download',
      name: 'downloadAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Full display`
  String get watchPictureInFullScreen {
    return Intl.message(
      'Full display',
      name: 'watchPictureInFullScreen',
      desc: '',
      args: [],
    );
  }

  /// `Manage account`
  String get manageAccount {
    return Intl.message(
      'Manage account',
      name: 'manageAccount',
      desc: '',
      args: [],
    );
  }

  /// `Successfully download file: {filename}.`
  String successfullyDownloadFiles(Object filename) {
    return Intl.message(
      'Successfully download file: $filename.',
      name: 'successfullyDownloadFiles',
      desc: '',
      args: [filename],
    );
  }

  /// `Downloading file: {filename} in background.`
  String downloadingFiles(Object filename) {
    return Intl.message(
      'Downloading file: $filename in background.',
      name: 'downloadingFiles',
      desc: '',
      args: [filename],
    );
  }

  /// `Open`
  String get openFileInExternalAppActionText {
    return Intl.message(
      'Open',
      name: 'openFileInExternalAppActionText',
      desc: '',
      args: [],
    );
  }

  /// `File downloads successfully. Do you want to open it now?`
  String get openFileInExternalAppContent {
    return Intl.message(
      'File downloads successfully. Do you want to open it now?',
      name: 'openFileInExternalAppContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Manage accounts`
  String get manageAccountTitle {
    return Intl.message(
      'Manage accounts',
      name: 'manageAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteAccount {
    return Intl.message(
      'Delete',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete account {account} successfully.`
  String deleteAccountSuccessfully(Object account) {
    return Intl.message(
      'Delete account $account successfully.',
      name: 'deleteAccountSuccessfully',
      desc: '',
      args: [account],
    );
  }

  /// `Preparing the page.`
  String get preparingPage {
    return Intl.message(
      'Preparing the page.',
      name: 'preparingPage',
      desc: '',
      args: [],
    );
  }

  /// `Delete discuz {account} successfully.`
  String deleteDiscuzSuccessfully(Object account) {
    return Intl.message(
      'Delete discuz $account successfully.',
      name: 'deleteDiscuzSuccessfully',
      desc: '',
      args: [account],
    );
  }

  /// `Manage BBS`
  String get manageDiscuz {
    return Intl.message(
      'Manage BBS',
      name: 'manageDiscuz',
      desc: '',
      args: [],
    );
  }

  /// `relogin`
  String get relogin {
    return Intl.message(
      'relogin',
      name: 'relogin',
      desc: '',
      args: [],
    );
  }

  /// `Record history`
  String get recordHistoryTitle {
    return Intl.message(
      'Record history',
      name: 'recordHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `App will record your browser history`
  String get recordHistoryOnDescription {
    return Intl.message(
      'App will record your browser history',
      name: 'recordHistoryOnDescription',
      desc: '',
      args: [],
    );
  }

  /// `App Won't record your browser history`
  String get recordHistoryOffDescription {
    return Intl.message(
      'App Won\'t record your browser history',
      name: 'recordHistoryOffDescription',
      desc: '',
      args: [],
    );
  }

  /// `Common`
  String get common {
    return Intl.message(
      'Common',
      name: 'common',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Open source licence`
  String get openSourceLicence {
    return Intl.message(
      'Open source licence',
      name: 'openSourceLicence',
      desc: '',
      args: [],
    );
  }

  /// `Our policy`
  String get policy {
    return Intl.message(
      'Our policy',
      name: 'policy',
      desc: '',
      args: [],
    );
  }

  /// `View History`
  String get viewHistory {
    return Intl.message(
      'View History',
      name: 'viewHistory',
      desc: '',
      args: [],
    );
  }

  /// `Clear all histories`
  String get clearAllViewHistories {
    return Intl.message(
      'Clear all histories',
      name: 'clearAllViewHistories',
      desc: '',
      args: [],
    );
  }

  /// `The content is empty`
  String get emptyListDescription {
    return Intl.message(
      'The content is empty',
      name: 'emptyListDescription',
      desc: '',
      args: [],
    );
  }

  /// `Successfully remove view history {title}.`
  String successfullyDeleteViewHistoryContent(Object title) {
    return Intl.message(
      'Successfully remove view history $title.',
      name: 'successfullyDeleteViewHistoryContent',
      desc: '',
      args: [title],
    );
  }

  /// `Clearing operation is irrecoverable, please take care.`
  String get deleteViewHistoryWarnContent {
    return Intl.message(
      'Clearing operation is irrecoverable, please take care.',
      name: 'deleteViewHistoryWarnContent',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get undo {
    return Intl.message(
      'Undo',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Trusted host`
  String get trustHostTitle {
    return Intl.message(
      'Trusted host',
      name: 'trustHostTitle',
      desc: '',
      args: [],
    );
  }

  /// `Trust this host`
  String get trustHostActionText {
    return Intl.message(
      'Trust this host',
      name: 'trustHostActionText',
      desc: '',
      args: [],
    );
  }

  /// `Captcha required.`
  String get captchaRequired {
    return Intl.message(
      'Captcha required.',
      name: 'captchaRequired',
      desc: '',
      args: [],
    );
  }

  /// `Submit ({checked} / {allowed})`
  String submitPoll(Object checked, Object allowed) {
    return Intl.message(
      'Submit ($checked / $allowed)',
      name: 'submitPoll',
      desc: '',
      args: [checked, allowed],
    );
  }

  /// `Poll will expire at {time}.`
  String pollExpireAt(Object time) {
    return Intl.message(
      'Poll will expire at $time.',
      name: 'pollExpireAt',
      desc: '',
      args: [time],
    );
  }

  /// `{people} have voted.`
  String pollVoterNumber(Object people) {
    return Intl.message(
      '$people have voted.',
      name: 'pollVoterNumber',
      desc: '',
      args: [people],
    );
  }

  /// `Unable to verify your auth status`
  String get unableToVerifyAuthStatus {
    return Intl.message(
      'Unable to verify your auth status',
      name: 'unableToVerifyAuthStatus',
      desc: '',
      args: [],
    );
  }

  /// `How to login by web?`
  String get loginByWebTitle {
    return Intl.message(
      'How to login by web?',
      name: 'loginByWebTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please login via webpage then press the floating button on bottom-right to save the authentication to the device.`
  String get loginByWebMessage {
    return Intl.message(
      'Please login via webpage then press the floating button on bottom-right to save the authentication to the device.',
      name: 'loginByWebMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please be aware that you are browsing a HTTP-served webpage, and it may be modified by a third-party entity. You should take caution in sending your information via the protocol. Consider using HTTPS for safety.`
  String get loginByWebHttpWarn {
    return Intl.message(
      'Please be aware that you are browsing a HTTP-served webpage, and it may be modified by a third-party entity. You should take caution in sending your information via the protocol. Consider using HTTPS for safety.',
      name: 'loginByWebHttpWarn',
      desc: '',
      args: [],
    );
  }

  /// `Current operation system doesn't support webview.`
  String get loginByWebNotSupported {
    return Intl.message(
      'Current operation system doesn\'t support webview.',
      name: 'loginByWebNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get forumFilterTypeIdTitle {
    return Intl.message(
      'Category',
      name: 'forumFilterTypeIdTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get forumFilterSortByTitle {
    return Intl.message(
      'Sort by',
      name: 'forumFilterSortByTitle',
      desc: '',
      args: [],
    );
  }

  /// `Last post`
  String get forumFilterSortByLastPost {
    return Intl.message(
      'Last post',
      name: 'forumFilterSortByLastPost',
      desc: '',
      args: [],
    );
  }

  /// `New post`
  String get forumFilterSortByNewPost {
    return Intl.message(
      'New post',
      name: 'forumFilterSortByNewPost',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get forumFilterSortByView {
    return Intl.message(
      'View',
      name: 'forumFilterSortByView',
      desc: '',
      args: [],
    );
  }

  /// `Heat`
  String get forumFilterSortByHeat {
    return Intl.message(
      'Heat',
      name: 'forumFilterSortByHeat',
      desc: '',
      args: [],
    );
  }

  /// `Special Thread`
  String get forumFilterSpecialTypeTitle {
    return Intl.message(
      'Special Thread',
      name: 'forumFilterSpecialTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Debate`
  String get forumFilterSpecialTypeDebate {
    return Intl.message(
      'Debate',
      name: 'forumFilterSpecialTypeDebate',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get forumFilterSpecialTypeActivity {
    return Intl.message(
      'Activity',
      name: 'forumFilterSpecialTypeActivity',
      desc: '',
      args: [],
    );
  }

  /// `Poll`
  String get forumFilterSpecialTypePoll {
    return Intl.message(
      'Poll',
      name: 'forumFilterSpecialTypePoll',
      desc: '',
      args: [],
    );
  }

  /// `Time Filter`
  String get forumFilterTimeTitle {
    return Intl.message(
      'Time Filter',
      name: 'forumFilterTimeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get forumFilterTimeToday {
    return Intl.message(
      'Today',
      name: 'forumFilterTimeToday',
      desc: '',
      args: [],
    );
  }

  /// `This week`
  String get forumFilterTimeThisWeek {
    return Intl.message(
      'This week',
      name: 'forumFilterTimeThisWeek',
      desc: '',
      args: [],
    );
  }

  /// `This month`
  String get forumFilterTimeThisMonth {
    return Intl.message(
      'This month',
      name: 'forumFilterTimeThisMonth',
      desc: '',
      args: [],
    );
  }

  /// `This quarter`
  String get forumFilterTimeThisQuarter {
    return Intl.message(
      'This quarter',
      name: 'forumFilterTimeThisQuarter',
      desc: '',
      args: [],
    );
  }

  /// `This year`
  String get forumFilterTimeThisYear {
    return Intl.message(
      'This year',
      name: 'forumFilterTimeThisYear',
      desc: '',
      args: [],
    );
  }

  /// `Thread Status`
  String get forumFilterStatusTitle {
    return Intl.message(
      'Thread Status',
      name: 'forumFilterStatusTitle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get forumFilterStatusAll {
    return Intl.message(
      'All',
      name: 'forumFilterStatusAll',
      desc: '',
      args: [],
    );
  }

  /// `Digest`
  String get forumFilterStatusDigest {
    return Intl.message(
      'Digest',
      name: 'forumFilterStatusDigest',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get forumFilterStatusHot {
    return Intl.message(
      'Popular',
      name: 'forumFilterStatusHot',
      desc: '',
      args: [],
    );
  }

  /// `The content here is empty.`
  String get emptyScreenTitle {
    return Intl.message(
      'The content here is empty.',
      name: 'emptyScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `User Profiles`
  String get userProfileTitle {
    return Intl.message(
      'User Profiles',
      name: 'userProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Read Access: {readAccess} and Star: {star}`
  String groupInfoDescription(Object readAccess, Object star) {
    return Intl.message(
      'Read Access: $readAccess and Star: $star',
      name: 'groupInfoDescription',
      desc: '',
      args: [readAccess, star],
    );
  }

  /// `Custom title`
  String get customStatusTitle {
    return Intl.message(
      'Custom title',
      name: 'customStatusTitle',
      desc: '',
      args: [],
    );
  }

  /// `Register at`
  String get registerAccountTime {
    return Intl.message(
      'Register at',
      name: 'registerAccountTime',
      desc: '',
      args: [],
    );
  }

  /// `Last visit at`
  String get lastVisitTime {
    return Intl.message(
      'Last visit at',
      name: 'lastVisitTime',
      desc: '',
      args: [],
    );
  }

  /// `Last active at`
  String get lastActivityTime {
    return Intl.message(
      'Last active at',
      name: 'lastActivityTime',
      desc: '',
      args: [],
    );
  }

  /// `Last post at`
  String get lastPostTime {
    return Intl.message(
      'Last post at',
      name: 'lastPostTime',
      desc: '',
      args: [],
    );
  }

  /// `Recent note`
  String get recentNote {
    return Intl.message(
      'Recent note',
      name: 'recentNote',
      desc: '',
      args: [],
    );
  }

  /// `Online Time`
  String get onlineHoursTitle {
    return Intl.message(
      'Online Time',
      name: 'onlineHoursTitle',
      desc: '',
      args: [],
    );
  }

  /// `{hour} hour(s).`
  String onlineHours(Object hour) {
    return Intl.message(
      '$hour hour(s).',
      name: 'onlineHours',
      desc: '',
      args: [hour],
    );
  }

  /// `Birth place`
  String get birthPlace {
    return Intl.message(
      'Birth place',
      name: 'birthPlace',
      desc: '',
      args: [],
    );
  }

  /// `Resident place`
  String get residentPlace {
    return Intl.message(
      'Resident place',
      name: 'residentPlace',
      desc: '',
      args: [],
    );
  }

  /// `Credit`
  String get credit {
    return Intl.message(
      'Credit',
      name: 'credit',
      desc: '',
      args: [],
    );
  }

  /// `Homepage`
  String get homepage {
    return Intl.message(
      'Homepage',
      name: 'homepage',
      desc: '',
      args: [],
    );
  }

  /// `Habits`
  String get habit {
    return Intl.message(
      'Habits',
      name: 'habit',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friendNumber {
    return Intl.message(
      'Friends',
      name: 'friendNumber',
      desc: '',
      args: [],
    );
  }

  /// `Post number`
  String get postNumber {
    return Intl.message(
      'Post number',
      name: 'postNumber',
      desc: '',
      args: [],
    );
  }

  /// `Bio`
  String get bio {
    return Intl.message(
      'Bio',
      name: 'bio',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message(
      'Favorites',
      name: 'favorites',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chatMessage {
    return Intl.message(
      'Chat',
      name: 'chatMessage',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get privateMessage {
    return Intl.message(
      'Private',
      name: 'privateMessage',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get publicMessage {
    return Intl.message(
      'Public',
      name: 'publicMessage',
      desc: '',
      args: [],
    );
  }

  /// `The post is warned.`
  String get warnedPost {
    return Intl.message(
      'The post is warned.',
      name: 'warnedPost',
      desc: '',
      args: [],
    );
  }

  /// `The post is blocked.`
  String get blockedPost {
    return Intl.message(
      'The post is blocked.',
      name: 'blockedPost',
      desc: '',
      args: [],
    );
  }

  /// `The post is revised to prevent duplicated scoring.`
  String get revisedPost {
    return Intl.message(
      'The post is revised to prevent duplicated scoring.',
      name: 'revisedPost',
      desc: '',
      args: [],
    );
  }

  /// `Theme color`
  String get chooseThemeTitle {
    return Intl.message(
      'Theme color',
      name: 'chooseThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Grey`
  String get colorGrey {
    return Intl.message(
      'Grey',
      name: 'colorGrey',
      desc: '',
      args: [],
    );
  }

  /// `Blue`
  String get colorBlue {
    return Intl.message(
      'Blue',
      name: 'colorBlue',
      desc: '',
      args: [],
    );
  }

  /// `Blue Accent`
  String get colorBlueAccent {
    return Intl.message(
      'Blue Accent',
      name: 'colorBlueAccent',
      desc: '',
      args: [],
    );
  }

  /// `Cyan`
  String get colorCyan {
    return Intl.message(
      'Cyan',
      name: 'colorCyan',
      desc: '',
      args: [],
    );
  }

  /// `Deep purple`
  String get colorDeepPurple {
    return Intl.message(
      'Deep purple',
      name: 'colorDeepPurple',
      desc: '',
      args: [],
    );
  }

  /// `Deep purple accent`
  String get colorDeepPurpleAccent {
    return Intl.message(
      'Deep purple accent',
      name: 'colorDeepPurpleAccent',
      desc: '',
      args: [],
    );
  }

  /// `Deep orange`
  String get colorDeepOrange {
    return Intl.message(
      'Deep orange',
      name: 'colorDeepOrange',
      desc: '',
      args: [],
    );
  }

  /// `Green`
  String get colorGreen {
    return Intl.message(
      'Green',
      name: 'colorGreen',
      desc: '',
      args: [],
    );
  }

  /// `Indigo`
  String get colorIndigo {
    return Intl.message(
      'Indigo',
      name: 'colorIndigo',
      desc: '',
      args: [],
    );
  }

  /// `Indigo accent`
  String get colorIndigoAccent {
    return Intl.message(
      'Indigo accent',
      name: 'colorIndigoAccent',
      desc: '',
      args: [],
    );
  }

  /// `Orange`
  String get colorOrange {
    return Intl.message(
      'Orange',
      name: 'colorOrange',
      desc: '',
      args: [],
    );
  }

  /// `Purple`
  String get colorPurple {
    return Intl.message(
      'Purple',
      name: 'colorPurple',
      desc: '',
      args: [],
    );
  }

  /// `Pink`
  String get colorPink {
    return Intl.message(
      'Pink',
      name: 'colorPink',
      desc: '',
      args: [],
    );
  }

  /// `Red`
  String get colorRed {
    return Intl.message(
      'Red',
      name: 'colorRed',
      desc: '',
      args: [],
    );
  }

  /// `Teal`
  String get colorTeal {
    return Intl.message(
      'Teal',
      name: 'colorTeal',
      desc: '',
      args: [],
    );
  }

  /// `Black`
  String get colorBlack {
    return Intl.message(
      'Black',
      name: 'colorBlack',
      desc: '',
      args: [],
    );
  }

  /// `Brown`
  String get colorBrown {
    return Intl.message(
      'Brown',
      name: 'colorBrown',
      desc: '',
      args: [],
    );
  }

  /// `Amber`
  String get colorAmber {
    return Intl.message(
      'Amber',
      name: 'colorAmber',
      desc: '',
      args: [],
    );
  }

  /// `Light blue`
  String get colorLightBlue {
    return Intl.message(
      'Light blue',
      name: 'colorLightBlue',
      desc: '',
      args: [],
    );
  }

  /// `Blue Grey`
  String get colorBlueGrey {
    return Intl.message(
      'Blue Grey',
      name: 'colorBlueGrey',
      desc: '',
      args: [],
    );
  }

  /// `Light green`
  String get colorLightGreen {
    return Intl.message(
      'Light green',
      name: 'colorLightGreen',
      desc: '',
      args: [],
    );
  }

  /// `Lime`
  String get colorLime {
    return Intl.message(
      'Lime',
      name: 'colorLime',
      desc: '',
      args: [],
    );
  }

  /// `Yellow`
  String get colorYellow {
    return Intl.message(
      'Yellow',
      name: 'colorYellow',
      desc: '',
      args: [],
    );
  }

  /// `Connect to BBS server for verification.`
  String get connectServerWhenAdding {
    return Intl.message(
      'Connect to BBS server for verification.',
      name: 'connectServerWhenAdding',
      desc: '',
      args: [],
    );
  }

  /// `The Discuz's address`
  String get discuzServerAddress {
    return Intl.message(
      'The Discuz\'s address',
      name: 'discuzServerAddress',
      desc: '',
      args: [],
    );
  }

  /// `eg. https://bbs.nwpu.edu.cn`
  String get discuzServerAddressHint {
    return Intl.message(
      'eg. https://bbs.nwpu.edu.cn',
      name: 'discuzServerAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `It usually is the address discuz serves.`
  String get discuzServerAddressHelperText {
    return Intl.message(
      'It usually is the address discuz serves.',
      name: 'discuzServerAddressHelperText',
      desc: '',
      args: [],
    );
  }

  /// `Invalid discuz address.`
  String get incorrectDiscuzAddress {
    return Intl.message(
      'Invalid discuz address.',
      name: 'incorrectDiscuzAddress',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelAdding {
    return Intl.message(
      'Cancel',
      name: 'cancelAdding',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueAdding {
    return Intl.message(
      'Continue',
      name: 'continueAdding',
      desc: '',
      args: [],
    );
  }

  /// `View author's profile`
  String get viewAuthorInfo {
    return Intl.message(
      'View author\'s profile',
      name: 'viewAuthorInfo',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get replyPost {
    return Intl.message(
      'Reply',
      name: 'replyPost',
      desc: '',
      args: [],
    );
  }

  /// `View {user}'s profile.`
  String viewUserInfo(Object user) {
    return Intl.message(
      'View $user\'s profile.',
      name: 'viewUserInfo',
      desc: '',
      args: [user],
    );
  }

  /// `[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid={pid}&ptid={ptid}]{author} posted at {fullTimeString}[/url][/size]\n{trimMessage}[/quote]`
  String replyPostTrimMessage(Object pid, Object ptid, Object author,
      Object fullTimeString, Object trimMessage) {
    return Intl.message(
      '[quote][size=2][url=forum.php?mod=redirect&goto=findpost&pid=$pid&ptid=$ptid]$author posted at $fullTimeString[/url][/size]\n$trimMessage[/quote]',
      name: 'replyPostTrimMessage',
      desc: '',
      args: [pid, ptid, author, fullTimeString, trimMessage],
    );
  }

  /// `[Pic]`
  String get pictureTagInMessage {
    return Intl.message(
      '[Pic]',
      name: 'pictureTagInMessage',
      desc: '',
      args: [],
    );
  }

  /// `HTTP protocol warning`
  String get httpBrowseWarn {
    return Intl.message(
      'HTTP protocol warning',
      name: 'httpBrowseWarn',
      desc: '',
      args: [],
    );
  }

  /// `Platform preference`
  String get appearanceOptimizedPlatform {
    return Intl.message(
      'Platform preference',
      name: 'appearanceOptimizedPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Choose the app appearance on preferred platform.`
  String get appearanceOptimizedPlatformSubtitle {
    return Intl.message(
      'Choose the app appearance on preferred platform.',
      name: 'appearanceOptimizedPlatformSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `iOS`
  String get ios {
    return Intl.message(
      'iOS',
      name: 'ios',
      desc: '',
      args: [],
    );
  }

  /// `Material Design`
  String get materialDesign {
    return Intl.message(
      'Material Design',
      name: 'materialDesign',
      desc: '',
      args: [],
    );
  }

  /// `Fuchsia`
  String get fuchsia {
    return Intl.message(
      'Fuchsia',
      name: 'fuchsia',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get followSystem {
    return Intl.message(
      'Follow system',
      name: 'followSystem',
      desc: '',
      args: [],
    );
  }

  /// `Add a discuz! BBS`
  String get addDiscuzTitle {
    return Intl.message(
      'Add a discuz! BBS',
      name: 'addDiscuzTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add {discuz} to your device successfully.`
  String addDiscuzSuccessfully(Object discuz) {
    return Intl.message(
      'Add $discuz to your device successfully.',
      name: 'addDiscuzSuccessfully',
      desc: '',
      args: [discuz],
    );
  }

  /// `Built with flutter, made with ♥, run on multiple platforms.`
  String get buildDescription {
    return Intl.message(
      'Built with flutter, made with ♥, run on multiple platforms.',
      name: 'buildDescription',
      desc: '',
      args: [],
    );
  }

  /// `Legal information`
  String get legalInformation {
    return Intl.message(
      'Legal information',
      name: 'legalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get displaySettingTitle {
    return Intl.message(
      'Display',
      name: 'displaySettingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Font size in paragraph`
  String get fontSizeInParagraph {
    return Intl.message(
      'Font size in paragraph',
      name: 'fontSizeInParagraph',
      desc: '',
      args: [],
    );
  }

  /// `{size} pt`
  String fontSizeInParagraphUnit(Object size) {
    return Intl.message(
      '$size pt',
      name: 'fontSizeInParagraphUnit',
      desc: '',
      args: [size],
    );
  }

  /// `Scale parameter in typesetting`
  String get fontSizeScaleParameter {
    return Intl.message(
      'Scale parameter in typesetting',
      name: 'fontSizeScaleParameter',
      desc: '',
      args: [],
    );
  }

  /// `x {size}`
  String fontSizeScaleParameterUnit(Object size) {
    return Intl.message(
      'x $size',
      name: 'fontSizeScaleParameterUnit',
      desc: '',
      args: [size],
    );
  }

  /// `Welcome to Discuzhub<br/>Thanks for using our products and <a href="https://discuzhub.kidozh.com/en/term_of_use/">services</a> (“Services”).<br/>By using our Services, you are agreeing to these terms. Please read them <b>carefully</b>.<br/>Our Services are very diverse, so sometimes additional terms or product requirements (including age requirements) may apply. Additional terms will be available with the relevant Services, and those additional terms become part of your agreement with us if you use those Services`
  String get largeRichText {
    return Intl.message(
      'Welcome to Discuzhub<br/>Thanks for using our products and <a href="https://discuzhub.kidozh.com/en/term_of_use/">services</a> (“Services”).<br/>By using our Services, you are agreeing to these terms. Please read them <b>carefully</b>.<br/>Our Services are very diverse, so sometimes additional terms or product requirements (including age requirements) may apply. Additional terms will be available with the relevant Services, and those additional terms become part of your agreement with us if you use those Services',
      name: 'largeRichText',
      desc: '',
      args: [],
    );
  }

  /// `Comes From Our Term of Services`
  String get largeRichTextDescription {
    return Intl.message(
      'Comes From Our Term of Services',
      name: 'largeRichTextDescription',
      desc: '',
      args: [],
    );
  }

  /// `OP`
  String get postAuthorLabel {
    return Intl.message(
      'OP',
      name: 'postAuthorLabel',
      desc: '',
      args: [],
    );
  }

  /// `User Profile`
  String get userProfile {
    return Intl.message(
      'User Profile',
      name: 'userProfile',
      desc: '',
      args: [],
    );
  }

  /// `Just Now`
  String get justNow {
    return Intl.message(
      'Just Now',
      name: 'justNow',
      desc: '',
      args: [],
    );
  }

  /// `{min} minutes ago`
  String minuteAgo(Object min) {
    return Intl.message(
      '$min minutes ago',
      name: 'minuteAgo',
      desc: '',
      args: [min],
    );
  }

  /// `{hour} hours ago`
  String hourAgo(Object hour) {
    return Intl.message(
      '$hour hours ago',
      name: 'hourAgo',
      desc: '',
      args: [hour],
    );
  }

  /// `{day} days ago`
  String dayAgo(Object day) {
    return Intl.message(
      '$day days ago',
      name: 'dayAgo',
      desc: '',
      args: [day],
    );
  }

  /// `{min} minutes later`
  String minuteLater(Object min) {
    return Intl.message(
      '$min minutes later',
      name: 'minuteLater',
      desc: '',
      args: [min],
    );
  }

  /// `{hour} hours later`
  String hourLater(Object hour) {
    return Intl.message(
      '$hour hours later',
      name: 'hourLater',
      desc: '',
      args: [hour],
    );
  }

  /// `{day} days later`
  String dayLater(Object day) {
    return Intl.message(
      '$day days later',
      name: 'dayLater',
      desc: '',
      args: [day],
    );
  }

  /// `Brightness`
  String get interfaceBrightness {
    return Intl.message(
      'Brightness',
      name: 'interfaceBrightness',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get brightnessLight {
    return Intl.message(
      'Light',
      name: 'brightnessLight',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get brightnessDark {
    return Intl.message(
      'Dark',
      name: 'brightnessDark',
      desc: '',
      args: [],
    );
  }

  /// `Open Website in webview`
  String get openViaInternalBrowser {
    return Intl.message(
      'Open Website in webview',
      name: 'openViaInternalBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Smiley #{index}`
  String smileyLabel(Object index) {
    return Intl.message(
      'Smiley #$index',
      name: 'smileyLabel',
      desc: '',
      args: [index],
    );
  }

  /// `OP mode`
  String get onlyViewAuthor {
    return Intl.message(
      'OP mode',
      name: 'onlyViewAuthor',
      desc: '',
      args: [],
    );
  }

  /// `View all replies`
  String get seeAllReplies {
    return Intl.message(
      'View all replies',
      name: 'seeAllReplies',
      desc: '',
      args: [],
    );
  }

  /// `Homepage`
  String get sitePage {
    return Intl.message(
      'Homepage',
      name: 'sitePage',
      desc: '',
      args: [],
    );
  }

  /// `Disable custom font`
  String get disableFontCustomization {
    return Intl.message(
      'Disable custom font',
      name: 'disableFontCustomization',
      desc: '',
      args: [],
    );
  }

  /// `Ignore all customized font information`
  String get disableFontCustomizationTitle {
    return Intl.message(
      'Ignore all customized font information',
      name: 'disableFontCustomizationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Typesetting`
  String get typeSetting {
    return Intl.message(
      'Typesetting',
      name: 'typeSetting',
      desc: '',
      args: [],
    );
  }

  /// `Tap to wipe out and re-login user`
  String get tapToWipeAndRelogin {
    return Intl.message(
      'Tap to wipe out and re-login user',
      name: 'tapToWipeAndRelogin',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Take a bite on beta test`
  String get testVersionNotificationTitle {
    return Intl.message(
      'Take a bite on beta test',
      name: 'testVersionNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Beta Test`
  String get testVersion {
    return Intl.message(
      'Beta Test',
      name: 'testVersion',
      desc: '',
      args: [],
    );
  }

  /// `The final product will be changed according to latest development.`
  String get testVersionDescription {
    return Intl.message(
      'The final product will be changed according to latest development.',
      name: 'testVersionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sometimes bug exists`
  String get bugTestTitle {
    return Intl.message(
      'Sometimes bug exists',
      name: 'bugTestTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can directly email us via kidozh@gmail.com. Thank you for your help!`
  String get bugTestSubtitle {
    return Intl.message(
      'You can directly email us via kidozh@gmail.com. Thank you for your help!',
      name: 'bugTestSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy protection`
  String get privacyProtectTitle {
    return Intl.message(
      'Privacy protection',
      name: 'privacyProtectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Nothing is collected by us`
  String get privacyProtectSubtitle {
    return Intl.message(
      'Nothing is collected by us',
      name: 'privacyProtectSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Open software`
  String get openSoftwareTitle {
    return Intl.message(
      'Open software',
      name: 'openSoftwareTitle',
      desc: '',
      args: [],
    );
  }

  /// `Our service is open sourced with MIT license`
  String get openSoftwareSubtitle {
    return Intl.message(
      'Our service is open sourced with MIT license',
      name: 'openSoftwareSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue to take a bite`
  String get continueToTest {
    return Intl.message(
      'Continue to take a bite',
      name: 'continueToTest',
      desc: '',
      args: [],
    );
  }

  /// `Data backup`
  String get dataBackupInTestTitle {
    return Intl.message(
      'Data backup',
      name: 'dataBackupInTestTitle',
      desc: '',
      args: [],
    );
  }

  /// `The version is not permanent and your data may get lost in upgrading process.`
  String get dataBackupInTestSubtitle {
    return Intl.message(
      'The version is not permanent and your data may get lost in upgrading process.',
      name: 'dataBackupInTestSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcomeTitle {
    return Intl.message(
      'Welcome',
      name: 'welcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to use our Services.`
  String get welcomeSubtitle {
    return Intl.message(
      'Welcome to use our Services.',
      name: 'welcomeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueToDo {
    return Intl.message(
      'Continue',
      name: 'continueToDo',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get finishLoginInWeb {
    return Intl.message(
      'Finish',
      name: 'finishLoginInWeb',
      desc: '',
      args: [],
    );
  }

  /// `Invalid cookie from response.`
  String get invalidCookie {
    return Intl.message(
      'Invalid cookie from response.',
      name: 'invalidCookie',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get addAPhoto {
    return Intl.message(
      'Photo',
      name: 'addAPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Shot`
  String get takeAPicture {
    return Intl.message(
      'Shot',
      name: 'takeAPicture',
      desc: '',
      args: [],
    );
  }

  /// `Error in connecting with the server.`
  String get networkFail {
    return Intl.message(
      'Error in connecting with the server.',
      name: 'networkFail',
      desc: '',
      args: [],
    );
  }

  /// `No Image picked`
  String get noImagePicked {
    return Intl.message(
      'No Image picked',
      name: 'noImagePicked',
      desc: '',
      args: [],
    );
  }

  /// `Encounter a unresolved issue when uploading the file`
  String get uploadImageUnknownError {
    return Intl.message(
      'Encounter a unresolved issue when uploading the file',
      name: 'uploadImageUnknownError',
      desc: '',
      args: [],
    );
  }

  /// `Internal Server Error`
  String get uploadImageErrorNegative1 {
    return Intl.message(
      'Internal Server Error',
      name: 'uploadImageErrorNegative1',
      desc: '',
      args: [],
    );
  }

  /// `The file extension is not supported.`
  String get uploadImageError1 {
    return Intl.message(
      'The file extension is not supported.',
      name: 'uploadImageError1',
      desc: '',
      args: [],
    );
  }

  /// `Your file size excesses the server limit.`
  String get uploadImageError2 {
    return Intl.message(
      'Your file size excesses the server limit.',
      name: 'uploadImageError2',
      desc: '',
      args: [],
    );
  }

  /// `The file size excesses your group limit.`
  String get uploadImageError3 {
    return Intl.message(
      'The file size excesses your group limit.',
      name: 'uploadImageError3',
      desc: '',
      args: [],
    );
  }

  /// `Your file type is not supported.`
  String get uploadImageError4 {
    return Intl.message(
      'Your file type is not supported.',
      name: 'uploadImageError4',
      desc: '',
      args: [],
    );
  }

  /// `The file size excesses file type limit.`
  String get uploadImageError5 {
    return Intl.message(
      'The file size excesses file type limit.',
      name: 'uploadImageError5',
      desc: '',
      args: [],
    );
  }

  /// `You can not upload any files today.`
  String get uploadImageError6 {
    return Intl.message(
      'You can not upload any files today.',
      name: 'uploadImageError6',
      desc: '',
      args: [],
    );
  }

  /// `The file is not an image.`
  String get uploadImageError7 {
    return Intl.message(
      'The file is not an image.',
      name: 'uploadImageError7',
      desc: '',
      args: [],
    );
  }

  /// `The file can not be stored in the server.`
  String get uploadImageError8 {
    return Intl.message(
      'The file can not be stored in the server.',
      name: 'uploadImageError8',
      desc: '',
      args: [],
    );
  }

  /// `Invalid upload method.`
  String get uploadImageError9 {
    return Intl.message(
      'Invalid upload method.',
      name: 'uploadImageError9',
      desc: '',
      args: [],
    );
  }

  /// `Invalid operation.`
  String get uploadImageError10 {
    return Intl.message(
      'Invalid operation.',
      name: 'uploadImageError10',
      desc: '',
      args: [],
    );
  }

  /// `You can not upload any large files like this today.`
  String get uploadImageError11 {
    return Intl.message(
      'You can not upload any large files like this today.',
      name: 'uploadImageError11',
      desc: '',
      args: [],
    );
  }

  /// `Upload file to server sucessfully.`
  String get uploadImageSuccessfully {
    return Intl.message(
      'Upload file to server sucessfully.',
      name: 'uploadImageSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Upload #{index}`
  String attachFile(Object index) {
    return Intl.message(
      'Upload #$index',
      name: 'attachFile',
      desc: '',
      args: [index],
    );
  }

  /// `Captcha required in reply. Please fill the captcha then send it by pushing the button.`
  String get sendImageWithVerificationNotice {
    return Intl.message(
      'Captcha required in reply. Please fill the captcha then send it by pushing the button.',
      name: 'sendImageWithVerificationNotice',
      desc: '',
      args: [],
    );
  }

  /// `You haven't login in the website, please try after you actually login.`
  String get websiteNotLogined {
    return Intl.message(
      'You haven\'t login in the website, please try after you actually login.',
      name: 'websiteNotLogined',
      desc: '',
      args: [],
    );
  }

  /// `Network failed.`
  String get networkFailed {
    return Intl.message(
      'Network failed.',
      name: 'networkFailed',
      desc: '',
      args: [],
    );
  }

  /// `Check user status...`
  String get checkUserLoginStatus {
    return Intl.message(
      'Check user status...',
      name: 'checkUserLoginStatus',
      desc: '',
      args: [],
    );
  }

  /// `Display mode can not be adjusted manually when running on iOS platform mode.`
  String get iosDarkModeDisabledText {
    return Intl.message(
      'Display mode can not be adjusted manually when running on iOS platform mode.',
      name: 'iosDarkModeDisabledText',
      desc: '',
      args: [],
    );
  }

  /// `Upload the file to Discuz server.`
  String get uploadImageToServerDialogTitle {
    return Intl.message(
      'Upload the file to Discuz server.',
      name: 'uploadImageToServerDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Recently used`
  String get savedSmileyTabTitle {
    return Intl.message(
      'Recently used',
      name: 'savedSmileyTabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try to use the first smiley?`
  String get noSmileyFoundInDB {
    return Intl.message(
      'Try to use the first smiley?',
      name: 'noSmileyFoundInDB',
      desc: '',
      args: [],
    );
  }

  /// `Upload image failed`
  String get uploadImageFailed {
    return Intl.message(
      'Upload image failed',
      name: 'uploadImageFailed',
      desc: '',
      args: [],
    );
  }

  /// `Upload the file to the server...`
  String get uploadingImageToServer {
    return Intl.message(
      'Upload the file to the server...',
      name: 'uploadingImageToServer',
      desc: '',
      args: [],
    );
  }

  /// `Send compressed image(Recommended)`
  String get uploadCompressedImageToServer {
    return Intl.message(
      'Send compressed image(Recommended)',
      name: 'uploadCompressedImageToServer',
      desc: '',
      args: [],
    );
  }

  /// `Send raw image`
  String get uploadRawImageToServer {
    return Intl.message(
      'Send raw image',
      name: 'uploadRawImageToServer',
      desc: '',
      args: [],
    );
  }

  /// `Thread is closed.`
  String get threadIsClosed {
    return Intl.message(
      'Thread is closed.',
      name: 'threadIsClosed',
      desc: '',
      args: [],
    );
  }

  /// `Block user`
  String get blockUser {
    return Intl.message(
      'Block user',
      name: 'blockUser',
      desc: '',
      args: [],
    );
  }

  /// `Unblock user`
  String get unblockUser {
    return Intl.message(
      'Unblock user',
      name: 'unblockUser',
      desc: '',
      args: [],
    );
  }

  /// `This content is posted from block user {username}`
  String contentPostByBlockUserTitle(Object username) {
    return Intl.message(
      'This content is posted from block user $username',
      name: 'contentPostByBlockUserTitle',
      desc: '',
      args: [username],
    );
  }

  /// `Unblock content`
  String get unblockContent {
    return Intl.message(
      'Unblock content',
      name: 'unblockContent',
      desc: '',
      args: [],
    );
  }

  /// `Blocked user list`
  String get blockedUserList {
    return Intl.message(
      'Blocked user list',
      name: 'blockedUserList',
      desc: '',
      args: [],
    );
  }

  /// `Report {name}`
  String reportContentTitle(Object name) {
    return Intl.message(
      'Report $name',
      name: 'reportContentTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Trash Advertisement`
  String get trashAd {
    return Intl.message(
      'Trash Advertisement',
      name: 'trashAd',
      desc: '',
      args: [],
    );
  }

  /// `Illegal Content`
  String get illegalContent {
    return Intl.message(
      'Illegal Content',
      name: 'illegalContent',
      desc: '',
      args: [],
    );
  }

  /// `Spam`
  String get spam {
    return Intl.message(
      'Spam',
      name: 'spam',
      desc: '',
      args: [],
    );
  }

  /// `Duplicated Posts`
  String get duplicatedPost {
    return Intl.message(
      'Duplicated Posts',
      name: 'duplicatedPost',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Type to report other reason`
  String get reportOtherReasonHint {
    return Intl.message(
      'Type to report other reason',
      name: 'reportOtherReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `Report to the {discuzName} Successfully`
  String reportSuccessfully(Object discuzName) {
    return Intl.message(
      'Report to the $discuzName Successfully',
      name: 'reportSuccessfully',
      desc: '',
      args: [discuzName],
    );
  }

  /// `Posts`
  String get userPost {
    return Intl.message(
      'Posts',
      name: 'userPost',
      desc: '',
      args: [],
    );
  }

  /// `Threads`
  String get userThread {
    return Intl.message(
      'Threads',
      name: 'userThread',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get userCredit {
    return Intl.message(
      'Credits',
      name: 'userCredit',
      desc: '',
      args: [],
    );
  }

  /// `RP {num}`
  String threadReadAccess(Object num) {
    return Intl.message(
      'RP $num',
      name: 'threadReadAccess',
      desc: '',
      args: [num],
    );
  }

  /// `No objectionable content and abusive action`
  String get preventAbuseUser {
    return Intl.message(
      'No objectionable content and abusive action',
      name: 'preventAbuseUser',
      desc: '',
      args: [],
    );
  }

  /// `There is no tolerance for objectionable content and abusive users`
  String get preventAbuseUserDescription {
    return Intl.message(
      'There is no tolerance for objectionable content and abusive users',
      name: 'preventAbuseUserDescription',
      desc: '',
      args: [],
    );
  }

  /// `You should agree to terms of services before using the application.`
  String get termsOfUseDescription {
    return Intl.message(
      'You should agree to terms of services before using the application.',
      name: 'termsOfUseDescription',
      desc: '',
      args: [],
    );
  }

  /// `No favorite thread is stored in your device`
  String get noFavoriteThreadInDb {
    return Intl.message(
      'No favorite thread is stored in your device',
      name: 'noFavoriteThreadInDb',
      desc: '',
      args: [],
    );
  }

  /// `All {num} favorite threads are synced from the server.`
  String syncSuccessfullyWithServer(Object num) {
    return Intl.message(
      'All $num favorite threads are synced from the server.',
      name: 'syncSuccessfullyWithServer',
      desc: '',
      args: [num],
    );
  }

  /// `Favorite threads`
  String get favoriteThread {
    return Intl.message(
      'Favorite threads',
      name: 'favoriteThread',
      desc: '',
      args: [],
    );
  }

  /// `{content}({key})`
  String discuzOperationMessage(Object key, Object content) {
    return Intl.message(
      '$content($key)',
      name: 'discuzOperationMessage',
      desc: '',
      args: [key, content],
    );
  }

  /// `Favorite forums`
  String get favoriteForum {
    return Intl.message(
      'Favorite forums',
      name: 'favoriteForum',
      desc: '',
      args: [],
    );
  }

  /// `Collapse content`
  String get collapseItem {
    return Intl.message(
      'Collapse content',
      name: 'collapseItem',
      desc: '',
      args: [],
    );
  }

  /// `Invalid count down timer`
  String get brokenCountDown {
    return Intl.message(
      'Invalid count down timer',
      name: 'brokenCountDown',
      desc: '',
      args: [],
    );
  }

  /// `The count down is finished.`
  String get countDownEnd {
    return Intl.message(
      'The count down is finished.',
      name: 'countDownEnd',
      desc: '',
      args: [],
    );
  }

  /// `This count down timezone shall be in Asia/Shanghai and might differ from your timezone`
  String get countDownTimeZoneNotify {
    return Intl.message(
      'This count down timezone shall be in Asia/Shanghai and might differ from your timezone',
      name: 'countDownTimeZoneNotify',
      desc: '',
      args: [],
    );
  }

  /// `D`
  String get day {
    return Intl.message(
      'D',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `H`
  String get hour {
    return Intl.message(
      'H',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `M`
  String get minute {
    return Intl.message(
      'M',
      name: 'minute',
      desc: '',
      args: [],
    );
  }

  /// `S`
  String get second {
    return Intl.message(
      'S',
      name: 'second',
      desc: '',
      args: [],
    );
  }

  /// `Safe update`
  String get upgrade_notification_title {
    return Intl.message(
      'Safe update',
      name: 'upgrade_notification_title',
      desc: '',
      args: [],
    );
  }

  /// `The app now supports tablet layout.`
  String get upgrade_notification_subtitle {
    return Intl.message(
      'The app now supports tablet layout.',
      name: 'upgrade_notification_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Use Material You design`
  String get useMaterial3Title {
    return Intl.message(
      'Use Material You design',
      name: 'useMaterial3Title',
      desc: '',
      args: [],
    );
  }

  /// `Components that have been migrated to Material 3 will use new colors, typography and other features of Material 3.`
  String get useMaterial3YesSubtitle {
    return Intl.message(
      'Components that have been migrated to Material 3 will use new colors, typography and other features of Material 3.',
      name: 'useMaterial3YesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `App will use the Material 2 look and feel.`
  String get useMaterial3NoSubtitle {
    return Intl.message(
      'App will use the Material 2 look and feel.',
      name: 'useMaterial3NoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get post {
    return Intl.message(
      'Post',
      name: 'post',
      desc: '',
      args: [],
    );
  }

  /// `Signature style`
  String get signatureStyle {
    return Intl.message(
      'Signature style',
      name: 'signatureStyle',
      desc: '',
      args: [],
    );
  }

  /// `Enable signature`
  String get insertSignatureAtTheEndTitle {
    return Intl.message(
      'Enable signature',
      name: 'insertSignatureAtTheEndTitle',
      desc: '',
      args: [],
    );
  }

  /// `No signature`
  String get noSignature {
    return Intl.message(
      'No signature',
      name: 'noSignature',
      desc: '',
      args: [],
    );
  }

  /// `Use device name`
  String get deviceNameSignature {
    return Intl.message(
      'Use device name',
      name: 'deviceNameSignature',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get customSignature {
    return Intl.message(
      'Custom',
      name: 'customSignature',
      desc: '',
      args: [],
    );
  }

  /// `{name}'s Windows device`
  String windowsDeviceName(Object name) {
    return Intl.message(
      '$name\'s Windows device',
      name: 'windowsDeviceName',
      desc: '',
      args: [name],
    );
  }

  /// `{name}'s Linux device`
  String linuxDeviceName(Object name) {
    return Intl.message(
      '$name\'s Linux device',
      name: 'linuxDeviceName',
      desc: '',
      args: [name],
    );
  }

  /// `{name}'s MacOS device`
  String macOSDeviceName(Object name) {
    return Intl.message(
      '$name\'s MacOS device',
      name: 'macOSDeviceName',
      desc: '',
      args: [name],
    );
  }

  /// `Input signature for every post`
  String get signatureHint {
    return Intl.message(
      'Input signature for every post',
      name: 'signatureHint',
      desc: '',
      args: [],
    );
  }

  /// `Sent by {device}.`
  String fromDeviceSignature(Object device) {
    return Intl.message(
      'Sent by $device.',
      name: 'fromDeviceSignature',
      desc: '',
      args: [device],
    );
  }

  /// `Popular`
  String get hotThread {
    return Intl.message(
      'Popular',
      name: 'hotThread',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newThread {
    return Intl.message(
      'New',
      name: 'newThread',
      desc: '',
      args: [],
    );
  }

  /// `Edited`
  String get editedPost {
    return Intl.message(
      'Edited',
      name: 'editedPost',
      desc: '',
      args: [],
    );
  }

  /// `Push notification service`
  String get pushNotification {
    return Intl.message(
      'Push notification service',
      name: 'pushNotification',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get pushNotificationOn {
    return Intl.message(
      'On',
      name: 'pushNotificationOn',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get pushNotificationOff {
    return Intl.message(
      'Off',
      name: 'pushNotificationOff',
      desc: '',
      args: [],
    );
  }

  /// `Enable Push notification service`
  String get pushNotificationEnable {
    return Intl.message(
      'Enable Push notification service',
      name: 'pushNotificationEnable',
      desc: '',
      args: [],
    );
  }

  /// `Push notification is only enabled when dhpush is enabled in the Discuz site.`
  String get pushNotificationDescription {
    return Intl.message(
      'Push notification is only enabled when dhpush is enabled in the Discuz site.',
      name: 'pushNotificationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Law information`
  String get lawInformation {
    return Intl.message(
      'Law information',
      name: 'lawInformation',
      desc: '',
      args: [],
    );
  }

  /// `Push service relies on Firebase and APNs, which needs token, device information. You should agree with terms of service and privacy policy of push service to use it.`
  String get pushNotificationSubmittedContent {
    return Intl.message(
      'Push service relies on Firebase and APNs, which needs token, device information. You should agree with terms of service and privacy policy of push service to use it.',
      name: 'pushNotificationSubmittedContent',
      desc: '',
      args: [],
    );
  }

  /// `Pushed information`
  String get pushInformation {
    return Intl.message(
      'Pushed information',
      name: 'pushInformation',
      desc: '',
      args: [],
    );
  }

  /// `Device type`
  String get pushDevice {
    return Intl.message(
      'Device type',
      name: 'pushDevice',
      desc: '',
      args: [],
    );
  }

  /// `Channel`
  String get pushChannel {
    return Intl.message(
      'Channel',
      name: 'pushChannel',
      desc: '',
      args: [],
    );
  }

  /// `Firebase token`
  String get pushToken {
    return Intl.message(
      'Firebase token',
      name: 'pushToken',
      desc: '',
      args: [],
    );
  }

  /// `Firebase`
  String get pushChannelFirebase {
    return Intl.message(
      'Firebase',
      name: 'pushChannelFirebase',
      desc: '',
      args: [],
    );
  }

  /// `Push permission not authorized.`
  String get pushNotificationPermissionNotAuthorized {
    return Intl.message(
      'Push permission not authorized.',
      name: 'pushNotificationPermissionNotAuthorized',
      desc: '',
      args: [],
    );
  }

  /// `Package ID`
  String get pushPackageId {
    return Intl.message(
      'Package ID',
      name: 'pushPackageId',
      desc: '',
      args: [],
    );
  }

  /// `Authorized site`
  String get authorizedSite {
    return Intl.message(
      'Authorized site',
      name: 'authorizedSite',
      desc: '',
      args: [],
    );
  }

  /// `Device not supported or network failed to connect with Google.`
  String get pushDeviceNotSupported {
    return Intl.message(
      'Device not supported or network failed to connect with Google.',
      name: 'pushDeviceNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Cannot find GMS or APNs service in your device.`
  String get pushDeviceNotSupportedDescription {
    return Intl.message(
      'Cannot find GMS or APNs service in your device.',
      name: 'pushDeviceNotSupportedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Other service functions normally`
  String get pushDeviceNotInterfaceWithService {
    return Intl.message(
      'Other service functions normally',
      name: 'pushDeviceNotInterfaceWithService',
      desc: '',
      args: [],
    );
  }

  /// `Other functions not relied on push service still works.`
  String get pushDeviceNotInterfaceWithServiceDescription {
    return Intl.message(
      'Other functions not relied on push service still works.',
      name: 'pushDeviceNotInterfaceWithServiceDescription',
      desc: '',
      args: [],
    );
  }

  /// `How does push service work?`
  String get workProcedure {
    return Intl.message(
      'How does push service work?',
      name: 'workProcedure',
      desc: '',
      args: [],
    );
  }

  /// `Helps`
  String get pushHelpPages {
    return Intl.message(
      'Helps',
      name: 'pushHelpPages',
      desc: '',
      args: [],
    );
  }

  /// `Upload your token to discuz successfully.`
  String get uploadTokenSuccessful {
    return Intl.message(
      'Upload your token to discuz successfully.',
      name: 'uploadTokenSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Unable to upload your token.`
  String get uploadTokenUnsuccessful {
    return Intl.message(
      'Unable to upload your token.',
      name: 'uploadTokenUnsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `The site may not install DHP Service.`
  String get siteDoesNotSupportPushService {
    return Intl.message(
      'The site may not install DHP Service.',
      name: 'siteDoesNotSupportPushService',
      desc: '',
      args: [],
    );
  }

  /// `Apple Push Notification service`
  String get pushChannelAPNs {
    return Intl.message(
      'Apple Push Notification service',
      name: 'pushChannelAPNs',
      desc: '',
      args: [],
    );
  }

  /// `Shortcut`
  String get shortcut {
    return Intl.message(
      'Shortcut',
      name: 'shortcut',
      desc: '',
      args: [],
    );
  }

  /// `Go`
  String get shortcutGo {
    return Intl.message(
      'Go',
      name: 'shortcutGo',
      desc: '',
      args: [],
    );
  }

  /// `Input forum id (fid)`
  String get shortcutFidHint {
    return Intl.message(
      'Input forum id (fid)',
      name: 'shortcutFidHint',
      desc: '',
      args: [],
    );
  }

  /// `Input thread id (tid)`
  String get shortcutTidHint {
    return Intl.message(
      'Input thread id (tid)',
      name: 'shortcutTidHint',
      desc: '',
      args: [],
    );
  }

  /// `Input user id (uid)`
  String get shortcutUidHint {
    return Intl.message(
      'Input user id (uid)',
      name: 'shortcutUidHint',
      desc: '',
      args: [],
    );
  }

  /// `Build ver. {version}, num {number}`
  String buildVersionDescription(Object version, Object number) {
    return Intl.message(
      'Build ver. $version, num $number',
      name: 'buildVersionDescription',
      desc: '',
      args: [version, number],
    );
  }

  /// `Can't parse URL in the iframe.`
  String get iframeUrlNull {
    return Intl.message(
      'Can\'t parse URL in the iframe.',
      name: 'iframeUrlNull',
      desc: '',
      args: [],
    );
  }

  /// `Pull to refresh`
  String get easyRefreshClassicHeaderDragText {
    return Intl.message(
      'Pull to refresh',
      name: 'easyRefreshClassicHeaderDragText',
      desc: '',
      args: [],
    );
  }

  /// `Release ready`
  String get easyRefreshClassicHeaderArmedText {
    return Intl.message(
      'Release ready',
      name: 'easyRefreshClassicHeaderArmedText',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing...`
  String get easyRefreshClassicHeaderReadyText {
    return Intl.message(
      'Refreshing...',
      name: 'easyRefreshClassicHeaderReadyText',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing...`
  String get easyRefreshClassicHeaderProcessingText {
    return Intl.message(
      'Refreshing...',
      name: 'easyRefreshClassicHeaderProcessingText',
      desc: '',
      args: [],
    );
  }

  /// `Succeeded`
  String get easyRefreshClassicHeaderProcessedText {
    return Intl.message(
      'Succeeded',
      name: 'easyRefreshClassicHeaderProcessedText',
      desc: '',
      args: [],
    );
  }

  /// `No more`
  String get easyRefreshClassicHeaderNoMoreText {
    return Intl.message(
      'No more',
      name: 'easyRefreshClassicHeaderNoMoreText',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get easyRefreshClassicHeaderFailedText {
    return Intl.message(
      'Failed',
      name: 'easyRefreshClassicHeaderFailedText',
      desc: '',
      args: [],
    );
  }

  /// `Last updated at %T`
  String get easyRefreshClassicHeaderMessageText {
    return Intl.message(
      'Last updated at %T',
      name: 'easyRefreshClassicHeaderMessageText',
      desc: '',
      args: [],
    );
  }

  /// `Pull to load`
  String get easyRefreshClassicFooterDragText {
    return Intl.message(
      'Pull to load',
      name: 'easyRefreshClassicFooterDragText',
      desc: '',
      args: [],
    );
  }

  /// `Release ready`
  String get easyRefreshClassicFooterArmedText {
    return Intl.message(
      'Release ready',
      name: 'easyRefreshClassicFooterArmedText',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get easyRefreshClassicFooterReadyText {
    return Intl.message(
      'Loading...',
      name: 'easyRefreshClassicFooterReadyText',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get easyRefreshClassicFooterProcessingText {
    return Intl.message(
      'Loading...',
      name: 'easyRefreshClassicFooterProcessingText',
      desc: '',
      args: [],
    );
  }

  /// `Succeeded`
  String get easyRefreshClassicFooterProcessedText {
    return Intl.message(
      'Succeeded',
      name: 'easyRefreshClassicFooterProcessedText',
      desc: '',
      args: [],
    );
  }

  /// `No more`
  String get easyRefreshClassicFooterNoMoreText {
    return Intl.message(
      'No more',
      name: 'easyRefreshClassicFooterNoMoreText',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get easyRefreshClassicFooterFailedText {
    return Intl.message(
      'Failed',
      name: 'easyRefreshClassicFooterFailedText',
      desc: '',
      args: [],
    );
  }

  /// `Last updated at %T`
  String get easyRefreshClassicFooterMessageText {
    return Intl.message(
      'Last updated at %T',
      name: 'easyRefreshClassicFooterMessageText',
      desc: '',
      args: [],
    );
  }

  /// `Forum info.`
  String get forumInformation {
    return Intl.message(
      'Forum info.',
      name: 'forumInformation',
      desc: '',
      args: [],
    );
  }

  /// `Filter and sort`
  String get forumSortPosts {
    return Intl.message(
      'Filter and sort',
      name: 'forumSortPosts',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get pushThreadTitle {
    return Intl.message(
      'Publish',
      name: 'pushThreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bold`
  String get insertBoldText {
    return Intl.message(
      'Bold',
      name: 'insertBoldText',
      desc: '',
      args: [],
    );
  }

  /// `Italic`
  String get insertItalicText {
    return Intl.message(
      'Italic',
      name: 'insertItalicText',
      desc: '',
      args: [],
    );
  }

  /// `Quote`
  String get insertQuoteText {
    return Intl.message(
      'Quote',
      name: 'insertQuoteText',
      desc: '',
      args: [],
    );
  }

  /// `Loading configuration for publish a thread in the forum.`
  String get loadingForumInformation {
    return Intl.message(
      'Loading configuration for publish a thread in the forum.',
      name: 'loadingForumInformation',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get pushThreadTitleHint {
    return Intl.message(
      'Title',
      name: 'pushThreadTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Loading captcha information.`
  String get loadingCaptchaInformation {
    return Intl.message(
      'Loading captcha information.',
      name: 'loadingCaptchaInformation',
      desc: '',
      args: [],
    );
  }

  /// `No captcha needed.`
  String get noCaptachaRequired {
    return Intl.message(
      'No captcha needed.',
      name: 'noCaptachaRequired',
      desc: '',
      args: [],
    );
  }

  /// `You haven't trusted any hosts.`
  String get emptyTrustHost {
    return Intl.message(
      'You haven\'t trusted any hosts.',
      name: 'emptyTrustHost',
      desc: '',
      args: [],
    );
  }

  /// `No post is currently listed.`
  String get emptyPosts {
    return Intl.message(
      'No post is currently listed.',
      name: 'emptyPosts',
      desc: '',
      args: [],
    );
  }

  /// `No thread is currently fetched.`
  String get emptyThreads {
    return Intl.message(
      'No thread is currently fetched.',
      name: 'emptyThreads',
      desc: '',
      args: [],
    );
  }

  /// `No user here.`
  String get emptyUser {
    return Intl.message(
      'No user here.',
      name: 'emptyUser',
      desc: '',
      args: [],
    );
  }

  /// `No history is found in your device. Have you ever browse anything or never open the history recording in the setting?`
  String get emptyHistory {
    return Intl.message(
      'No history is found in your device. Have you ever browse anything or never open the history recording in the setting?',
      name: 'emptyHistory',
      desc: '',
      args: [],
    );
  }

  /// `No fourm here`
  String get emptyForum {
    return Intl.message(
      'No fourm here',
      name: 'emptyForum',
      desc: '',
      args: [],
    );
  }

  /// `No notification here.`
  String get emptyNotification {
    return Intl.message(
      'No notification here.',
      name: 'emptyNotification',
      desc: '',
      args: [],
    );
  }

  /// `Poll (single selection)`
  String get pollTitle {
    return Intl.message(
      'Poll (single selection)',
      name: 'pollTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can't join in the polls.`
  String get pollNotAllowed {
    return Intl.message(
      'You can\'t join in the polls.',
      name: 'pollNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Contact us (Email)`
  String get contactUsViaEmail {
    return Intl.message(
      'Contact us (Email)',
      name: 'contactUsViaEmail',
      desc: '',
      args: [],
    );
  }

  /// `Contact us (Weibo)`
  String get contactUsViaWeibo {
    return Intl.message(
      'Contact us (Weibo)',
      name: 'contactUsViaWeibo',
      desc: '',
      args: [],
    );
  }

  /// `AD provided by Google`
  String get adLoadingText {
    return Intl.message(
      'AD provided by Google',
      name: 'adLoadingText',
      desc: '',
      args: [],
    );
  }

  /// `User authentication expired.`
  String get errorUserExpired {
    return Intl.message(
      'User authentication expired.',
      name: 'errorUserExpired',
      desc: '',
      args: [],
    );
  }

  /// `Connection timeout.`
  String get dioErrorConnectionTimeout {
    return Intl.message(
      'Connection timeout.',
      name: 'dioErrorConnectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Send timeout.`
  String get dioErrorSendTimeout {
    return Intl.message(
      'Send timeout.',
      name: 'dioErrorSendTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Receive timeout.`
  String get dioErrorReceiveTimeout {
    return Intl.message(
      'Receive timeout.',
      name: 'dioErrorReceiveTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Response error.`
  String get dioErrorResponse {
    return Intl.message(
      'Response error.',
      name: 'dioErrorResponse',
      desc: '',
      args: [],
    );
  }

  /// `Response cancelled.`
  String get dioErrorCancel {
    return Intl.message(
      'Response cancelled.',
      name: 'dioErrorCancel',
      desc: '',
      args: [],
    );
  }

  /// `Error.`
  String get dioErrorOther {
    return Intl.message(
      'Error.',
      name: 'dioErrorOther',
      desc: '',
      args: [],
    );
  }

  /// `This page is optimized for web view.`
  String get mobileTemplateNotFound {
    return Intl.message(
      'This page is optimized for web view.',
      name: 'mobileTemplateNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Go to web.`
  String get navigateToWebPage {
    return Intl.message(
      'Go to web.',
      name: 'navigateToWebPage',
      desc: '',
      args: [],
    );
  }

  /// `Google analytics used`
  String get useGoogleAnalyticsTitle {
    return Intl.message(
      'Google analytics used',
      name: 'useGoogleAnalyticsTitle',
      desc: '',
      args: [],
    );
  }

  /// `The app use Google analytics to collect only basic information and we will not track your account according to our privacy policy.`
  String get useGoogleAnalyticsContent {
    return Intl.message(
      'The app use Google analytics to collect only basic information and we will not track your account according to our privacy policy.',
      name: 'useGoogleAnalyticsContent',
      desc: '',
      args: [],
    );
  }

  /// `Firebase cloud messaging`
  String get pushChannelFCM {
    return Intl.message(
      'Firebase cloud messaging',
      name: 'pushChannelFCM',
      desc: '',
      args: [],
    );
  }

  /// `Apple push notification service`
  String get pushChannelAPN {
    return Intl.message(
      'Apple push notification service',
      name: 'pushChannelAPN',
      desc: '',
      args: [],
    );
  }

  /// `Xiaomi push`
  String get pushChannelXMI {
    return Intl.message(
      'Xiaomi push',
      name: 'pushChannelXMI',
      desc: '',
      args: [],
    );
  }

  /// `HMS Push`
  String get pushChannelHMS {
    return Intl.message(
      'HMS Push',
      name: 'pushChannelHMS',
      desc: '',
      args: [],
    );
  }

  /// `Terms of push services`
  String get pushTermsOfService {
    return Intl.message(
      'Terms of push services',
      name: 'pushTermsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy of push services`
  String get pushPrivacyPolicy {
    return Intl.message(
      'Privacy policy of push services',
      name: 'pushPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Register your device to the forum`
  String get registerPushTokenTitle {
    return Intl.message(
      'Register your device to the forum',
      name: 'registerPushTokenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to register your device to the forum so that you can receive a updated push.`
  String get registerPushTokenMessage {
    return Intl.message(
      'Do you wish to register your device to the forum so that you can receive a updated push.',
      name: 'registerPushTokenMessage',
      desc: '',
      args: [],
    );
  }

  /// `In the material setting, App's brightness will follow the system without any options to offer.`
  String get materialBrightnessSwitchDisabledText {
    return Intl.message(
      'In the material setting, App\'s brightness will follow the system without any options to offer.',
      name: 'materialBrightnessSwitchDisabledText',
      desc: '',
      args: [],
    );
  }

  /// `Due to the incompatibility brought by the upgrade of Material Design, the default color scheme app adopt is purple now but you can still customize some of them.`
  String get iosColorSchemeSuggestions {
    return Intl.message(
      'Due to the incompatibility brought by the upgrade of Material Design, the default color scheme app adopt is purple now but you can still customize some of them.',
      name: 'iosColorSchemeSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `App now will follow the system appearance according to design discipline.`
  String get brightnessManualChangeDisabled {
    return Intl.message(
      'App now will follow the system appearance according to design discipline.',
      name: 'brightnessManualChangeDisabled',
      desc: '',
      args: [],
    );
  }

  /// `DH Push service`
  String get dhPushServiceTitle {
    return Intl.message(
      'DH Push service',
      name: 'dhPushServiceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Click thread to view posts inside.`
  String get viewThreadTwoPaneText {
    return Intl.message(
      'Click thread to view posts inside.',
      name: 'viewThreadTwoPaneText',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to enable push service to receive the updated information?`
  String get pushServiceEnableDescription {
    return Intl.message(
      'Do you wish to enable push service to receive the updated information?',
      name: 'pushServiceEnableDescription',
      desc: '',
      args: [],
    );
  }

  /// `You are now able to get the updated information from supported Discuz.`
  String get pushServiceOnDescription {
    return Intl.message(
      'You are now able to get the updated information from supported Discuz.',
      name: 'pushServiceOnDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
