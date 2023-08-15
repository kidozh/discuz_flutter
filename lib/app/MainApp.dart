import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/dialog/SwitchDiscuzDialog.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/DrawerPage.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/TestFlightBannerPage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/screen/DashboardScreen.dart';
import 'package:discuz_flutter/screen/DiscuzMessageScreen.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:push/push.dart' as Push;

import '../client/PushServiceClient.dart';
import '../main.dart';
import '../provider/SelectedTidNotifierProvider.dart';
import '../screen/TwoPaneEmptyScreen.dart';
import '../utility/NetworkUtils.dart';
import '../utility/TwoPaneScaffold.dart';
import '../utility/TwoPaneUtils.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  String platformName = "";
  GlobalKey<NavigatorState> navigatorKey;

  MyApp(this.platformName, this.navigatorKey);

  _loadPreference(BuildContext context) async {
    String colorName = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness =
        await UserPreferencesUtils.getInterfaceBrightnessPreference();
    bool useMaterial3 =
        await UserPreferencesUtils.getMaterial3PropertyPreference();
    bool allowPush = await UserPreferencesUtils.getPushPreference();
    String signature = await UserPreferencesUtils.getSignaturePreference();

    print("Get brightness ${brightness}");

    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setTheme(colorName);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context, listen: false)
        .setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setBrightness(brightness);
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setMaterial3(useMaterial3);
    Provider.of<UserPreferenceNotifierProvider>(context, listen: false)
        .allowPush = allowPush;
    Provider.of<UserPreferenceNotifierProvider>(context, listen: false)
        .signature = signature;
  }

  TargetPlatform? getTargetPlatformByName(String name) {
    switch (name) {
      case "android":
        return TargetPlatform.android;
      case "ios":
        return TargetPlatform.iOS;
    }
    return null;
  }

  bool isUseCupertinoStyle(ThemeNotifierProvider themeNotifierProvider) {
    if (themeNotifierProvider.platformName == "ios") {
      return true;
    }
    if ((Platform.isIOS || Platform.isMacOS) &&
        (themeNotifierProvider.platformName == "")) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    _loadPreference(context);
    //_listenToChanges(context);
    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _) {
        ThemeMode? themeMode = null;

        final materialThemeDataLight = ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
                seedColor: themeColorEntity.themeColor,
              brightness: Brightness.light,
            ),
            useMaterial3: themeColorEntity.useMaterial3
        );
        final materialThemeDataDark = ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeColorEntity.themeColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: themeColorEntity.useMaterial3
        );
        const darkDefaultCupertinoTheme =
            CupertinoThemeData(brightness: Brightness.dark);
        final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
          materialTheme: materialThemeDataDark.copyWith(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
              textTheme: CupertinoTextThemeData(
                primaryColor: Colors.white,
                navActionTextStyle: darkDefaultCupertinoTheme
                    .textTheme.navActionTextStyle
                    .copyWith(
                  color: const Color(0xF0F9F9F9),
                ),
                navLargeTitleTextStyle: darkDefaultCupertinoTheme
                    .textTheme.navLargeTitleTextStyle
                    .copyWith(color: const Color(0xF0F9F9F9)),
              ),
            ),
          ),
        );
        final cupertinoLightTheme = MaterialBasedCupertinoThemeData(
            materialTheme: materialThemeDataLight);
        // check the system setting
        if (themeColorEntity.brightness == null) {
          themeMode = ThemeMode.system;
        } else if (themeColorEntity.brightness == Brightness.light) {
          themeMode = ThemeMode.light;
        } else if (themeColorEntity.brightness == Brightness.dark) {
          themeMode = ThemeMode.dark;
        } else {
          themeMode = null;
        }

        return PlatformProvider(
          initialPlatform: getTargetPlatformByName(initialPlatform),
          settings: PlatformSettingsData(),
          builder: (context) {
            return PlatformTheme(
                themeMode: themeMode,
                materialLightTheme: materialThemeDataLight,
                materialDarkTheme: materialThemeDataDark,
                cupertinoLightTheme: cupertinoLightTheme,
                cupertinoDarkTheme: cupertinoDarkTheme,
                onThemeModeChanged: (themeMode) {
                  themeMode = themeMode;
                },
                builder: (context) => PlatformApp(
                      //title: S.of(context).appName,
                      navigatorKey: navigatorKey,
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates: [
                        S.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate
                      ],
                      supportedLocales: S.delegate.supportedLocales,
                      builder: EasyLoading.init(),
                      home: MainTwoPanePage(),
                    ));
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, this.onSelectTid})
      : super(key: key);

  final ValueChanged<int>? onSelectTid;

  final String title;

  @override
  _MyHomePageState createState() =>
      _MyHomePageState(onSelectTid: this.onSelectTid);
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final ValueChanged<int>? onSelectTid;

  int _bottomNavigationbarIndex = 0;
  late List<Widget> bodies = [];
  late UserDao _userDao;
  late DiscuzDao _discuzDao;

  //
  List<Discuz> _allDiscuzs = [];

  _MyHomePageState({this.onSelectTid}) {
    _queryDiscuzList();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // change now
    var window = WidgetsBinding.instance.window;
    Provider.of<ThemeNotifierProvider>(context, listen: false)
        .setBrightness(window.platformBrightness);
    //Theme.of(context).brightness = window.platformBrightness;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print("Update token to all applicable discuzes");
    PushServiceUtils.updateTokenToAllApplicableDiscuzes(context);
  }

  StreamSubscription<Map<String?, Object?>>? _onNotificationTap = null;



  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    // RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // Push.Push.instance.notificationTapWhichLaunchedAppFromTerminated
    //     .then((data) {
    //   if (data == null) {
    //     print("App was not launched by tapping a notification");
    //   } else {
    //     _handleMessageByPush(data);
    //     print('Notification tap launched app from terminated state:\n'
    //         'RemoteMessage: ${data} \n');
    //   }
    // });
    //
    // _onNotificationTap = Push.Push.instance.onNotificationTap.listen((event) {
    //   print("Notification tap ${event}");
    //   _handleMessageByPush(event);
    // });
  }

  // Future<void> _handleMessageByPush(Map<String?, Object?> message) async {
  //   Map<String, String> data = message.cast<String, String>();
  //   if (data['type'] == 'thread_reply' && data.containsKey("tid")) {
  //     int tid = int.parse(data["tid"]!);
  //     String site_url = data["site_url"]!;
  //     int uid = int.parse(data["uid"]!);
  //     // find it in discuz or uid
  //     _userDao = await AppDatabase.getUserDao();
  //     _discuzDao = await AppDatabase.getDiscuzDao();
  //     Discuz? _discuz = _discuzDao.findDiscuzByHost(site_url);
  //     if (_discuz != null) {
  //       User? _user = _userDao.findUsersByDiscuzAndUid(_discuz, uid);
  //       if (_user != null) {
  //         Navigator.push(
  //             context,
  //             platformPageRoute(
  //                 context: context,
  //                 builder: (context) =>
  //                     ViewThreadSliverPage(_discuz, _user, tid)));
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _initDb();
    WidgetsBinding.instance.addObserver(this);
    _checkAcceptVersionFlag(context);
    setupInteractedMessage();
  }

  Future<void> _checkAcceptVersionFlag(BuildContext context) async {
    String flag = await UserPreferencesUtils.getAcceptVersionCodeFlag();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    log("get version ${version} and flag: ${flag}");
    if (flag != version) {
      // shown
      Navigator.push(
          context,
          platformPageRoute(
              context: context, builder: (context) => TestFlightBannerPage()));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(_onNotificationTap != null){
      _onNotificationTap!.cancel();
    }
    super.dispose();
  }

  void _initDb() async {
    _userDao = await AppDatabase.getUserDao();
    _discuzDao = await AppDatabase.getDiscuzDao();
  }

  void _setFirstUserInDiscuz(Discuz discuz) async {
    List<User> userList = await _userDao.findAllUsersByDiscuz(discuz);
    if (userList.isNotEmpty && userList.length > 0) {
      Provider.of<DiscuzAndUserNotifier>(context, listen: false)
          .setUser(userList.first);
    }
  }

  Future<void> _triggerSwitchDiscuzDialog() async {
    await _getDiscuzList();
    List<Widget> widgetList = [];
    for (int i = 0; i < _allDiscuzs.length; i++) {
      Discuz discuz = _allDiscuzs[i];
      Discuz? _selecteddiscuz =
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;

      widgetList.add(SimpleDialogItem(
        key: UniqueKey(),
        icon: (_selecteddiscuz != null && _selecteddiscuz == discuz)
            ? PlatformIcons(context).checkMarkCircledSolid
            : Icons.amp_stories,
        color: (_selecteddiscuz != null && _selecteddiscuz == discuz)
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).unselectedWidgetColor,
        text: discuz.siteName,
        onPressed: () async {
          await UserPreferencesUtils.putFirstShowDiscuzPreference(
              discuz.key.toString());
          setState(() {
            VibrationUtils.vibrateWithClickIfPossible();
            Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                .initDiscuz(discuz);
            // save to user preference

            _setFirstUserInDiscuz(discuz);
            if (onSelectTid != null) {
              onSelectTid!(0);
            }
            Navigator.of(context).pop();
          });
        },
      ));
    }

    widgetList.add(Padding(
      padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
      child: PlatformElevatedButton(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Text(S.of(context).addNewDiscuz, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),),
        //color: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () {
          VibrationUtils.vibrateWithClickIfPossible();
          Navigator.of(context).pop();
          Navigator.push(
              context,
              platformPageRoute(
                  context: context, builder: (context) => AddDiscuzPage()));
        },
      ),
    ));

    if (isCupertino(context)) {
      await showPlatformModalSheet(
          context: context, //BuildContext对象
          builder: (BuildContext context) {
            return SimpleDialog(
                title: Text(S.of(context).chooseDiscuz), children: widgetList);
          });
    } else {
      await showPlatformDialog(
          context: context, //BuildContext对象
          builder: (BuildContext context) {
            return SimpleDialog(
                title: Text(S.of(context).chooseDiscuz), children: widgetList);
          });
    }
  }

  Future<void> _getDiscuzList() async {
    final dao = await AppDatabase.getDiscuzDao();

    _allDiscuzs = await dao.findAllDiscuzs();
  }

  void _queryDiscuzList() async {
    final dao = await AppDatabase.getDiscuzDao();

    _allDiscuzs = await dao.findAllDiscuzs();

    // query data
    String? discuzKey =
        await UserPreferencesUtils.getFirstShowDiscuzPreference();
    log("recv discuz list ${_allDiscuzs.length} -> selected discuz key ${discuzKey}");
    if (_allDiscuzs.isNotEmpty) {
      Discuz selectedDiscuz = _allDiscuzs.first;
      if (discuzKey != null) {
        for (var discuz in _allDiscuzs) {
          if (discuz.key.toString() == discuzKey) {
            selectedDiscuz = discuz;
            break;
          }
        }
      }
      setState(() {
        // set
        Provider.of<DiscuzAndUserNotifier>(context, listen: false)
            .initDiscuz(selectedDiscuz);
        _setFirstUserInDiscuz(selectedDiscuz);
      });
    }
  }

  var tabController = PlatformTabController(
    initialIndex: 0,
  );

  @override
  Widget build(BuildContext context) {
    // need to check whether discuz exists in dataset

    return PlatformScaffold(
      //iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child) {
            if (value.discuz == null) {
              return Text(S.of(context).appName);
            } else {
              return Column(
                children: [
                  Text(value.discuz!.siteName),
                  if (value.user == null)
                    Text(S.of(context).incognitoTitle,
                        style: TextStyle(fontSize: 12)),
                  if (value.user != null)
                    Text(
                      "${value.user!.username} (${value.user!.uid})",
                      style: TextStyle(fontSize: 12),
                    )
                ],
              );
            }
          },
        ),
        trailingActions: [
          PlatformIconButton(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            onPressed: _triggerSwitchDiscuzDialog,

            icon: Icon(
              AppPlatformIcons(context).manageDiscuzSolid,
              color: Theme.of(context).textTheme.titleSmall?.color,
              semanticLabel: S.of(context).selectDiscuzIconTooltip,
            ),
          )
        ],
        automaticallyImplyLeading: true,
        leading: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child) {
            if (value.discuz == null) {
              return Container();
            } else {
              return PlatformIconButton(

                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  onPressed: () async {
                    // open drawer
                    VibrationUtils.vibrateWithClickIfPossible();
                    await Navigator.push(
                        context,
                        platformPageRoute(
                            context: context,
                            builder: (context) => DrawerPage()));
                  },
                  icon: Icon(

                      AppPlatformIcons(context).menuSolid,
                      semanticLabel: S.of(context).menuIconTooltip,
                      color: Theme.of(context).textTheme.titleSmall?.color));
            }
          },
        ),
      ),
      body: [
        if (!Platform.isIOS)
          ExploreWebsitePage(
            key: ValueKey(0),
            onSelectTid: this.onSelectTid,
          ),
        // should not exist any
        DiscuzPortalScreen(
          key: ValueKey(1),
        ),
        //HotThreadScreen(key: ValueKey(2),),
        DashboardScreen(
          onSelectTid: onSelectTid,
        ),
        NotificationScreen(
          //key: ValueKey(3),
          onSelectTid: this.onSelectTid,
        ),
        // FavoriteThreadScreen(),
        DiscuzMessageScreen(
          key: ValueKey(4),
        )
      ][_bottomNavigationbarIndex],
      bottomNavBar: PlatformNavBar(
        currentIndex: _bottomNavigationbarIndex,
        material: (context, _) => MaterialNavBarData(
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor),
        itemChanged: (index) {
          setState(() {
            VibrationUtils.vibrateWithClickIfPossible();
            _bottomNavigationbarIndex = index;
          });
        },
        items: [
          if (!Platform.isIOS)
            BottomNavigationBarItem(
                icon: new Icon(AppPlatformIcons(context).discuzSiteOutlined),
                activeIcon: Icon(AppPlatformIcons(context).discuzSiteSolid),
                label: S.of(context).sitePage),
          BottomNavigationBarItem(
              icon: new Icon(AppPlatformIcons(context).discuzPortalOutlined),
              activeIcon: Icon(AppPlatformIcons(context).discuzPortalSolid),
              label: S.of(context).index),
          BottomNavigationBarItem(
              icon: new Icon(AppPlatformIcons(context).discuzExploreOutlined),
              activeIcon: Icon(AppPlatformIcons(context).discuzExploreSolid),
              label: S.of(context).dashboard),
          BottomNavigationBarItem(
              icon: new Icon(
                  AppPlatformIcons(context).discuzNotificationOutlined),
              activeIcon:
                  Icon(AppPlatformIcons(context).discuzNotificationSolid),
              label: S.of(context).notification),
          // BottomNavigationBarItem(
          //     icon: new Icon(Icons.stars_outlined),
          //     activeIcon: Icon(Icons.stars),
          //     label: S.of(context).favorites),
          BottomNavigationBarItem(
              icon: new Icon(AppPlatformIcons(context).discuzMessageOutlined),
              activeIcon: Icon(AppPlatformIcons(context).discuzMessageSolid),
              label: S.of(context).chatMessage),
        ],
      ),
      material: (_, __) => MaterialScaffoldData(),
    );
  }
}

class MainTwoPanePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MainTwoPaneStatefulWidget(
          type: TwoPaneUtils.getTwoPaneType(constraints));
    });
  }
}

class MainTwoPaneStatefulWidget extends StatefulWidget {
  final String restorationId = "DisplayForumTid";
  final TwoPaneType type;

  MainTwoPaneStatefulWidget({super.key, required this.type});

  @override
  State<StatefulWidget> createState() {
    return MainTwoPaneState();
  }
}

class MainTwoPaneState extends State<MainTwoPaneStatefulWidget>
    with RestorationMixin {
  final RestorableInt _currentTid = RestorableInt(0);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentTid, "DisplayForumTid");
  }

  @override
  void dispose() {
    _currentTid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var panePriority = TwoPanePriority.both;
    if (widget.type == TwoPaneType.smallScreen) {
      panePriority =
          _currentTid.value == 0 ? TwoPanePriority.start : TwoPanePriority.end;
      return MyHomePage(title: "");
    }
    double paneProportion = 0.35;
    // directly give
    return OrientationBuilder(builder: (context, orientation) {
      if (widget.type != TwoPaneType.smallScreen &&
          orientation == Orientation.portrait) {
        paneProportion = 0.5;
      }

      return TwoPaneScaffold(
          type: widget.type,
          child: TwoPane(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              paneProportion: paneProportion,
              panePriority: panePriority,
              startPane: MyHomePage(
                title: "",
                onSelectTid: (tid) async {
                  Provider.of<SelectedTidNotifierProvider>(context,
                          listen: false)
                      .setTid(tid);
                  if (tid != _currentTid) {
                    setState(() {
                      _currentTid.value = 0;
                    });
                    // I don't know why it takes time to refresh
                    await Future.delayed(const Duration(milliseconds: 100));
                    setState(() {
                      _currentTid.value = tid;
                      _currentTid.didUpdateValue(tid);
                    });
                    log("Two Pane Changed current tid ${_currentTid.value}");
                  }
                },
              ),
              endPane: _currentTid.value == 0
                  ? TwoPaneEmptyScreen(S.of(context).viewThreadTwoPaneText)
                  : Consumer<DiscuzAndUserNotifier>(
                      builder: (context, discuzAndUser, child) {
                      if (discuzAndUser.discuz != null) {
                        Discuz discuz = discuzAndUser.discuz!;
                        User? user = discuzAndUser.user;
                        return ViewThreadSliverPage(
                          discuz,
                          user,
                          _currentTid.value,
                          onClosed: () {
                            Provider.of<SelectedTidNotifierProvider>(context,
                                    listen: false)
                                .setTid(0);
                            setState(() {
                              _currentTid.value = 0;
                            });
                          },
                        );
                      } else {
                        return Container();
                      }
                    })));
    });
  }
}
