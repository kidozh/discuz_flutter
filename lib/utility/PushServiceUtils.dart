

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    await Firebase.initializeApp();

    print("Handling a background message ${message.messageId}");
    //{fid: 2, uid: 2, site_url: http://192.168.0.145/,
    // pid: 316, sender_name: admin, type: thread_reply,
    // title: Cenr, message: SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDDDDDDDDDDDDDD,
    // tid: 12, sender_id: 1}
    Map<String, dynamic> data = message.data;
    print("Recv data ${data}");
    // init for io
    await Hive.initFlutter();
    await AppDatabase.initBoxes();
    // need to find discuz
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    String baseURL = data["site_url"];
    String uid = data["uid"];
    String type = data["type"];
    Discuz? discuz = discuzDao.findDiscuzByBaseURL(baseURL);
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
    }
  }

  static Future<void> makeThreadReplyNotification(Discuz discuz, User user, Map<String, dynamic> data) async{

  }

}