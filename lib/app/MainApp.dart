import 'dart:developer';
import 'dart:io';
import 'package:discuz_flutter/page/DrawerPage.dart';
import 'package:discuz_flutter/page/ExclusiveDiscuzPortalPage.dart';
import 'package:discuz_flutter/dialog/SwitchDiscuzDialog.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/ManageAccountPage.dart';
import 'package:discuz_flutter/page/ManageDiscuzPage.dart';
import 'package:discuz_flutter/page/ManageTrustHostPage.dart';
import 'package:discuz_flutter/page/ViewHistoryPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/DiscuzMessageScreen.dart';
import 'package:discuz_flutter/screen/FavoriteThreadScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/SettingPage.dart';

import 'package:discuz_flutter/entity/User.dart';

import '../main.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  String platformName = "";

  MyApp(this.platformName);

  _loadPreference(context) async{

    String colorName = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    double scale = await UserPreferencesUtils.getTypesettingScalePreference();
    Brightness? brightness = await UserPreferencesUtils.getInterfaceBrightnessPreference();

    print("Get brightness ${brightness}");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setPlatformName(platformName);
    Provider.of<TypeSettingNotifierProvider>(context,listen: false).setScalingParameter(scale);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setBrightness(brightness);

  }

  TargetPlatform? getTargetPlatformByName(String name){
    switch (name){
      case "android": return TargetPlatform.android;
      case "ios": return TargetPlatform.iOS;
    }
    return TargetPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    _loadPreference(context);

    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _){
        print("Change brightness ${themeColorEntity.brightness}");
        final materialTheme = ThemeData(
          brightness: themeColorEntity.brightness,
          cupertinoOverrideTheme: CupertinoThemeData(
            primaryColor: themeColorEntity.themeColor,
            brightness: themeColorEntity.brightness
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
                iosUsesMaterialWidgets: true,


              ),
              builder: (context){
                return  PlatformApp(
                  //title: S.of(context).appName,

                  material: (_,__)=> MaterialAppData(

                      theme: materialTheme,
                      darkTheme: ThemeData(
                        primaryColor: themeColorEntity.themeColor,
                        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                        brightness: Brightness.dark,
                      )
                  ),
                  cupertino: (_,__) => CupertinoAppData(
                    theme: CupertinoThemeData(
                      primaryColor: themeColorEntity.themeColor,
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

class _MyHomePageState extends State<MyHomePage> {
  bool _showUserDetail = false;
  int _bottomNavigationbarIndex = 0;
  late List<Widget> bodies = [];
  late UserDao _userDao;
  late DiscuzDao _discuzDao;

  //
  List<Discuz> _allDiscuzs = [];
  Stream<List<Discuz>>? _discuzListStream;


  _MyHomePageState() {
    _queryDiscuzList();
  }

  @override
  void initState() {
    super.initState();
    _initDb();

  }

  void _initDb() async {
    final db = await DBHelper.getAppDb();
    _userDao = db.userDao;
    _discuzDao = db.discuzDao;
  }

  void _setFirstUserInDiscuz(int discuzId) async{
    List<User> userList = await _userDao.findAllUsersByDiscuzId(discuzId);
    if(userList.isNotEmpty && userList.length > 0){
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(userList.first);
    }

  }

  void _triggerSwitchDiscuzDialog() async {
    await _getDiscuzList();
    List<Widget> widgetList = [];
    for (int i = 0; i < _allDiscuzs.length; i++) {
      Discuz discuz = _allDiscuzs[i];
      Discuz? _selecteddiscuz =
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;

      widgetList.add(SimpleDialogItem(
        key: UniqueKey(),
        icon:
        (_selecteddiscuz != null && _selecteddiscuz.id == discuz.id) ? Icons.check_circle : Icons.amp_stories,
        color: (_selecteddiscuz != null && _selecteddiscuz.id == discuz.id) ? Colors.green : Colors.grey,
        text: discuz.siteName,
        onPressed: () {
          setState(() {
            VibrationUtils.vibrateWithClickIfPossible();
            Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                .initDiscuz(discuz);
            _setFirstUserInDiscuz(discuz.id!);
            Navigator.of(context).pop();
          });
        },

      ));
    }

    widgetList.add(SimpleDialogItem(
        key: UniqueKey(),
        icon: Icons.add_box_outlined,
        color: Theme.of(context).primaryColor,
        text: S.of(context).addNewDiscuz,
        onPressed: () {
          VibrationUtils.vibrateWithClickIfPossible();
          Navigator.of(context).pop();
          Navigator.push(
              context,
              platformPageRoute(
                  context: context,
                  builder: (context) => AddDiscuzPage()));
        }));

    await showPlatformDialog<Null>(
        context: context, //BuildContext对象
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(S.of(context).chooseDiscuz), children: widgetList);
        });
  }

  Future<void> _getDiscuzList() async {
    final db = await DBHelper.getAppDb();
    final dao = db.discuzDao;

    _allDiscuzs = await dao.findAllDiscuzs();

  }



  void _queryDiscuzList() async {
    final db = await DBHelper.getAppDb();
    final dao = db.discuzDao;
    setState(() {
      this._discuzListStream = dao.findAllDiscuzStream();
    });

    _allDiscuzs = await dao.findAllDiscuzs();
    log("recv discuz list ${_allDiscuzs.length}");
    if(_allDiscuzs.isNotEmpty){
      setState(() {
        // set
        Provider.of<DiscuzAndUserNotifier>(context, listen: false)
            .initDiscuz(_allDiscuzs.first);
        _setFirstUserInDiscuz(_allDiscuzs.first.id!);
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
            onPressed: _triggerSwitchDiscuzDialog,
            icon: Icon(Icons.account_tree),
          )
        ],
        leading: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child){
            if(value.discuz == null){
              return Container();
            }
            else{
              return PlatformIconButton(
                  onPressed: () async{
                    // open drawer
                    VibrationUtils.vibrateWithClickIfPossible();
                    await Navigator.push(context, platformPageRoute(context:context,builder: (context) => DrawerPage()));
                  },
                  icon: Icon(Icons.menu)
              );
            }
          },
        ),
      ),
      body: [
        ExploreWebsitePage(key: ValueKey(0),),
        DiscuzPortalScreen(key: ValueKey(1),),
        HotThreadScreen(key: ValueKey(2),),
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
          BottomNavigationBarItem(
              icon: new Icon(CupertinoIcons.today),
              //activeIcon: Icon(CupertinoIcons.today),
              label: S.of(context).sitePage),
          BottomNavigationBarItem(
              icon: new Icon(Icons.amp_stories_outlined),
              activeIcon: Icon(Icons.amp_stories),
              label: S.of(context).index),
          BottomNavigationBarItem(
              icon: new Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: S.of(context).dashboard),
          BottomNavigationBarItem(
              icon: new Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: S.of(context).notification),
          // BottomNavigationBarItem(
          //     icon: new Icon(Icons.stars_outlined),
          //     activeIcon: Icon(Icons.stars),
          //     label: S.of(context).favorites),
          BottomNavigationBarItem(
              icon: new Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message_rounded),
              label: S.of(context).chatMessage),
        ],

      ),
      material: (_,__) => MaterialScaffoldData(

      ),

    );
  }
}


