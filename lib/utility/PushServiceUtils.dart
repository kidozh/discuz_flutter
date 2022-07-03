

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../dao/DiscuzDao.dart';
import '../dao/UserDao.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';

class PushServiceUtils{

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.


    print("Handling a background message ${message.messageId}");
    //{fid: 2, uid: 2, site_url: http://192.168.0.145/,
    // pid: 316, sender_name: admin, type: thread_reply,
    // title: Cenr, message: SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDDDDDDDDDDDDDD,
    // tid: 12, sender_id: 1}
    Map<String, dynamic> data = message.data;
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
          makeThreadReplyNotification(discuz, user, message, data);
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
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: PushServiceUtils.onDidReceiveLocalNotification
    );
    final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: PushServiceUtils.selectNotification);
    return flutterLocalNotificationsPlugin;
  }



  static Future<void> makeThreadReplyNotification(Discuz discuz, User user, RemoteMessage remoteMessage, Map<String, dynamic> data) async{
    IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound: false,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        sound: null,  // Specifics the file path to play (only from iOS 10 onwards)
        badgeNumber: null, // The application's icon badge number
        attachments: [],
        subtitle: "Reply", //Secondary description  (only from iOS 10 onwards)
        threadIdentifier: remoteMessage.messageId!
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
      remoteMessage.hashCode,
      data["title"],
      data["message"],
      platformChannelSpecifics,
      payload: data.toString()
    );

  }

}