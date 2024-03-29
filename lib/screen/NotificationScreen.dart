import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/UserDiscuzNotificationResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/DiscuzNotificationWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../utility/EasyRefreshUtils.dart';
import '../utility/MobileSignUtils.dart';
import 'EmptyListScreen.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({this.onSelectTid});

  final ValueChanged<int>? onSelectTid;

  @override
  Widget build(BuildContext context) {

    return NotificationStatefulWidget(onSelectTid: onSelectTid,);
  }
}

class NotificationStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;

  NotificationStatefulWidget({this.onSelectTid});

  _NotificationState createState() {
    return _NotificationState(onSelectTid: this.onSelectTid);
  }
}

class _NotificationState extends State<NotificationStatefulWidget> {
  late Dio _dio;
  late MobileApiClient _client;
  UserDiscuzNotificationResult result = UserDiscuzNotificationResult();
  DiscuzError? _error;
  int _page = 1;
  List<DiscuzNotification> _noteList = [];
  bool _isFirstLoading = true;

  late EasyRefreshController _controller;

  final ValueChanged<int>? onSelectTid;

  _NotificationState({this.onSelectTid});

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);

  }

  Future<IndicatorResult> _invalidateNotificationContent(Discuz discuz) async {
    _page = 1;
    VibrationUtils.vibrateWithClickIfPossible();
    return await _loadNotificationContent(discuz);
  }

  Future<IndicatorResult> _loadNotificationContent(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.userNotificationRaw(_page).then((value){
    //   log(value);
    //   result = UserDiscuzNotificationResult.fromJson(jsonDecode(value));
    //
    // });

    return await _client.userNotificationResult(_page).then((value) async {
      setState(() {
        _isFirstLoading = false;
        result = value;
        _error = null;
        if (_page == 1) {
          _noteList = value.variables.notificationList;
        } else {
          _noteList.addAll(value.variables.notificationList);
        }
      });
      _page += 1;
      _controller.finishRefresh();
      _controller.finishLoad(_noteList.length >= value.variables.count
          ? IndicatorResult.noMore
          : IndicatorResult.success);
      // check for loaded all?
      log("Get Notification ${_noteList.length} ${value.variables.count}");


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
      // mobile sign?
      if(user!= null && value.variables.member_uid == user.uid){
        // conduct mobile sign
        await MobileSignUtils.conductMobileSign(context, discuz, user, value.variables.formHash);
      }

      if(_noteList.length >= value.variables.count){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }
    }).catchError((onError) {
      if(mounted){
        setState(() {
          _isFirstLoading = false;
        });
      }
      switch (onError.runtimeType) {
        case DioException:
          {
            DioException dioError = onError;
            log("${dioError.message} >-> ${dioError.type}");
            EasyLoading.showError("${dioError.message} (${dioError})");
            setState((){
              _error =
                  DiscuzError(dioError.message==null?S.of(context).error: dioError.message!,dioError.type.name, dioError: dioError);
            });

            break;
          }
        default:
          {
            setState(() {
              _error = DiscuzError(
                  onError.runtimeType.toString(), onError.toString());
            });
          }
      }
      return IndicatorResult.fail;
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
      } else {
        return Column(
          children: [
            if (_error != null)
              ErrorCard(_error!, () {
                _controller.callRefresh();
              }),

            Expanded(
                child: getEasyRefreshWidget(
                    discuzAndUser.discuz!, discuzAndUser.user)),

          ],
        );
      }
    });
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user) {
    return EasyRefresh(
      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,
      onRefresh: () async {
              return await _invalidateNotificationContent(discuz);
            },
      onLoad: () async {
              return await _loadNotificationContent(discuz);
            },
      child: CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index)=> SafeArea(child: Container(), bottom: false,),
              childCount: 1
          )),
          if(_noteList.isEmpty)
            SliverList(delegate: SliverChildBuilderDelegate(
                    (context, index)=> _isFirstLoading? LoadingStateWidget(hintText: S.of(context).notification,): EmptyListScreen(EmptyItemType.notification),
                childCount: 1
            )),
          SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index)=> DiscuzNotificationWidget(discuz, _noteList[index], onSelectTid: this.onSelectTid,),
            childCount: _noteList.length
          )),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }
}
