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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Replies`
  String get noticeReplies {
    return Intl.message('Replies', name: 'noticeReplies', desc: '', args: []);
  }

  /// `Mentions`
  String get noticeMentions {
    return Intl.message('Mentions', name: 'noticeMentions', desc: '', args: []);
  }

  /// `Comments`
  String get noticeReviews {
    return Intl.message('Comments', name: 'noticeReviews', desc: '', args: []);
  }

  /// `Ratings`
  String get noticeRatings {
    return Intl.message('Ratings', name: 'noticeRatings', desc: '', args: []);
  }

  /// `Activities`
  String get noticeActivities {
    return Intl.message(
      'Activities',
      name: 'noticeActivities',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get noticeSystem {
    return Intl.message('System', name: 'noticeSystem', desc: '', args: []);
  }

  /// `Unread`
  String get onlyUnreadMessages {
    return Intl.message(
      'Unread',
      name: 'onlyUnreadMessages',
      desc: '',
      args: [],
    );
  }

  /// `Message settings`
  String get managePrivateMessages {
    return Intl.message(
      'Message settings',
      name: 'managePrivateMessages',
      desc: '',
      args: [],
    );
  }

  /// `Manage conversation on forum`
  String get manageConversation {
    return Intl.message(
      'Manage conversation on forum',
      name: 'manageConversation',
      desc: '',
      args: [],
    );
  }

  /// `Report message`
  String get reportPrivateMessage {
    return Intl.message(
      'Report message',
      name: 'reportPrivateMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add friend`
  String get friendRequest {
    return Intl.message(
      'Add friend',
      name: 'friendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Friend requests`
  String get friendRequests {
    return Intl.message(
      'Friend requests',
      name: 'friendRequests',
      desc: '',
      args: [],
    );
  }

  /// `Manage friends`
  String get friendManage {
    return Intl.message(
      'Manage friends',
      name: 'friendManage',
      desc: '',
      args: [],
    );
  }

  /// `Change group`
  String get friendChangeGroup {
    return Intl.message(
      'Change group',
      name: 'friendChangeGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit note`
  String get friendEditNote {
    return Intl.message(
      'Edit note',
      name: 'friendEditNote',
      desc: '',
      args: [],
    );
  }

  /// `Unlock board`
  String get boardUnlock {
    return Intl.message(
      'Unlock board',
      name: 'boardUnlock',
      desc: '',
      args: [],
    );
  }

  /// `Board password`
  String get boardPasswordInput {
    return Intl.message(
      'Board password',
      name: 'boardPasswordInput',
      desc: '',
      args: [],
    );
  }

  /// `Enter the password set by the forum.`
  String get boardPasswordPrompt {
    return Intl.message(
      'Enter the password set by the forum.',
      name: 'boardPasswordPrompt',
      desc: '',
      args: [],
    );
  }

  /// `The board password is incorrect.`
  String get boardPasswordWrong {
    return Intl.message(
      'The board password is incorrect.',
      name: 'boardPasswordWrong',
      desc: '',
      args: [],
    );
  }

  /// `Winning replies`
  String get rushWinnerList {
    return Intl.message(
      'Winning replies',
      name: 'rushWinnerList',
      desc: '',
      args: [],
    );
  }

  /// `No winning replies yet`
  String get rushNoWinners {
    return Intl.message(
      'No winning replies yet',
      name: 'rushNoWinners',
      desc: '',
      args: [],
    );
  }

  /// `Create debate`
  String get debateCreate {
    return Intl.message(
      'Create debate',
      name: 'debateCreate',
      desc: '',
      args: [],
    );
  }

  /// `Judge`
  String get debateJudge {
    return Intl.message('Judge', name: 'debateJudge', desc: '', args: []);
  }

  /// `Neutral`
  String get debateNeutral {
    return Intl.message('Neutral', name: 'debateNeutral', desc: '', args: []);
  }

  /// `Support`
  String get debateSupport {
    return Intl.message('Support', name: 'debateSupport', desc: '', args: []);
  }

  /// `Reply as`
  String get debateReplySide {
    return Intl.message(
      'Reply as',
      name: 'debateReplySide',
      desc: '',
      args: [],
    );
  }

  /// `Replies by side`
  String get debateFilterReplies {
    return Intl.message(
      'Replies by side',
      name: 'debateFilterReplies',
      desc: '',
      args: [],
    );
  }

  /// `Submit your vote for this side?`
  String get debateSupportConfirm {
    return Intl.message(
      'Submit your vote for this side?',
      name: 'debateSupportConfirm',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get forumAll {
    return Intl.message('All', name: 'forumAll', desc: '', args: []);
  }

  /// `More posting options`
  String get morePostSettings {
    return Intl.message(
      'More posting options',
      name: 'morePostSettings',
      desc: '',
      args: [],
    );
  }

  /// `Notify me of replies`
  String get postNotifyReplies {
    return Intl.message(
      'Notify me of replies',
      name: 'postNotifyReplies',
      desc: '',
      args: [],
    );
  }

  /// `Post anonymously`
  String get postAnonymous {
    return Intl.message(
      'Post anonymously',
      name: 'postAnonymous',
      desc: '',
      args: [],
    );
  }

  /// `Minimum reading access`
  String get postReadPermission {
    return Intl.message(
      'Minimum reading access',
      name: 'postReadPermission',
      desc: '',
      args: [],
    );
  }

  /// `Schedule publication`
  String get postSchedule {
    return Intl.message(
      'Schedule publication',
      name: 'postSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Publication time (YYYY-MM-DD HH:mm)`
  String get postScheduleTime {
    return Intl.message(
      'Publication time (YYYY-MM-DD HH:mm)',
      name: 'postScheduleTime',
      desc: '',
      args: [],
    );
  }

  /// `These posting options are no longer available or the values are invalid. Review the forum settings.`
  String get postSettingsChanged {
    return Intl.message(
      'These posting options are no longer available or the values are invalid. Review the forum settings.',
      name: 'postSettingsChanged',
      desc: '',
      args: [],
    );
  }

  /// `Items for sale`
  String get tradeItems {
    return Intl.message(
      'Items for sale',
      name: 'tradeItems',
      desc: '',
      args: [],
    );
  }

  /// `Stock`
  String get tradeStock {
    return Intl.message('Stock', name: 'tradeStock', desc: '', args: []);
  }

  /// `Availability`
  String get tradeExpires {
    return Intl.message(
      'Availability',
      name: 'tradeExpires',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get tradeExpired {
    return Intl.message('Expired', name: 'tradeExpired', desc: '', args: []);
  }

  /// `View item on the forum`
  String get tradeOpenItem {
    return Intl.message(
      'View item on the forum',
      name: 'tradeOpenItem',
      desc: '',
      args: [],
    );
  }

  /// `DisFly`
  String get appName {
    return Intl.message('DisFly', name: 'appName', desc: '', args: []);
  }

  /// `Sample`
  String get sample {
    return Intl.message('Sample', name: 'sample', desc: '', args: []);
  }

  /// `Style`
  String get style {
    return Intl.message('Style', name: 'style', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Basic`
  String get basicUse {
    return Intl.message('Basic', name: 'basicUse', desc: '', args: []);
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
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `LoadMore`
  String get loadMore {
    return Intl.message('LoadMore', name: 'loadMore', desc: '', args: []);
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
    return Intl.message('Push to load', name: 'pushToLoad', desc: '', args: []);
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
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
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
    return Intl.message('Load completed', name: 'loaded', desc: '', args: []);
  }

  /// `Load failed`
  String get loadFailed {
    return Intl.message('Load failed', name: 'loadFailed', desc: '', args: []);
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
    return Intl.message('Load done', name: 'completeLoad', desc: '', args: []);
  }

  /// `No more`
  String get noMore {
    return Intl.message('No more', name: 'noMore', desc: '', args: []);
  }

  /// `Update at %T`
  String get updateAt {
    return Intl.message('Update at %T', name: 'updateAt', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Me`
  String get me {
    return Intl.message('Me', name: 'me', desc: '', args: []);
  }

  /// `Bob minion`
  String get bobMinion {
    return Intl.message('Bob minion', name: 'bobMinion', desc: '', args: []);
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
    return Intl.message('A', name: 'anonymous', desc: '', args: []);
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

  /// `View thread`
  String get viewThreadTitle {
    return Intl.message(
      'View thread',
      name: 'viewThreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `# {pos}`
  String postPosition(Object pos) {
    return Intl.message('# $pos', name: 'postPosition', desc: '', args: [pos]);
  }

  /// `Index`
  String get index {
    return Intl.message('Index', name: 'index', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
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

  /// `Add a Discuz`
  String get addNewDiscuz {
    return Intl.message(
      'Add a Discuz',
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
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
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
    return Intl.message('AD', name: 'googleAdTitle', desc: '', args: []);
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
    return Intl.message('Settings', name: 'settingTitle', desc: '', args: []);
  }

  /// `Login`
  String get loginTitle {
    return Intl.message('Login', name: 'loginTitle', desc: '', args: []);
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
    return Intl.message('Send', name: 'sendReply', desc: '', args: []);
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

  /// `Username`
  String get account {
    return Intl.message('Username', name: 'account', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
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
    return Intl.message('or', name: 'or', desc: '', args: []);
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
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
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
    return Intl.message('OK', name: 'ok', desc: '', args: []);
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

  /// `Hold to talk`
  String get voiceHoldToTalk {
    return Intl.message(
      'Hold to talk',
      name: 'voiceHoldToTalk',
      desc: '',
      args: [],
    );
  }

  /// `Release to send`
  String get voiceReleaseSend {
    return Intl.message(
      'Release to send',
      name: 'voiceReleaseSend',
      desc: '',
      args: [],
    );
  }

  /// `Release to finish`
  String get voiceReleaseFinish {
    return Intl.message(
      'Release to finish',
      name: 'voiceReleaseFinish',
      desc: '',
      args: [],
    );
  }

  /// `Slide up to cancel`
  String get voiceSlideCancel {
    return Intl.message(
      'Slide up to cancel',
      name: 'voiceSlideCancel',
      desc: '',
      args: [],
    );
  }

  /// `Release to cancel`
  String get voiceReleaseCancel {
    return Intl.message(
      'Release to cancel',
      name: 'voiceReleaseCancel',
      desc: '',
      args: [],
    );
  }

  /// `Use keyboard`
  String get voiceUseKeyboard {
    return Intl.message(
      'Use keyboard',
      name: 'voiceUseKeyboard',
      desc: '',
      args: [],
    );
  }

  /// `Record voice`
  String get voiceRecord {
    return Intl.message(
      'Record voice',
      name: 'voiceRecord',
      desc: '',
      args: [],
    );
  }

  /// `Start recording`
  String get voiceStart {
    return Intl.message(
      'Start recording',
      name: 'voiceStart',
      desc: '',
      args: [],
    );
  }

  /// `Stop recording`
  String get voiceStop {
    return Intl.message(
      'Stop recording',
      name: 'voiceStop',
      desc: '',
      args: [],
    );
  }

  /// `Record again`
  String get voiceRecordAgain {
    return Intl.message(
      'Record again',
      name: 'voiceRecordAgain',
      desc: '',
      args: [],
    );
  }

  /// `Attach voice`
  String get voiceAttach {
    return Intl.message(
      'Attach voice',
      name: 'voiceAttach',
      desc: '',
      args: [],
    );
  }

  /// `Voice message`
  String get voiceMessage {
    return Intl.message(
      'Voice message',
      name: 'voiceMessage',
      desc: '',
      args: [],
    );
  }

  /// `Play voice`
  String get voicePlay {
    return Intl.message('Play voice', name: 'voicePlay', desc: '', args: []);
  }

  /// `Pause voice`
  String get voicePause {
    return Intl.message('Pause voice', name: 'voicePause', desc: '', args: []);
  }

  /// `Tap to retry`
  String get voicePlaybackFailed {
    return Intl.message(
      'Tap to retry',
      name: 'voicePlaybackFailed',
      desc: '',
      args: [],
    );
  }

  /// `Allow microphone access to record voice.`
  String get voiceMicrophonePermission {
    return Intl.message(
      'Allow microphone access to record voice.',
      name: 'voiceMicrophonePermission',
      desc: '',
      args: [],
    );
  }

  /// `Couldn’t record voice. Try again.`
  String get voiceRecordingFailed {
    return Intl.message(
      'Couldn’t record voice. Try again.',
      name: 'voiceRecordingFailed',
      desc: '',
      args: [],
    );
  }

  /// `Record at least 1 second.`
  String get voiceTooShort {
    return Intl.message(
      'Record at least 1 second.',
      name: 'voiceTooShort',
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

  /// `Downloading attachment…`
  String get downloadingAttachment {
    return Intl.message(
      'Downloading attachment…',
      name: 'downloadingAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Unable to download the attachment.`
  String get attachmentDownloadFailed {
    return Intl.message(
      'Unable to download the attachment.',
      name: 'attachmentDownloadFailed',
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
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
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
    return Intl.message('Delete', name: 'deleteAccount', desc: '', args: []);
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
    return Intl.message('Manage BBS', name: 'manageDiscuz', desc: '', args: []);
  }

  /// `relogin`
  String get relogin {
    return Intl.message('relogin', name: 'relogin', desc: '', args: []);
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
    return Intl.message('Common', name: 'common', desc: '', args: []);
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
    return Intl.message('Our policy', name: 'policy', desc: '', args: []);
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
    return Intl.message('Undo', name: 'undo', desc: '', args: []);
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

  /// `The forum requires extra verification. Continue in the browser to sign in.`
  String get loginBrowserVerificationRequired {
    return Intl.message(
      'The forum requires extra verification. Continue in the browser to sign in.',
      name: 'loginBrowserVerificationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Reload captcha`
  String get reloadCaptcha {
    return Intl.message(
      'Reload captcha',
      name: 'reloadCaptcha',
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

  /// `Recent activity`
  String get forumFilterTimeTitle {
    return Intl.message(
      'Recent activity',
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
    return Intl.message('Recent note', name: 'recentNote', desc: '', args: []);
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
    return Intl.message('Birth place', name: 'birthPlace', desc: '', args: []);
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
    return Intl.message('Credit', name: 'credit', desc: '', args: []);
  }

  /// `Homepage`
  String get homepage {
    return Intl.message('Homepage', name: 'homepage', desc: '', args: []);
  }

  /// `Habits`
  String get habit {
    return Intl.message('Habits', name: 'habit', desc: '', args: []);
  }

  /// `Friends`
  String get friendNumber {
    return Intl.message('Friends', name: 'friendNumber', desc: '', args: []);
  }

  /// `Post number`
  String get postNumber {
    return Intl.message('Post number', name: 'postNumber', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Favorites`
  String get favorites {
    return Intl.message('Favorites', name: 'favorites', desc: '', args: []);
  }

  /// `Chat`
  String get chatMessage {
    return Intl.message('Chat', name: 'chatMessage', desc: '', args: []);
  }

  /// `Private`
  String get privateMessage {
    return Intl.message('Private', name: 'privateMessage', desc: '', args: []);
  }

  /// `Public`
  String get publicMessage {
    return Intl.message('Public', name: 'publicMessage', desc: '', args: []);
  }

  /// `Published {date}`
  String bilibiliPublishedAt(String date) {
    return Intl.message(
      'Published $date',
      name: 'bilibiliPublishedAt',
      desc: '',
      args: [date],
    );
  }

  /// `Duration {duration}`
  String bilibiliDuration(String duration) {
    return Intl.message(
      'Duration $duration',
      name: 'bilibiliDuration',
      desc: '',
      args: [duration],
    );
  }

  /// `{count} parts`
  String bilibiliParts(int count) {
    return Intl.message(
      '$count parts',
      name: 'bilibiliParts',
      desc: '',
      args: [count],
    );
  }

  /// `Blocked`
  String get postBlockedLabel {
    return Intl.message(
      'Blocked',
      name: 'postBlockedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Warned`
  String get postWarnedLabel {
    return Intl.message('Warned', name: 'postWarnedLabel', desc: '', args: []);
  }

  /// `Edited after review`
  String get postRevisedLabel {
    return Intl.message(
      'Edited after review',
      name: 'postRevisedLabel',
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
    return Intl.message('Grey', name: 'colorGrey', desc: '', args: []);
  }

  /// `Blue`
  String get colorBlue {
    return Intl.message('Blue', name: 'colorBlue', desc: '', args: []);
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
    return Intl.message('Cyan', name: 'colorCyan', desc: '', args: []);
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
    return Intl.message('Green', name: 'colorGreen', desc: '', args: []);
  }

  /// `Indigo`
  String get colorIndigo {
    return Intl.message('Indigo', name: 'colorIndigo', desc: '', args: []);
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
    return Intl.message('Orange', name: 'colorOrange', desc: '', args: []);
  }

  /// `Purple`
  String get colorPurple {
    return Intl.message('Purple', name: 'colorPurple', desc: '', args: []);
  }

  /// `Pink`
  String get colorPink {
    return Intl.message('Pink', name: 'colorPink', desc: '', args: []);
  }

  /// `Red`
  String get colorRed {
    return Intl.message('Red', name: 'colorRed', desc: '', args: []);
  }

  /// `Teal`
  String get colorTeal {
    return Intl.message('Teal', name: 'colorTeal', desc: '', args: []);
  }

  /// `Black`
  String get colorBlack {
    return Intl.message('Black', name: 'colorBlack', desc: '', args: []);
  }

  /// `Brown`
  String get colorBrown {
    return Intl.message('Brown', name: 'colorBrown', desc: '', args: []);
  }

  /// `Amber`
  String get colorAmber {
    return Intl.message('Amber', name: 'colorAmber', desc: '', args: []);
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
    return Intl.message('Blue Grey', name: 'colorBlueGrey', desc: '', args: []);
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
    return Intl.message('Lime', name: 'colorLime', desc: '', args: []);
  }

  /// `Yellow`
  String get colorYellow {
    return Intl.message('Yellow', name: 'colorYellow', desc: '', args: []);
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
    return Intl.message('Cancel', name: 'cancelAdding', desc: '', args: []);
  }

  /// `Continue`
  String get continueAdding {
    return Intl.message('Continue', name: 'continueAdding', desc: '', args: []);
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
    return Intl.message('Reply', name: 'replyPost', desc: '', args: []);
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
  String replyPostTrimMessage(
    Object pid,
    Object ptid,
    Object author,
    Object fullTimeString,
    Object trimMessage,
  ) {
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

  /// `Display Style`
  String get appearanceOptimizedPlatform {
    return Intl.message(
      'Display Style',
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
    return Intl.message('iOS', name: 'ios', desc: '', args: []);
  }

  /// `Liquid Glass`
  String get liquidGlassStyle {
    return Intl.message(
      'Liquid Glass',
      name: 'liquidGlassStyle',
      desc: '',
      args: [],
    );
  }

  /// `Cupertino`
  String get cupertinoStyle {
    return Intl.message(
      'Cupertino',
      name: 'cupertinoStyle',
      desc: '',
      args: [],
    );
  }

  /// `Follow the system using Material Design.`
  String get systemStyleAndroidDescription {
    return Intl.message(
      'Follow the system using Material Design.',
      name: 'systemStyleAndroidDescription',
      desc: '',
      args: [],
    );
  }

  /// `Liquid Glass on iOS 26 or later, Cupertino on earlier iOS, and Material Design on other platforms.`
  String get systemStyleDescription {
    return Intl.message(
      'Liquid Glass on iOS 26 or later, Cupertino on earlier iOS, and Material Design on other platforms.',
      name: 'systemStyleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Native glass controls on iOS / iPadOS 26 or later.`
  String get liquidGlassStyleDescription {
    return Intl.message(
      'Native glass controls on iOS / iPadOS 26 or later.',
      name: 'liquidGlassStyleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Requires iOS / iPadOS 26 or later. Unavailable on this device; a saved selection falls back to Cupertino.`
  String get liquidGlassStyleUnavailable {
    return Intl.message(
      'Requires iOS / iPadOS 26 or later. Unavailable on this device; a saved selection falls back to Cupertino.',
      name: 'liquidGlassStyleUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Classic Apple-style controls without custom Liquid Glass effects.`
  String get cupertinoStyleDescription {
    return Intl.message(
      'Classic Apple-style controls without custom Liquid Glass effects.',
      name: 'cupertinoStyleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Material Design controls, available on all platforms.`
  String get materialStyleDescription {
    return Intl.message(
      'Material Design controls, available on all platforms.',
      name: 'materialStyleDescription',
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
    return Intl.message('Fuchsia', name: 'fuchsia', desc: '', args: []);
  }

  /// `System`
  String get followSystem {
    return Intl.message('System', name: 'followSystem', desc: '', args: []);
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
    return Intl.message('OP', name: 'postAuthorLabel', desc: '', args: []);
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
    return Intl.message('Just Now', name: 'justNow', desc: '', args: []);
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
    return Intl.message('$day days ago', name: 'dayAgo', desc: '', args: [day]);
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
    return Intl.message('Light', name: 'brightnessLight', desc: '', args: []);
  }

  /// `Dark`
  String get brightnessDark {
    return Intl.message('Dark', name: 'brightnessDark', desc: '', args: []);
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

  /// `You’ve left this forum`
  String get browserOutsideForum {
    return Intl.message(
      'You’ve left this forum',
      name: 'browserOutsideForum',
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

  /// `OP mode / View all`
  String get onlyViewAuthor {
    return Intl.message(
      'OP mode / View all',
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
    return Intl.message('Homepage', name: 'sitePage', desc: '', args: []);
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
    return Intl.message('Typesetting', name: 'typeSetting', desc: '', args: []);
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
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
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
    return Intl.message('Beta Test', name: 'testVersion', desc: '', args: []);
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
    return Intl.message('Welcome', name: 'welcomeTitle', desc: '', args: []);
  }

  /// `What’s new`
  String get welcomeWhatsNew {
    return Intl.message(
      'What’s new',
      name: 'welcomeWhatsNew',
      desc: '',
      args: [],
    );
  }

  /// `Search and post from the top of the menu. Sign in from the account card when browsing as a guest.`
  String get welcomeDrawerDetail {
    return Intl.message(
      'Search and post from the top of the menu. Sign in from the account card when browsing as a guest.',
      name: 'welcomeDrawerDetail',
      desc: '',
      args: [],
    );
  }

  /// `Find your polls, debates, rewards and trades in the menu.`
  String get welcomeParticipationDetail {
    return Intl.message(
      'Find your polls, debates, rewards and trades in the menu.',
      name: 'welcomeParticipationDetail',
      desc: '',
      args: [],
    );
  }

  /// `Edit, save or publish drafts you saved on the forum website.`
  String get welcomeForumDraftsDetail {
    return Intl.message(
      'Edit, save or publish drafts you saved on the forum website.',
      name: 'welcomeForumDraftsDetail',
      desc: '',
      args: [],
    );
  }

  /// `Read and post article comments, and open related articles or topic tags.`
  String get welcomePortalDetail {
    return Intl.message(
      'Read and post article comments, and open related articles or topic tags.',
      name: 'welcomePortalDetail',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to version {version}`
  String welcomeVersionTitle(Object version) {
    return Intl.message(
      'Welcome to version $version',
      name: 'welcomeVersionTitle',
      desc: '',
      args: [version],
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
    return Intl.message('Continue', name: 'continueToDo', desc: '', args: []);
  }

  /// `Finish`
  String get finishLoginInWeb {
    return Intl.message('Finish', name: 'finishLoginInWeb', desc: '', args: []);
  }

  /// `Unable to read the web sign-in status. Refresh the sign-in page and try again.`
  String get invalidCookie {
    return Intl.message(
      'Unable to read the web sign-in status. Refresh the sign-in page and try again.',
      name: 'invalidCookie',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get addAPhoto {
    return Intl.message('Photo', name: 'addAPhoto', desc: '', args: []);
  }

  /// `Shot`
  String get takeAPicture {
    return Intl.message('Shot', name: 'takeAPicture', desc: '', args: []);
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

  /// `The forum rejected the attachment filename.`
  String get uploadImageError12 {
    return Intl.message(
      'The forum rejected the attachment filename.',
      name: 'uploadImageError12',
      desc: '',
      args: [],
    );
  }

  /// `The image dimensions fall outside the forum limits.`
  String get uploadImageError13 {
    return Intl.message(
      'The image dimensions fall outside the forum limits.',
      name: 'uploadImageError13',
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

  /// `Send compressed image`
  String get uploadCompressedImageToServer {
    return Intl.message(
      'Send compressed image',
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
    return Intl.message('Block user', name: 'blockUser', desc: '', args: []);
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
    return Intl.message('Spam', name: 'spam', desc: '', args: []);
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
    return Intl.message('Other', name: 'other', desc: '', args: []);
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
    return Intl.message('Posts', name: 'userPost', desc: '', args: []);
  }

  /// `Threads`
  String get userThread {
    return Intl.message('Threads', name: 'userThread', desc: '', args: []);
  }

  /// `Credits`
  String get userCredit {
    return Intl.message('Credits', name: 'userCredit', desc: '', args: []);
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
    return Intl.message('D', name: 'day', desc: '', args: []);
  }

  /// `H`
  String get hour {
    return Intl.message('H', name: 'hour', desc: '', args: []);
  }

  /// `M`
  String get minute {
    return Intl.message('M', name: 'minute', desc: '', args: []);
  }

  /// `S`
  String get second {
    return Intl.message('S', name: 'second', desc: '', args: []);
  }

  /// `Service termination`
  String get upgrade_notification_title {
    return Intl.message(
      'Service termination',
      name: 'upgrade_notification_title',
      desc: '',
      args: [],
    );
  }

  /// `Due to ongoing incidences, push notification service has been terminated.`
  String get upgrade_notification_subtitle {
    return Intl.message(
      'Due to ongoing incidences, push notification service has been terminated.',
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
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Post`
  String get post {
    return Intl.message('Post', name: 'post', desc: '', args: []);
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
    return Intl.message('Custom', name: 'customSignature', desc: '', args: []);
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
    return Intl.message('Popular', name: 'hotThread', desc: '', args: []);
  }

  /// `New`
  String get newThread {
    return Intl.message('New', name: 'newThread', desc: '', args: []);
  }

  /// `Edited`
  String get editedPost {
    return Intl.message('Edited', name: 'editedPost', desc: '', args: []);
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
    return Intl.message('On', name: 'pushNotificationOn', desc: '', args: []);
  }

  /// `Off`
  String get pushNotificationOff {
    return Intl.message('Off', name: 'pushNotificationOff', desc: '', args: []);
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
    return Intl.message('Device type', name: 'pushDevice', desc: '', args: []);
  }

  /// `Channel`
  String get pushChannel {
    return Intl.message('Channel', name: 'pushChannel', desc: '', args: []);
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
    return Intl.message('Helps', name: 'pushHelpPages', desc: '', args: []);
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
    return Intl.message('Shortcut', name: 'shortcut', desc: '', args: []);
  }

  /// `Go`
  String get shortcutGo {
    return Intl.message('Go', name: 'shortcutGo', desc: '', args: []);
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
    return Intl.message('Publish', name: 'pushThreadTitle', desc: '', args: []);
  }

  /// `Bold`
  String get insertBoldText {
    return Intl.message('Bold', name: 'insertBoldText', desc: '', args: []);
  }

  /// `Italic`
  String get insertItalicText {
    return Intl.message('Italic', name: 'insertItalicText', desc: '', args: []);
  }

  /// `Quote`
  String get insertQuoteText {
    return Intl.message('Quote', name: 'insertQuoteText', desc: '', args: []);
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

  /// `The forum allows 2–{count} options.`
  String pollOptionLimit(int count) {
    return Intl.message(
      'The forum allows 2–$count options.',
      name: 'pollOptionLimit',
      desc: '',
      args: [count],
    );
  }

  /// `Choose image for option {count}`
  String pollOptionPicture(int count) {
    return Intl.message(
      'Choose image for option $count',
      name: 'pollOptionPicture',
      desc: '',
      args: [count],
    );
  }

  /// `Remove option {count}`
  String removePollOption(int count) {
    return Intl.message(
      'Remove option $count',
      name: 'removePollOption',
      desc: '',
      args: [count],
    );
  }

  /// `Add option`
  String get addPollOption {
    return Intl.message(
      'Add option',
      name: 'addPollOption',
      desc: '',
      args: [],
    );
  }

  /// `Show results after voting`
  String get pollHideResults {
    return Intl.message(
      'Show results after voting',
      name: 'pollHideResults',
      desc: '',
      args: [],
    );
  }

  /// `The poll image is missing or does not meet the forum’s size or format rules.`
  String get pollPictureRejected {
    return Intl.message(
      'The poll image is missing or does not meet the forum’s size or format rules.',
      name: 'pollPictureRejected',
      desc: '',
      args: [],
    );
  }

  /// `Check the value for {name}.`
  String classifiedFieldInvalid(String name) {
    return Intl.message(
      'Check the value for $name.',
      name: 'classifiedFieldInvalid',
      desc: '',
      args: [name],
    );
  }

  /// `Listing duration`
  String get classifiedExpiration {
    return Intl.message(
      'Listing duration',
      name: 'classifiedExpiration',
      desc: '',
      args: [],
    );
  }

  /// `Choose a listing type and fill in its required fields.`
  String get classifiedRequired {
    return Intl.message(
      'Choose a listing type and fill in its required fields.',
      name: 'classifiedRequired',
      desc: '',
      args: [],
    );
  }

  /// `This listing has fields that need the forum’s web form.`
  String get classifiedUnsupported {
    return Intl.message(
      'This listing has fields that need the forum’s web form.',
      name: 'classifiedUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `Closing floor`
  String get rushStopFloorInput {
    return Intl.message(
      'Closing floor',
      name: 'rushStopFloorInput',
      desc: '',
      args: [],
    );
  }

  /// `Replies per member`
  String get rushReplyLimitInput {
    return Intl.message(
      'Replies per member',
      name: 'rushReplyLimitInput',
      desc: '',
      args: [],
    );
  }

  /// `Separate floors with commas. Use * as a wildcard, for example 8,88,*88.`
  String get rushFloorsHint {
    return Intl.message(
      'Separate floors with commas. Use * as a wildcard, for example 8,88,*88.',
      name: 'rushFloorsHint',
      desc: '',
      args: [],
    );
  }

  /// `Check the dates, floor numbers and credit limit.`
  String get rushSettingsInvalid {
    return Intl.message(
      'Check the dates, floor numbers and credit limit.',
      name: 'rushSettingsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Rush replies are unavailable for this account or post type.`
  String get rushSettingsUnavailable {
    return Intl.message(
      'Rush replies are unavailable for this account or post type.',
      name: 'rushSettingsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Remove rush reply settings`
  String get removeRushSettings {
    return Intl.message(
      'Remove rush reply settings',
      name: 'removeRushSettings',
      desc: '',
      args: [],
    );
  }

  /// `Times use the forum’s time zone. Leave optional limits blank.`
  String get rushForumTimeHint {
    return Intl.message(
      'Times use the forum’s time zone. Leave optional limits blank.',
      name: 'rushForumTimeHint',
      desc: '',
      args: [],
    );
  }

  /// `Post settings`
  String get postSettings {
    return Intl.message(
      'Post settings',
      name: 'postSettings',
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

  /// `No thread is posted here, look around?`
  String get emptyThreads {
    return Intl.message(
      'No thread is posted here, look around?',
      name: 'emptyThreads',
      desc: '',
      args: [],
    );
  }

  /// `No user here.`
  String get emptyUser {
    return Intl.message('No user here.', name: 'emptyUser', desc: '', args: []);
  }

  /// `No history found in your device. Have you ever browse anything or never open the history recording in the setting?`
  String get emptyHistory {
    return Intl.message(
      'No history found in your device. Have you ever browse anything or never open the history recording in the setting?',
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

  /// `You haven't recieved any notification.`
  String get emptyNotification {
    return Intl.message(
      'You haven\'t recieved any notification.',
      name: 'emptyNotification',
      desc: '',
      args: [],
    );
  }

  /// `Choose up to {count} options`
  String pollSelectUpTo(int count) {
    return Intl.message(
      'Choose up to $count options',
      name: 'pollSelectUpTo',
      desc: '',
      args: [count],
    );
  }

  /// `Submit vote`
  String get pollSubmit {
    return Intl.message('Submit vote', name: 'pollSubmit', desc: '', args: []);
  }

  /// `Poll closed`
  String get pollFinished {
    return Intl.message(
      'Poll closed',
      name: 'pollFinished',
      desc: '',
      args: [],
    );
  }

  /// `Vote submitted`
  String get pollVoted {
    return Intl.message(
      'Vote submitted',
      name: 'pollVoted',
      desc: '',
      args: [],
    );
  }

  /// `The forum has not published the results yet`
  String get pollResultsHidden {
    return Intl.message(
      'The forum has not published the results yet',
      name: 'pollResultsHidden',
      desc: '',
      args: [],
    );
  }

  /// `Reward topic`
  String get createReward {
    return Intl.message(
      'Reward topic',
      name: 'createReward',
      desc: '',
      args: [],
    );
  }

  /// `Edit reward`
  String get editReward {
    return Intl.message('Edit reward', name: 'editReward', desc: '', args: []);
  }

  /// `Activity topic`
  String get createActivity {
    return Intl.message(
      'Activity topic',
      name: 'createActivity',
      desc: '',
      args: [],
    );
  }

  /// `Edit activity`
  String get editActivity {
    return Intl.message(
      'Edit activity',
      name: 'editActivity',
      desc: '',
      args: [],
    );
  }

  /// `Switch to regular topic`
  String get removeSpecialPost {
    return Intl.message(
      'Switch to regular topic',
      name: 'removeSpecialPost',
      desc: '',
      args: [],
    );
  }

  /// `Total including the fee: {amount}`
  String rewardTotal(String amount) {
    return Intl.message(
      'Total including the fee: $amount',
      name: 'rewardTotal',
      desc: '',
      args: [amount],
    );
  }

  /// `Enter a reward within the forum limits and check your balance.`
  String get rewardAmountInvalid {
    return Intl.message(
      'Enter a reward within the forum limits and check your balance.',
      name: 'rewardAmountInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the forum’s posting rules. Refresh and try again.`
  String get specialPostFormUnavailable {
    return Intl.message(
      'Could not read the forum’s posting rules. Refresh and try again.',
      name: 'specialPostFormUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `The forum rules or credit balance changed. Review the form and submit again.`
  String get specialPostRulesChanged {
    return Intl.message(
      'The forum rules or credit balance changed. Review the form and submit again.',
      name: 'specialPostRulesChanged',
      desc: '',
      args: [],
    );
  }

  /// `Start time`
  String get activityStartsAt {
    return Intl.message(
      'Start time',
      name: 'activityStartsAt',
      desc: '',
      args: [],
    );
  }

  /// `End time (optional)`
  String get activityEndsAt {
    return Intl.message(
      'End time (optional)',
      name: 'activityEndsAt',
      desc: '',
      args: [],
    );
  }

  /// `Registration deadline (optional)`
  String get activityDeadline {
    return Intl.message(
      'Registration deadline (optional)',
      name: 'activityDeadline',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get activityLocation {
    return Intl.message(
      'Location',
      name: 'activityLocation',
      desc: '',
      args: [],
    );
  }

  /// `Activity category`
  String get activityCategory {
    return Intl.message(
      'Activity category',
      name: 'activityCategory',
      desc: '',
      args: [],
    );
  }

  /// `Capacity (0 for unlimited)`
  String get activityCapacity {
    return Intl.message(
      'Capacity (0 for unlimited)',
      name: 'activityCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Who can register`
  String get activityGender {
    return Intl.message(
      'Who can register',
      name: 'activityGender',
      desc: '',
      args: [],
    );
  }

  /// `Anyone`
  String get activityAnyone {
    return Intl.message('Anyone', name: 'activityAnyone', desc: '', args: []);
  }

  /// `Men only`
  String get activityMen {
    return Intl.message('Men only', name: 'activityMen', desc: '', args: []);
  }

  /// `Women only`
  String get activityWomen {
    return Intl.message(
      'Women only',
      name: 'activityWomen',
      desc: '',
      args: [],
    );
  }

  /// `Information required to register`
  String get activityRegistrationFields {
    return Intl.message(
      'Information required to register',
      name: 'activityRegistrationFields',
      desc: '',
      args: [],
    );
  }

  /// `Custom registration fields, one per line, up to {count}`
  String activityCustomFields(int count) {
    return Intl.message(
      'Custom registration fields, one per line, up to $count',
      name: 'activityCustomFields',
      desc: '',
      args: [count],
    );
  }

  /// `Check the event dates, location, category, fees, and registration fields.`
  String get activityDraftInvalid {
    return Intl.message(
      'Check the event dates, location, category, fees, and registration fields.',
      name: 'activityDraftInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Clear date`
  String get clearActivityDate {
    return Intl.message(
      'Clear date',
      name: 'clearActivityDate',
      desc: '',
      args: [],
    );
  }

  /// `Forum guide`
  String get forumGuide {
    return Intl.message('Forum guide', name: 'forumGuide', desc: '', args: []);
  }

  /// `Featured topics`
  String get guideDigest {
    return Intl.message(
      'Featured topics',
      name: 'guideDigest',
      desc: '',
      args: [],
    );
  }

  /// `Recently active`
  String get guideRecentReplies {
    return Intl.message(
      'Recently active',
      name: 'guideRecentReplies',
      desc: '',
      args: [],
    );
  }

  /// `Photo topics`
  String get guidePhotos {
    return Intl.message(
      'Photo topics',
      name: 'guidePhotos',
      desc: '',
      args: [],
    );
  }

  /// `Search forum`
  String get forumSearchWeb {
    return Intl.message(
      'Search forum',
      name: 'forumSearchWeb',
      desc: '',
      args: [],
    );
  }

  /// `Edit on website`
  String get editPostWeb {
    return Intl.message(
      'Edit on website',
      name: 'editPostWeb',
      desc: '',
      args: [],
    );
  }

  /// `Choose a board`
  String get choosePostingForum {
    return Intl.message(
      'Choose a board',
      name: 'choosePostingForum',
      desc: '',
      args: [],
    );
  }

  /// `Pin this reply`
  String get stickReply {
    return Intl.message(
      'Pin this reply',
      name: 'stickReply',
      desc: '',
      args: [],
    );
  }

  /// `Manage pinned reply`
  String get manageReplyPin {
    return Intl.message(
      'Manage pinned reply',
      name: 'manageReplyPin',
      desc: '',
      args: [],
    );
  }

  /// `Unpin this reply`
  String get unstickReply {
    return Intl.message(
      'Unpin this reply',
      name: 'unstickReply',
      desc: '',
      args: [],
    );
  }

  /// `Play motion photo`
  String get motionPhotoPlay {
    return Intl.message(
      'Play motion photo',
      name: 'motionPhotoPlay',
      desc: '',
      args: [],
    );
  }

  /// `This image has no playable motion photo video.`
  String get motionPhotoUnavailable {
    return Intl.message(
      'This image has no playable motion photo video.',
      name: 'motionPhotoUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Poll`
  String get pollTitle {
    return Intl.message('Poll', name: 'pollTitle', desc: '', args: []);
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

  /// `Could not connect to the server in time. Check your network connection and try again.`
  String get dioErrorConnectionTimeout {
    return Intl.message(
      'Could not connect to the server in time. Check your network connection and try again.',
      name: 'dioErrorConnectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Sending data to the server timed out. Check your connection.`
  String get dioErrorSendTimeout {
    return Intl.message(
      'Sending data to the server timed out. Check your connection.',
      name: 'dioErrorSendTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The server took too long to respond. Try again in a moment.`
  String get dioErrorReceiveTimeout {
    return Intl.message(
      'The server took too long to respond. Try again in a moment.',
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

  /// `The request was canceled.`
  String get dioErrorCancel {
    return Intl.message(
      'The request was canceled.',
      name: 'dioErrorCancel',
      desc: '',
      args: [],
    );
  }

  /// `Error.`
  String get dioErrorOther {
    return Intl.message('Error.', name: 'dioErrorOther', desc: '', args: []);
  }

  /// `Could not verify the server’s HTTPS certificate. Check your device’s date and time or contact the site administrator.`
  String get dioErrorBadCertificate {
    return Intl.message(
      'Could not verify the server’s HTTPS certificate. Check your device’s date and time or contact the site administrator.',
      name: 'dioErrorBadCertificate',
      desc: '',
      args: [],
    );
  }

  /// `The server did not return a usable response. Try again later.`
  String get dioErrorBadResponse {
    return Intl.message(
      'The server did not return a usable response. Try again later.',
      name: 'dioErrorBadResponse',
      desc: '',
      args: [],
    );
  }

  /// `Could not connect to the server. Check your network or try opening the site in a browser.`
  String get dioErrorConnectionError {
    return Intl.message(
      'Could not connect to the server. Check your network or try opening the site in a browser.',
      name: 'dioErrorConnectionError',
      desc: '',
      args: [],
    );
  }

  /// `Could not look up the server address. Check the site address and your network connection.`
  String get forumDnsFailure {
    return Intl.message(
      'Could not look up the server address. Check the site address and your network connection.',
      name: 'forumDnsFailure',
      desc: '',
      args: [],
    );
  }

  /// `The server requires sign-in (HTTP 401). Sign in again or open the site in a browser.`
  String get forumHttpUnauthorized {
    return Intl.message(
      'The server requires sign-in (HTTP 401). Sign in again or open the site in a browser.',
      name: 'forumHttpUnauthorized',
      desc: '',
      args: [],
    );
  }

  /// `The server refused access (HTTP 403). Check your permissions or open the site in a browser.`
  String get forumHttpForbidden {
    return Intl.message(
      'The server refused access (HTTP 403). Check your permissions or open the site in a browser.',
      name: 'forumHttpForbidden',
      desc: '',
      args: [],
    );
  }

  /// `The requested page or resource is unavailable. Check the address or try again from the forum.`
  String get forumHttpMissing {
    return Intl.message(
      'The requested page or resource is unavailable. Check the address or try again from the forum.',
      name: 'forumHttpMissing',
      desc: '',
      args: [],
    );
  }

  /// `The server timed out (HTTP {status}). Try again later.`
  String forumHttpTimeout(String status) {
    return Intl.message(
      'The server timed out (HTTP $status). Try again later.',
      name: 'forumHttpTimeout',
      desc: '',
      args: [status],
    );
  }

  /// `The server rejected the request because it was too large (HTTP 413). Try a smaller file.`
  String get forumHttpTooLarge {
    return Intl.message(
      'The server rejected the request because it was too large (HTTP 413). Try a smaller file.',
      name: 'forumHttpTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `The server is receiving too many requests (HTTP 429). Wait a moment before trying again.`
  String get forumHttpRateLimited {
    return Intl.message(
      'The server is receiving too many requests (HTTP 429). Wait a moment before trying again.',
      name: 'forumHttpRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `The server is temporarily unavailable (HTTP {status}). Try again later.`
  String forumHttpServerError(String status) {
    return Intl.message(
      'The server is temporarily unavailable (HTTP $status). Try again later.',
      name: 'forumHttpServerError',
      desc: '',
      args: [status],
    );
  }

  /// `The server rejected the request (HTTP {status}). Try opening the site in a browser.`
  String forumHttpRejected(String status) {
    return Intl.message(
      'The server rejected the request (HTTP $status). Try opening the site in a browser.',
      name: 'forumHttpRejected',
      desc: '',
      args: [status],
    );
  }

  /// `The app took too long to process the server response.`
  String get forumResponseProcessingTimeout {
    return Intl.message(
      'The app took too long to process the server response.',
      name: 'forumResponseProcessingTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The app could not read the server response. Try refreshing.`
  String get forumUnexpectedResponse {
    return Intl.message(
      'The app could not read the server response. Try refreshing.',
      name: 'forumUnexpectedResponse',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error interrupted the operation. Please try again.`
  String get forumUnexpectedError {
    return Intl.message(
      'An unexpected error interrupted the operation. Please try again.',
      name: 'forumUnexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `The site requires browser verification. Open it in a browser to continue.`
  String get forumSecurityChallenge {
    return Intl.message(
      'The site requires browser verification. Open it in a browser to continue.',
      name: 'forumSecurityChallenge',
      desc: '',
      args: [],
    );
  }

  /// `The forum redirected this request to a web page. Open the page to continue.`
  String get forumWebpageRedirect {
    return Intl.message(
      'The forum redirected this request to a web page. Open the page to continue.',
      name: 'forumWebpageRedirect',
      desc: '',
      args: [],
    );
  }

  /// `This forum does not provide the mobile API needed for this feature. Try opening it in a browser.`
  String get forumApiUnavailable {
    return Intl.message(
      'This forum does not provide the mobile API needed for this feature. Try opening it in a browser.',
      name: 'forumApiUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `The forum rejected the request parameters. Reopen the page from the forum or continue in a browser.`
  String get forumApiInvalidRequest {
    return Intl.message(
      'The forum rejected the request parameters. Reopen the page from the forum or continue in a browser.',
      name: 'forumApiInvalidRequest',
      desc: '',
      args: [],
    );
  }

  /// `The forum has disabled this feature or temporarily closed access.`
  String get forumFeatureDisabled {
    return Intl.message(
      'The forum has disabled this feature or temporarily closed access.',
      name: 'forumFeatureDisabled',
      desc: '',
      args: [],
    );
  }

  /// `The forum rejected the current session or form. Refresh the page before submitting again.`
  String get forumFormExpired {
    return Intl.message(
      'The forum rejected the current session or form. Refresh the page before submitting again.',
      name: 'forumFormExpired',
      desc: '',
      args: [],
    );
  }

  /// `The verification code was incorrect or expired. Refresh it and try again.`
  String get forumCaptchaIncorrect {
    return Intl.message(
      'The verification code was incorrect or expired. Refresh it and try again.',
      name: 'forumCaptchaIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `The forum rejected the login. Check your account and password.`
  String get forumLoginRejected {
    return Intl.message(
      'The forum rejected the login. Check your account and password.',
      name: 'forumLoginRejected',
      desc: '',
      args: [],
    );
  }

  /// `This content is unavailable. It may have been removed or may still be under review.`
  String get forumContentUnavailable {
    return Intl.message(
      'This content is unavailable. It may have been removed or may still be under review.',
      name: 'forumContentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `This board requires the correct board password. Open it in a browser to continue.`
  String get forumPasswordRequired {
    return Intl.message(
      'This board requires the correct board password. Open it in a browser to continue.',
      name: 'forumPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `This topic is closed and no longer accepts new replies.`
  String get forumThreadClosed {
    return Intl.message(
      'This topic is closed and no longer accepts new replies.',
      name: 'forumThreadClosed',
      desc: '',
      args: [],
    );
  }

  /// `The forum is limiting how often you can perform this action. Please try again later.`
  String get forumRateLimited {
    return Intl.message(
      'The forum is limiting how often you can perform this action. Please try again later.',
      name: 'forumRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Your forum credit balance is too low for this action.`
  String get forumCreditsInsufficient {
    return Intl.message(
      'Your forum credit balance is too low for this action.',
      name: 'forumCreditsInsufficient',
      desc: '',
      args: [],
    );
  }

  /// `The forum did not grant your account permission for this action.`
  String get forumPermissionDenied {
    return Intl.message(
      'The forum did not grant your account permission for this action.',
      name: 'forumPermissionDenied',
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
    return Intl.message('HMS Push', name: 'pushChannelHMS', desc: '', args: []);
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

  /// `Vibration feedback`
  String get hapticFeedbackTitle {
    return Intl.message(
      'Vibration feedback',
      name: 'hapticFeedbackTitle',
      desc: '',
      args: [],
    );
  }

  /// `Haptic`
  String get feedbackTitle {
    return Intl.message('Haptic', name: 'feedbackTitle', desc: '', args: []);
  }

  /// `Favorite forum`
  String get favoriteIconTooltip {
    return Intl.message(
      'Favorite forum',
      name: 'favoriteIconTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Unfavorite forum`
  String get unfavoriteIconTooltip {
    return Intl.message(
      'Unfavorite forum',
      name: 'unfavoriteIconTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Favorite thread`
  String get favoriteThreadTooltip {
    return Intl.message(
      'Favorite thread',
      name: 'favoriteThreadTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Unfavorite thread`
  String get unfavoriteThreadTooltip {
    return Intl.message(
      'Unfavorite thread',
      name: 'unfavoriteThreadTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Sort thread in ascent order`
  String get sortThreadInAscendOrder {
    return Intl.message(
      'Sort thread in ascent order',
      name: 'sortThreadInAscendOrder',
      desc: '',
      args: [],
    );
  }

  /// `Sort thread in descent order`
  String get sortThreadInDescendOrder {
    return Intl.message(
      'Sort thread in descent order',
      name: 'sortThreadInDescendOrder',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menuIconTooltip {
    return Intl.message('Menu', name: 'menuIconTooltip', desc: '', args: []);
  }

  /// `Select discuz forum`
  String get selectDiscuzIconTooltip {
    return Intl.message(
      'Select discuz forum',
      name: 'selectDiscuzIconTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Chat with him / her`
  String get chatIconToolTip {
    return Intl.message(
      'Chat with him / her',
      name: 'chatIconToolTip',
      desc: '',
      args: [],
    );
  }

  /// `Report the post`
  String get reportThreadTooltip {
    return Intl.message(
      'Report the post',
      name: 'reportThreadTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Insert smiley emoij`
  String get emoijButtonTooltip {
    return Intl.message(
      'Insert smiley emoij',
      name: 'emoijButtonTooltip',
      desc: '',
      args: [],
    );
  }

  /// `More functions`
  String get extraFuncButtonTooltip {
    return Intl.message(
      'More functions',
      name: 'extraFuncButtonTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Close the keyboard`
  String get closeKeyboardTooltip {
    return Intl.message(
      'Close the keyboard',
      name: 'closeKeyboardTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Switch to keyboard`
  String get showKeyboardTooltip {
    return Intl.message(
      'Switch to keyboard',
      name: 'showKeyboardTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Image hosting`
  String get pictureBedTitle {
    return Intl.message(
      'Image hosting',
      name: 'pictureBedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get pictureBedActive {
    return Intl.message('Active', name: 'pictureBedActive', desc: '', args: []);
  }

  /// `Not ready, click to continue`
  String get pictureBedNotPrepared {
    return Intl.message(
      'Not ready, click to continue',
      name: 'pictureBedNotPrepared',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get pictureBedDisabled {
    return Intl.message(
      'Disabled',
      name: 'pictureBedDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Service provided by {pictureBedName}`
  String pictureBedTermsTitle(Object pictureBedName) {
    return Intl.message(
      'Service provided by $pictureBedName',
      name: 'pictureBedTermsTitle',
      desc: '',
      args: [pictureBedName],
    );
  }

  /// `This service is not provided by us but the 3rd party services and we exclude all warranties for it. Using our service does not mean you are granted with 3rd party service as mentioned in our terms. You shall agree to their terms before using 3rd party service.`
  String get pictureBedTermsSubtitle {
    return Intl.message(
      'This service is not provided by us but the 3rd party services and we exclude all warranties for it. Using our service does not mean you are granted with 3rd party service as mentioned in our terms. You shall agree to their terms before using 3rd party service.',
      name: 'pictureBedTermsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get pictureBedAgreeToService {
    return Intl.message(
      'Agree',
      name: 'pictureBedAgreeToService',
      desc: '',
      args: [],
    );
  }

  /// `These service are not provided by us but the 3rd party service. We exclude any warranties or obligation to them. Some of them are not operated in China and you shall carefully watch their policy change to accommodate your use.`
  String get pictureBedServiceNote {
    return Intl.message(
      'These service are not provided by us but the 3rd party service. We exclude any warranties or obligation to them. Some of them are not operated in China and you shall carefully watch their policy change to accommodate your use.',
      name: 'pictureBedServiceNote',
      desc: '',
      args: [],
    );
  }

  /// `imgloc.com`
  String get pictureBedImgloc {
    return Intl.message(
      'imgloc.com',
      name: 'pictureBedImgloc',
      desc: '',
      args: [],
    );
  }

  /// `Chevereto`
  String get cheveretoPictureBed {
    return Intl.message(
      'Chevereto',
      name: 'cheveretoPictureBed',
      desc: '',
      args: [],
    );
  }

  /// `API Key`
  String get cheveretoApiKey {
    return Intl.message('API Key', name: 'cheveretoApiKey', desc: '', args: []);
  }

  /// `The chevereto API key is created by user and usually started with chv_, where you can upload your picture to the hosting site.`
  String get cheveretoApiDescription {
    return Intl.message(
      'The chevereto API key is created by user and usually started with chv_, where you can upload your picture to the hosting site.',
      name: 'cheveretoApiDescription',
      desc: '',
      args: [],
    );
  }

  /// `How to use`
  String get cheveretoApiSetupGuideTitle {
    return Intl.message(
      'How to use',
      name: 'cheveretoApiSetupGuideTitle',
      desc: '',
      args: [],
    );
  }

  /// `1. Sign in to the image hosting website in your browser.\n2. Open account/API settings and create or copy your API key.\n3. Paste the API key here.\n4. Tap Test and save. The app uploads a tiny test image first and saves the key only after the test succeeds.`
  String get cheveretoApiSetupGuide {
    return Intl.message(
      '1. Sign in to the image hosting website in your browser.\n2. Open account/API settings and create or copy your API key.\n3. Paste the API key here.\n4. Tap Test and save. The app uploads a tiny test image first and saves the key only after the test succeeds.',
      name: 'cheveretoApiSetupGuide',
      desc: '',
      args: [],
    );
  }

  /// `Test and save`
  String get pictureBedTestAndSave {
    return Intl.message(
      'Test and save',
      name: 'pictureBedTestAndSave',
      desc: '',
      args: [],
    );
  }

  /// `Testing image hosting API...`
  String get pictureBedTestingApi {
    return Intl.message(
      'Testing image hosting API...',
      name: 'pictureBedTestingApi',
      desc: '',
      args: [],
    );
  }

  /// `API test passed and saved.`
  String get pictureBedTestPassedAndSaved {
    return Intl.message(
      'API test passed and saved.',
      name: 'pictureBedTestPassedAndSaved',
      desc: '',
      args: [],
    );
  }

  /// `Image hosting API test failed.`
  String get pictureBedTestFailed {
    return Intl.message(
      'Image hosting API test failed.',
      name: 'pictureBedTestFailed',
      desc: '',
      args: [],
    );
  }

  /// `Enter an API key first.`
  String get pictureBedApiKeyEmpty {
    return Intl.message(
      'Enter an API key first.',
      name: 'pictureBedApiKeyEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{discuz} may not support push service`
  String pushServiceSiteNotSupport(Object discuz) {
    return Intl.message(
      '$discuz may not support push service',
      name: 'pushServiceSiteNotSupport',
      desc: '',
      args: [discuz],
    );
  }

  /// `About push service ↗️`
  String get viewPushServiceHomePage {
    return Intl.message(
      'About push service ↗️',
      name: 'viewPushServiceHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Push subscription`
  String get subscribeChannel {
    return Intl.message(
      'Push subscription',
      name: 'subscribeChannel',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message('Subscribe', name: 'subscribe', desc: '', args: []);
  }

  /// `No subscription channel exists for {discuz} now.`
  String noSubscribeChannelProvided(Object discuz) {
    return Intl.message(
      'No subscription channel exists for $discuz now.',
      name: 'noSubscribeChannelProvided',
      desc: '',
      args: [discuz],
    );
  }

  /// `Notify us {discuz}`
  String emailUsToAddChannel(Object discuz) {
    return Intl.message(
      'Notify us $discuz',
      name: 'emailUsToAddChannel',
      desc: '',
      args: [discuz],
    );
  }

  /// `Subscription change successful.`
  String get subscriptionSuccess {
    return Intl.message(
      'Subscription change successful.',
      name: 'subscriptionSuccess',
      desc: '',
      args: [],
    );
  }

  /// `The push service is not on.`
  String get pushServiceOff {
    return Intl.message(
      'The push service is not on.',
      name: 'pushServiceOff',
      desc: '',
      args: [],
    );
  }

  /// `No discuz site is added to this device.`
  String get noDiscuzNotFound {
    return Intl.message(
      'No discuz site is added to this device.',
      name: 'noDiscuzNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Add {discuz} to subscription list`
  String emailChannelTitle(Object discuz) {
    return Intl.message(
      'Add $discuz to subscription list',
      name: 'emailChannelTitle',
      desc: '',
      args: [discuz],
    );
  }

  /// `I hereby would like to add {discuz}({discuzUrl}) to subscription list`
  String emailChannelBody(Object discuz, Object discuzUrl) {
    return Intl.message(
      'I hereby would like to add $discuz($discuzUrl) to subscription list',
      name: 'emailChannelBody',
      desc: '',
      args: [discuz, discuzUrl],
    );
  }

  /// `Could not find mail app in this device. You could email us (kidozh@gmail.com) to add this site to the subscription list.`
  String get emailChannelFailed {
    return Intl.message(
      'Could not find mail app in this device. You could email us (kidozh@gmail.com) to add this site to the subscription list.',
      name: 'emailChannelFailed',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe to the channels to get updates.`
  String get subscribeChannelForMore {
    return Intl.message(
      'Subscribe to the channels to get updates.',
      name: 'subscribeChannelForMore',
      desc: '',
      args: [],
    );
  }

  /// `Please enable push service to enable this function.`
  String get pushServiceNotEnabled {
    return Intl.message(
      'Please enable push service to enable this function.',
      name: 'pushServiceNotEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Enable push service`
  String get goToPushSetting {
    return Intl.message(
      'Enable push service',
      name: 'goToPushSetting',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to query saved password.`
  String get authenticateBySystem {
    return Intl.message(
      'Please authenticate to query saved password.',
      name: 'authenticateBySystem',
      desc: '',
      args: [],
    );
  }

  /// `Remember password to device.`
  String get rememeberPasswordInApp {
    return Intl.message(
      'Remember password to device.',
      name: 'rememeberPasswordInApp',
      desc: '',
      args: [],
    );
  }

  /// `View details`
  String get rememberPasswordInAppDetail {
    return Intl.message(
      'View details',
      name: 'rememberPasswordInAppDetail',
      desc: '',
      args: [],
    );
  }

  /// `No authentication is found in this device.`
  String get noAuthenticationFoundInApp {
    return Intl.message(
      'No authentication is found in this device.',
      name: 'noAuthenticationFoundInApp',
      desc: '',
      args: [],
    );
  }

  /// `Auto fill {username} to the form.`
  String autoFillUsername(Object username) {
    return Intl.message(
      'Auto fill $username to the form.',
      name: 'autoFillUsername',
      desc: '',
      args: [username],
    );
  }

  /// `Secure at your device`
  String get authenticationSecurityTitle {
    return Intl.message(
      'Secure at your device',
      name: 'authenticationSecurityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 private key is stored at keychain of the system. Only after authentication from the system, your data is accessible to DisFly.`
  String get authenticationSecurityIosContent {
    return Intl.message(
      'Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 private key is stored at keychain of the system. Only after authentication from the system, your data is accessible to DisFly.',
      name: 'authenticationSecurityIosContent',
      desc: '',
      args: [],
    );
  }

  /// `Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 secret key is encrypted with RSA and RSA key is stored in Android Keystore system. Only after authentication from the system, your data is accessible to DisFly.`
  String get authenticationSecurityAndroidContent {
    return Intl.message(
      'Your authentication are AES-256 encrypted in this device and never sent outside. AES-256 secret key is encrypted with RSA and RSA key is stored in Android Keystore system. Only after authentication from the system, your data is accessible to DisFly.',
      name: 'authenticationSecurityAndroidContent',
      desc: '',
      args: [],
    );
  }

  /// `Doesn't get authentication from the system and auto fill failed.`
  String get unableToAuthenticate {
    return Intl.message(
      'Doesn\'t get authentication from the system and auto fill failed.',
      name: 'unableToAuthenticate',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get discuzAuthenticationTitle {
    return Intl.message(
      'Authentication',
      name: 'discuzAuthenticationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get securityTitle {
    return Intl.message('Security', name: 'securityTitle', desc: '', args: []);
  }

  /// `Your device is not supported.`
  String get authenticationStatusDeviceNotSupported {
    return Intl.message(
      'Your device is not supported.',
      name: 'authenticationStatusDeviceNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Your device is not enrolled in any authentication method.`
  String get authenticationStatusCannotAuthenticate {
    return Intl.message(
      'Your device is not enrolled in any authentication method.',
      name: 'authenticationStatusCannotAuthenticate',
      desc: '',
      args: [],
    );
  }

  /// `Could not pass system's authentication.`
  String get authenticationStatusFailed {
    return Intl.message(
      'Could not pass system\'s authentication.',
      name: 'authenticationStatusFailed',
      desc: '',
      args: [],
    );
  }

  /// `No authentication found in this device.`
  String get authenticationEmpty {
    return Intl.message(
      'No authentication found in this device.',
      name: 'authenticationEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The data is locked`
  String get authenticationLocked {
    return Intl.message(
      'The data is locked',
      name: 'authenticationLocked',
      desc: '',
      args: [],
    );
  }

  /// `Authenticate`
  String get authenticationRetry {
    return Intl.message(
      'Authenticate',
      name: 'authenticationRetry',
      desc: '',
      args: [],
    );
  }

  /// `Last update at {time}`
  String authenticationLastUpdateAt(Object time) {
    return Intl.message(
      'Last update at $time',
      name: 'authenticationLastUpdateAt',
      desc: '',
      args: [time],
    );
  }

  /// `Add`
  String get addAuthentication {
    return Intl.message('Add', name: 'addAuthentication', desc: '', args: []);
  }

  /// `Autofill`
  String get autofillDialogTitle {
    return Intl.message(
      'Autofill',
      name: 'autofillDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select the username to fill the login form`
  String get autofillDialogSubtitle {
    return Intl.message(
      'Select the username to fill the login form',
      name: 'autofillDialogSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Username is empty in the form`
  String get usernameIsEmpty {
    return Intl.message(
      'Username is empty in the form',
      name: 'usernameIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Password is empty in the form`
  String get passwordIsEmpty {
    return Intl.message(
      'Password is empty in the form',
      name: 'passwordIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Host is empty in the form.`
  String get hostIsEmpty {
    return Intl.message(
      'Host is empty in the form.',
      name: 'hostIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{view} views`
  String threadView(Object view) {
    return Intl.message(
      '$view views',
      name: 'threadView',
      desc: '',
      args: [view],
    );
  }

  /// `{reply} replies`
  String threadReply(Object reply) {
    return Intl.message(
      '$reply replies',
      name: 'threadReply',
      desc: '',
      args: [reply],
    );
  }

  /// `Select color`
  String get selectColorTitle {
    return Intl.message(
      'Select color',
      name: 'selectColorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom color`
  String get customColor {
    return Intl.message(
      'Custom color',
      name: 'customColor',
      desc: '',
      args: [],
    );
  }

  /// `Custom · {name}`
  String customColorNamed(Object name) {
    return Intl.message(
      'Custom · $name',
      name: 'customColorNamed',
      desc: '',
      args: [name],
    );
  }

  /// `Select color shade`
  String get selectColorShadeTitle {
    return Intl.message(
      'Select color shade',
      name: 'selectColorShadeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select color and shade`
  String get selectColorAndShadeTitle {
    return Intl.message(
      'Select color and shade',
      name: 'selectColorAndShadeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Primary`
  String get primaryColorPickerType {
    return Intl.message(
      'Primary',
      name: 'primaryColorPickerType',
      desc: '',
      args: [],
    );
  }

  /// `Accent`
  String get accentColorPickerType {
    return Intl.message(
      'Accent',
      name: 'accentColorPickerType',
      desc: '',
      args: [],
    );
  }

  /// `Wheel`
  String get wheelColorPickerType {
    return Intl.message(
      'Wheel',
      name: 'wheelColorPickerType',
      desc: '',
      args: [],
    );
  }

  /// `Black & White`
  String get blackAndWhiteColorPickerType {
    return Intl.message(
      'Black & White',
      name: 'blackAndWhiteColorPickerType',
      desc: '',
      args: [],
    );
  }

  /// `Both`
  String get bothColorPickerType {
    return Intl.message(
      'Both',
      name: 'bothColorPickerType',
      desc: '',
      args: [],
    );
  }

  /// `Typography theme`
  String get chooseTypographyTheme {
    return Intl.message(
      'Typography theme',
      name: 'chooseTypographyTheme',
      desc: '',
      args: [],
    );
  }

  /// `Material 2014`
  String get typographyMaterial2014 {
    return Intl.message(
      'Material 2014',
      name: 'typographyMaterial2014',
      desc: '',
      args: [],
    );
  }

  /// `Material 2018`
  String get typographyMaterial2018 {
    return Intl.message(
      'Material 2018',
      name: 'typographyMaterial2018',
      desc: '',
      args: [],
    );
  }

  /// `Material 2021`
  String get typographyMaterial2021 {
    return Intl.message(
      'Material 2021',
      name: 'typographyMaterial2021',
      desc: '',
      args: [],
    );
  }

  /// `Typography default`
  String get typographySystem {
    return Intl.message(
      'Typography default',
      name: 'typographySystem',
      desc: '',
      args: [],
    );
  }

  /// `Inline frame`
  String get inlineFramePage {
    return Intl.message(
      'Inline frame',
      name: 'inlineFramePage',
      desc: '',
      args: [],
    );
  }

  /// `Thin font`
  String get useThinFont {
    return Intl.message('Thin font', name: 'useThinFont', desc: '', args: []);
  }

  /// `No forum is cached`
  String get noForumIsCachedTitle {
    return Intl.message(
      'No forum is cached',
      name: 'noForumIsCachedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Could you please open index page once to get a cache of all forums?`
  String get noForumIsCachedSubtitle {
    return Intl.message(
      'Could you please open index page once to get a cache of all forums?',
      name: 'noForumIsCachedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Scroll to last read position.`
  String get animateToLastReadingPosition {
    return Intl.message(
      'Scroll to last read position.',
      name: 'animateToLastReadingPosition',
      desc: '',
      args: [],
    );
  }

  /// `Compact paragraph`
  String get compactTypography {
    return Intl.message(
      'Compact paragraph',
      name: 'compactTypography',
      desc: '',
      args: [],
    );
  }

  /// `Use app signature`
  String get signatureWithDisFly {
    return Intl.message(
      'Use app signature',
      name: 'signatureWithDisFly',
      desc: '',
      args: [],
    );
  }

  /// `Support us`
  String get signatureSupportUS {
    return Intl.message(
      'Support us',
      name: 'signatureSupportUS',
      desc: '',
      args: [],
    );
  }

  /// `- Sent by {device}'s [url=https://discuzhub.kidozh.com/]DisFly[/url] v{version}.`
  String fromAppSignature(Object device, Object version) {
    return Intl.message(
      '- Sent by $device\'s [url=https://discuzhub.kidozh.com/]DisFly[/url] v$version.',
      name: 'fromAppSignature',
      desc: '',
      args: [device, version],
    );
  }

  /// `Preview`
  String get signaturePreview {
    return Intl.message(
      'Preview',
      name: 'signaturePreview',
      desc: '',
      args: [],
    );
  }

  /// `You can support us by adding the app information to your post signature. You may opt it out any time in the setting.`
  String get signatureWithDisFlyDescription {
    return Intl.message(
      'You can support us by adding the app information to your post signature. You may opt it out any time in the setting.',
      name: 'signatureWithDisFlyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Scheme variant`
  String get dynamicSchemeVariant {
    return Intl.message(
      'Scheme variant',
      name: 'dynamicSchemeVariant',
      desc: '',
      args: [],
    );
  }

  /// `In some cases, the tones can prevent colors from appearing as intended, such as when a color is too light to offer enough contrast for accessibility.`
  String get dynamicSchemeVariantNotification {
    return Intl.message(
      'In some cases, the tones can prevent colors from appearing as intended, such as when a color is too light to offer enough contrast for accessibility.',
      name: 'dynamicSchemeVariantNotification',
      desc: '',
      args: [],
    );
  }

  /// `'Fidelity' is a feature that adjusts tones in these cases to produce the intended visual results without harming visual contrast.`
  String get dynamicSchemeVariantFidelityNotification {
    return Intl.message(
      '\'Fidelity\' is a feature that adjusts tones in these cases to produce the intended visual results without harming visual contrast.',
      name: 'dynamicSchemeVariantFidelityNotification',
      desc: '',
      args: [],
    );
  }

  /// `Tonal`
  String get dynamicSchemeVariantTonalSpotKey {
    return Intl.message(
      'Tonal',
      name: 'dynamicSchemeVariantTonalSpotKey',
      desc: '',
      args: [],
    );
  }

  /// `Pastel palettes with a low chroma.`
  String get dynamicSchemeVariantTonalSpotDescription {
    return Intl.message(
      'Pastel palettes with a low chroma.',
      name: 'dynamicSchemeVariantTonalSpotDescription',
      desc: '',
      args: [],
    );
  }

  /// `Fidelity`
  String get dynamicSchemeVariantFidelityKey {
    return Intl.message(
      'Fidelity',
      name: 'dynamicSchemeVariantFidelityKey',
      desc: '',
      args: [],
    );
  }

  /// `Pastel palettes with a low chroma.`
  String get dynamicSchemeVariantFidelityDescription {
    return Intl.message(
      'Pastel palettes with a low chroma.',
      name: 'dynamicSchemeVariantFidelityDescription',
      desc: '',
      args: [],
    );
  }

  /// `Monochrome`
  String get dynamicSchemeVariantMonochromeKey {
    return Intl.message(
      'Monochrome',
      name: 'dynamicSchemeVariantMonochromeKey',
      desc: '',
      args: [],
    );
  }

  /// `Gray scale color, no chroma.`
  String get dynamicSchemeVariantMonochromeDescription {
    return Intl.message(
      'Gray scale color, no chroma.',
      name: 'dynamicSchemeVariantMonochromeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Neutral`
  String get dynamicSchemeVariantNeutralKey {
    return Intl.message(
      'Neutral',
      name: 'dynamicSchemeVariantNeutralKey',
      desc: '',
      args: [],
    );
  }

  /// `Close to grayscale, a hint of chroma.`
  String get dynamicSchemeVariantNeutralDescription {
    return Intl.message(
      'Close to grayscale, a hint of chroma.',
      name: 'dynamicSchemeVariantNeutralDescription',
      desc: '',
      args: [],
    );
  }

  /// `Vibrant`
  String get dynamicSchemeVariantVibrantKey {
    return Intl.message(
      'Vibrant',
      name: 'dynamicSchemeVariantVibrantKey',
      desc: '',
      args: [],
    );
  }

  /// `Pastel colors, high chroma palettes.`
  String get dynamicSchemeVariantVibrantDescription {
    return Intl.message(
      'Pastel colors, high chroma palettes.',
      name: 'dynamicSchemeVariantVibrantDescription',
      desc: '',
      args: [],
    );
  }

  /// `Expressive`
  String get dynamicSchemeVariantExpressiveKey {
    return Intl.message(
      'Expressive',
      name: 'dynamicSchemeVariantExpressiveKey',
      desc: '',
      args: [],
    );
  }

  /// `Pastel colors, medium chroma palettes.`
  String get dynamicSchemeVariantExpressiveDescription {
    return Intl.message(
      'Pastel colors, medium chroma palettes.',
      name: 'dynamicSchemeVariantExpressiveDescription',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get dynamicSchemeVariantContentKey {
    return Intl.message(
      'Content',
      name: 'dynamicSchemeVariantContentKey',
      desc: '',
      args: [],
    );
  }

  /// `Tokens and palettes match the seed color.`
  String get dynamicSchemeVariantContentDescription {
    return Intl.message(
      'Tokens and palettes match the seed color.',
      name: 'dynamicSchemeVariantContentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Rainbow`
  String get dynamicSchemeVariantRainbowKey {
    return Intl.message(
      'Rainbow',
      name: 'dynamicSchemeVariantRainbowKey',
      desc: '',
      args: [],
    );
  }

  /// `A playful theme.`
  String get dynamicSchemeVariantRainbowDescription {
    return Intl.message(
      'A playful theme.',
      name: 'dynamicSchemeVariantRainbowDescription',
      desc: '',
      args: [],
    );
  }

  /// `FruitSalad`
  String get dynamicSchemeVariantFruitSaladKey {
    return Intl.message(
      'FruitSalad',
      name: 'dynamicSchemeVariantFruitSaladKey',
      desc: '',
      args: [],
    );
  }

  /// `A playful theme.`
  String get dynamicSchemeVariantFruitSaladDescription {
    return Intl.message(
      'A playful theme.',
      name: 'dynamicSchemeVariantFruitSaladDescription',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for letting our app heard by more people. The number of inline app will be reduced to appreciate your assistance.`
  String get acknowledgeAppSignatureAndAdDiminish {
    return Intl.message(
      'Thank you for letting our app heard by more people. The number of inline app will be reduced to appreciate your assistance.',
      name: 'acknowledgeAppSignatureAndAdDiminish',
      desc: '',
      args: [],
    );
  }

  /// `Report availability to us`
  String get reportDiscuzApiInformationToAnalytics {
    return Intl.message(
      'Report availability to us',
      name: 'reportDiscuzApiInformationToAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Report availability to us`
  String get reportDiscuzApiInformationToAnalyticsTitle {
    return Intl.message(
      'Report availability to us',
      name: 'reportDiscuzApiInformationToAnalyticsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your report to this site is truly important to us. Our app is optimised for Discuz! forum, and it is important for us to know which our app should be optimised for. The report itself is anonymous and we will not record any information related with you.`
  String get reportDiscuzApiInformationToAnalyticsDescription {
    return Intl.message(
      'Your report to this site is truly important to us. Our app is optimised for Discuz! forum, and it is important for us to know which our app should be optimised for. The report itself is anonymous and we will not record any information related with you.',
      name: 'reportDiscuzApiInformationToAnalyticsDescription',
      desc: '',
      args: [],
    );
  }

  /// `View our privacy policy`
  String get viewPrivacyPolicy {
    return Intl.message(
      'View our privacy policy',
      name: 'viewPrivacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you looking for`
  String get addDiscuzSuggestionTitle {
    return Intl.message(
      'Are you looking for',
      name: 'addDiscuzSuggestionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get addDiscuzSuggestionAnnotation {
    return Intl.message(
      'Feedback',
      name: 'addDiscuzSuggestionAnnotation',
      desc: '',
      args: [],
    );
  }

  /// `Disfly is a third-party app for Discuz ! forum site. We have no relation with any Discuz forum.`
  String get addDiscuzSuggestionStatement {
    return Intl.message(
      'Disfly is a third-party app for Discuz ! forum site. We have no relation with any Discuz forum.',
      name: 'addDiscuzSuggestionStatement',
      desc: '',
      args: [],
    );
  }

  /// `Have any suggestion?`
  String get addDiscuzSuggestionDialogTitle {
    return Intl.message(
      'Have any suggestion?',
      name: 'addDiscuzSuggestionDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `We love to hear your suggestion. If you would like to recommend or hide a Discuz site, you are welcomed to contact us via email (kidozh@gmail.com).`
  String get addDiscuzSuggestionDialogDescription {
    return Intl.message(
      'We love to hear your suggestion. If you would like to recommend or hide a Discuz site, you are welcomed to contact us via email (kidozh@gmail.com).',
      name: 'addDiscuzSuggestionDialogDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tell us your voice`
  String get addDiscuzSuggestionDialogButtonTitle {
    return Intl.message(
      'Tell us your voice',
      name: 'addDiscuzSuggestionDialogButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// ` of discuz has ICP license from MIIT.`
  String get addDiscuzSuggestionVerifiedDiscuz {
    return Intl.message(
      ' of discuz has ICP license from MIIT.',
      name: 'addDiscuzSuggestionVerifiedDiscuz',
      desc: '',
      args: [],
    );
  }

  /// `Let's get started`
  String get nullDiscuzScreenTitle {
    return Intl.message(
      'Let\'s get started',
      name: 'nullDiscuzScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add discuz ! now to Disfly to enjoy the app.`
  String get nullDiscuzScreenSubtitle {
    return Intl.message(
      'Add discuz ! now to Disfly to enjoy the app.',
      name: 'nullDiscuzScreenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Block`
  String get adminBlockPost {
    return Intl.message('Block', name: 'adminBlockPost', desc: '', args: []);
  }

  /// `Unblock`
  String get adminUnblockPost {
    return Intl.message(
      'Unblock',
      name: 'adminUnblockPost',
      desc: '',
      args: [],
    );
  }

  /// `Warn`
  String get adminWarnPost {
    return Intl.message('Warn', name: 'adminWarnPost', desc: '', args: []);
  }

  /// `Redo warn`
  String get adminUnwarnPost {
    return Intl.message(
      'Redo warn',
      name: 'adminUnwarnPost',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get adminDeletePost {
    return Intl.message('Delete', name: 'adminDeletePost', desc: '', args: []);
  }

  /// `Pinned thread`
  String get stickyThread {
    return Intl.message(
      'Pinned thread',
      name: 'stickyThread',
      desc: '',
      args: [],
    );
  }

  /// `AD exempt`
  String get adExemptTitle {
    return Intl.message('AD exempt', name: 'adExemptTitle', desc: '', args: []);
  }

  /// `You can choose one discuz to exempt its advertisement by App.`
  String get adExemptDescription {
    return Intl.message(
      'You can choose one discuz to exempt its advertisement by App.',
      name: 'adExemptDescription',
      desc: '',
      args: [],
    );
  }

  /// `As a gift, you can opt one discuz forum out of advertisement.`
  String get adExemptCondition {
    return Intl.message(
      'As a gift, you can opt one discuz forum out of advertisement.',
      name: 'adExemptCondition',
      desc: '',
      args: [],
    );
  }

  /// `The following discuz forums have already been exempted out of advertisement.`
  String get adExemptEmbeddedList {
    return Intl.message(
      'The following discuz forums have already been exempted out of advertisement.',
      name: 'adExemptEmbeddedList',
      desc: '',
      args: [],
    );
  }

  /// `Choose one discuz to exempt AD`
  String get adExemptNeedConfirm {
    return Intl.message(
      'Choose one discuz to exempt AD',
      name: 'adExemptNeedConfirm',
      desc: '',
      args: [],
    );
  }

  /// `There is no discuz forum needs to opt out of advertisement`
  String get adExemptNoNeedToConfirm {
    return Intl.message(
      'There is no discuz forum needs to opt out of advertisement',
      name: 'adExemptNoNeedToConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The attachment is too large`
  String get attachmentUploadExceedingSizeTitle {
    return Intl.message(
      'The attachment is too large',
      name: 'attachmentUploadExceedingSizeTitle',
      desc: '',
      args: [],
    );
  }

  /// `The attachment shall be compressed to be accepted by the forum.`
  String get attachmentUploadExceedingSizeDescription {
    return Intl.message(
      'The attachment shall be compressed to be accepted by the forum.',
      name: 'attachmentUploadExceedingSizeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Unable to recognise the discuz!`
  String get addDiscuzApiBrowseUnsuccessfully {
    return Intl.message(
      'Unable to recognise the discuz!',
      name: 'addDiscuzApiBrowseUnsuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The app received an unrecognized response from the forum’s mobile API. Check the forum address and try again.`
  String get addDiscuzApiParseUnsuccessfully {
    return Intl.message(
      'The app received an unrecognized response from the forum’s mobile API. Check the forum address and try again.',
      name: 'addDiscuzApiParseUnsuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The site's security policy blocked the API request. Please try again from the site settings if the issue persists.`
  String get addDiscuzApiSecurityChallengeBlocked {
    return Intl.message(
      'The site\'s security policy blocked the API request. Please try again from the site settings if the issue persists.',
      name: 'addDiscuzApiSecurityChallengeBlocked',
      desc: '',
      args: [],
    );
  }

  /// `Complete Security Challenge`
  String get securityChallengeTitle {
    return Intl.message(
      'Complete Security Challenge',
      name: 'securityChallengeTitle',
      desc: '',
      args: [],
    );
  }

  /// `{sitename} is in AD exempt list`
  String discuzInAdExemptBuiltInList(Object sitename) {
    return Intl.message(
      '$sitename is in AD exempt list',
      name: 'discuzInAdExemptBuiltInList',
      desc: '',
      args: [sitename],
    );
  }

  /// `The inner AD is invisible when browsing {sitename}. \nThanks for choosing DisFly.`
  String discuzInAdExemptBuiltInListDescription(Object sitename) {
    return Intl.message(
      'The inner AD is invisible when browsing $sitename. \nThanks for choosing DisFly.',
      name: 'discuzInAdExemptBuiltInListDescription',
      desc: '',
      args: [sitename],
    );
  }

  /// `View in Steam`
  String get openGameInSteam {
    return Intl.message(
      'View in Steam',
      name: 'openGameInSteam',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get gameFreeOfCharge {
    return Intl.message('Free', name: 'gameFreeOfCharge', desc: '', args: []);
  }

  /// `Coming Soon`
  String get gameComingSoon {
    return Intl.message(
      'Coming Soon',
      name: 'gameComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Not support {language}`
  String gameLanguageNotSupported(Object language) {
    return Intl.message(
      'Not support $language',
      name: 'gameLanguageNotSupported',
      desc: '',
      args: [language],
    );
  }

  /// `Menu`
  String get menuDrawerTitle {
    return Intl.message('Menu', name: 'menuDrawerTitle', desc: '', args: []);
  }

  /// `My content`
  String get drawerMyContent {
    return Intl.message(
      'My content',
      name: 'drawerMyContent',
      desc: '',
      args: [],
    );
  }

  /// `Browse forum`
  String get drawerBrowseForum {
    return Intl.message(
      'Browse forum',
      name: 'drawerBrowseForum',
      desc: '',
      args: [],
    );
  }

  /// `Accounts and forums`
  String get drawerAccountAndForum {
    return Intl.message(
      'Accounts and forums',
      name: 'drawerAccountAndForum',
      desc: '',
      args: [],
    );
  }

  /// `Preferences and privacy`
  String get drawerPreferences {
    return Intl.message(
      'Preferences and privacy',
      name: 'drawerPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Switch account`
  String get drawerSwitchAccount {
    return Intl.message(
      'Switch account',
      name: 'drawerSwitchAccount',
      desc: '',
      args: [],
    );
  }

  /// `Post thread`
  String get postThread {
    return Intl.message('Post thread', name: 'postThread', desc: '', args: []);
  }

  /// `Preview`
  String get viewPicture {
    return Intl.message('Preview', name: 'viewPicture', desc: '', args: []);
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Thread`
  String get thread {
    return Intl.message('Thread', name: 'thread', desc: '', args: []);
  }

  /// `Locale`
  String get pushLocale {
    return Intl.message('Locale', name: 'pushLocale', desc: '', args: []);
  }

  /// `FCM limited availability`
  String get pushServiceLimitedInChinaMainlandTitle {
    return Intl.message(
      'FCM limited availability',
      name: 'pushServiceLimitedInChinaMainlandTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Firebase Cloud Messaging service is limited in China Mainland. To ensure a prompt notification, you are advised to turn on the auto-restart or add DisFly to the except list.`
  String get pushServiceLimitedInChinaMainlandSubtitle {
    return Intl.message(
      'The Firebase Cloud Messaging service is limited in China Mainland. To ensure a prompt notification, you are advised to turn on the auto-restart or add DisFly to the except list.',
      name: 'pushServiceLimitedInChinaMainlandSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `404 Not Found`
  String get responseStatusError404 {
    return Intl.message(
      '404 Not Found',
      name: 'responseStatusError404',
      desc: '',
      args: [],
    );
  }

  /// `ImgBB`
  String get pictureBedImgBB {
    return Intl.message('ImgBB', name: 'pictureBedImgBB', desc: '', args: []);
  }

  /// `Keylol Portal`
  String get keylolPortal {
    return Intl.message(
      'Keylol Portal',
      name: 'keylolPortal',
      desc: '',
      args: [],
    );
  }

  /// `On-device AI`
  String get appleIntelligence {
    return Intl.message(
      'On-device AI',
      name: 'appleIntelligence',
      desc: '',
      args: [],
    );
  }

  /// `Enable on-device AI`
  String get appleIntelligenceEnabled {
    return Intl.message(
      'Enable on-device AI',
      name: 'appleIntelligenceEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Translate posts or process text with custom on-device AI rules. Content is processed locally rather than sent to a cloud model for these actions. Initial model setup may require an internet download. Generated results can be inaccurate; check important information.`
  String get appleIntelligenceUseNotice {
    return Intl.message(
      'Translate posts or process text with custom on-device AI rules. Content is processed locally rather than sent to a cloud model for these actions. Initial model setup may require an internet download. Generated results can be inaccurate; check important information.',
      name: 'appleIntelligenceUseNotice',
      desc: '',
      args: [],
    );
  }

  /// `Learn more ↗`
  String get appleIntelligenceLearnMore {
    return Intl.message(
      'Learn more ↗',
      name: 'appleIntelligenceLearnMore',
      desc: '',
      args: [],
    );
  }

  /// `Translate`
  String get appleIntelligenceTranslate {
    return Intl.message(
      'Translate',
      name: 'appleIntelligenceTranslate',
      desc: '',
      args: [],
    );
  }

  /// `Prompt hint`
  String get appleIntelligencePromptHint {
    return Intl.message(
      'Prompt hint',
      name: 'appleIntelligencePromptHint',
      desc: '',
      args: [],
    );
  }

  /// `Instruction`
  String get appleIntelligencePromptInstruction {
    return Intl.message(
      'Instruction',
      name: 'appleIntelligencePromptInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Guardrail Level`
  String get appleIntelligenceGuardrailLevel {
    return Intl.message(
      'Guardrail Level',
      name: 'appleIntelligenceGuardrailLevel',
      desc: '',
      args: [],
    );
  }

  /// `Strict`
  String get appleIntelligenceGuardrailLevelStrict {
    return Intl.message(
      'Strict',
      name: 'appleIntelligenceGuardrailLevelStrict',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get appleIntelligenceGuardrailLevelStandard {
    return Intl.message(
      'Standard',
      name: 'appleIntelligenceGuardrailLevelStandard',
      desc: '',
      args: [],
    );
  }

  /// `Permissive`
  String get appleIntelligenceGuardrailLevelPermissive {
    return Intl.message(
      'Permissive',
      name: 'appleIntelligenceGuardrailLevelPermissive',
      desc: '',
      args: [],
    );
  }

  /// `Add AI Rule`
  String get appleIntelligenceAddRule {
    return Intl.message(
      'Add AI Rule',
      name: 'appleIntelligenceAddRule',
      desc: '',
      args: [],
    );
  }

  /// `Not supported`
  String get appleIntelligenceNotSupported {
    return Intl.message(
      'Not supported',
      name: 'appleIntelligenceNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `The current device does not enable any LLM model services.`
  String get appleIntelligenceNotSupportedInThisPlatform {
    return Intl.message(
      'The current device does not enable any LLM model services.',
      name: 'appleIntelligenceNotSupportedInThisPlatform',
      desc: '',
      args: [],
    );
  }

  /// `This device does not support the required on-device foundation model.`
  String get appleIntelligenceUnavailableDeviceNotEligible {
    return Intl.message(
      'This device does not support the required on-device foundation model.',
      name: 'appleIntelligenceUnavailableDeviceNotEligible',
      desc: '',
      args: [],
    );
  }

  /// `Apple Intelligence is not enabled. Enable it in system Settings, then try again.`
  String get appleIntelligenceUnavailableNotEnabled {
    return Intl.message(
      'Apple Intelligence is not enabled. Enable it in system Settings, then try again.',
      name: 'appleIntelligenceUnavailableNotEnabled',
      desc: '',
      args: [],
    );
  }

  /// `The on-device model is still downloading or preparing. Try again shortly.`
  String get appleIntelligenceUnavailableModelNotReady {
    return Intl.message(
      'The on-device model is still downloading or preparing. Try again shortly.',
      name: 'appleIntelligenceUnavailableModelNotReady',
      desc: '',
      args: [],
    );
  }

  /// `The current system version ({osVersion}) is too old. Update the system and try again.`
  String appleIntelligenceUnavailablePlatformTooOld(Object osVersion) {
    return Intl.message(
      'The current system version ($osVersion) is too old. Update the system and try again.',
      name: 'appleIntelligenceUnavailablePlatformTooOld',
      desc: '',
      args: [osVersion],
    );
  }

  /// `The on-device intelligence service is temporarily unavailable. Try again later.`
  String get appleIntelligenceUnavailableUnknown {
    return Intl.message(
      'The on-device intelligence service is temporarily unavailable. Try again later.',
      name: 'appleIntelligenceUnavailableUnknown',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while checking the on-device intelligence service. Try again later.`
  String get appleIntelligenceAvailabilityCheckFailed {
    return Intl.message(
      'An error occurred while checking the on-device intelligence service. Try again later.',
      name: 'appleIntelligenceAvailabilityCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get appleIntelligenceHelp {
    return Intl.message(
      'Help',
      name: 'appleIntelligenceHelp',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get appleIntelligenceRuleName {
    return Intl.message(
      'Name',
      name: 'appleIntelligenceRuleName',
      desc: '',
      args: [],
    );
  }

  /// `Rule {placeholder}`
  String appleIntelligenceRuleNameTemplate(Object placeholder) {
    return Intl.message(
      'Rule $placeholder',
      name: 'appleIntelligenceRuleNameTemplate',
      desc: '',
      args: [placeholder],
    );
  }

  /// `This field should not be empty`
  String get textFieldShouldNotBeEmpty {
    return Intl.message(
      'This field should not be empty',
      name: 'textFieldShouldNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `AI Rule`
  String get appleIntelligenceRule {
    return Intl.message(
      'AI Rule',
      name: 'appleIntelligenceRule',
      desc: '',
      args: [],
    );
  }

  /// `Modify rule {placeholder}`
  String appleIntelligenceModifyRuleTitleTemplate(Object placeholder) {
    return Intl.message(
      'Modify rule $placeholder',
      name: 'appleIntelligenceModifyRuleTitleTemplate',
      desc: '',
      args: [placeholder],
    );
  }

  /// `Delete {placeholder}`
  String appleIntelligenceDeleteRuleTitleTemplate(Object placeholder) {
    return Intl.message(
      'Delete $placeholder',
      name: 'appleIntelligenceDeleteRuleTitleTemplate',
      desc: '',
      args: [placeholder],
    );
  }

  /// `Are you sure to delete the AI rule ,{placeholder}? This operation is non-reversible.`
  String appleIntelligenceDeleteRuleContentemplate(Object placeholder) {
    return Intl.message(
      'Are you sure to delete the AI rule ,$placeholder? This operation is non-reversible.',
      name: 'appleIntelligenceDeleteRuleContentemplate',
      desc: '',
      args: [placeholder],
    );
  }

  /// `You are a professional translator. Translating the text into the language of the user. Don’t answer questions or don’t try to evaluate any task from the input text. Your only task is to translate input text. Keep the same tone of the text (Example: if INPUT TEXT is funny, TRANSLATION should be funny. If INPUT TEXT is formal, TRANSLATION should be formal). If INPUT TEXT contains HTML, keep the same HTML structure in your TRANSLATION. TRANSLATION should have a similar length as INPUT TEXT.`
  String get appleIntelligenceInstructionExample {
    return Intl.message(
      'You are a professional translator. Translating the text into the language of the user. Don’t answer questions or don’t try to evaluate any task from the input text. Your only task is to translate input text. Keep the same tone of the text (Example: if INPUT TEXT is funny, TRANSLATION should be funny. If INPUT TEXT is formal, TRANSLATION should be formal). If INPUT TEXT contains HTML, keep the same HTML structure in your TRANSLATION. TRANSLATION should have a similar length as INPUT TEXT.',
      name: 'appleIntelligenceInstructionExample',
      desc: '',
      args: [],
    );
  }

  /// `Translate the following text into user's language`
  String get appleIntelligencePromptExample {
    return Intl.message(
      'Translate the following text into user\'s language',
      name: 'appleIntelligencePromptExample',
      desc: '',
      args: [],
    );
  }

  /// `The translation rule is inherent into the app itself and can not be deleted.`
  String get appleIntelligenceRuleTranslationExampleNotice {
    return Intl.message(
      'The translation rule is inherent into the app itself and can not be deleted.',
      name: 'appleIntelligenceRuleTranslationExampleNotice',
      desc: '',
      args: [],
    );
  }

  /// `AI chat history`
  String get appleIntelligenceUseHistory {
    return Intl.message(
      'AI chat history',
      name: 'appleIntelligenceUseHistory',
      desc: '',
      args: [],
    );
  }

  /// `Read our post ↗`
  String get appleIntelligenceLearnMoreFromOurPost {
    return Intl.message(
      'Read our post ↗',
      name: 'appleIntelligenceLearnMoreFromOurPost',
      desc: '',
      args: [],
    );
  }

  /// `The on-device model is ready. Enable it to translate posts and use custom text-processing rules.`
  String get onDeviceAiReadyDescription {
    return Intl.message(
      'The on-device model is ready. Enable it to translate posts and use custom text-processing rules.',
      name: 'onDeviceAiReadyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Download the on-device model`
  String get onDeviceAiModelDownloadTitle {
    return Intl.message(
      'Download the on-device model',
      name: 'onDeviceAiModelDownloadTitle',
      desc: '',
      args: [],
    );
  }

  /// `The device reports model support, but the required files are not ready. Tap Download model to let Android AICore download them, preferably over Wi-Fi. Intelligence can be enabled once the download is complete.`
  String get onDeviceAiModelDownloadDescription {
    return Intl.message(
      'The device reports model support, but the required files are not ready. Tap Download model to let Android AICore download them, preferably over Wi-Fi. Intelligence can be enabled once the download is complete.',
      name: 'onDeviceAiModelDownloadDescription',
      desc: '',
      args: [],
    );
  }

  /// `Download model`
  String get onDeviceAiDownloadModel {
    return Intl.message(
      'Download model',
      name: 'onDeviceAiDownloadModel',
      desc: '',
      args: [],
    );
  }

  /// `Downloading model…`
  String get onDeviceAiDownloadingModel {
    return Intl.message(
      'Downloading model…',
      name: 'onDeviceAiDownloadingModel',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded {downloaded} MB`
  String onDeviceAiDownloadProgress(Object downloaded) {
    return Intl.message(
      'Downloaded $downloaded MB',
      name: 'onDeviceAiDownloadProgress',
      desc: '',
      args: [downloaded],
    );
  }

  /// `The model download failed. Check the network and available storage, then try again.`
  String get onDeviceAiDownloadFailed {
    return Intl.message(
      'The model download failed. Check the network and available storage, then try again.',
      name: 'onDeviceAiDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Android AICore is required`
  String get onDeviceAiAICoreTitle {
    return Intl.message(
      'Android AICore is required',
      name: 'onDeviceAiAICoreTitle',
      desc: '',
      args: [],
    );
  }

  /// `AICore is incompatible with the version required by this feature. Check for AICore updates in Google Play on a supported physical device, then check again. Installing AICore alone does not make an unsupported device compatible.`
  String get onDeviceAiAICoreDescription {
    return Intl.message(
      'AICore is incompatible with the version required by this feature. Check for AICore updates in Google Play on a supported physical device, then check again. Installing AICore alone does not make an unsupported device compatible.',
      name: 'onDeviceAiAICoreDescription',
      desc: '',
      args: [],
    );
  }

  /// `Open Google Play`
  String get onDeviceAiOpenGooglePlay {
    return Intl.message(
      'Open Google Play',
      name: 'onDeviceAiOpenGooglePlay',
      desc: '',
      args: [],
    );
  }

  /// `System update required`
  String get onDeviceAiSystemUpdateTitle {
    return Intl.message(
      'System update required',
      name: 'onDeviceAiSystemUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `This Android or Apple system version is too old for the on-device model. Update the system and try again.`
  String get onDeviceAiSystemUpdateDescription {
    return Intl.message(
      'This Android or Apple system version is too old for the on-device model. Update the system and try again.',
      name: 'onDeviceAiSystemUpdateDescription',
      desc: '',
      args: [],
    );
  }

  /// `Not enough storage`
  String get onDeviceAiStorageTitle {
    return Intl.message(
      'Not enough storage',
      name: 'onDeviceAiStorageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Free some device storage before downloading or using the on-device model.`
  String get onDeviceAiStorageDescription {
    return Intl.message(
      'Free some device storage before downloading or using the on-device model.',
      name: 'onDeviceAiStorageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Temporarily unavailable`
  String get onDeviceAiTemporarilyUnavailableTitle {
    return Intl.message(
      'Temporarily unavailable',
      name: 'onDeviceAiTemporarilyUnavailableTitle',
      desc: '',
      args: [],
    );
  }

  /// `The system intelligence service is preparing or temporarily busy. Keep the device online and try again shortly.`
  String get onDeviceAiTemporarilyUnavailableDescription {
    return Intl.message(
      'The system intelligence service is preparing or temporarily busy. Keep the device online and try again shortly.',
      name: 'onDeviceAiTemporarilyUnavailableDescription',
      desc: '',
      args: [],
    );
  }

  /// `Check again`
  String get onDeviceAiRetry {
    return Intl.message(
      'Check again',
      name: 'onDeviceAiRetry',
      desc: '',
      args: [],
    );
  }

  /// `Setup required`
  String get onDeviceAiSetupRequired {
    return Intl.message(
      'Setup required',
      name: 'onDeviceAiSetupRequired',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get onDeviceAiStatusDownloading {
    return Intl.message(
      'Downloading',
      name: 'onDeviceAiStatusDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Apple devices use the system on-device foundation model. A compatible device, enabled Apple Intelligence, and a ready model are required.`
  String get onDeviceAiProviderApple {
    return Intl.message(
      'Apple devices use the system on-device foundation model. A compatible device, enabled Apple Intelligence, and a ready model are required.',
      name: 'onDeviceAiProviderApple',
      desc: '',
      args: [],
    );
  }

  /// `Android uses Gemini Nano through the AICore system service. A Google-supported physical device and a ready model are required. Standard Android emulators are not in the official support list; having Google Play or the Gemini app does not establish support.`
  String get onDeviceAiProviderAndroid {
    return Intl.message(
      'Android uses Gemini Nano through the AICore system service. A Google-supported physical device and a ready model are required. Standard Android emulators are not in the official support list; having Google Play or the Gemini app does not establish support.',
      name: 'onDeviceAiProviderAndroid',
      desc: '',
      args: [],
    );
  }

  /// `This post is too long for the on-device model.`
  String get onDeviceAiRequestTooLarge {
    return Intl.message(
      'This post is too long for the on-device model.',
      name: 'onDeviceAiRequestTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `The on-device model could not complete this request. Try again shortly.`
  String get onDeviceAiRequestFailed {
    return Intl.message(
      'The on-device model could not complete this request. Try again shortly.',
      name: 'onDeviceAiRequestFailed',
      desc: '',
      args: [],
    );
  }

  /// `Checking whether the on-device model is available…`
  String get onDeviceAiChecking {
    return Intl.message(
      'Checking whether the on-device model is available…',
      name: 'onDeviceAiChecking',
      desc: '',
      args: [],
    );
  }

  /// `Waiting up to 15 seconds for Android AICore. This checks availability; it is not a model download.`
  String get onDeviceAiCheckingAndroid {
    return Intl.message(
      'Waiting up to 15 seconds for Android AICore. This checks availability; it is not a model download.',
      name: 'onDeviceAiCheckingAndroid',
      desc: '',
      args: [],
    );
  }

  /// `On-device service did not respond`
  String get onDeviceAiCheckTimeoutTitle {
    return Intl.message(
      'On-device service did not respond',
      name: 'onDeviceAiCheckTimeoutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Android AICore did not return a status within 15 seconds, so model availability is still unknown. Use a supported physical device instead of an emulator. On a physical device, check system and AICore updates, then check again.`
  String get onDeviceAiCheckTimeoutDescription {
    return Intl.message(
      'Android AICore did not return a status within 15 seconds, so model availability is still unknown. Use a supported physical device instead of an emulator. On a physical device, check system and AICore updates, then check again.',
      name: 'onDeviceAiCheckTimeoutDescription',
      desc: '',
      args: [],
    );
  }

  /// `This device or its system configuration has not made the required Gemini Nano model available to this app. This does not mean all ML Kit features are unavailable. Check the official device list. On a supported device, update the system and AICore, stay online while configuration is prepared, then check again.`
  String get onDeviceAiAndroidUnavailable {
    return Intl.message(
      'This device or its system configuration has not made the required Gemini Nano model available to this app. This does not mean all ML Kit features are unavailable. Check the official device list. On a supported device, update the system and AICore, stay online while configuration is prepared, then check again.',
      name: 'onDeviceAiAndroidUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `View Google-supported devices ↗`
  String get onDeviceAiSupportedDevices {
    return Intl.message(
      'View Google-supported devices ↗',
      name: 'onDeviceAiSupportedDevices',
      desc: '',
      args: [],
    );
  }

  /// `The system model is busy. Wait a little, then check again.`
  String get onDeviceAiServiceBusy {
    return Intl.message(
      'The system model is busy. Wait a little, then check again.',
      name: 'onDeviceAiServiceBusy',
      desc: '',
      args: [],
    );
  }

  /// `The system model usage quota for this app has been reached. Try later; checking again does not reset the quota.`
  String get onDeviceAiBatteryQuota {
    return Intl.message(
      'The system model usage quota for this app has been reached. Try later; checking again does not reset the quota.',
      name: 'onDeviceAiBatteryQuota',
      desc: '',
      args: [],
    );
  }

  /// `The system only allows model use while the app is in the foreground. Keep this app open and try again.`
  String get onDeviceAiForegroundRequired {
    return Intl.message(
      'The system only allows model use while the app is in the foreground. Keep this app open and try again.',
      name: 'onDeviceAiForegroundRequired',
      desc: '',
      args: [],
    );
  }

  /// `Report a problem · GitHub`
  String get reportIssueSettingsTitle {
    return Intl.message(
      'Report a problem · GitHub',
      name: 'reportIssueSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Report a problem · GitHub ↗`
  String get reportIssue {
    return Intl.message(
      'Report a problem · GitHub ↗',
      name: 'reportIssue',
      desc: '',
      args: [],
    );
  }

  /// `If this problem persists, open a GitHub issue describing what you did and what happened.`
  String get reportIssueHint {
    return Intl.message(
      'If this problem persists, open a GitHub issue describing what you did and what happened.',
      name: 'reportIssueHint',
      desc: '',
      args: [],
    );
  }

  /// `Could not open a browser. Visit https://github.com/kidozh/discuz_flutter/issues manually.`
  String get reportIssueOpenFailed {
    return Intl.message(
      'Could not open a browser. Visit https://github.com/kidozh/discuz_flutter/issues manually.',
      name: 'reportIssueOpenFailed',
      desc: '',
      args: [],
    );
  }

  /// `Apple Foundation Models`
  String get onDeviceAiNameApple {
    return Intl.message(
      'Apple Foundation Models',
      name: 'onDeviceAiNameApple',
      desc: '',
      args: [],
    );
  }

  /// `Gemini Nano`
  String get onDeviceAiNameAndroid {
    return Intl.message(
      'Gemini Nano',
      name: 'onDeviceAiNameAndroid',
      desc: '',
      args: [],
    );
  }

  /// `Enable Apple Foundation Models`
  String get onDeviceAiEnableApple {
    return Intl.message(
      'Enable Apple Foundation Models',
      name: 'onDeviceAiEnableApple',
      desc: '',
      args: [],
    );
  }

  /// `Enable Gemini Nano`
  String get onDeviceAiEnableAndroid {
    return Intl.message(
      'Enable Gemini Nano',
      name: 'onDeviceAiEnableAndroid',
      desc: '',
      args: [],
    );
  }

  /// `Game`
  String get steamTypeGame {
    return Intl.message('Game', name: 'steamTypeGame', desc: '', args: []);
  }

  /// `DLC`
  String get steamTypeDlc {
    return Intl.message('DLC', name: 'steamTypeDlc', desc: '', args: []);
  }

  /// `Soundtrack / Music`
  String get steamTypeMusic {
    return Intl.message(
      'Soundtrack / Music',
      name: 'steamTypeMusic',
      desc: '',
      args: [],
    );
  }

  /// `Demo`
  String get steamTypeDemo {
    return Intl.message('Demo', name: 'steamTypeDemo', desc: '', args: []);
  }

  /// `Software`
  String get steamTypeSoftware {
    return Intl.message(
      'Software',
      name: 'steamTypeSoftware',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get steamTypeVideo {
    return Intl.message('Video', name: 'steamTypeVideo', desc: '', args: []);
  }

  /// `Steam content`
  String get steamTypeOther {
    return Intl.message(
      'Steam content',
      name: 'steamTypeOther',
      desc: '',
      args: [],
    );
  }

  /// `Related game: {name}`
  String steamParentApp(String name) {
    return Intl.message(
      'Related game: $name',
      name: 'steamParentApp',
      desc: '',
      args: [name],
    );
  }

  /// `See Steam for pricing`
  String get steamPriceUnavailable {
    return Intl.message(
      'See Steam for pricing',
      name: 'steamPriceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get steamComingSoon {
    return Intl.message(
      'Coming soon',
      name: 'steamComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Saved passwords are unavailable. Existing data has been preserved. You can enter your account and password manually.`
  String get savedPasswordsUnavailable {
    return Intl.message(
      'Saved passwords are unavailable. Existing data has been preserved. You can enter your account and password manually.',
      name: 'savedPasswordsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Login can continue, but the password could not be saved.`
  String get passwordSaveFailed {
    return Intl.message(
      'Login can continue, but the password could not be saved.',
      name: 'passwordSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Saved passwords could not be read`
  String get passwordRecoveryTitle {
    return Intl.message(
      'Saved passwords could not be read',
      name: 'passwordRecoveryTitle',
      desc: '',
      args: [],
    );
  }

  /// `The local password store is damaged or its encryption key is unavailable. Create an empty password store and save your passwords again. The old encrypted data will be kept.`
  String get passwordRecoveryMessage {
    return Intl.message(
      'The local password store is damaged or its encryption key is unavailable. Create an empty password store and save your passwords again. The old encrypted data will be kept.',
      name: 'passwordRecoveryMessage',
      desc: '',
      args: [],
    );
  }

  /// `Create new store`
  String get passwordRecoveryCreate {
    return Intl.message(
      'Create new store',
      name: 'passwordRecoveryCreate',
      desc: '',
      args: [],
    );
  }

  /// `The local password store is temporarily unavailable. Unlock your device and try again.`
  String get passwordStorageUnavailable {
    return Intl.message(
      'The local password store is temporarily unavailable. Unlock your device and try again.',
      name: 'passwordStorageUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Local private-message data is damaged`
  String get privateMessageRecoveryTitle {
    return Intl.message(
      'Local private-message data is damaged',
      name: 'privateMessageRecoveryTitle',
      desc: '',
      args: [],
    );
  }

  /// `The old encrypted cache could not be migrated. A new cache is ready. Messages will reload from the forum when you open a conversation. The old encrypted data is kept on this device.`
  String get privateMessageRecoveryMessage {
    return Intl.message(
      'The old encrypted cache could not be migrated. A new cache is ready. Messages will reload from the forum when you open a conversation. The old encrypted data is kept on this device.',
      name: 'privateMessageRecoveryMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reward`
  String get specialReward {
    return Intl.message('Reward', name: 'specialReward', desc: '', args: []);
  }

  /// `Reward amount`
  String get specialRewardAmount {
    return Intl.message(
      'Reward amount',
      name: 'specialRewardAmount',
      desc: '',
      args: [],
    );
  }

  /// `View best answer`
  String get specialBestAnswer {
    return Intl.message(
      'View best answer',
      name: 'specialBestAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get specialActivity {
    return Intl.message(
      'Activity',
      name: 'specialActivity',
      desc: '',
      args: [],
    );
  }

  /// `Global rules`
  String get creditGlobalRules {
    return Intl.message(
      'Global rules',
      name: 'creditGlobalRules',
      desc: '',
      args: [],
    );
  }

  /// `Maximum replies per member: {count}`
  String rushReplyPerMember(int count) {
    return Intl.message(
      'Maximum replies per member: $count',
      name: 'rushReplyPerMember',
      desc: '',
      args: [count],
    );
  }

  /// `Rules`
  String get creditRules {
    return Intl.message('Rules', name: 'creditRules', desc: '', args: []);
  }

  /// `In favor`
  String get debateAffirm {
    return Intl.message('In favor', name: 'debateAffirm', desc: '', args: []);
  }

  /// `Against`
  String get debateAgainst {
    return Intl.message('Against', name: 'debateAgainst', desc: '', args: []);
  }

  /// `{count, plural, =1{1 vote} other{{count} votes}}`
  String debateVoteCount(int count) {
    return Intl.plural(
      count,
      one: '1 vote',
      other: '$count votes',
      name: 'debateVoteCount',
      desc: '',
      args: [count],
    );
  }

  /// `Judge’s verdict`
  String get debateVerdict {
    return Intl.message(
      'Judge’s verdict',
      name: 'debateVerdict',
      desc: '',
      args: [],
    );
  }

  /// `Mention a friend`
  String get mentionFriend {
    return Intl.message(
      'Mention a friend',
      name: 'mentionFriend',
      desc: '',
      args: [],
    );
  }

  /// `Reward per reply`
  String get rewardPerReply {
    return Intl.message(
      'Reward per reply',
      name: 'rewardPerReply',
      desc: '',
      args: [],
    );
  }

  /// `Number of rewards`
  String get rewardPortions {
    return Intl.message(
      'Number of rewards',
      name: 'rewardPortions',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get rewardFee {
    return Intl.message('Fee', name: 'rewardFee', desc: '', args: []);
  }

  /// `Remove reply rewards`
  String get removeReplyReward {
    return Intl.message(
      'Remove reply rewards',
      name: 'removeReplyReward',
      desc: '',
      args: [],
    );
  }

  /// `Reply rewards are unavailable for this account or forum.`
  String get replyRewardUnavailable {
    return Intl.message(
      'Reply rewards are unavailable for this account or forum.',
      name: 'replyRewardUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Reply rewards`
  String get replyCreditTitle {
    return Intl.message(
      'Reply rewards',
      name: 'replyCreditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reward per eligible reply: {amount} {credit}`
  String replyCreditEach(int amount, String credit) {
    return Intl.message(
      'Reward per eligible reply: $amount $credit',
      name: 'replyCreditEach',
      desc: '',
      args: [amount, credit],
    );
  }

  /// `Rewards remaining: {count}`
  String replyCreditRemaining(int count) {
    return Intl.message(
      'Rewards remaining: $count',
      name: 'replyCreditRemaining',
      desc: '',
      args: [count],
    );
  }

  /// `Maximum per member: {count}`
  String replyCreditPerMember(int count) {
    return Intl.message(
      'Maximum per member: $count',
      name: 'replyCreditPerMember',
      desc: '',
      args: [count],
    );
  }

  /// `Chance of receiving a reward: {percent}%`
  String replyCreditChance(int percent) {
    return Intl.message(
      'Chance of receiving a reward: $percent%',
      name: 'replyCreditChance',
      desc: '',
      args: [percent],
    );
  }

  /// `Reply reward +{amount}`
  String replyCreditReceived(int amount) {
    return Intl.message(
      'Reply reward +$amount',
      name: 'replyCreditReceived',
      desc: '',
      args: [amount],
    );
  }

  /// `Rush replies`
  String get rushReplyTitle {
    return Intl.message(
      'Rush replies',
      name: 'rushReplyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Winning floor`
  String get rushReplyWinningFloor {
    return Intl.message(
      'Winning floor',
      name: 'rushReplyWinningFloor',
      desc: '',
      args: [],
    );
  }

  /// `Winning floors`
  String get rushReplyRewardFloors {
    return Intl.message(
      'Winning floors',
      name: 'rushReplyRewardFloors',
      desc: '',
      args: [],
    );
  }

  /// `Closes at floor {floor}`
  String rushReplyStopFloor(int floor) {
    return Intl.message(
      'Closes at floor $floor',
      name: 'rushReplyStopFloor',
      desc: '',
      args: [floor],
    );
  }

  /// `Minimum credits`
  String get rushReplyMinimum {
    return Intl.message(
      'Minimum credits',
      name: 'rushReplyMinimum',
      desc: '',
      args: [],
    );
  }

  /// `Starts in {time}`
  String rushReplyStartsIn(String time) {
    return Intl.message(
      'Starts in $time',
      name: 'rushReplyStartsIn',
      desc: '',
      args: [time],
    );
  }

  /// `Ends in {time}`
  String rushReplyEndsIn(String time) {
    return Intl.message(
      'Ends in $time',
      name: 'rushReplyEndsIn',
      desc: '',
      args: [time],
    );
  }

  /// `Classified information`
  String get specialClassified {
    return Intl.message(
      'Classified information',
      name: 'specialClassified',
      desc: '',
      args: [],
    );
  }

  /// `View details on website`
  String get specialOpenWebsite {
    return Intl.message(
      'View details on website',
      name: 'specialOpenWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get activityPlace {
    return Intl.message('Location', name: 'activityPlace', desc: '', args: []);
  }

  /// `Starts`
  String get activityStarts {
    return Intl.message('Starts', name: 'activityStarts', desc: '', args: []);
  }

  /// `Ends`
  String get activityEnds {
    return Intl.message('Ends', name: 'activityEnds', desc: '', args: []);
  }

  /// `Applicants`
  String get activityApplicants {
    return Intl.message(
      'Applicants',
      name: 'activityApplicants',
      desc: '',
      args: [],
    );
  }

  /// `Registration credits`
  String get activityCost {
    return Intl.message(
      'Registration credits',
      name: 'activityCost',
      desc: '',
      args: [],
    );
  }

  /// `Registration pending`
  String get activityWaiting {
    return Intl.message(
      'Registration pending',
      name: 'activityWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Registered`
  String get activityJoined {
    return Intl.message(
      'Registered',
      name: 'activityJoined',
      desc: '',
      args: [],
    );
  }

  /// `Registration available`
  String get activityCanJoin {
    return Intl.message(
      'Registration available',
      name: 'activityCanJoin',
      desc: '',
      args: [],
    );
  }

  /// `Registration processed`
  String get activityComplete {
    return Intl.message(
      'Registration processed',
      name: 'activityComplete',
      desc: '',
      args: [],
    );
  }

  /// `Registration closed`
  String get activityClosed {
    return Intl.message(
      'Registration closed',
      name: 'activityClosed',
      desc: '',
      args: [],
    );
  }

  /// `Activity is full`
  String get activityFull {
    return Intl.message(
      'Activity is full',
      name: 'activityFull',
      desc: '',
      args: [],
    );
  }

  /// `Your account cannot create threads in this forum`
  String get postPermissionDenied {
    return Intl.message(
      'Your account cannot create threads in this forum',
      name: 'postPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Your account cannot reply to this thread`
  String get replyPermissionDenied {
    return Intl.message(
      'Your account cannot reply to this thread',
      name: 'replyPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Could not verify posting permission. Please retry.`
  String get postPermissionUnknown {
    return Intl.message(
      'Could not verify posting permission. Please retry.',
      name: 'postPermissionUnknown',
      desc: '',
      args: [],
    );
  }

  /// `This file type is not allowed by the forum`
  String get uploadTypeDenied {
    return Intl.message(
      'This file type is not allowed by the forum',
      name: 'uploadTypeDenied',
      desc: '',
      args: [],
    );
  }

  /// `Daily attachment count exhausted`
  String get uploadCountExhausted {
    return Intl.message(
      'Daily attachment count exhausted',
      name: 'uploadCountExhausted',
      desc: '',
      args: [],
    );
  }

  /// `File exceeds the remaining daily upload quota`
  String get uploadDailySizeExceeded {
    return Intl.message(
      'File exceeds the remaining daily upload quota',
      name: 'uploadDailySizeExceeded',
      desc: '',
      args: [],
    );
  }

  /// `File exceeds the size limit for this type`
  String get uploadFileSizeExceeded {
    return Intl.message(
      'File exceeds the size limit for this type',
      name: 'uploadFileSizeExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Remaining daily quota`
  String get uploadQuotaLabel {
    return Intl.message(
      'Remaining daily quota',
      name: 'uploadQuotaLabel',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited`
  String get uploadUnlimited {
    return Intl.message(
      'Unlimited',
      name: 'uploadUnlimited',
      desc: '',
      args: [],
    );
  }

  /// `Not provided`
  String get uploadQuotaUnknown {
    return Intl.message(
      'Not provided',
      name: 'uploadQuotaUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Allowed types`
  String get uploadTypesLabel {
    return Intl.message(
      'Allowed types',
      name: 'uploadTypesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose file`
  String get selectAttachmentFile {
    return Intl.message(
      'Choose file',
      name: 'selectAttachmentFile',
      desc: '',
      args: [],
    );
  }

  /// `Attachment`
  String get composerAttachmentLabel {
    return Intl.message(
      'Attachment',
      name: 'composerAttachmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remove attachment`
  String get removeComposerAttachment {
    return Intl.message(
      'Remove attachment',
      name: 'removeComposerAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Choose a readable file that is not empty.`
  String get attachmentFileUnreadable {
    return Intl.message(
      'Choose a readable file that is not empty.',
      name: 'attachmentFileUnreadable',
      desc: '',
      args: [],
    );
  }

  /// `Uploading attachment…`
  String get uploadingAttachment {
    return Intl.message(
      'Uploading attachment…',
      name: 'uploadingAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Could not upload the attachment.`
  String get attachmentUploadFailed {
    return Intl.message(
      'Could not upload the attachment.',
      name: 'attachmentUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Could not locate this post. It may have been deleted or restricted.`
  String get postLocateFailed {
    return Intl.message(
      'Could not locate this post. It may have been deleted or restricted.',
      name: 'postLocateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Locating post…`
  String get postLocating {
    return Intl.message(
      'Locating post…',
      name: 'postLocating',
      desc: '',
      args: [],
    );
  }

  /// `Back to full thread`
  String get postReturnThread {
    return Intl.message(
      'Back to full thread',
      name: 'postReturnThread',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get forumConfirm {
    return Intl.message('Confirm', name: 'forumConfirm', desc: '', args: []);
  }

  /// `Sign in to this forum first`
  String get forumSignInRequired {
    return Intl.message(
      'Sign in to this forum first',
      name: 'forumSignInRequired',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance or invalid quote. Refresh and try again.`
  String get forumPurchaseUnavailable {
    return Intl.message(
      'Insufficient balance or invalid quote. Refresh and try again.',
      name: 'forumPurchaseUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Confirm purchase`
  String get forumConfirmPurchase {
    return Intl.message(
      'Confirm purchase',
      name: 'forumConfirmPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get forumPurchasePrice {
    return Intl.message(
      'Price',
      name: 'forumPurchasePrice',
      desc: '',
      args: [],
    );
  }

  /// `Balance after purchase`
  String get forumBalanceAfterPurchase {
    return Intl.message(
      'Balance after purchase',
      name: 'forumBalanceAfterPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Action not completed`
  String get forumActionFailed {
    return Intl.message(
      'Action not completed',
      name: 'forumActionFailed',
      desc: '',
      args: [],
    );
  }

  /// `The submission result is unknown. Refresh to check its status before trying again.`
  String get forumSubmissionUnknown {
    return Intl.message(
      'The submission result is unknown. Refresh to check its status before trying again.',
      name: 'forumSubmissionUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Could not load. Please try again.`
  String get forumLoadFailed {
    return Intl.message(
      'Could not load. Please try again.',
      name: 'forumLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Working…`
  String get forumWorking {
    return Intl.message('Working…', name: 'forumWorking', desc: '', args: []);
  }

  /// `View all comments`
  String get forumAllComments {
    return Intl.message(
      'View all comments',
      name: 'forumAllComments',
      desc: '',
      args: [],
    );
  }

  /// `My replies`
  String get forumMyReplies {
    return Intl.message(
      'My replies',
      name: 'forumMyReplies',
      desc: '',
      args: [],
    );
  }

  /// `My threads`
  String get forumMyThreads {
    return Intl.message(
      'My threads',
      name: 'forumMyThreads',
      desc: '',
      args: [],
    );
  }

  /// `Account changed. Go back and reopen this page.`
  String get forumAccountChanged {
    return Intl.message(
      'Account changed. Go back and reopen this page.',
      name: 'forumAccountChanged',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get forumRefresh {
    return Intl.message('Refresh', name: 'forumRefresh', desc: '', args: []);
  }

  /// `These are threads you replied to. Open a thread to read it.`
  String get forumReplyThreadsHint {
    return Intl.message(
      'These are threads you replied to. Open a thread to read it.',
      name: 'forumReplyThreadsHint',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get forumLoadMore {
    return Intl.message('Load more', name: 'forumLoadMore', desc: '', args: []);
  }

  /// `No content yet`
  String get forumEmpty {
    return Intl.message(
      'No content yet',
      name: 'forumEmpty',
      desc: '',
      args: [],
    );
  }

  /// `All loaded`
  String get forumNoMore {
    return Intl.message('All loaded', name: 'forumNoMore', desc: '', args: []);
  }

  /// `replies`
  String get forumReplies {
    return Intl.message('replies', name: 'forumReplies', desc: '', args: []);
  }

  /// `Like`
  String get forumRecommend {
    return Intl.message('Like', name: 'forumRecommend', desc: '', args: []);
  }

  /// `Liked`
  String get forumRecommended {
    return Intl.message('Liked', name: 'forumRecommended', desc: '', args: []);
  }

  /// `Buy thread`
  String get forumBuyThread {
    return Intl.message(
      'Buy thread',
      name: 'forumBuyThread',
      desc: '',
      args: [],
    );
  }

  /// `Buy attachment`
  String get forumBuyAttachment {
    return Intl.message(
      'Buy attachment',
      name: 'forumBuyAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Purchased`
  String get forumPurchased {
    return Intl.message(
      'Purchased',
      name: 'forumPurchased',
      desc: '',
      args: [],
    );
  }

  /// `Dislike`
  String get forumDisrecommend {
    return Intl.message(
      'Dislike',
      name: 'forumDisrecommend',
      desc: '',
      args: [],
    );
  }

  /// `Disliked`
  String get forumNotRecommended {
    return Intl.message(
      'Disliked',
      name: 'forumNotRecommended',
      desc: '',
      args: [],
    );
  }

  /// `Feedback submitted`
  String get forumFeedbackSent {
    return Intl.message(
      'Feedback submitted',
      name: 'forumFeedbackSent',
      desc: '',
      args: [],
    );
  }

  /// `Could not open the NetEase Cloud Music song link.`
  String get neteaseUnavailable {
    return Intl.message(
      'Could not open the NetEase Cloud Music song link.',
      name: 'neteaseUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Open in NetEase Cloud Music`
  String get neteaseOpenSong {
    return Intl.message(
      'Open in NetEase Cloud Music',
      name: 'neteaseOpenSong',
      desc: '',
      args: [],
    );
  }

  /// `Change avatar`
  String get changeAvatar {
    return Intl.message(
      'Change avatar',
      name: 'changeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Choose image`
  String get chooseAvatar {
    return Intl.message(
      'Choose image',
      name: 'chooseAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Upload avatar`
  String get uploadAvatar {
    return Intl.message(
      'Upload avatar',
      name: 'uploadAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Preview your image, then tap Upload. The forum generates the avatar sizes.`
  String get avatarPreviewHint {
    return Intl.message(
      'Preview your image, then tap Upload. The forum generates the avatar sizes.',
      name: 'avatarPreviewHint',
      desc: '',
      args: [],
    );
  }

  /// `Cannot read this image. Choose an image at least 10×10 pixels and below 20 MB.`
  String get avatarImageInvalid {
    return Intl.message(
      'Cannot read this image. Choose an image at least 10×10 pixels and below 20 MB.',
      name: 'avatarImageInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Avatar upload failed. Please try again.`
  String get avatarUploadFailed {
    return Intl.message(
      'Avatar upload failed. Please try again.',
      name: 'avatarUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Accept as best answer`
  String get selectBestAnswer {
    return Intl.message(
      'Accept as best answer',
      name: 'selectBestAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Accept the reply by {author} as the best answer? This settles the reward and cannot be undone in the app.`
  String confirmBestAnswer(String author) {
    return Intl.message(
      'Accept the reply by $author as the best answer? This settles the reward and cannot be undone in the app.',
      name: 'confirmBestAnswer',
      desc: '',
      args: [author],
    );
  }

  /// `Accepted`
  String get bestAnswerSelected {
    return Intl.message(
      'Accepted',
      name: 'bestAnswerSelected',
      desc: '',
      args: [],
    );
  }

  /// `The reward or reply has changed, or you lack permission. Refresh the thread and try again.`
  String get bestAnswerChanged {
    return Intl.message(
      'The reward or reply has changed, or you lack permission. Refresh the thread and try again.',
      name: 'bestAnswerChanged',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friendList {
    return Intl.message('Friends', name: 'friendList', desc: '', args: []);
  }

  /// `Popular forums`
  String get hotForums {
    return Intl.message(
      'Popular forums',
      name: 'hotForums',
      desc: '',
      args: [],
    );
  }

  /// `Pinned threads`
  String get pinnedThreads {
    return Intl.message(
      'Pinned threads',
      name: 'pinnedThreads',
      desc: '',
      args: [],
    );
  }

  /// `Posts today`
  String get directoryTodayPosts {
    return Intl.message(
      'Posts today',
      name: 'directoryTodayPosts',
      desc: '',
      args: [],
    );
  }

  /// `Add poll`
  String get createPoll {
    return Intl.message('Add poll', name: 'createPoll', desc: '', args: []);
  }

  /// `Edit poll`
  String get editPoll {
    return Intl.message('Edit poll', name: 'editPoll', desc: '', args: []);
  }

  /// `Remove poll`
  String get removePoll {
    return Intl.message('Remove poll', name: 'removePoll', desc: '', args: []);
  }

  /// `One option per line, 2–20 options, up to 80 characters each.`
  String get pollOptionsHint {
    return Intl.message(
      'One option per line, 2–20 options, up to 80 characters each.',
      name: 'pollOptionsHint',
      desc: '',
      args: [],
    );
  }

  /// `Maximum selections (1 for single choice)`
  String get pollChoicesHint {
    return Intl.message(
      'Maximum selections (1 for single choice)',
      name: 'pollChoicesHint',
      desc: '',
      args: [],
    );
  }

  /// `Duration in days (0 for no deadline)`
  String get pollDaysHint {
    return Intl.message(
      'Duration in days (0 for no deadline)',
      name: 'pollDaysHint',
      desc: '',
      args: [],
    );
  }

  /// `Check the options, duplicates, maximum selections and duration.`
  String get pollInvalid {
    return Intl.message(
      'Check the options, duplicates, maximum selections and duration.',
      name: 'pollInvalid',
      desc: '',
      args: [],
    );
  }

  /// `This forum or account cannot create polls, or the permission check failed.`
  String get pollUnavailable {
    return Intl.message(
      'This forum or account cannot create polls, or the permission check failed.',
      name: 'pollUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Moderate thread`
  String get moderateThread {
    return Intl.message(
      'Moderate thread',
      name: 'moderateThread',
      desc: '',
      args: [],
    );
  }

  /// `Pin in this forum`
  String get modStick {
    return Intl.message(
      'Pin in this forum',
      name: 'modStick',
      desc: '',
      args: [],
    );
  }

  /// `Unpin`
  String get modUnstick {
    return Intl.message('Unpin', name: 'modUnstick', desc: '', args: []);
  }

  /// `Mark as digest`
  String get modDigest {
    return Intl.message(
      'Mark as digest',
      name: 'modDigest',
      desc: '',
      args: [],
    );
  }

  /// `Remove digest`
  String get modUndigest {
    return Intl.message(
      'Remove digest',
      name: 'modUndigest',
      desc: '',
      args: [],
    );
  }

  /// `Close thread`
  String get modClose {
    return Intl.message('Close thread', name: 'modClose', desc: '', args: []);
  }

  /// `Reopen thread`
  String get modOpen {
    return Intl.message('Reopen thread', name: 'modOpen', desc: '', args: []);
  }

  /// `Move thread`
  String get modMove {
    return Intl.message('Move thread', name: 'modMove', desc: '', args: []);
  }

  /// `Highlight in bold red`
  String get modHighlight {
    return Intl.message(
      'Highlight in bold red',
      name: 'modHighlight',
      desc: '',
      args: [],
    );
  }

  /// `Remove highlight`
  String get modUnhighlight {
    return Intl.message(
      'Remove highlight',
      name: 'modUnhighlight',
      desc: '',
      args: [],
    );
  }

  /// `Enter a reason and select a destination forum if needed.`
  String get moderationRequired {
    return Intl.message(
      'Enter a reason and select a destination forum if needed.',
      name: 'moderationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get moderationReason {
    return Intl.message('Reason', name: 'moderationReason', desc: '', args: []);
  }

  /// `Destination forum`
  String get moveDestination {
    return Intl.message(
      'Destination forum',
      name: 'moveDestination',
      desc: '',
      args: [],
    );
  }

  /// `No category`
  String get directoryNoType {
    return Intl.message(
      'No category',
      name: 'directoryNoType',
      desc: '',
      args: [],
    );
  }

  /// `Activity registration`
  String get activityRegistration {
    return Intl.message(
      'Activity registration',
      name: 'activityRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Complete all required fields and check the contribution amount.`
  String get activityRequired {
    return Intl.message(
      'Complete all required fields and check the contribution amount.',
      name: 'activityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Join activity`
  String get joinActivity {
    return Intl.message(
      'Join activity',
      name: 'joinActivity',
      desc: '',
      args: [],
    );
  }

  /// `Cancel registration`
  String get cancelActivity {
    return Intl.message(
      'Cancel registration',
      name: 'cancelActivity',
      desc: '',
      args: [],
    );
  }

  /// `Cancel this registration? Any credit refund is determined by the forum.`
  String get cancelActivityHint {
    return Intl.message(
      'Cancel this registration? Any credit refund is determined by the forum.',
      name: 'cancelActivityHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm registration. The forum may deduct the required credits.`
  String get activityPaymentHint {
    return Intl.message(
      'Confirm registration. The forum may deduct the required credits.',
      name: 'activityPaymentHint',
      desc: '',
      args: [],
    );
  }

  /// `Registration credits`
  String get activityCredits {
    return Intl.message(
      'Registration credits',
      name: 'activityCredits',
      desc: '',
      args: [],
    );
  }

  /// `The activity status, costs or fields changed. Refresh and confirm again.`
  String get activityChanged {
    return Intl.message(
      'The activity status, costs or fields changed. Refresh and confirm again.',
      name: 'activityChanged',
      desc: '',
      args: [],
    );
  }

  /// `Specify a contribution amount`
  String get activityContribute {
    return Intl.message(
      'Specify a contribution amount',
      name: 'activityContribute',
      desc: '',
      args: [],
    );
  }

  /// `When off, choose to pay your own expenses.`
  String get activitySelfPay {
    return Intl.message(
      'When off, choose to pay your own expenses.',
      name: 'activitySelfPay',
      desc: '',
      args: [],
    );
  }

  /// `Message / cancellation reason`
  String get activityMessage {
    return Intl.message(
      'Message / cancellation reason',
      name: 'activityMessage',
      desc: '',
      args: [],
    );
  }

  /// `This activity is closed or has fields that need the website. Open the website to continue.`
  String get activityWebsiteRequired {
    return Intl.message(
      'This activity is closed or has fields that need the website. Open the website to continue.',
      name: 'activityWebsiteRequired',
      desc: '',
      args: [],
    );
  }

  /// `Add comment`
  String get postAddComment {
    return Intl.message(
      'Add comment',
      name: 'postAddComment',
      desc: '',
      args: [],
    );
  }

  /// `Write a short comment (up to 200 characters). The forum may apply a shorter limit.`
  String get postCommentHint {
    return Intl.message(
      'Write a short comment (up to 200 characters). The forum may apply a shorter limit.',
      name: 'postCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Commenting is unavailable. Refresh and check your login or continue on the website for verification.`
  String get postCommentUnavailable {
    return Intl.message(
      'Commenting is unavailable. Refresh and check your login or continue on the website for verification.',
      name: 'postCommentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Forums for new threads`
  String get feedForumsTitle {
    return Intl.message(
      'Forums for new threads',
      name: 'feedForumsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Changes save automatically. Newly available forums are selected; previously deselected forums stay off.`
  String get feedForumsHint {
    return Intl.message(
      'Changes save automatically. Newly available forums are selected; previously deselected forums stay off.',
      name: 'feedForumsHint',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get feedSelectAll {
    return Intl.message(
      'Select all',
      name: 'feedSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `Select none`
  String get feedSelectNone {
    return Intl.message(
      'Select none',
      name: 'feedSelectNone',
      desc: '',
      args: [],
    );
  }

  /// `No forums selected. Choose forums in Settings.`
  String get feedNoForums {
    return Intl.message(
      'No forums selected. Choose forums in Settings.',
      name: 'feedNoForums',
      desc: '',
      args: [],
    );
  }

  /// `No popular threads yet`
  String get portalNoHotThreads {
    return Intl.message(
      'No popular threads yet',
      name: 'portalNoHotThreads',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get feedGuest {
    return Intl.message('Guest', name: 'feedGuest', desc: '', args: []);
  }

  /// `Dashboard order`
  String get dashboardOrder {
    return Intl.message(
      'Dashboard order',
      name: 'dashboardOrder',
      desc: '',
      args: [],
    );
  }

  /// `Drag the handles to reorder. Changes save automatically.`
  String get dashboardOrderHint {
    return Intl.message(
      'Drag the handles to reorder. Changes save automatically.',
      name: 'dashboardOrderHint',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get postSupport {
    return Intl.message('Support', name: 'postSupport', desc: '', args: []);
  }

  /// `Supported`
  String get postSupported {
    return Intl.message('Supported', name: 'postSupported', desc: '', args: []);
  }

  /// `Oppose`
  String get postAgainst {
    return Intl.message('Oppose', name: 'postAgainst', desc: '', args: []);
  }

  /// `Opposed`
  String get postOpposed {
    return Intl.message('Opposed', name: 'postOpposed', desc: '', args: []);
  }

  /// `Already voted`
  String get postAlreadyReviewed {
    return Intl.message(
      'Already voted',
      name: 'postAlreadyReviewed',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get postRate {
    return Intl.message('Rate', name: 'postRate', desc: '', args: []);
  }

  /// `Rating options are unavailable. You may lack permission or the site may use a different rating form.`
  String get postRatingUnavailable {
    return Intl.message(
      'Rating options are unavailable. You may lack permission or the site may use a different rating form.',
      name: 'postRatingUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Choose a nonzero score within the allowed range and remaining allowance.`
  String get postRatingInvalid {
    return Intl.message(
      'Choose a nonzero score within the allowed range and remaining allowance.',
      name: 'postRatingInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Rating limits or terms changed. Review them and confirm again.`
  String get postRatingChanged {
    return Intl.message(
      'Rating limits or terms changed. Review them and confirm again.',
      name: 'postRatingChanged',
      desc: '',
      args: [],
    );
  }

  /// `Remaining today`
  String get postRatingRemaining {
    return Intl.message(
      'Remaining today',
      name: 'postRatingRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get postRatingReason {
    return Intl.message('Reason', name: 'postRatingReason', desc: '', args: []);
  }

  /// `Notify author`
  String get postRatingNotify {
    return Intl.message(
      'Notify author',
      name: 'postRatingNotify',
      desc: '',
      args: [],
    );
  }

  /// `View ratings`
  String get postViewRatings {
    return Intl.message(
      'View ratings',
      name: 'postViewRatings',
      desc: '',
      args: [],
    );
  }

  /// `No rating records could be displayed, or this site uses an unsupported format. Use the browser button to view them on the website.`
  String get postRatingsUnavailable {
    return Intl.message(
      'No rating records could be displayed, or this site uses an unsupported format. Use the browser button to view them on the website.',
      name: 'postRatingsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Automatically summarize long posts`
  String get autoSummarizeTitle {
    return Intl.message(
      'Automatically summarize long posts',
      name: 'autoSummarizeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Summarize posts over 500 characters when Apple Intelligence is enabled. The original remains available.`
  String get autoSummarizeDescription {
    return Intl.message(
      'Summarize posts over 500 characters when Apple Intelligence is enabled. The original remains available.',
      name: 'autoSummarizeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Background new-post alerts`
  String get backgroundNewPostsTitle {
    return Intl.message(
      'Background new-post alerts',
      name: 'backgroundNewPostsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checks only when your Android device is idle, battery is not low, and a network is available. The target interval is about one hour; Android may delay checks. Reopen the app after force-stopping it to resume.`
  String get backgroundNewPostsDescription {
    return Intl.message(
      'Checks only when your Android device is idle, battery is not low, and a network is available. The target interval is about one hour; Android may delay checks. Reopen the app after force-stopping it to resume.',
      name: 'backgroundNewPostsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Checks public posts on selected sites as a guest. The first successful check records existing posts; later alerts are deduplicated by thread ID.`
  String get backgroundNewPostsPublicOnly {
    return Intl.message(
      'Checks public posts on selected sites as a guest. The first successful check records existing posts; later alerts are deduplicated by thread ID.',
      name: 'backgroundNewPostsPublicOnly',
      desc: '',
      args: [],
    );
  }

  /// `Monitored forum sites`
  String get backgroundNewPostsSites {
    return Intl.message(
      'Monitored forum sites',
      name: 'backgroundNewPostsSites',
      desc: '',
      args: [],
    );
  }

  /// `Add a forum site first.`
  String get backgroundNewPostsNoSites {
    return Intl.message(
      'Add a forum site first.',
      name: 'backgroundNewPostsNoSites',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one forum site.`
  String get backgroundNewPostsSelectSites {
    return Intl.message(
      'Select at least one forum site.',
      name: 'backgroundNewPostsSelectSites',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for an idle-device check`
  String get backgroundNewPostsWaiting {
    return Intl.message(
      'Waiting for an idle-device check',
      name: 'backgroundNewPostsWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Last successful check: {time}`
  String backgroundNewPostsLastCheck(Object time) {
    return Intl.message(
      'Last successful check: $time',
      name: 'backgroundNewPostsLastCheck',
      desc: '',
      args: [time],
    );
  }

  /// `Last check failed; waiting for the next eligible run`
  String get backgroundNewPostsCheckFailed {
    return Intl.message(
      'Last check failed; waiting for the next eligible run',
      name: 'backgroundNewPostsCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `Allow new-post notifications in system settings.`
  String get backgroundNewPostsPermissionRequired {
    return Intl.message(
      'Allow new-post notifications in system settings.',
      name: 'backgroundNewPostsPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `System notification settings`
  String get backgroundNewPostsSystemSettings {
    return Intl.message(
      'System notification settings',
      name: 'backgroundNewPostsSystemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Could not update background alert settings. Try again.`
  String get backgroundNewPostsLoadFailed {
    return Intl.message(
      'Could not update background alert settings. Try again.',
      name: 'backgroundNewPostsLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `AI summary`
  String get postSummaryTitle {
    return Intl.message(
      'AI summary',
      name: 'postSummaryTitle',
      desc: '',
      args: [],
    );
  }

  /// `AI may err. Check the original.`
  String get postSummaryDisclaimer {
    return Intl.message(
      'AI may err. Check the original.',
      name: 'postSummaryDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Summarizing…`
  String get postSummaryLoading {
    return Intl.message(
      'Summarizing…',
      name: 'postSummaryLoading',
      desc: '',
      args: [],
    );
  }

  /// `Summary failed. Tap to retry.`
  String get postSummaryFailed {
    return Intl.message(
      'Summary failed. Tap to retry.',
      name: 'postSummaryFailed',
      desc: '',
      args: [],
    );
  }

  /// `The text is already in the target language or no different translation was produced.`
  String get translationUnchanged {
    return Intl.message(
      'The text is already in the target language or no different translation was produced.',
      name: 'translationUnchanged',
      desc: '',
      args: [],
    );
  }

  /// `Translating…`
  String get postTranslating {
    return Intl.message(
      'Translating…',
      name: 'postTranslating',
      desc: '',
      args: [],
    );
  }

  /// `Show original`
  String get postShowOriginal {
    return Intl.message(
      'Show original',
      name: 'postShowOriginal',
      desc: '',
      args: [],
    );
  }

  /// `Translate to`
  String get translationLanguage {
    return Intl.message(
      'Translate to',
      name: 'translationLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Device language`
  String get translationAppLanguage {
    return Intl.message(
      'Device language',
      name: 'translationAppLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Hold to choose language`
  String get translationLongPress {
    return Intl.message(
      'Hold to choose language',
      name: 'translationLongPress',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load translation languages. Please try again.`
  String get translationLanguagesFailed {
    return Intl.message(
      'Unable to load translation languages. Please try again.',
      name: 'translationLanguagesFailed',
      desc: '',
      args: [],
    );
  }

  /// `Apple Translation requires a physical device. It is not available in the iOS simulator.`
  String get translationSimulator {
    return Intl.message(
      'Apple Translation requires a physical device. It is not available in the iOS simulator.',
      name: 'translationSimulator',
      desc: '',
      args: [],
    );
  }

  /// `Apple Translation requires iOS 18 or macOS 15 or later.`
  String get translationUnavailable {
    return Intl.message(
      'Apple Translation requires iOS 18 or macOS 15 or later.',
      name: 'translationUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `There is not enough readable text to identify the source language.`
  String get translationSourceUndetected {
    return Intl.message(
      'There is not enough readable text to identify the source language.',
      name: 'translationSourceUndetected',
      desc: '',
      args: [],
    );
  }

  /// `Auto-translate`
  String get autoTranslateTitle {
    return Intl.message(
      'Auto-translate',
      name: 'autoTranslateTitle',
      desc: '',
      args: [],
    );
  }

  /// `New conversation`
  String get aiChatNew {
    return Intl.message(
      'New conversation',
      name: 'aiChatNew',
      desc: '',
      args: [],
    );
  }

  /// `Delete conversation`
  String get aiChatDelete {
    return Intl.message(
      'Delete conversation',
      name: 'aiChatDelete',
      desc: '',
      args: [],
    );
  }

  /// `Delete this conversation and all its messages?`
  String get aiChatDeleteConfirmation {
    return Intl.message(
      'Delete this conversation and all its messages?',
      name: 'aiChatDeleteConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `No conversations yet. Tap + to start a conversation.`
  String get aiChatHistoryEmpty {
    return Intl.message(
      'No conversations yet. Tap + to start a conversation.',
      name: 'aiChatHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load chat history. Please try again.`
  String get aiChatHistoryLoadFailed {
    return Intl.message(
      'Unable to load chat history. Please try again.',
      name: 'aiChatHistoryLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Chat with AI`
  String get aiChatTitle {
    return Intl.message(
      'Chat with AI',
      name: 'aiChatTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start a conversation. Replies are generated on your device and history is saved locally.`
  String get aiChatStart {
    return Intl.message(
      'Start a conversation. Replies are generated on your device and history is saved locally.',
      name: 'aiChatStart',
      desc: '',
      args: [],
    );
  }

  /// `Unable to get a reply. Your message is kept; tap Send to retry.`
  String get aiChatRequestFailed {
    return Intl.message(
      'Unable to get a reply. Your message is kept; tap Send to retry.',
      name: 'aiChatRequestFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unable to save the reply. Tap Send to retry saving.`
  String get aiChatSaveFailed {
    return Intl.message(
      'Unable to save the reply. Tap Send to retry saving.',
      name: 'aiChatSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get aiChatYou {
    return Intl.message('You', name: 'aiChatYou', desc: '', args: []);
  }

  /// `Enable Intelligence with an available model to continue chatting. Saved messages are still available.`
  String get aiChatUnavailable {
    return Intl.message(
      'Enable Intelligence with an available model to continue chatting. Saved messages are still available.',
      name: 'aiChatUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Enter a message`
  String get aiChatInput {
    return Intl.message(
      'Enter a message',
      name: 'aiChatInput',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get aiChatSend {
    return Intl.message('Send', name: 'aiChatSend', desc: '', args: []);
  }

  /// `App and device name`
  String get signatureAppAndDevice {
    return Intl.message(
      'App and device name',
      name: 'signatureAppAndDevice',
      desc: '',
      args: [],
    );
  }

  /// `Device signatures publish your device model or computer name with every post.`
  String get signatureDevicePrivacy {
    return Intl.message(
      'Device signatures publish your device model or computer name with every post.',
      name: 'signatureDevicePrivacy',
      desc: '',
      args: [],
    );
  }

  /// `- Sent via [url=https://discuzhub.kidozh.com/]DisFly[/url] v{version}.`
  String fromAppOnlySignature(String version) {
    return Intl.message(
      '- Sent via [url=https://discuzhub.kidozh.com/]DisFly[/url] v$version.',
      name: 'fromAppOnlySignature',
      desc: '',
      args: [version],
    );
  }

  /// `Show forum name in navigation`
  String get showForumName {
    return Intl.message(
      'Show forum name in navigation',
      name: 'showForumName',
      desc: '',
      args: [],
    );
  }

  /// `Show account name and UID in navigation`
  String get showAccountInfo {
    return Intl.message(
      'Show account name and UID in navigation',
      name: 'showAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Show thread views and replies`
  String get showThreadStats {
    return Intl.message(
      'Show thread views and replies',
      name: 'showThreadStats',
      desc: '',
      args: [],
    );
  }

  /// `Show promoted thread carousel`
  String get showForumCarousel {
    return Intl.message(
      'Show promoted thread carousel',
      name: 'showForumCarousel',
      desc: '',
      args: [],
    );
  }

  /// `Compact promoted thread carousel`
  String get compactForumCarousel {
    return Intl.message(
      'Compact promoted thread carousel',
      name: 'compactForumCarousel',
      desc: '',
      args: [],
    );
  }

  /// `Interface display`
  String get forumDisplaySettingsTitle {
    return Intl.message(
      'Interface display',
      name: 'forumDisplaySettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Merge home navigation and categories`
  String get mergeHomeNavigation {
    return Intl.message(
      'Merge home navigation and categories',
      name: 'mergeHomeNavigation',
      desc: '',
      args: [],
    );
  }

  /// `Move category switching into the home title. Tap the title to choose a category. Off by default.`
  String get mergeHomeNavigationDescription {
    return Intl.message(
      'Move category switching into the home title. Tap the title to choose a category. Off by default.',
      name: 'mergeHomeNavigationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Cookies for images and attachments`
  String get imageCookiePolicyTitle {
    return Intl.message(
      'Cookies for images and attachments',
      name: 'imageCookiePolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Always allow`
  String get imageCookiePolicyAlways {
    return Intl.message(
      'Always allow',
      name: 'imageCookiePolicyAlways',
      desc: '',
      args: [],
    );
  }

  /// `Allow cookies on any site. Each address only receives cookies that apply to it.`
  String get imageCookiePolicyAlwaysDescription {
    return Intl.message(
      'Allow cookies on any site. Each address only receives cookies that apply to it.',
      name: 'imageCookiePolicyAlwaysDescription',
      desc: '',
      args: [],
    );
  }

  /// `Same site`
  String get imageCookiePolicySameSite {
    return Intl.message(
      'Same site',
      name: 'imageCookiePolicySameSite',
      desc: '',
      args: [],
    );
  }

  /// `Share eligible forum cookies with the forum and subdomains of the same site.`
  String get imageCookiePolicySameSiteDescription {
    return Intl.message(
      'Share eligible forum cookies with the forum and subdomains of the same site.',
      name: 'imageCookiePolicySameSiteDescription',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get imageCookiePolicyNever {
    return Intl.message(
      'Never',
      name: 'imageCookiePolicyNever',
      desc: '',
      args: [],
    );
  }

  /// `Load images and attachments without account cookies.`
  String get imageCookiePolicyNeverDescription {
    return Intl.message(
      'Load images and attachments without account cookies.',
      name: 'imageCookiePolicyNeverDescription',
      desc: '',
      args: [],
    );
  }

  /// `Translate with Google`
  String get googleTranslationAction {
    return Intl.message(
      'Translate with Google',
      name: 'googleTranslationAction',
      desc: '',
      args: [],
    );
  }

  /// `Automatic translation powered by Google Translate`
  String get googleTranslationAttribution {
    return Intl.message(
      'Automatic translation powered by Google Translate',
      name: 'googleTranslationAttribution',
      desc: '',
      args: [],
    );
  }

  /// `About Google Translate`
  String get googleTranslationInfoTitle {
    return Intl.message(
      'About Google Translate',
      name: 'googleTranslationInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Android posts are automatically translated by Google Translate on your device. Language packs may need downloading before first use. You can always view the original post.`
  String get googleTranslationInfoBody {
    return Intl.message(
      'Android posts are automatically translated by Google Translate on your device. Language packs may need downloading before first use. You can always view the original post.',
      name: 'googleTranslationInfoBody',
      desc: '',
      args: [],
    );
  }

  /// `Google Translate attribution guidelines`
  String get googleTranslationPolicy {
    return Intl.message(
      'Google Translate attribution guidelines',
      name: 'googleTranslationPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Copy post text`
  String get postCopyText {
    return Intl.message(
      'Copy post text',
      name: 'postCopyText',
      desc: '',
      args: [],
    );
  }

  /// `Post text copied`
  String get postTextCopied {
    return Intl.message(
      'Post text copied',
      name: 'postTextCopied',
      desc: '',
      args: [],
    );
  }

  /// `This post has no text to copy.`
  String get postCopyEmpty {
    return Intl.message(
      'This post has no text to copy.',
      name: 'postCopyEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Image {number}`
  String composerImageLabel(int number) {
    return Intl.message(
      'Image $number',
      name: 'composerImageLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Remove image {number}`
  String removeComposerImage(int number) {
    return Intl.message(
      'Remove image $number',
      name: 'removeComposerImage',
      desc: '',
      args: [number],
    );
  }

  /// `Title keyword`
  String get forumSearchKeyword {
    return Intl.message(
      'Title keyword',
      name: 'forumSearchKeyword',
      desc: '',
      args: [],
    );
  }

  /// `All boards`
  String get forumSearchAllBoards {
    return Intl.message(
      'All boards',
      name: 'forumSearchAllBoards',
      desc: '',
      args: [],
    );
  }

  /// `Search board`
  String get forumSearchBoard {
    return Intl.message(
      'Search board',
      name: 'forumSearchBoard',
      desc: '',
      args: [],
    );
  }

  /// `Complete the forum verification on the website.`
  String get forumSearchVerification {
    return Intl.message(
      'Complete the forum verification on the website.',
      name: 'forumSearchVerification',
      desc: '',
      args: [],
    );
  }

  /// `Manage applications`
  String get activityReview {
    return Intl.message(
      'Manage applications',
      name: 'activityReview',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get activityReviewApprove {
    return Intl.message(
      'Approve',
      name: 'activityReviewApprove',
      desc: '',
      args: [],
    );
  }

  /// `Request more information`
  String get activityReviewReplenish {
    return Intl.message(
      'Request more information',
      name: 'activityReviewReplenish',
      desc: '',
      args: [],
    );
  }

  /// `Notify applicants`
  String get activityReviewNotify {
    return Intl.message(
      'Notify applicants',
      name: 'activityReviewNotify',
      desc: '',
      args: [],
    );
  }

  /// `Reject applications`
  String get activityReviewReject {
    return Intl.message(
      'Reject applications',
      name: 'activityReviewReject',
      desc: '',
      args: [],
    );
  }

  /// `Apply this action to {count} selected applicants?`
  String activityReviewConfirm(int count) {
    return Intl.message(
      'Apply this action to $count selected applicants?',
      name: 'activityReviewConfirm',
      desc: '',
      args: [count],
    );
  }

  /// `Reason or message`
  String get activityReviewReason {
    return Intl.message(
      'Reason or message',
      name: 'activityReviewReason',
      desc: '',
      args: [],
    );
  }

  /// `Enter a message to notify the selected applicants.`
  String get activityReviewReasonRequired {
    return Intl.message(
      'Enter a message to notify the selected applicants.',
      name: 'activityReviewReasonRequired',
      desc: '',
      args: [],
    );
  }

  /// `The selected applications changed. Refresh and review them again.`
  String get activityReviewChanged {
    return Intl.message(
      'The selected applications changed. Refresh and review them again.',
      name: 'activityReviewChanged',
      desc: '',
      args: [],
    );
  }

  /// `Credit history`
  String get creditHistory {
    return Intl.message(
      'Credit history',
      name: 'creditHistory',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get creditTransactions {
    return Intl.message(
      'Transactions',
      name: 'creditTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Forum rewards`
  String get creditRewards {
    return Intl.message(
      'Forum rewards',
      name: 'creditRewards',
      desc: '',
      args: [],
    );
  }

  /// `Edit post`
  String get editPostTitle {
    return Intl.message('Edit post', name: 'editPostTitle', desc: '', args: []);
  }

  /// `Save changes`
  String get editPostSave {
    return Intl.message(
      'Save changes',
      name: 'editPostSave',
      desc: '',
      args: [],
    );
  }

  /// `This post changed on the forum. Open the latest version before editing.`
  String get editPostChanged {
    return Intl.message(
      'This post changed on the forum. Open the latest version before editing.',
      name: 'editPostChanged',
      desc: '',
      args: [],
    );
  }

  /// `Check the forum page to confirm whether the edit was saved.`
  String get editPostVerify {
    return Intl.message(
      'Check the forum page to confirm whether the edit was saved.',
      name: 'editPostVerify',
      desc: '',
      args: [],
    );
  }

  /// `Existing attachments`
  String get editPostKeepAttachments {
    return Intl.message(
      'Existing attachments',
      name: 'editPostKeepAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Post text and BBCode`
  String get editPostPlainText {
    return Intl.message(
      'Post text and BBCode',
      name: 'editPostPlainText',
      desc: '',
      args: [],
    );
  }

  /// `This editing form requires the forum website.`
  String get editPostUnsupported {
    return Intl.message(
      'This editing form requires the forum website.',
      name: 'editPostUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `The reply draft could not be restored.`
  String get replyDraftRestoreFailed {
    return Intl.message(
      'The reply draft could not be restored.',
      name: 'replyDraftRestoreFailed',
      desc: '',
      args: [],
    );
  }

  /// `The reply draft could not be saved.`
  String get replyDraftSaveFailed {
    return Intl.message(
      'The reply draft could not be saved.',
      name: 'replyDraftSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `A draft attachment is unavailable. Remove it or select the file again.`
  String get replyDraftUploadMissing {
    return Intl.message(
      'A draft attachment is unavailable. Remove it or select the file again.',
      name: 'replyDraftUploadMissing',
      desc: '',
      args: [],
    );
  }

  /// `Enter the post text and a title when required.`
  String get editPostEmpty {
    return Intl.message(
      'Enter the post text and a title when required.',
      name: 'editPostEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get editPostSubject {
    return Intl.message('Title', name: 'editPostSubject', desc: '', args: []);
  }

  /// `Save the post and remove {count} existing attachment(s)?`
  String editPostRemoveConfirm(int count) {
    return Intl.message(
      'Save the post and remove $count existing attachment(s)?',
      name: 'editPostRemoveConfirm',
      desc: '',
      args: [count],
    );
  }

  /// `Poll option {number}`
  String editPostPollOption(int number) {
    return Intl.message(
      'Poll option $number',
      name: 'editPostPollOption',
      desc: '',
      args: [number],
    );
  }

  /// `Maximum votes per person`
  String get editPostPollMaximum {
    return Intl.message(
      'Maximum votes per person',
      name: 'editPostPollMaximum',
      desc: '',
      args: [],
    );
  }

  /// `Days until the poll closes`
  String get editPostPollDays {
    return Intl.message(
      'Days until the poll closes',
      name: 'editPostPollDays',
      desc: '',
      args: [],
    );
  }

  /// `Show results after voting`
  String get editPostPollVisibility {
    return Intl.message(
      'Show results after voting',
      name: 'editPostPollVisibility',
      desc: '',
      args: [],
    );
  }

  /// `Show voter names`
  String get editPostPollVoterList {
    return Intl.message(
      'Show voter names',
      name: 'editPostPollVoterList',
      desc: '',
      args: [],
    );
  }

  /// `The edited post is pending forum moderation.`
  String get editPostModeration {
    return Intl.message(
      'The edited post is pending forum moderation.',
      name: 'editPostModeration',
      desc: '',
      args: [],
    );
  }

  /// `The forum may have removed attachments before the edit finished. Open the forum page to verify the current post.`
  String get editPostAttachmentPartial {
    return Intl.message(
      'The forum may have removed attachments before the edit finished. Open the forum page to verify the current post.',
      name: 'editPostAttachmentPartial',
      desc: '',
      args: [],
    );
  }

  /// `Author username`
  String get searchAuthor {
    return Intl.message(
      'Author username',
      name: 'searchAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Search full text`
  String get searchFullText {
    return Intl.message(
      'Search full text',
      name: 'searchFullText',
      desc: '',
      args: [],
    );
  }

  /// `Time range`
  String get searchTime {
    return Intl.message('Time range', name: 'searchTime', desc: '', args: []);
  }

  /// `Any time`
  String get searchAnyTime {
    return Intl.message('Any time', name: 'searchAnyTime', desc: '', args: []);
  }

  /// `Older than selected time`
  String get searchOlder {
    return Intl.message(
      'Older than selected time',
      name: 'searchOlder',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get searchOrder {
    return Intl.message('Sort by', name: 'searchOrder', desc: '', args: []);
  }

  /// `Last reply`
  String get searchLastPost {
    return Intl.message(
      'Last reply',
      name: 'searchLastPost',
      desc: '',
      args: [],
    );
  }

  /// `Ascending order`
  String get searchAscending {
    return Intl.message(
      'Ascending order',
      name: 'searchAscending',
      desc: '',
      args: [],
    );
  }

  /// `{credits} credits to next level`
  String creditUpgradeRemaining(String credits) {
    return Intl.message(
      '$credits credits to next level',
      name: 'creditUpgradeRemaining',
      desc: '',
      args: [credits],
    );
  }

  /// `Drafts`
  String get draftInbox {
    return Intl.message('Drafts', name: 'draftInbox', desc: '', args: []);
  }

  /// `Choose the original account for this older draft. The forum checks attachment permissions when sending.`
  String get draftChooseAccount {
    return Intl.message(
      'Choose the original account for this older draft. The forum checks attachment permissions when sending.',
      name: 'draftChooseAccount',
      desc: '',
      args: [],
    );
  }

  /// `Older drafts, account unknown`
  String get draftUnknownAccount {
    return Intl.message(
      'Older drafts, account unknown',
      name: 'draftUnknownAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete draft`
  String get draftDelete {
    return Intl.message(
      'Delete draft',
      name: 'draftDelete',
      desc: '',
      args: [],
    );
  }

  /// `Untitled draft`
  String get draftUntitled {
    return Intl.message(
      'Untitled draft',
      name: 'draftUntitled',
      desc: '',
      args: [],
    );
  }

  /// `No drafts yet`
  String get draftEmpty {
    return Intl.message(
      'No drafts yet',
      name: 'draftEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get draftReply {
    return Intl.message('Reply', name: 'draftReply', desc: '', args: []);
  }

  /// `Quoting {author}`
  String draftQuote(String author) {
    return Intl.message(
      'Quoting $author',
      name: 'draftQuote',
      desc: '',
      args: [author],
    );
  }

  /// `Keyword`
  String get searchKeyword {
    return Intl.message('Keyword', name: 'searchKeyword', desc: '', args: []);
  }

  /// `Search scope`
  String get searchScope {
    return Intl.message(
      'Search scope',
      name: 'searchScope',
      desc: '',
      args: [],
    );
  }

  /// `Match in`
  String get searchMatchIn {
    return Intl.message('Match in', name: 'searchMatchIn', desc: '', args: []);
  }

  /// `Titles only`
  String get searchTitleOnly {
    return Intl.message(
      'Titles only',
      name: 'searchTitleOnly',
      desc: '',
      args: [],
    );
  }

  /// `Titles and post text`
  String get searchTitleAndBody {
    return Intl.message(
      'Titles and post text',
      name: 'searchTitleAndBody',
      desc: '',
      args: [],
    );
  }

  /// `Filters and sorting`
  String get searchFiltersSort {
    return Intl.message(
      'Filters and sorting',
      name: 'searchFiltersSort',
      desc: '',
      args: [],
    );
  }

  /// `Narrow the results`
  String get searchNarrowResults {
    return Intl.message(
      'Narrow the results',
      name: 'searchNarrowResults',
      desc: '',
      args: [],
    );
  }

  /// `Arrange the results`
  String get searchArrangeResults {
    return Intl.message(
      'Arrange the results',
      name: 'searchArrangeResults',
      desc: '',
      args: [],
    );
  }

  /// `Any author, or enter a username`
  String get searchAuthorHint {
    return Intl.message(
      'Any author, or enter a username',
      name: 'searchAuthorHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter words to find`
  String get searchKeywordHint {
    return Intl.message(
      'Enter words to find',
      name: 'searchKeywordHint',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchSubmit {
    return Intl.message('Search', name: 'searchSubmit', desc: '', args: []);
  }

  /// `Search on the forum website`
  String get searchWebsite {
    return Intl.message(
      'Search on the forum website',
      name: 'searchWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Search results`
  String get searchResults {
    return Intl.message(
      'Search results',
      name: 'searchResults',
      desc: '',
      args: [],
    );
  }

  /// `Filters changed. Tap Search to update these results.`
  String get searchConditionsChanged {
    return Intl.message(
      'Filters changed. Tap Search to update these results.',
      name: 'searchConditionsChanged',
      desc: '',
      args: [],
    );
  }

  /// `Enter keywords, or filter by an author or time range.`
  String get searchStartHint {
    return Intl.message(
      'Enter keywords, or filter by an author or time range.',
      name: 'searchStartHint',
      desc: '',
      args: [],
    );
  }

  /// `No posts match these conditions. Try other keywords or broader filters.`
  String get searchNoMatches {
    return Intl.message(
      'No posts match these conditions. Try other keywords or broader filters.',
      name: 'searchNoMatches',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get searchDirection {
    return Intl.message(
      'Direction',
      name: 'searchDirection',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get searchNewestFirst {
    return Intl.message(
      'Newest first',
      name: 'searchNewestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Oldest first`
  String get searchOldestFirst {
    return Intl.message(
      'Oldest first',
      name: 'searchOldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Highest first`
  String get searchMostFirst {
    return Intl.message(
      'Highest first',
      name: 'searchMostFirst',
      desc: '',
      args: [],
    );
  }

  /// `Lowest first`
  String get searchFewestFirst {
    return Intl.message(
      'Lowest first',
      name: 'searchFewestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Time boundary`
  String get searchTimeRelation {
    return Intl.message(
      'Time boundary',
      name: 'searchTimeRelation',
      desc: '',
      args: [],
    );
  }

  /// `Within the last {period}`
  String searchRecentPeriod(String period) {
    return Intl.message(
      'Within the last $period',
      name: 'searchRecentPeriod',
      desc: '',
      args: [period],
    );
  }

  /// `More than {period} ago`
  String searchBeforePeriod(String period) {
    return Intl.message(
      'More than $period ago',
      name: 'searchBeforePeriod',
      desc: '',
      args: [period],
    );
  }

  /// `{count} loaded`
  String searchLoadedResults(int count) {
    return Intl.message(
      '$count loaded',
      name: 'searchLoadedResults',
      desc: '',
      args: [count],
    );
  }

  /// `All favorites`
  String get favoriteAllThreads {
    return Intl.message(
      'All favorites',
      name: 'favoriteAllThreads',
      desc: '',
      args: [],
    );
  }

  /// `Updated`
  String get favoriteHasUpdates {
    return Intl.message(
      'Updated',
      name: 'favoriteHasUpdates',
      desc: '',
      args: [],
    );
  }

  /// `No new replies in favorites`
  String get favoriteNoUpdates {
    return Intl.message(
      'No new replies in favorites',
      name: 'favoriteNoUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Continue reading`
  String get favoriteContinueReading {
    return Intl.message(
      'Continue reading',
      name: 'favoriteContinueReading',
      desc: '',
      args: [],
    );
  }

  /// `Latest reply`
  String get favoriteLatestReply {
    return Intl.message(
      'Latest reply',
      name: 'favoriteLatestReply',
      desc: '',
      args: [],
    );
  }

  /// `Thread attachments`
  String get threadAttachments {
    return Intl.message(
      'Thread attachments',
      name: 'threadAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Load more attachments`
  String get threadLoadMoreAttachments {
    return Intl.message(
      'Load more attachments',
      name: 'threadLoadMoreAttachments',
      desc: '',
      args: [],
    );
  }

  /// `No attachments available in this thread`
  String get threadNoAttachments {
    return Intl.message(
      'No attachments available in this thread',
      name: 'threadNoAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Jump to post`
  String get threadJumpToAttachmentPost {
    return Intl.message(
      'Jump to post',
      name: 'threadJumpToAttachmentPost',
      desc: '',
      args: [],
    );
  }

  /// `The forum returned an incomplete favorites list. Pull to retry.`
  String get favoriteSyncIncomplete {
    return Intl.message(
      'The forum returned an incomplete favorites list. Pull to retry.',
      name: 'favoriteSyncIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `Reward status`
  String get forumRewardStatus {
    return Intl.message(
      'Reward status',
      name: 'forumRewardStatus',
      desc: '',
      args: [],
    );
  }

  /// `Solved`
  String get forumRewardSolved {
    return Intl.message(
      'Solved',
      name: 'forumRewardSolved',
      desc: '',
      args: [],
    );
  }

  /// `Unsolved`
  String get forumRewardUnsolved {
    return Intl.message(
      'Unsolved',
      name: 'forumRewardUnsolved',
      desc: '',
      args: [],
    );
  }

  /// `My content`
  String get myContentTitle {
    return Intl.message(
      'My content',
      name: 'myContentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get myContentComments {
    return Intl.message(
      'Comments',
      name: 'myContentComments',
      desc: '',
      args: [],
    );
  }

  /// `Thread status`
  String get myContentStatus {
    return Intl.message(
      'Thread status',
      name: 'myContentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Status: {status}`
  String myContentStatusValue(String status) {
    return Intl.message(
      'Status: $status',
      name: 'myContentStatusValue',
      desc: '',
      args: [status],
    );
  }

  /// `Published`
  String get myContentPublished {
    return Intl.message(
      'Published',
      name: 'myContentPublished',
      desc: '',
      args: [],
    );
  }

  /// `Pending approval`
  String get myContentPending {
    return Intl.message(
      'Pending approval',
      name: 'myContentPending',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get myContentClosed {
    return Intl.message('Closed', name: 'myContentClosed', desc: '', args: []);
  }

  /// `Forum drafts`
  String get myContentServerDrafts {
    return Intl.message(
      'Forum drafts',
      name: 'myContentServerDrafts',
      desc: '',
      args: [],
    );
  }

  /// `This forum has not enabled the My content API.`
  String get myContentUnavailable {
    return Intl.message(
      'This forum has not enabled the My content API.',
      name: 'myContentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Manage multiple threads`
  String get batchModeration {
    return Intl.message(
      'Manage multiple threads',
      name: 'batchModeration',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String modSelected(int count) {
    return Intl.message(
      '$count selected',
      name: 'modSelected',
      desc: '',
      args: [count],
    );
  }

  /// `{count} selected, up to {limit}`
  String modSelectionLimit(int count, int limit) {
    return Intl.message(
      '$count selected, up to $limit',
      name: 'modSelectionLimit',
      desc: '',
      args: [count, limit],
    );
  }

  /// `Change thread category`
  String get modChangeType {
    return Intl.message(
      'Change thread category',
      name: 'modChangeType',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get modAction {
    return Intl.message('Action', name: 'modAction', desc: '', args: []);
  }

  /// `Mark all as read`
  String get markPrivateMessagesRead {
    return Intl.message(
      'Mark all as read',
      name: 'markPrivateMessagesRead',
      desc: '',
      args: [],
    );
  }

  /// `Ignore list and messaging settings`
  String get privateMessageIgnoreList {
    return Intl.message(
      'Ignore list and messaging settings',
      name: 'privateMessageIgnoreList',
      desc: '',
      args: [],
    );
  }

  /// `Delete conversation`
  String get deletePrivateConversation {
    return Intl.message(
      'Delete conversation',
      name: 'deletePrivateConversation',
      desc: '',
      args: [],
    );
  }

  /// `Delete your message history for this conversation?`
  String get deletePrivateConversationConfirm {
    return Intl.message(
      'Delete your message history for this conversation?',
      name: 'deletePrivateConversationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The forum could not complete the action. Refresh to check the conversation.`
  String get privateMessageActionFailed {
    return Intl.message(
      'The forum could not complete the action. Refresh to check the conversation.',
      name: 'privateMessageActionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Thread collections`
  String get forumCollections {
    return Intl.message(
      'Thread collections',
      name: 'forumCollections',
      desc: '',
      args: [],
    );
  }

  /// `My collections`
  String get myForumCollections {
    return Intl.message(
      'My collections',
      name: 'myForumCollections',
      desc: '',
      args: [],
    );
  }

  /// `Browse collections`
  String get browseForumCollections {
    return Intl.message(
      'Browse collections',
      name: 'browseForumCollections',
      desc: '',
      args: [],
    );
  }

  /// `Create a collection`
  String get createForumCollection {
    return Intl.message(
      'Create a collection',
      name: 'createForumCollection',
      desc: '',
      args: [],
    );
  }

  /// `Add to collection`
  String get addToForumCollection {
    return Intl.message(
      'Add to collection',
      name: 'addToForumCollection',
      desc: '',
      args: [],
    );
  }

  /// `Forum tasks`
  String get forumTasks {
    return Intl.message('Forum tasks', name: 'forumTasks', desc: '', args: []);
  }

  /// `Available`
  String get forumTasksAvailable {
    return Intl.message(
      'Available',
      name: 'forumTasksAvailable',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get forumTasksInProgress {
    return Intl.message(
      'In progress',
      name: 'forumTasksInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get forumTasksCompleted {
    return Intl.message(
      'Completed',
      name: 'forumTasksCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Forum medals`
  String get forumMedals {
    return Intl.message(
      'Forum medals',
      name: 'forumMedals',
      desc: '',
      args: [],
    );
  }

  /// `Moderation center`
  String get forumModerationCenter {
    return Intl.message(
      'Moderation center',
      name: 'forumModerationCenter',
      desc: '',
      args: [],
    );
  }

  /// `Threads awaiting approval`
  String get forumModerationThreads {
    return Intl.message(
      'Threads awaiting approval',
      name: 'forumModerationThreads',
      desc: '',
      args: [],
    );
  }

  /// `Replies awaiting approval`
  String get forumModerationReplies {
    return Intl.message(
      'Replies awaiting approval',
      name: 'forumModerationReplies',
      desc: '',
      args: [],
    );
  }

  /// `Reported content`
  String get forumModerationReports {
    return Intl.message(
      'Reported content',
      name: 'forumModerationReports',
      desc: '',
      args: [],
    );
  }

  /// `Thread recycle bin`
  String get forumModerationRecycleBin {
    return Intl.message(
      'Thread recycle bin',
      name: 'forumModerationRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `View voters`
  String get pollVoterList {
    return Intl.message(
      'View voters',
      name: 'pollVoterList',
      desc: '',
      args: [],
    );
  }

  /// `The forum has not made the voter list available for this option.`
  String get pollVotersUnavailable {
    return Intl.message(
      'The forum has not made the voter list available for this option.',
      name: 'pollVotersUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Pricing`
  String get paidPostSettings {
    return Intl.message(
      'Pricing',
      name: 'paidPostSettings',
      desc: '',
      args: [],
    );
  }

  /// `Thread price`
  String get paidThreadPrice {
    return Intl.message(
      'Thread price',
      name: 'paidThreadPrice',
      desc: '',
      args: [],
    );
  }

  /// `Attachment price`
  String get paidPostFilePrice {
    return Intl.message(
      'Attachment price',
      name: 'paidPostFilePrice',
      desc: '',
      args: [],
    );
  }

  /// `Maximum {maximum}. Leave blank or enter 0 to make it free.`
  String paidPostRange(String maximum) {
    return Intl.message(
      'Maximum $maximum. Leave blank or enter 0 to make it free.',
      name: 'paidPostRange',
      desc: '',
      args: [maximum],
    );
  }

  /// `Estimated proceeds per purchase {amount}`
  String paidPostIncome(String amount) {
    return Intl.message(
      'Estimated proceeds per purchase $amount',
      name: 'paidPostIncome',
      desc: '',
      args: [amount],
    );
  }

  /// `Enter whole numbers within the limit. A paid thread must earn credits after fees.`
  String get paidPostInvalid {
    return Intl.message(
      'Enter whole numbers within the limit. A paid thread must earn credits after fees.',
      name: 'paidPostInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Pricing is unavailable for this board.`
  String get paidPostUnavailable {
    return Intl.message(
      'Pricing is unavailable for this board.',
      name: 'paidPostUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Clear pricing`
  String get paidPostClear {
    return Intl.message(
      'Clear pricing',
      name: 'paidPostClear',
      desc: '',
      args: [],
    );
  }

  /// `Switch back to a regular thread or clear pricing in post settings.`
  String get paidPostNeedsOrdinaryThread {
    return Intl.message(
      'Switch back to a regular thread or clear pricing in post settings.',
      name: 'paidPostNeedsOrdinaryThread',
      desc: '',
      args: [],
    );
  }

  /// `The forum pricing rules changed. Review the pricing settings again.`
  String get paidPostRulesChanged {
    return Intl.message(
      'The forum pricing rules changed. Review the pricing settings again.',
      name: 'paidPostRulesChanged',
      desc: '',
      args: [],
    );
  }

  /// `My choice`
  String get pollOwnVoteOption {
    return Intl.message(
      'My choice',
      name: 'pollOwnVoteOption',
      desc: '',
      args: [],
    );
  }

  /// `Vote submitted. The choices could not be saved on this device.`
  String get pollVoteDeviceSaveFailed {
    return Intl.message(
      'Vote submitted. The choices could not be saved on this device.',
      name: 'pollVoteDeviceSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one {1 voter} other {{count} voters}}`
  String pollParticipantCount(int count) {
    return Intl.plural(
      count,
      one: '1 voter',
      other: '$count voters',
      name: 'pollParticipantCount',
      desc: '',
      args: [count],
    );
  }

  /// `Forum announcements`
  String get forumAnnouncements {
    return Intl.message(
      'Forum announcements',
      name: 'forumAnnouncements',
      desc: '',
      args: [],
    );
  }

  /// `The forum has no available announcements.`
  String get forumAnnouncementsUnavailable {
    return Intl.message(
      'The forum has no available announcements.',
      name: 'forumAnnouncementsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Thread tags`
  String get forumThreadTags {
    return Intl.message(
      'Thread tags',
      name: 'forumThreadTags',
      desc: '',
      args: [],
    );
  }

  /// `Tags (comma-separated, up to 5)`
  String get forumThreadTagsHint {
    return Intl.message(
      'Tags (comma-separated, up to 5)',
      name: 'forumThreadTagsHint',
      desc: '',
      args: [],
    );
  }

  /// `Tags for this thread are unavailable.`
  String get threadTagsUnavailable {
    return Intl.message(
      'Tags for this thread are unavailable.',
      name: 'threadTagsUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Use up to 5 tags that meet the forum length and character rules.`
  String get threadTagsInvalid {
    return Intl.message(
      'Use up to 5 tags that meet the forum length and character rules.',
      name: 'threadTagsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Thread moderation history`
  String get threadModerationHistory {
    return Intl.message(
      'Thread moderation history',
      name: 'threadModerationHistory',
      desc: '',
      args: [],
    );
  }

  /// `Thread purchase history`
  String get threadBuyerHistory {
    return Intl.message(
      'Thread purchase history',
      name: 'threadBuyerHistory',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get communityGroups {
    return Intl.message('Groups', name: 'communityGroups', desc: '', args: []);
  }

  /// `Joined groups`
  String get communityJoinedGroups {
    return Intl.message(
      'Joined groups',
      name: 'communityJoinedGroups',
      desc: '',
      args: [],
    );
  }

  /// `Managed groups`
  String get communityManagedGroups {
    return Intl.message(
      'Managed groups',
      name: 'communityManagedGroups',
      desc: '',
      args: [],
    );
  }

  /// `Search groups`
  String get communityGroupSearch {
    return Intl.message(
      'Search groups',
      name: 'communityGroupSearch',
      desc: '',
      args: [],
    );
  }

  /// `Group discussions`
  String get communityGroupThreads {
    return Intl.message(
      'Group discussions',
      name: 'communityGroupThreads',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get communityMembers {
    return Intl.message(
      'Members',
      name: 'communityMembers',
      desc: '',
      args: [],
    );
  }

  /// `Membership requests`
  String get communityGroupRequests {
    return Intl.message(
      'Membership requests',
      name: 'communityGroupRequests',
      desc: '',
      args: [],
    );
  }

  /// `Group settings`
  String get communityManageGroup {
    return Intl.message(
      'Group settings',
      name: 'communityManageGroup',
      desc: '',
      args: [],
    );
  }

  /// `Create a group`
  String get communityCreateGroup {
    return Intl.message(
      'Create a group',
      name: 'communityCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Join group`
  String get communityJoinGroup {
    return Intl.message(
      'Join group',
      name: 'communityJoinGroup',
      desc: '',
      args: [],
    );
  }

  /// `Leave group`
  String get communityLeaveGroup {
    return Intl.message(
      'Leave group',
      name: 'communityLeaveGroup',
      desc: '',
      args: [],
    );
  }

  /// `Following feed`
  String get communityFollowingFeed {
    return Intl.message(
      'Following feed',
      name: 'communityFollowingFeed',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get communityFollowing {
    return Intl.message(
      'Following',
      name: 'communityFollowing',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get communityFollowers {
    return Intl.message(
      'Followers',
      name: 'communityFollowers',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get communityFollowUser {
    return Intl.message(
      'Follow',
      name: 'communityFollowUser',
      desc: '',
      args: [],
    );
  }

  /// `Unfollow`
  String get communityUnfollowUser {
    return Intl.message(
      'Unfollow',
      name: 'communityUnfollowUser',
      desc: '',
      args: [],
    );
  }

  /// `Find users`
  String get communityFindUsers {
    return Intl.message(
      'Find users',
      name: 'communityFindUsers',
      desc: '',
      args: [],
    );
  }

  /// `Request sent`
  String get communityFriendSent {
    return Intl.message(
      'Request sent',
      name: 'communityFriendSent',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get communityAccept {
    return Intl.message('Accept', name: 'communityAccept', desc: '', args: []);
  }

  /// `Ignore`
  String get communityIgnore {
    return Intl.message('Ignore', name: 'communityIgnore', desc: '', args: []);
  }

  /// `My medal history`
  String get communityMyMedals {
    return Intl.message(
      'My medal history',
      name: 'communityMyMedals',
      desc: '',
      args: [],
    );
  }

  /// `Rankings`
  String get communityRankings {
    return Intl.message(
      'Rankings',
      name: 'communityRankings',
      desc: '',
      args: [],
    );
  }

  /// `Portal articles`
  String get communityPortal {
    return Intl.message(
      'Portal articles',
      name: 'communityPortal',
      desc: '',
      args: [],
    );
  }

  /// `Copy RSS feed link`
  String get communityRss {
    return Intl.message(
      'Copy RSS feed link',
      name: 'communityRss',
      desc: '',
      args: [],
    );
  }

  /// `RSS feed link copied`
  String get communityRssCopied {
    return Intl.message(
      'RSS feed link copied',
      name: 'communityRssCopied',
      desc: '',
      args: [],
    );
  }

  /// `Only show original poster`
  String get communityOnlyThreadAuthor {
    return Intl.message(
      'Only show original poster',
      name: 'communityOnlyThreadAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Only show this author`
  String get communityOnlyThisAuthor {
    return Intl.message(
      'Only show this author',
      name: 'communityOnlyThisAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Search history and presets`
  String get savedSearches {
    return Intl.message(
      'Search history and presets',
      name: 'savedSearches',
      desc: '',
      args: [],
    );
  }

  /// `Presets`
  String get searchPresets {
    return Intl.message('Presets', name: 'searchPresets', desc: '', args: []);
  }

  /// `Recent searches`
  String get searchHistory {
    return Intl.message(
      'Recent searches',
      name: 'searchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Clear search history`
  String get clearSearchHistory {
    return Intl.message(
      'Clear search history',
      name: 'clearSearchHistory',
      desc: '',
      args: [],
    );
  }

  /// `No search presets`
  String get noSearchPresets {
    return Intl.message(
      'No search presets',
      name: 'noSearchPresets',
      desc: '',
      args: [],
    );
  }

  /// `No recent searches`
  String get noSearchHistory {
    return Intl.message(
      'No recent searches',
      name: 'noSearchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Save current search as a preset`
  String get saveSearchPreset {
    return Intl.message(
      'Save current search as a preset',
      name: 'saveSearchPreset',
      desc: '',
      args: [],
    );
  }

  /// `Preset name`
  String get searchPresetName {
    return Intl.message(
      'Preset name',
      name: 'searchPresetName',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get removeLocalRecord {
    return Intl.message(
      'Remove',
      name: 'removeLocalRecord',
      desc: '',
      args: [],
    );
  }

  /// `Could not save on this device`
  String get forumLocalSaveFailed {
    return Intl.message(
      'Could not save on this device',
      name: 'forumLocalSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Content filters`
  String get forumContentFilters {
    return Intl.message(
      'Content filters',
      name: 'forumContentFilters',
      desc: '',
      args: [],
    );
  }

  /// `Blocked keywords`
  String get forumBlockedKeywords {
    return Intl.message(
      'Blocked keywords',
      name: 'forumBlockedKeywords',
      desc: '',
      args: [],
    );
  }

  /// `Add blocked keyword`
  String get forumAddBlockedKeyword {
    return Intl.message(
      'Add blocked keyword',
      name: 'forumAddBlockedKeyword',
      desc: '',
      args: [],
    );
  }

  /// `Muted threads`
  String get forumMutedThreads {
    return Intl.message(
      'Muted threads',
      name: 'forumMutedThreads',
      desc: '',
      args: [],
    );
  }

  /// `No muted threads`
  String get forumNoMutedThreads {
    return Intl.message(
      'No muted threads',
      name: 'forumNoMutedThreads',
      desc: '',
      args: [],
    );
  }

  /// `Mute thread`
  String get forumMuteThread {
    return Intl.message(
      'Mute thread',
      name: 'forumMuteThread',
      desc: '',
      args: [],
    );
  }

  /// `Unmute`
  String get forumUnmuteThread {
    return Intl.message(
      'Unmute',
      name: 'forumUnmuteThread',
      desc: '',
      args: [],
    );
  }

  /// `My activities`
  String get forumMyActivities {
    return Intl.message(
      'My activities',
      name: 'forumMyActivities',
      desc: '',
      args: [],
    );
  }

  /// `Organized`
  String get forumActivitiesOrganized {
    return Intl.message(
      'Organized',
      name: 'forumActivitiesOrganized',
      desc: '',
      args: [],
    );
  }

  /// `Signed up`
  String get forumActivitiesJoined {
    return Intl.message(
      'Signed up',
      name: 'forumActivitiesJoined',
      desc: '',
      args: [],
    );
  }

  /// `Attachment downloads`
  String get attachmentDownloadHistory {
    return Intl.message(
      'Attachment downloads',
      name: 'attachmentDownloadHistory',
      desc: '',
      args: [],
    );
  }

  /// `No attachment downloads`
  String get noAttachmentDownloads {
    return Intl.message(
      'No attachment downloads',
      name: 'noAttachmentDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get attachmentDownloadComplete {
    return Intl.message(
      'Downloaded',
      name: 'attachmentDownloadComplete',
      desc: '',
      args: [],
    );
  }

  /// `File is missing. Download it again.`
  String get attachmentLocalFileMissing {
    return Intl.message(
      'File is missing. Download it again.',
      name: 'attachmentLocalFileMissing',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveLocalRecord {
    return Intl.message('Save', name: 'saveLocalRecord', desc: '', args: []);
  }

  /// `Could not open the file`
  String get downloadedFileOpenFailed {
    return Intl.message(
      'Could not open the file',
      name: 'downloadedFileOpenFailed',
      desc: '',
      args: [],
    );
  }

  /// `Member posts`
  String get forumMemberContent {
    return Intl.message(
      'Member posts',
      name: 'forumMemberContent',
      desc: '',
      args: [],
    );
  }

  /// `My participation`
  String get forumMyParticipation {
    return Intl.message(
      'My participation',
      name: 'forumMyParticipation',
      desc: '',
      args: [],
    );
  }

  /// `My polls`
  String get forumMyPolls {
    return Intl.message('My polls', name: 'forumMyPolls', desc: '', args: []);
  }

  /// `My debates`
  String get forumMyDebates {
    return Intl.message(
      'My debates',
      name: 'forumMyDebates',
      desc: '',
      args: [],
    );
  }

  /// `My bounties`
  String get forumMyRewards {
    return Intl.message(
      'My bounties',
      name: 'forumMyRewards',
      desc: '',
      args: [],
    );
  }

  /// `Participated`
  String get forumContentJoined {
    return Intl.message(
      'Participated',
      name: 'forumContentJoined',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get forumRewardOpen {
    return Intl.message('Open', name: 'forumRewardOpen', desc: '', args: []);
  }

  /// `Resolved`
  String get forumRewardResolved {
    return Intl.message(
      'Resolved',
      name: 'forumRewardResolved',
      desc: '',
      args: [],
    );
  }

  /// `Related threads`
  String get forumRelatedThreads {
    return Intl.message(
      'Related threads',
      name: 'forumRelatedThreads',
      desc: '',
      args: [],
    );
  }

  /// `Article comments`
  String get portalArticleComments {
    return Intl.message(
      'Article comments',
      name: 'portalArticleComments',
      desc: '',
      args: [],
    );
  }

  /// `Anonymous`
  String get portalAnonymousComment {
    return Intl.message(
      'Anonymous',
      name: 'portalAnonymousComment',
      desc: '',
      args: [],
    );
  }

  /// `My trades`
  String get forumMyTrades {
    return Intl.message('My trades', name: 'forumMyTrades', desc: '', args: []);
  }

  /// `Sales`
  String get forumTradeSold {
    return Intl.message('Sales', name: 'forumTradeSold', desc: '', args: []);
  }

  /// `Purchases`
  String get forumTradeBought {
    return Intl.message(
      'Purchases',
      name: 'forumTradeBought',
      desc: '',
      args: [],
    );
  }

  /// `Publish forum draft`
  String get publishForumDraft {
    return Intl.message(
      'Publish forum draft',
      name: 'publishForumDraft',
      desc: '',
      args: [],
    );
  }

  /// `Save as forum draft`
  String get saveForumDraft {
    return Intl.message(
      'Save as forum draft',
      name: 'saveForumDraft',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get forumEditProfile {
    return Intl.message(
      'Edit profile',
      name: 'forumEditProfile',
      desc: '',
      args: [],
    );
  }

  /// `Invite friends`
  String get forumInviteFriends {
    return Intl.message(
      'Invite friends',
      name: 'forumInviteFriends',
      desc: '',
      args: [],
    );
  }

  /// `Choose group icon`
  String get forumGroupChangeIcon {
    return Intl.message(
      'Choose group icon',
      name: 'forumGroupChangeIcon',
      desc: '',
      args: [],
    );
  }

  /// `Submitted to the forum`
  String get forumSettingsSaved {
    return Intl.message(
      'Submitted to the forum',
      name: 'forumSettingsSaved',
      desc: '',
      args: [],
    );
  }

  /// `Basic information`
  String get forumProfileBasic {
    return Intl.message(
      'Basic information',
      name: 'forumProfileBasic',
      desc: '',
      args: [],
    );
  }

  /// `Contact details`
  String get forumProfileContact {
    return Intl.message(
      'Contact details',
      name: 'forumProfileContact',
      desc: '',
      args: [],
    );
  }

  /// `Education`
  String get forumProfileEducation {
    return Intl.message(
      'Education',
      name: 'forumProfileEducation',
      desc: '',
      args: [],
    );
  }

  /// `Work`
  String get forumProfileWork {
    return Intl.message('Work', name: 'forumProfileWork', desc: '', args: []);
  }

  /// `Personal information`
  String get forumProfileOther {
    return Intl.message(
      'Personal information',
      name: 'forumProfileOther',
      desc: '',
      args: [],
    );
  }

  /// `The forum settings changed. Refresh and review the fields.`
  String get forumSettingsChanged {
    return Intl.message(
      'The forum settings changed. Refresh and review the fields.',
      name: 'forumSettingsChanged',
      desc: '',
      args: [],
    );
  }

  /// `The forum did not confirm the change. Open the webpage to check before trying again.`
  String get forumSettingsUnconfirmed {
    return Intl.message(
      'The forum did not confirm the change. Open the webpage to check before trying again.',
      name: 'forumSettingsUnconfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Related articles`
  String get portalRelatedArticles {
    return Intl.message(
      'Related articles',
      name: 'portalRelatedArticles',
      desc: '',
      args: [],
    );
  }

  /// `View all comments`
  String get portalAllComments {
    return Intl.message(
      'View all comments',
      name: 'portalAllComments',
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
