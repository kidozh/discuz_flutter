


import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/PushTokenListResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PostTextFieldUtils.dart';

class PushServicePage extends StatelessWidget{


  PushServicePage();

  @override
  Widget build(BuildContext context) {

    return PushServiceStateWidget();
  }
}

class PushServiceStateWidget extends StatefulWidget{

  PushServiceStateWidget();

  @override
  PushServiceState createState() {

    return PushServiceState();
  }

}

class PushServiceState extends State<PushServiceStateWidget>{

  PushServiceState();

  late EasyRefreshController _controller;
  late Dio _dio;
  late MobileApiClient _client;

  PushTokenListResult result = PushTokenListResult();

  // 控制结束
  bool _enableControlFinish = false;
  bool _enableRefresh = true;
  String deviceToken = "";


  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _loadTokenInfo();
  }

  void _loadTokenInfo() async{

    try{
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      // try to get APNs before
      String? fetchedToken = null;
      if(Platform.isIOS){

        String? apnsToken = await messaging.getAPNSToken();
        print("Get APNS token ${apnsToken}");
        fetchedToken = apnsToken;
      }
      else{
        fetchedToken = await messaging.getToken();
      }

      print("Get token ${fetchedToken}");
      if(fetchedToken != null){
        deviceToken = fetchedToken;
      }

    }
    catch (e){

    }


  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushNotification),
      ),
      body: Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child){
          if(discuzAndUser.discuz == null || discuzAndUser.user == null){
            return NullUserScreen();
          }
          else{
            Discuz discuz = discuzAndUser.discuz!;
            User user = discuzAndUser.user!;

            // start to trigger
            return EasyRefresh(
              header: EasyRefreshUtils.i18nClassicHeader(context),
              footer: EasyRefreshUtils.i18nClassicFooter(context),
              refreshOnStart: true,
              controller: _controller,
              child: ListView.builder(itemBuilder: (context, index){

                if(result.list[index].token != deviceToken){
                  return ListTile(
                    title: Text(result.list[index].deviceName),
                    subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, result.list[index].updateAt)),
                    trailing: result.list[index].token == deviceToken? Icon(AppPlatformIcons(context).thisDeviceSolid): null,
                  );
                }
                else{
                  return Card(
                    color: Theme.of(context).primaryColor,
                    child: ListTile(
                      textColor: Theme.of(context).primaryTextTheme.bodyText1?.color,
                      title: Text(result.list[index].deviceName),
                      subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, result.list[index].updateAt)),
                      trailing: result.list[index].token == deviceToken? Icon(AppPlatformIcons(context).thisDeviceSolid, color: Theme.of(context).primaryTextTheme.bodyText1?.color,): null,
                    ),
                  );
                }

              },
                itemCount: result.list.length,
              ),
              onRefresh: _enableRefresh? () async{
                await _loadTokenList(discuz, user);
              }: null,
            );
          }
        },
      ),
    );

  }

  Future<void> _loadTokenList(Discuz discuz, User user) async{

    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    _client.getPushTokenListResult().then((value) async {
      setState((){
        result = value;
      });
      if (!_enableControlFinish) {
        //_controller.resetLoadState();
        _controller.finishRefresh();
        _controller.finishRefresh(IndicatorResult.noMore);
      }
      // check with token
      String token = "";
      try{
        // check with platform
        if(Platform.isIOS){
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          String? apnToken = await messaging.getAPNSToken();
          if(apnToken != null){
            token = apnToken;
          }
        }
        else{
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          String? fetchedToken = await messaging.getToken();
          if(fetchedToken != null){
            token = fetchedToken;
          }
        }


      }
      catch(e){
        log(e.toString());
      }
      bool refreshToken = true;
      DateTime now = DateTime.now();
      for(var tokenInfo in result.list){
        // if time interval > 6, we need to refresh the page
        if(tokenInfo.token == token && now.difference(tokenInfo.updateAt).inDays < 6){
          refreshToken = false;
        }
      }
      if(refreshToken || true){
        _sendTokenList(discuz, user);
      }


    }).catchError((e,StackTrace stackTrace){
      log(stackTrace.toString());
      EasyLoading.showError(S.of(context).siteDoesNotSupportPushService);
    });
  }

  Future<void> _sendTokenList(Discuz discuz, User user) async{
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);
    // send it
    // check with token
    String token = "";
    String channel = "FCM";
    try{
      // check with platform
      if(Platform.isIOS){
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? apnToken = await messaging.getAPNSToken();
        log("Get APNS ${apnToken}");
        if(apnToken != null){
          token = apnToken;
        }
        // to make sure apn get posted
        channel = "APN";
      }
      else{
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? fetchedToken = await messaging.getToken();
        if(fetchedToken != null){
          token = fetchedToken;
        }
      }


    }
    catch(e){
      log(e.toString());
    }
    // prepare to send token
    String deviceName = await PostTextFieldUtils.getDeviceName(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageId = packageInfo.packageName;
    log("Get formhash ${result.formhash}");
    _client.sendToken(result.formhash, token, deviceName, packageId, channel).then((value){
      if(value.result =="success"){
        EasyLoading.showSuccess(S.of(context).uploadTokenSuccessful);
      }
    }).catchError((Object object,StackTrace stackTrace){
      log(stackTrace.toString());
      EasyLoading.showError(S.of(context).uploadTokenUnsuccessful);
    });
  }

}
