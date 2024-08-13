import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/PrivateMessagePortalWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/UserPreferencesUtils.dart';

class PrivateMessagePortalScreen extends StatelessWidget {
  PrivateMessagePortalScreen();

  @override
  Widget build(BuildContext context) {
    return PrivateMessagePortalStatefulWidget();
  }
}

class PrivateMessagePortalStatefulWidget extends StatefulWidget {
  PrivateMessagePortalStatefulWidget();

  _PrivateMessagePortalState createState() {
    return _PrivateMessagePortalState();
  }
}

class _PrivateMessagePortalState
    extends State<PrivateMessagePortalStatefulWidget> {
  late Dio _dio;
  late MobileApiClient _client;
  PrivateMessagePortalResult result = PrivateMessagePortalResult();
  DiscuzError? _error;
  int _page = 1;
  List<PrivateMessagePortal> _pmList = [];

  late EasyRefreshController _controller;

  _PrivateMessagePortalState();

  @override
  void initState() {
    super.initState();
    _loadPrivateMessageCache();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
  }
  
  Future<void> _loadPrivateMessageCache() async{
    log("Load private message cache");
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if(discuz!= null && user!= null){
      String jsonString = await UserPreferencesUtils.getDiscuzPrivateMessageResultCacheJson(discuz, user!);
      try{
        PrivateMessagePortalResult cacheResult = PrivateMessagePortalResult.fromJson(jsonDecode(jsonString));
        log("Set state ->");
        setState(() {
          result = cacheResult;
          _pmList = cacheResult.variables.pmList;
        });
      }
      catch(e,s){

        log(e.toString());
      }
      log("Load private message string -> ${jsonString}");

    }
    
  }

  Future<IndicatorResult> _invalidateHotThreadContent(Discuz discuz) async {

    _page = 1;
    return await _loadPortalPrivateMessage(discuz);
  }

  Future<IndicatorResult> _loadPortalPrivateMessage(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.hotThreadRaw(_page).then((value){
    //   log(value);
    //   result = HotThreadResult.fromJson(jsonDecode(value));
    //
    // });
    Provider.of<DiscuzNotificationProvider>(context, listen: false).setNotificationCount(result.variables.noticeCount);
    // if(result.variables.count != 0 && _pmList.length >= result.variables.count){
    //   _controller.finishLoad(IndicatorResult.noMore);
    //   return IndicatorResult.noMore;
    // }
    
    if(user == null){
      return IndicatorResult.fail;
    }

    return await _client.privateMessagePortalResult(_page).then((value) async{
      String cacheString = jsonEncode(value.toJson());
      await UserPreferencesUtils.putDiscuzPrivateMessageResultCacheJson(discuz, user!, cacheString);
      setState(() {
        result = value;
        _error = null;
        if (_page == 1) {
          _pmList = value.variables.pmList;
        } else {
          _pmList.addAll(value.variables.pmList);
        }
      });

      _page += 1;
      _controller.finishRefresh();


      // check for loaded all?
      log("Get pm list ${_pmList.length} ${value.variables.count}");
      _controller.finishLoad(_pmList.length >= value.variables.count
          ? IndicatorResult.noMore
          : IndicatorResult.success);


      if (user != null && value.variables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle);
        });
      }

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      if (value.errorResult != null) {
        setState(() {
          _error =
              DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      } else {
        setState(() {
          _error = null;
        });
      }
      if(_pmList.length >= value.variables.count){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }
    }).catchError((onError, stacktrace) {

      try {
        //_controller.resetLoadState();
        _controller.finishRefresh();
      } catch (e) {}
      return IndicatorResult.fail;
      setState(() {
        _error =
            DiscuzError(onError.runtimeType.toString(), onError.toString());
      });
      throw (onError);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return NullDiscuzScreen();
      } else if (discuzAndUser.user == null) {
        return NullUserScreen();
      }
      return Column(
        children: [
          if (_error != null)
            ErrorCard(_error!, () {
              _controller.callRefresh();
            }),
          Expanded(
              child: EasyRefresh(
                header: EasyRefreshUtils.i18nClassicHeader(context),
                footer: EasyRefreshUtils.i18nClassicFooter(context),
                refreshOnStart: true,
                controller: _controller,
                onRefresh: () async {
                  return await _invalidateHotThreadContent(discuzAndUser.discuz!);
                },
                onLoad: () async {
                  return await _loadPortalPrivateMessage(discuzAndUser.discuz!);
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return PrivateMessagePortalWidget(discuzAndUser.discuz!, discuzAndUser.user, _pmList[index]);
                  },
                  itemCount: _pmList.length,
                ),
              )
          )
        ],
      );
    });
  }


}
