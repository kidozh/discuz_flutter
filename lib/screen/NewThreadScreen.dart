import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/NewThreadResult.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/NewThread.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../widget/ErrorCard.dart';
import '../widget/NewThreadWidget.dart';
import 'EmptyScreen.dart';
import 'NullDiscuzScreen.dart';

class NewThreadScreen extends StatelessWidget {


  NewThreadScreen();

  @override
  Widget build(BuildContext context) {
    return NewThreadStatefulWidget(key: UniqueKey());
  }
}

class NewThreadStatefulWidget extends StatefulWidget {


  NewThreadStatefulWidget({required Key key}):super(key: key);

  _NewThreadState createState() {
    return _NewThreadState();
  }
}

class _NewThreadState extends State<NewThreadStatefulWidget> {
  late Dio _dio;
  late MobileApiClient _client;
  NewThreadResult result = NewThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<NewThread> _newThreadList = [];

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

  @override
  void initState() {
    
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();

  }

  _invalidateNewThreadContent(Discuz discuz) async{
    _page = 1;
    await _loadNewThreadContent(discuz);
  }

  Future<void> _loadNewThreadContent(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.NewThreadRaw(_page).then((value){
    //   log(value);
    //   result = NewThreadResult.fromJson(jsonDecode(value));
    //
    // });
    String fids = await UserPreferencesUtils.getDiscuzForumFids(discuz);
    log("Recv fids ${fids}");

    _client.newThreadsResult(fids,(_page-1)*20).then((value){
      setState(() {
        result = value;
        _error = null;
        if (_page == 1) {
          _newThreadList = value.variables.newThreadList;
        } else {
          _newThreadList.addAll(value.variables.newThreadList);
        }
      });
      _page += 1;
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get NewThread ${_newThreadList.length}");
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: value.variables.newThreadList.isEmpty);
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
      // VibrationUtils.vibrateErrorIfPossible();
      // // EasyLoading.showError('${onError}');
      // if (!_enableControlFinish) {
      //   _controller.resetLoadState();
      //   try{
      //     _controller.finishRefresh();
      //     setState(() {
      //       _error = DiscuzError(
      //           onError.runtimeType.toString(), onError.toString());
      //     });
      //   }
      //   catch(e){
      //
      //   }
      //
      // }

    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
      }
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
      emptyWidget: _newThreadList.length == 0? EmptyScreen(): null,
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
        _invalidateNewThreadContent(discuz);
        if (!_enableControlFinish) {
          _controller.resetLoadState();
          _controller.finishRefresh();
        }

      } : null,
      onLoad: _enableLoad
          ? () async {
        _loadNewThreadContent(discuz);
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
                return NewThreadWidget(discuz,user, _newThreadList[index]);
              },
              childCount: _newThreadList.length
          ),
        ),
      ],
    );
  }
  
}