
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/page/PushServicePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as FCM;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:push/push.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client/PushServiceClient.dart';
import '../dao/DiscuzDao.dart';
import '../dao/UserDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../page/ViewThreadSliverPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import 'NetworkUtils.dart';
import 'PostTextFieldUtils.dart';
import 'UserPreferencesUtils.dart';

enum PushChannel{
  fcm,
  apn,
  xmi,
  hms
}

class PushTokenChannel{
  String token;
  PushChannel channel;
  String deviceName;
  String packageId;

  PushTokenChannel(this.token, this.channel, this.deviceName, this.packageId);

  String get channelName{
    switch(this.channel){
      case PushChannel.fcm: return "FCM";
      case PushChannel.apn: return "APN";
      case PushChannel.xmi: return "XMI";
      case PushChannel.hms: return "HMS";
    }
  }

  String getLocalizedChannelName(BuildContext context){
    switch(this.channel){
      case PushChannel.fcm: return S.of(context).pushChannelFCM;
      case PushChannel.apn: return S.of(context).pushChannelAPN;
      case PushChannel.xmi: return S.of(context).pushChannelXMI;
      case PushChannel.hms: return S.of(context).pushChannelHMS;
    }
  }
}

class PushServiceUtils{

  static Future<PushTokenChannel?> getPushToken(BuildContext context) async{
    String deviceName = await PostTextFieldUtils.getDeviceName(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageId = packageInfo.packageName;

    try{
      FCM.FirebaseMessaging messaging = FCM.FirebaseMessaging.instance;
      // try to get APNs before
      String? fetchedToken = null;
      if(Platform.isIOS){

        String? apnsToken = await messaging.getAPNSToken();
        print("Get APNS token ${apnsToken}");
        if(apnsToken == null){
          return null;
        }
        else{
          return PushTokenChannel(apnsToken, PushChannel.apn, deviceName, packageId);
        }

      }
      else{
        fetchedToken = await messaging.getToken();
        if(fetchedToken == null){
          return null;
        }
        else{
          return PushTokenChannel(fetchedToken, PushChannel.fcm, deviceName, packageId);
        }
      }

    }
    catch (e){
      return null;
    }
  }

  static Future<void> updateTokenToAllApplicableDiscuzes(BuildContext context) async{
    final discuzDao = await AppDatabase.getDiscuzDao();
    final userDao = await AppDatabase.getUserDao();
    List<Discuz> allDiscuzList = await discuzDao.findAllDiscuzs();
    PushTokenChannel? pushTokenChannel = await getPushToken(context);
    if(pushTokenChannel != null){
      // traverse it one by one
      for(var discuz in allDiscuzList){
        // check with availability of push service
        bool pushEnabled = await getDiscuzPushPluginEnabled(discuz);
        if(pushEnabled){
          print("Update discuz push enabled ${discuz.baseURL}");
          List<User> userList = userDao.findAllUsersByDiscuz(discuz);
          // update all
          for(var user in userList){
            Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
            MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);
            // need to get formhash first
            client.getPushTokenListResult().then((value){
              // obtained data
              print("Update token to user successful ${user.username} ${discuz.baseURL} ${value.formhash}");
              client.sendToken(value.formhash, pushTokenChannel.token, pushTokenChannel.deviceName, pushTokenChannel.packageId, pushTokenChannel.channelName).then((value) async {
                if(value.result =="success"){
                  await putDiscuzPushPluginEnabled(discuz, true);
                }
              });
            });
          }
        }
        else{

        }
      }
    }

    // prepare to interact with dhpush
    bool allowPush = await UserPreferencesUtils.getPushPreference();
    bool shouldSendTokenToDhServer = await UserPreferencesUtils.shouldSendTokenToDHPushServer();
    if(allowPush && shouldSendTokenToDhServer){
      print("Interact with DHPUSH to update subscription information");
      _sendSubscriptionToDhPush(context);

    }

  }

  static Future<void> _sendSubscriptionToDhPush(BuildContext context) async{
    String pushServerBaseUrl = "https://dhp.kidozh.com";

    final dio = await NetworkUtils.getDioWithPersistCookieJar(null);
    final client = PushServiceClient(dio, baseUrl: pushServerBaseUrl);
    PushTokenChannel? pushTokenChannel = await PushServiceUtils.getPushToken(context);
    if(pushTokenChannel != null){
      String token = pushTokenChannel.token;
      String pushPlatform = pushTokenChannel.channelName;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageId = packageInfo.packageName;
      List<String> subscribedIdList = await UserPreferencesUtils.getSubscribedChannelList();
      if(subscribedIdList.isEmpty){
        return;
      }
      await UserPreferencesUtils.putLastPushSecond();
      client
          .changeSubscribeChannelByHost(
          "", token, subscribedIdList, [], packageId, pushPlatform)
          .then((value) {

      });
    }

  }

  static Future<void> initPushInformation(GlobalKey<NavigatorState> navigatorKey) async {
    print("Initialize push settings");
    Push.instance.onNewToken.listen((token) {
      print("Just got a new FCM registration token: ${token}");
    });

    Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data){
      if (data == null) {
        print("App was not launched by tapping a notification");
      } else {
        firebaseMessagingBackgroundHandlerByMsg(data);
        print('Notification tap launched app from terminated state:\n'
            'RemoteMessage: ${data} \n');
      }

    });

    // Push.instance.onMessage.listen((message) {
    //   print('RemoteMessage received while app is in foreground:\n'
    //       'RemoteMessage.Notification: ${message.notification} \n'
    //       ' title: ${message.notification?.title.toString()}\n'
    //       ' body: ${message.notification?.body.toString()}\n'
    //       'RemoteMessage.Data: ${message.data}');
    //   firebaseMessagingBackgroundHandler(message);
    // });

    // Handle push notifications
    // Push.instance.onBackgroundMessage.listen((message) {
    //   print('RemoteMessage received while app is in background:\n'
    //       'RemoteMessage.Notification: ${message.notification} \n'
    //       ' title: ${message.notification?.title.toString()}\n'
    //       ' body: ${message.notification?.body.toString()}\n'
    //       'RemoteMessage.Data: ${message.data}');
    //   firebaseMessagingBackgroundHandler(message);
    // });

    // Handle notification taps
    Push.instance.onNotificationTap.listen((data) {
      print("Handle the data ${data["payload"]} RAW ${data}");
      if(data["payload"] != null){
        _handleMessage(jsonDecode(data["payload"] as String),navigatorKey);
      }
      else{
        _handleMessage(data, navigatorKey);
      }

    });

  }

  static Future<void> handleMessage(Map<String?, Object?> msgData, GlobalKey<NavigatorState> navigatorKey) async{
    return _handleMessage(msgData, navigatorKey);
  }

  static Future<void> _handleMessage(Map<String?, Object?> msgData, GlobalKey<NavigatorState> navigatorKey) async {

    Map<String, dynamic> data = msgData.cast<String, dynamic>();
    int tid = int.parse(data["tid"].toString());
    String site_url = data["site_url"].toString();
    int uid = int.parse(data["uid"].toString());
    UserDao _userDao = await AppDatabase.getUserDao();
    DiscuzDao _discuzDao = await AppDatabase.getDiscuzDao();
    Discuz? _discuz = _discuzDao.findDiscuzByHost(site_url);

    //print("Receive discuz ${msg}} ");
    //Map<String, String>? data = msg;
    switch (data['type']){
      case 'thread_reply':{
        if(_discuz!=null){
          User? _user = _userDao.findUsersByDiscuzAndUid(_discuz, uid);

          print("Receive user ${_user}");
          if(_user != null && navigatorKey.currentState!=null && navigatorKey.currentState?.context!=null){

            // set to current discuz now
            Provider.of<DiscuzAndUserNotifier>(navigatorKey.currentState!.context, listen: false)
                .initDiscuz(_discuz);
            Navigator.push(
                navigatorKey.currentState!.context,
                platformPageRoute(
                    context: navigatorKey.currentState!.context,
                    builder: (context) => ViewThreadSliverPage(_discuz, _user, tid)));
          }
        }
        break;
      }
      // for login notification
      case 'login':{
        if(_discuz != null){
          Provider.of<DiscuzAndUserNotifier>(navigatorKey.currentState!.context, listen: false)
              .initDiscuz(_discuz);
          Navigator.push(
              navigatorKey.currentState!.context,
              platformPageRoute(
                  context: navigatorKey.currentState!.context,
                  builder: (context) => PushServicePage()));
        }
        break;

      }
      // for RSS
      case 'RSS_FEED':{
        if(_discuz!=null){
          List<User> _userList = _userDao.findAllUsers();
          User? _user = _userList.length == 0? null: _userList.first;

          print("Receive user ${_user}");
          if(navigatorKey.currentState!=null && navigatorKey.currentState?.context!=null){

            // set to current discuz now
            Provider.of<DiscuzAndUserNotifier>(navigatorKey.currentState!.context, listen: false)
                .initDiscuz(_discuz);
            Provider.of<DiscuzAndUserNotifier>(navigatorKey.currentState!.context, listen: false)
                .setUser(_user);
            Navigator.push(
                navigatorKey.currentState!.context,
                platformPageRoute(
                    context: navigatorKey.currentState!.context,
                    builder: (context) => ViewThreadSliverPage(_discuz, _user, tid)));
          }
        }
        break;
      }
    }
  }

  static Future<void> firebaseMessagingBackgroundHandlerByMsg(Map<String?, Object?>? msgData) async{
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.


    print("Handling a background message ${msgData}");
    //{fid: 2, uid: 2, site_url: http://192.168.0.145/,
    // pid: 316, sender_name: admin, type: thread_reply,
    // title: Cenr, message: SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDDDDDDDDDDDDDD,
    // tid: 12, sender_id: 1}
    Map<String, dynamic>? data = msgData?.cast<String, dynamic>();
    if(data == null){
      return ;
    }
    print("Recv data ${data}");
    // init for io
    await Hive.initFlutter();
    if(AppDatabase.imageAttachmentBox == null){
      await AppDatabase.initBoxes();
    }

    // need to find discuz
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    String baseURL = data["site_url"];
    String uid = data["uid"];
    String type = data["type"];
    Discuz? discuz = discuzDao.findDiscuzByHost(baseURL);
    if(discuz!= null){
      // find uid
      UserDao userDao = await AppDatabase.getUserDao();
      User? user = await userDao.findUsersByDiscuzAndUid(discuz, int.parse(uid));
      if(user!= null){
        // a valid trigger
        if(type == "thread_reply"){
          makeThreadReplyNotification(discuz, user, data);
        }
      }
      else{
        print("No user found!!!");
        // will regard it as common message
        makeCommonThreadNotification(discuz, data);
      }
    }
    else{
      print("No Discuz found!!!");
    }
    return;
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.


    print("Handling a background message ${message}");
    //{fid: 2, uid: 2, site_url: http://192.168.0.145/,
    // pid: 316, sender_name: admin, type: thread_reply,
    // title: Cenr, message: SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDDDDDDDDDDDDDD,
    // tid: 12, sender_id: 1}
    Map<String, dynamic>? data = message.data?.cast<String, dynamic>();
    if(data == null){
      return ;
    }
    print("Recv data ${data}");
    // init for io
    await Hive.initFlutter();
    if(AppDatabase.imageAttachmentBox == null){
      await AppDatabase.initBoxes();
    }

    // need to find discuz
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    String baseURL = data["site_url"];
    String uid = data["uid"];
    String type = data["type"];
    Discuz? discuz = discuzDao.findDiscuzByHost(baseURL);
    if(discuz!= null){
      // find uid
      UserDao userDao = await AppDatabase.getUserDao();
      User? user = await userDao.findUsersByDiscuzAndUid(discuz, int.parse(uid));
      if(user!= null){
        // a valid trigger
        if(type == "thread_reply"){
          makeThreadReplyNotification(discuz, user, data);
        }
      }
      else{
        print("No user found!!!");
        makeCommonThreadNotification(discuz, data);
      }
    }
    else{

      print("No Discuz found!!!");
    }
    return;
  }

  static void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }

  }

  static void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page

  }

  static Future<FlutterLocalNotificationsPlugin> initFirebaseLocalNotification() async{
    // notification initialisation
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        //onDidReceiveLocalNotification: PushServiceUtils.onDidReceiveLocalNotification
    );
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return flutterLocalNotificationsPlugin;
  }



  static Future<void> makeThreadReplyNotification(Discuz discuz, User user, Map<String, dynamic> data) async{
    print("Make local notification ${data}");
    DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound: false,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        sound: null,  // Specifics the file path to play (only from iOS 10 onwards)
        badgeNumber: null, // The application's icon badge number
        attachments: [],
        subtitle: "Reply", //Secondary description  (only from iOS 10 onwards)
        threadIdentifier: "s"
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        discuz.baseURL,   //Required for Android 8.0 or after
        discuz.siteName, //Required for Android 8.0 or after
        channelDescription: discuz.siteName, //Required for Android 8.0 or after
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = await initFirebaseLocalNotification();
    await flutterLocalNotificationsPlugin.show(
      1,
      data["title"],
      data["message"],
      platformChannelSpecifics,
      payload: jsonEncode(data)
    );

  }

  static Future<void> makeCommonThreadNotification(Discuz discuz, Map<String, dynamic> data) async{
    print("Make common notification ${data}");
    DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound: false,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        sound: null,  // Specifics the file path to play (only from iOS 10 onwards)
        badgeNumber: null, // The application's icon badge number
        attachments: [],
        subtitle: "", //Secondary description  (only from iOS 10 onwards)
        threadIdentifier: "s"
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      discuz.baseURL,   //Required for Android 8.0 or after
      discuz.siteName, //Required for Android 8.0 or after
      channelDescription: discuz.siteName, //Required for Android 8.0 or after
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = await initFirebaseLocalNotification();
    int? tid = int.tryParse(data["tid"]);

    await flutterLocalNotificationsPlugin.show(
        tid == null? 0 : tid,
        data["title"],
        data["message"],
        platformChannelSpecifics,
        payload: jsonEncode(data)
    );

  }

  static String getDiscuzPushPluginEnabledKey(Discuz discuz){
    return "discuz_push_plugin_enabled_${discuz.baseURL}";
  }

  static Future<bool> getDiscuzPushPluginEnabled(Discuz discuz) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var signaturePreference =  prefs.getBool(getDiscuzPushPluginEnabledKey(discuz));
    return signaturePreference == null? false: signaturePreference;
  }

  static Future<void> putDiscuzPushPluginEnabled(Discuz discuz, bool value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(getDiscuzPushPluginEnabledKey(discuz), value);
  }

}