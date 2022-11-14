
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:push/push.dart';

import '../dao/DiscuzDao.dart';
import '../dao/UserDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../page/ViewThreadSliverPage.dart';

class PushServiceUtils{

  static Future<void> initPushInformation(GlobalKey<NavigatorState> navigatorKey) async {
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

    final onMessageSubscription = Push.instance.onMessage.listen((message) {
      print('RemoteMessage received while app is in foreground:\n'
          'RemoteMessage.Notification: ${message.notification} \n'
          ' title: ${message.notification?.title.toString()}\n'
          ' body: ${message.notification?.body.toString()}\n'
          'RemoteMessage.Data: ${message.data}');
      firebaseMessagingBackgroundHandler(message);
    });

    // Handle push notifications
    final onBackgroundMessageSubscription =
    Push.instance.onBackgroundMessage.listen((message) {
      print('RemoteMessage received while app is in background:\n'
          'RemoteMessage.Notification: ${message.notification} \n'
          ' title: ${message.notification?.title.toString()}\n'
          ' body: ${message.notification?.body.toString()}\n'
          'RemoteMessage.Data: ${message.data}');
      firebaseMessagingBackgroundHandler(message);
    });

    // Handle notification taps
    Push.instance.onNotificationTap.listen((data) {
      print("Handle the data ${data}");
      _handleMessage(data,navigatorKey);
    });

  }

  static Future<void> _handleMessage(Map<String?, Object?> msgData, GlobalKey<NavigatorState> navigatorKey) async {

    Map<String, dynamic> msg = msgData.cast<String, dynamic>();
    print("Receive discuz ${msg}} ");
    Map<String, String>? data = msg["payload"];
    if (data!=null && data['type'] == 'thread_reply') {
      int tid = int.parse(data["tid"].toString());
      String site_url = data["site_url"].toString();
      int uid = int.parse(data["uid"].toString());
      // find it in discuz or uid
      UserDao _userDao = await AppDatabase.getUserDao();
      DiscuzDao _discuzDao = await AppDatabase.getDiscuzDao();
      Discuz? _discuz = _discuzDao.findDiscuzByHost(site_url);
      print("Receive discuz ${_discuz}");
      if(_discuz!=null){
        User? _user = _userDao.findUsersByDiscuzAndUid(_discuz, uid);
        print("Receive user ${_user}");
        if(_user != null && navigatorKey.currentState!=null && navigatorKey.currentState?.context!=null){
          Navigator.push(
              navigatorKey.currentState!.context,
              platformPageRoute(
                  context: navigatorKey.currentState!.context,
                  builder: (context) => ViewThreadSliverPage(_discuz, _user, tid)));
        }
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
        onDidReceiveLocalNotification: PushServiceUtils.onDidReceiveLocalNotification
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
      payload: data.toString()
    );

  }

}