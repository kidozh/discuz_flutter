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
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:push/push.dart' as Push;

import '../main.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  String platformName = "";
  GlobalKey<NavigatorState> navigatorKey;

  MyApp(this.platformName, this.navigatorKey);

  _loadPreference(BuildContext context) async{

    String colorName = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness = await UserPreferencesUtils.getInterfaceBrightnessPreference();
    bool useMaterial3 = await UserPreferencesUtils.getMaterial3PropertyPreference();
    bool allowPush = await UserPreferencesUtils.getPushPreference();
    String signature = await UserPreferencesUtils.getSignaturePreference();

    print("Get brightness ${brightness}");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context,listen: false).setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setBrightness(brightness);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setMaterial3(useMaterial3);
    Provider.of<UserPreferenceNotifierProvider>(context,listen: false).allowPush = allowPush;
    Provider.of<UserPreferenceNotifierProvider>(context,listen: false).signature = signature;

  }

  Future<void> _listenToChanges(BuildContext buildContext) async{
    Push.Push.instance.onNotificationTap.listen((data) {
      _handleMessage(data,buildContext);


    });
  }

  Future<void> _handleMessage(Map<String?, Object?> msgData, BuildContext context) async {
    Map<String, dynamic>? data = msgData.cast<String, dynamic>();
    if (data['type'] == 'thread_reply') {
      int tid = int.parse(data["tid"].toString());
      String site_url = data["site_url"].toString();
      int uid = int.parse(data["uid"].toString());
      // find it in discuz or uid
      UserDao _userDao = await AppDatabase.getUserDao();
      DiscuzDao _discuzDao = await AppDatabase.getDiscuzDao();
      Discuz? _discuz = _discuzDao.findDiscuzByHost(site_url);
      if(_discuz!=null){
        User? _user = _userDao.findUsersByDiscuzAndUid(_discuz, uid);
        if(_user != null){
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (context) => ViewThreadSliverPage(_discuz, _user, tid), context: context));
        }
      }


    }
  }


  TargetPlatform? getTargetPlatformByName(String name){
    switch (name){
      case "android": return TargetPlatform.android;
      case "ios": return TargetPlatform.iOS;
    }
    return null;
  }

  bool isUseCupertinoStyle(ThemeNotifierProvider themeNotifierProvider ){
    if(themeNotifierProvider.platformName == "ios"){
      return true;
    }
    if((Platform.isIOS || Platform.isMacOS)&&(themeNotifierProvider.platformName == "")){
      return true;
    }

    return false;

  }

  @override
  Widget build(BuildContext context) {
    _loadPreference(context);
    //_listenToChanges(context);
    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _){
        print("Change brightness ${themeColorEntity.brightness}");

        final systemBrightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
        log("Get system brightness ${systemBrightness} -> Cupertino? ${isCupertino(context)} ${platform(context).name}" );


        final materialTheme = ThemeData(
          useMaterial3: themeColorEntity.useMaterial3,
          brightness: (isUseCupertinoStyle(themeColorEntity) && themeColorEntity.brightness == null)?systemBrightness: themeColorEntity.brightness,

          cupertinoOverrideTheme: CupertinoThemeData(
            primaryColor: themeColorEntity.themeColor,
            brightness: (isUseCupertinoStyle(themeColorEntity) && themeColorEntity.brightness == null)?systemBrightness: themeColorEntity.brightness
          ),


          primarySwatch: themeColorEntity.themeColor,
          primaryColor: themeColorEntity.themeColor,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
              foregroundColor: MaterialStateProperty.all(themeColorEntity.themeColor),
            ),
          ),
        );

        if (Platform.isAndroid) {
          print("Selected color ${themeColorEntity.themeColorName} ${themeColorEntity.themeColor}");

          SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeColorEntity.iconBrightness,
            statusBarBrightness: themeColorEntity.brightness,
            // systemNavigationBarColor: Color(themeColorEntity.themeColor.value),
            // systemNavigationBarIconBrightness: themeColorEntity.brightness
          );
          SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }

        return Theme(
            data: materialTheme,
            child: PlatformProvider(
              initialPlatform: getTargetPlatformByName(initialPlatform),
              settings: PlatformSettingsData(
                iosUsesMaterialWidgets: false,

              ),
              builder: (context){
                return  PlatformApp(
                  //title: S.of(context).appName,
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  material: (_,__)=> MaterialAppData(
                      theme: materialTheme,
                      darkTheme: ThemeData(
                        useMaterial3: themeColorEntity.useMaterial3,
                        primaryColor: themeColorEntity.themeColor,
                        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                        brightness: Brightness.dark,
                      )
                  ),
                  cupertino: (_,__) => CupertinoAppData(
                    theme: CupertinoThemeData(
                      primaryColor: themeColorEntity.themeColor,
                      brightness: (isUseCupertinoStyle(themeColorEntity) && themeColorEntity.brightness == null)?systemBrightness: themeColorEntity.brightness
                      //brightness: systemBrightness == null? Brightness.light: systemBrightness
                    ),

                  ),
                  // localization
                  localizationsDelegates: [
                    S.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  localeResolutionCallback: (locale, _){
                    if(locale!=null){
                      print("Locale ${locale.languageCode},${locale.scriptCode}, ${locale.countryCode}");
                    }
                  },
                  builder: EasyLoading.init(),
                  home: MyHomePage(title: "谈坛"),
                );
              },
            )

        );
      },
    );

  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _showUserDetail = false;
  int _bottomNavigationbarIndex = 0;
  late List<Widget> bodies = [];
  late UserDao _userDao;
  late DiscuzDao _discuzDao;

  //
  List<Discuz> _allDiscuzs = [];


  _MyHomePageState() {
    _queryDiscuzList();
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    // RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    Push.Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data){
      if (data == null) {
        print("App was not launched by tapping a notification");
      } else {
        _handleMessageByPush(data);
        print('Notification tap launched app from terminated state:\n'
            'RemoteMessage: ${data} \n');
      }

    });


    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    // if (initialMessage != null) {
    //   _handleMessage(initialMessage);
    // }
    //
    // // Also handle any interaction when the app is in the background via a
    // // Stream listener
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessageByPush(Map<String?, Object?> message) async {
    Map<String, String> data = message.cast<String, String>();
    if (data['type'] == 'thread_reply' && data.containsKey("tid")) {
      int tid = int.parse(data["tid"]!);
      String site_url = data["site_url"]!;
      int uid = int.parse(data["uid"]!);
      // find it in discuz or uid
      _userDao = await AppDatabase.getUserDao();
      _discuzDao = await AppDatabase.getDiscuzDao();
      Discuz? _discuz = _discuzDao.findDiscuzByHost(site_url);
      if(_discuz!=null){
        User? _user = _userDao.findUsersByDiscuzAndUid(_discuz, uid);
        if(_user != null){
          Navigator.push(
              context,
              platformPageRoute(
                  context: context,
                  builder: (context) => ViewThreadSliverPage(_discuz, _user, tid)));
        }
      }


    }
  }

  @override
  void initState() {
    super.initState();
    _initDb();
    WidgetsBinding.instance.addObserver(this);
    _checkAcceptVersionFlag(context);
    setupInteractedMessage();
  }

  Future<void> _checkAcceptVersionFlag(BuildContext context) async{
    String flag = await UserPreferencesUtils.getAcceptVersionCodeFlag();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    log("get version ${version} and flag: ${flag}");
    if(flag != version){
      // shown
      Navigator.push(
          context,
          platformPageRoute(
              context: context,
              builder: (context) => TestFlightBannerPage()));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

  }

  void _initDb() async {
    _userDao = await AppDatabase.getUserDao();
    _discuzDao = await AppDatabase.getDiscuzDao();
  }

  void _setFirstUserInDiscuz(Discuz discuz) async{
    List<User> userList = await _userDao.findAllUsersByDiscuz(discuz);
    if(userList.isNotEmpty && userList.length > 0){
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(userList.first);
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
        icon:
        (_selecteddiscuz != null && _selecteddiscuz == discuz) ? PlatformIcons(context).checkMarkCircledSolid : Icons.amp_stories,
        color: (_selecteddiscuz != null && _selecteddiscuz == discuz) ? Theme.of(context).primaryColor : Theme.of(context).unselectedWidgetColor,
        text: discuz.siteName,
        onPressed: () async{
          await UserPreferencesUtils.putFirstShowDiscuzPreference(discuz.key.toString());
          setState(() {
            VibrationUtils.vibrateWithClickIfPossible();
            Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                .initDiscuz(discuz);
            // save to user preference

            _setFirstUserInDiscuz(discuz);
            Navigator.of(context).pop();
          });
        },

      ));
    }

    widgetList.add(
      Padding(
        padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
        child: PlatformElevatedButton(
          child: Text(S.of(context).addNewDiscuz, style: TextStyle(color: Theme.of(context).primaryTextTheme.button?.color),),
          color: Theme.of(context).primaryColor,
          onPressed: (){
            VibrationUtils.vibrateWithClickIfPossible();
            Navigator.of(context).pop();
            Navigator.push(
                context,
                platformPageRoute(
                    context: context,
                    builder: (context) => AddDiscuzPage()));
          },
        ),
      )

    );

    if(isCupertino(context)){
      await showPlatformModalSheet(
          context: context, //BuildContext对象
          builder: (BuildContext context) {

            return SimpleDialog(
                title: Text(S.of(context).chooseDiscuz),
                children: widgetList
            );
          });
    }
    else{
      await showPlatformDialog(
          context: context, //BuildContext对象
          builder: (BuildContext context) {

            return SimpleDialog(
                title: Text(S.of(context).chooseDiscuz),
                children: widgetList
            );
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
    String? discuzKey = await UserPreferencesUtils.getFirstShowDiscuzPreference();
    log("recv discuz list ${_allDiscuzs.length} -> selected discuz key ${discuzKey}");
    if(_allDiscuzs.isNotEmpty){
      Discuz selectedDiscuz = _allDiscuzs.first;
      if(discuzKey != null){
        for(var discuz in _allDiscuzs){
          if(discuz.key.toString() == discuzKey){
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
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child){
            if(value.discuz == null){
              return Text(S.of(context).appName);
            }
            else{
              return Column(
                children: [
                  Text(value.discuz!.siteName),
                  if(value.user == null)
                    Text(S.of(context).incognitoTitle,style: TextStyle(fontSize: 12)),
                  if(value.user!= null)
                    Text("${value.user!.username} (${value.user!.uid})",style: TextStyle(fontSize: 12),)
                ],
              );
            }

          },
        ),
        trailingActions: [
          PlatformIconButton(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            onPressed: _triggerSwitchDiscuzDialog,
            icon: Icon(Icons.account_tree, color: Theme.of(context).textTheme.titleSmall?.color,),
          )
        ],
        automaticallyImplyLeading: true,
        leading: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child){
            if(value.discuz == null){
              return Container();
            }
            else{
              return PlatformIconButton(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  onPressed: () async{
                    // open drawer
                    VibrationUtils.vibrateWithClickIfPossible();
                    await Navigator.push(context, platformPageRoute(context:context,builder: (context) => DrawerPage()));
                  },
                  icon: Icon(Icons.menu, color: Theme.of(context).textTheme.titleSmall?.color)
              );
            }
          },
        ),
      ),
      body: [
        if(!Platform.isIOS)
        ExploreWebsitePage(key: ValueKey(0),),
        DiscuzPortalScreen(key: ValueKey(1),),
        //HotThreadScreen(key: ValueKey(2),),
        DashboardScreen(),
        NotificationScreen(key: ValueKey(3),),
        // FavoriteThreadScreen(),
        DiscuzMessageScreen(key: ValueKey(4),)
      ][_bottomNavigationbarIndex],
      bottomNavBar: PlatformNavBar(
        currentIndex: _bottomNavigationbarIndex,
        material: (context,_) => MaterialNavBarData(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor
        ),
        itemChanged: (index){
          setState(() {
            VibrationUtils.vibrateWithClickIfPossible();
            _bottomNavigationbarIndex = index;
          });
        },
        items: [
          if(!Platform.isIOS)
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
              icon: new Icon(AppPlatformIcons(context).discuzNotificationOutlined),
              activeIcon: Icon(AppPlatformIcons(context).discuzNotificationSolid),
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
      material: (_,__) => MaterialScaffoldData(

      ),

    );
  }


}


