
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
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
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/DiscuzNotificationWidget.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'BlankScreen.dart';
import 'EmptyScreen.dart';

class NotificationScreen extends StatelessWidget {


  NotificationScreen();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return NotificationStatefulWidget(key: UniqueKey());
  }
}

class NotificationStatefulWidget extends StatefulWidget {


  NotificationStatefulWidget({required Key key}):super(key: key);

  _NotificationState createState() {
    return _NotificationState();
  }
}

class _NotificationState extends State<NotificationStatefulWidget> {

  late Dio _dio;
  late MobileApiClient _client;
  UserDiscuzNotificationResult result = UserDiscuzNotificationResult();
  DiscuzError? _error;
  int _page = 1;
  List<DiscuzNotification> _noteList = [];

  late EasyRefreshController _controller;
  late ScrollController _scrollController;

  // 反向
  bool _reverse = false;
  // 方向
  Axis _direction = Axis.vertical;
  // Header浮动
  bool _headerFloat = false;
  // 无限加载
  bool _enableInfiniteLoad = true;
  // 控制结束
  bool _enableControlFinish = false;
  // 任务独立
  bool _taskIndependence = false;
  // 震动
  bool _vibration = true;
  // 是否开启刷新
  bool _enableRefresh = true;
  // 是否开启加载
  bool _enableLoad = true;
  // 顶部回弹
  bool _topBouncing = true;
  // 底部回弹
  bool _bottomBouncing = true;

  _NotificationState();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();

  }

  _invalidateNotificationContent(Discuz discuz) async{
    _page = 1;
    await _loadNotificationContent(discuz);
  }

  Future<void> _loadNotificationContent(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.userNotificationRaw(_page).then((value){
    //   log(value);
    //   result = UserDiscuzNotificationResult.fromJson(jsonDecode(value));
    //
    // });

    _client.userNotificationResult(_page).then((value){
      setState(() {
        result = value;
        _error = null;
        if (_page == 1) {
          _noteList = value.variables.notificationList;
        } else {
          _noteList.addAll(value.variables.notificationList);
        }
      });
      _page += 1;
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get Notification ${_noteList.length} ${value.variables.count}");
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _noteList.length >= value.variables.count);
      }

      if(user != null && value.variables.member_uid != user.uid){
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username), S.of(context).userExpiredSubtitle);
        });
      }

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      if(value.errorResult!= null){
        setState(() {
          _error = DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      }
      else{
        setState(() {
          _error = null;
        });
      }


    })
    .catchError((onError){
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      setState(() {
        _error = DiscuzError(
            onError.runtimeType.toString(), onError.toString());
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
      }
      else if(discuzAndUser.user == null){
        return NullUserScreen();
      }
      else{
        return Column(
          children: [
            if(_error!=null)
              ErrorCard(_error!.key, _error!.content,(){
                _controller.callRefresh();
              }
              ),
              Expanded(
                  child: getEasyRefreshWidget(discuzAndUser.discuz!,discuzAndUser.user)
              )
          ],
        );
      }
    });
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user){
    return EasyRefresh.custom(

      enableControlFinishRefresh: true,
      enableControlFinishLoad: true,
      taskIndependence: _taskIndependence,
      controller: _controller,
      scrollController: _scrollController,
      reverse: _reverse,
      scrollDirection: _direction,
      topBouncing: _topBouncing,
      bottomBouncing: _bottomBouncing,
      emptyWidget: _noteList.length == 0? EmptyScreen(): null,
      header: _enableRefresh? ClassicalHeader(
        enableInfiniteRefresh: false,
        bgColor:
        _headerFloat ? Theme.of(context).primaryColor : Colors.transparent,
        // infoColor: _headerFloat ? Colors.black87 : Theme.of(context).primaryColor,
        textColor: Theme.of(context).textTheme.headline1!.color == null? Theme.of(context).primaryColorDark: Theme.of(context).textTheme.headline1!.color!,
        float: _headerFloat,
        enableHapticFeedback: _vibration,
        refreshText: S.of(context).pullToRefresh,
        refreshReadyText: S.of(context).releaseToRefresh,
        refreshingText: S.of(context).refreshing,
        refreshedText: S.of(context).refreshed,
        refreshFailedText: S.of(context).refreshFailed,
        noMoreText: S.of(context).noMore,
        infoText: S.of(context).updateAt,
      )
          : null,
      footer: _enableLoad
          ? ClassicalFooter(
        textColor: Theme.of(context).textTheme.headline1!.color == null? Theme.of(context).primaryColorDark: Theme.of(context).textTheme.headline1!.color!,
        enableInfiniteLoad: _enableInfiniteLoad,
        enableHapticFeedback: _vibration,
        loadText: S.of(context).pushToLoad,
        loadReadyText: S.of(context).releaseToLoad,
        loadingText: S.of(context).loading,
        loadedText: S.of(context).loaded,
        loadFailedText: S.of(context).loadFailed,
        noMoreText: S.of(context).noMore,
        infoText: S.of(context).updateAt,
      )
          : null,
      onRefresh: _enableRefresh
          ? () async {
        _invalidateNotificationContent(discuz);
        if (!_enableControlFinish) {
          _controller.resetLoadState();
          _controller.finishRefresh();
        }

      } : null,
      onLoad: _enableLoad
          ? () async {
        _loadNotificationContent(discuz);
      }
          : null,
      firstRefresh: true,
      firstRefreshWidget: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50.0,
                      height: 50.0,
                      child: SpinKitFadingCube(
                        color: Theme.of(context).primaryColor,
                        size: 25.0,
                      ),
                    ),
                    Container(
                      child: Text(S.of(context).loading),
                    )
                  ],
                ),
              ),
            )),
      ),
      slivers: <Widget>[

        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return DiscuzNotificationWidget(discuz, _noteList[index]);
            },
            childCount: _noteList.length
          ),
        ),
      ],
    );
  }
}
