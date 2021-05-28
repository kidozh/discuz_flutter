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

  /// `Discuzhao`
  String get appName {
    return Intl.message(
      'Discuzhao',
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

  /// `Auto load`
  String get autoLoad {
    return Intl.message(
      'Auto load',
      name: 'autoLoad',
      desc: '',
      args: [],
    );
  }

  /// `Automatically refresh the slide to the bottom`
  String get autoLoadDescribe {
    return Intl.message(
      'Automatically refresh the slide to the bottom',
      name: 'autoLoadDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Floating view`
  String get floatView {
    return Intl.message(
      'Floating view',
      name: 'floatView',
      desc: '',
      args: [],
    );
  }

  /// `At the top or bottom view floating on the list`
  String get floatViewDescribe {
    return Intl.message(
      'At the top or bottom view floating on the list',
      name: 'floatViewDescribe',
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

  /// `User Profile with the springback effect`
  String get userProfileDescribe {
    return Intl.message(
      'User Profile with the springback effect',
      name: 'userProfileDescribe',
      desc: '',
      args: [],
    );
  }

  /// `List with AppBar Folding, listener example`
  String get customScrollViewDescribe {
    return Intl.message(
      'List with AppBar Folding, listener example',
      name: 'customScrollViewDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Swiper example, resolve sliding conflicts`
  String get swiperDescribe {
    return Intl.message(
      'Swiper example, resolve sliding conflicts',
      name: 'swiperDescribe',
      desc: '',
      args: [],
    );
  }

  /// `List embed`
  String get listEmbed {
    return Intl.message(
      'List embed',
      name: 'listEmbed',
      desc: '',
      args: [],
    );
  }

  /// `Use the connector to set the Header and Footer positions`
  String get listEmbedDescribe {
    return Intl.message(
      'Use the connector to set the Header and Footer positions',
      name: 'listEmbedDescribe',
      desc: '',
      args: [],
    );
  }

  /// `ios style`
  String get cupertinoDescribe {
    return Intl.message(
      'ios style',
      name: 'cupertinoDescribe',
      desc: '',
      args: [],
    );
  }

  /// `First refresh`
  String get firstRefresh {
    return Intl.message(
      'First refresh',
      name: 'firstRefresh',
      desc: '',
      args: [],
    );
  }

  /// `First refresh widget`
  String get firstRefreshDescribe {
    return Intl.message(
      'First refresh widget',
      name: 'firstRefreshDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Empty widget`
  String get emptyWidget {
    return Intl.message(
      'Empty widget',
      name: 'emptyWidget',
      desc: '',
      args: [],
    );
  }

  /// `Show empty widget when there is no data`
  String get emptyWidgetDescribe {
    return Intl.message(
      'Show empty widget when there is no data',
      name: 'emptyWidgetDescribe',
      desc: '',
      args: [],
    );
  }

  /// `List and Grid consist of TabBarView`
  String get tabViewWidgetDescribe {
    return Intl.message(
      'List and Grid consist of TabBarView',
      name: 'tabViewWidgetDescribe',
      desc: '',
      args: [],
    );
  }

  /// `NestedScrollView example`
  String get nestedScrollViewDescribe {
    return Intl.message(
      'NestedScrollView example',
      name: 'nestedScrollViewDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Second floor`
  String get secondFloor {
    return Intl.message(
      'Second floor',
      name: 'secondFloor',
      desc: '',
      args: [],
    );
  }

  /// `Imitate the second floor of Taobao`
  String get secondFloorDescribe {
    return Intl.message(
      'Imitate the second floor of Taobao',
      name: 'secondFloorDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to second floor`
  String get welcomeToSecondFloor {
    return Intl.message(
      'Welcome to second floor',
      name: 'welcomeToSecondFloor',
      desc: '',
      args: [],
    );
  }

  /// `ScrollBar`
  String get scrollBar {
    return Intl.message(
      'ScrollBar',
      name: 'scrollBar',
      desc: '',
      args: [],
    );
  }

  /// `Add a scroll bar to the list`
  String get scrollBarDescribe {
    return Intl.message(
      'Add a scroll bar to the list',
      name: 'scrollBarDescribe',
      desc: '',
      args: [],
    );
  }

  /// `QQ group`
  String get qqGroup {
    return Intl.message(
      'QQ group',
      name: 'qqGroup',
      desc: '',
      args: [],
    );
  }

  /// `Github`
  String get github {
    return Intl.message(
      'Github',
      name: 'github',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Old`
  String get old {
    return Intl.message(
      'Old',
      name: 'old',
      desc: '',
      args: [],
    );
  }

  /// `Has not the bald`
  String get noBald {
    return Intl.message(
      'Has not the bald',
      name: 'noBald',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `China - HangZhou`
  String get hangzhou {
    return Intl.message(
      'China - HangZhou',
      name: 'hangzhou',
      desc: '',
      args: [],
    );
  }

  /// `China - ChengDu`
  String get chengdu {
    return Intl.message(
      'China - ChengDu',
      name: 'chengdu',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `E-Mail`
  String get email {
    return Intl.message(
      'E-Mail',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Classic`
  String get classic {
    return Intl.message(
      'Classic',
      name: 'classic',
      desc: '',
      args: [],
    );
  }

  /// `Classic and default`
  String get classicDescribe {
    return Intl.message(
      'Classic and default',
      name: 'classicDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Material design, Android style`
  String get materialDescribe {
    return Intl.message(
      'Material design, Android style',
      name: 'materialDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Ball pulse style`
  String get ballPulseDescribe {
    return Intl.message(
      'Ball pulse style',
      name: 'ballPulseDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Popup circle style`
  String get bezierCircleDescribe {
    return Intl.message(
      'Popup circle style',
      name: 'bezierCircleDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Popup HourGlass style`
  String get bezierHourGlassDescribe {
    return Intl.message(
      'Popup HourGlass style',
      name: 'bezierHourGlassDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Golden campus`
  String get phoenixDescribe {
    return Intl.message(
      'Golden campus',
      name: 'phoenixDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Rushing into the sky`
  String get taurusDescribe {
    return Intl.message(
      'Rushing into the sky',
      name: 'taurusDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Flare animation - Space`
  String get spaceDescribe {
    return Intl.message(
      'Flare animation - Space',
      name: 'spaceDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Express balloon`
  String get deliveryDescribe {
    return Intl.message(
      'Express balloon',
      name: 'deliveryDescribe',
      desc: '',
      args: [],
    );
  }

  /// `More style`
  String get moreStyle {
    return Intl.message(
      'More style',
      name: 'moreStyle',
      desc: '',
      args: [],
    );
  }

  /// `Come soon! You can also refer to the source code customization`
  String get moreStyleDescribe {
    return Intl.message(
      'Come soon! You can also refer to the source code customization',
      name: 'moreStyleDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Join the discussion`
  String get joinDiscussion {
    return Intl.message(
      'Join the discussion',
      name: 'joinDiscussion',
      desc: '',
      args: [],
    );
  }

  /// `Join the QQ group 554981921`
  String get joinDiscussionDescribe {
    return Intl.message(
      'Join the QQ group 554981921',
      name: 'joinDiscussionDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Project address`
  String get projectAddress {
    return Intl.message(
      'Project address',
      name: 'projectAddress',
      desc: '',
      args: [],
    );
  }

  /// `Support the author`
  String get supportAuthor {
    return Intl.message(
      'Support the author',
      name: 'supportAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Your support is my biggest motivation`
  String get supportAuthorDescribe {
    return Intl.message(
      'Your support is my biggest motivation',
      name: 'supportAuthorDescribe',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Star project`
  String get star {
    return Intl.message(
      'Star project',
      name: 'star',
      desc: '',
      args: [],
    );
  }

  /// `AliPay`
  String get aliPay {
    return Intl.message(
      'AliPay',
      name: 'aliPay',
      desc: '',
      args: [],
    );
  }

  /// `WeiXin Pay`
  String get weiXinPay {
    return Intl.message(
      'WeiXin Pay',
      name: 'weiXinPay',
      desc: '',
      args: [],
    );
  }

  /// `QQ Pay`
  String get qqPay {
    return Intl.message(
      'QQ Pay',
      name: 'qqPay',
      desc: '',
      args: [],
    );
  }

  /// `PayPal`
  String get payPal {
    return Intl.message(
      'PayPal',
      name: 'payPal',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get noData {
    return Intl.message(
      'No data',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get direction {
    return Intl.message(
      'Direction',
      name: 'direction',
      desc: '',
      args: [],
    );
  }

  /// `List direction`
  String get listDirection {
    return Intl.message(
      'List direction',
      name: 'listDirection',
      desc: '',
      args: [],
    );
  }

  /// `Vertical`
  String get vertical {
    return Intl.message(
      'Vertical',
      name: 'vertical',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal`
  String get horizontal {
    return Intl.message(
      'Horizontal',
      name: 'horizontal',
      desc: '',
      args: [],
    );
  }

  /// `reverse`
  String get reverse {
    return Intl.message(
      'reverse',
      name: 'reverse',
      desc: '',
      args: [],
    );
  }

  /// `List reverse`
  String get listReverse {
    return Intl.message(
      'List reverse',
      name: 'listReverse',
      desc: '',
      args: [],
    );
  }

  /// `Infinite load`
  String get infiniteLoad {
    return Intl.message(
      'Infinite load',
      name: 'infiniteLoad',
      desc: '',
      args: [],
    );
  }

  /// `Slide to bottom trigger loading`
  String get infiniteLoadDescribe {
    return Intl.message(
      'Slide to bottom trigger loading',
      name: 'infiniteLoadDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Control finish`
  String get controlFinish {
    return Intl.message(
      'Control finish',
      name: 'controlFinish',
      desc: '',
      args: [],
    );
  }

  /// `Using Controller to End Asynchronous Tasks`
  String get controlFinishDescribe {
    return Intl.message(
      'Using Controller to End Asynchronous Tasks',
      name: 'controlFinishDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Task independence`
  String get taskIndependence {
    return Intl.message(
      'Task independence',
      name: 'taskIndependence',
      desc: '',
      args: [],
    );
  }

  /// `Refresh and load tasks are not affected by each other`
  String get taskIndependenceDescribe {
    return Intl.message(
      'Refresh and load tasks are not affected by each other',
      name: 'taskIndependenceDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Header float`
  String get headerFloat {
    return Intl.message(
      'Header float',
      name: 'headerFloat',
      desc: '',
      args: [],
    );
  }

  /// `Header is displayed on the list`
  String get headerFloatDescribe {
    return Intl.message(
      'Header is displayed on the list',
      name: 'headerFloatDescribe',
      desc: '',
      args: [],
    );
  }

  /// `vibration`
  String get vibration {
    return Intl.message(
      'vibration',
      name: 'vibration',
      desc: '',
      args: [],
    );
  }

  /// `Triggered vibration feedback`
  String get vibrationDescribe {
    return Intl.message(
      'Triggered vibration feedback',
      name: 'vibrationDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Refresh switch`
  String get refreshSwitch {
    return Intl.message(
      'Refresh switch',
      name: 'refreshSwitch',
      desc: '',
      args: [],
    );
  }

  /// `Whether to turn on refresh`
  String get refreshSwitchDescribe {
    return Intl.message(
      'Whether to turn on refresh',
      name: 'refreshSwitchDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Load switch`
  String get loadSwitch {
    return Intl.message(
      'Load switch',
      name: 'loadSwitch',
      desc: '',
      args: [],
    );
  }

  /// `Whether to turn on load`
  String get loadSwitchDescribe {
    return Intl.message(
      'Whether to turn on load',
      name: 'loadSwitchDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Header linker`
  String get linkHeader {
    return Intl.message(
      'Header linker',
      name: 'linkHeader',
      desc: '',
      args: [],
    );
  }

  /// `Customize Header with linker`
  String get linkHeaderDescribeDescribe {
    return Intl.message(
      'Customize Header with linker',
      name: 'linkHeaderDescribeDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Top bouncing`
  String get topBouncing {
    return Intl.message(
      'Top bouncing',
      name: 'topBouncing',
      desc: '',
      args: [],
    );
  }

  /// `Top can be crossed`
  String get topBouncingDescribe {
    return Intl.message(
      'Top can be crossed',
      name: 'topBouncingDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Bottom bouncing`
  String get bottomBouncing {
    return Intl.message(
      'Bottom bouncing',
      name: 'bottomBouncing',
      desc: '',
      args: [],
    );
  }

  /// `Bottom can be crossed`
  String get bottomBouncingDescribe {
    return Intl.message(
      'Bottom can be crossed',
      name: 'bottomBouncingDescribe',
      desc: '',
      args: [],
    );
  }

  /// `Chat page`
  String get chatPage {
    return Intl.message(
      'Chat page',
      name: 'chatPage',
      desc: '',
      args: [],
    );
  }

  /// `Chat page example`
  String get chatPageDescribe {
    return Intl.message(
      'Chat page example',
      name: 'chatPageDescribe',
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

  /// `Add a new Discuz! forum`
  String get addNewDiscuz {
    return Intl.message(
      'Add a new Discuz! forum',
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

  /// `retry`
  String get retry {
    return Intl.message(
      'retry',
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

  /// `ok`
  String get ok {
    return Intl.message(
      'ok',
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

  /// `Hot`
  String get forumFilterStatusHot {
    return Intl.message(
      'Hot',
      name: 'forumFilterStatusHot',
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
