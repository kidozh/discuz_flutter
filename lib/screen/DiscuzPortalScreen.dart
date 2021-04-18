
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DiscuzPortalScreen extends StatelessWidget {
  Discuz _discuz;
  User? _user;

  DiscuzPortalScreen(this._discuz, this._user);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DiscuzPortalStatefulWidget(_discuz, _user);
  }
}

class DiscuzPortalStatefulWidget extends StatefulWidget {
  Discuz _discuz;
  User? _user;

  DiscuzPortalStatefulWidget(this._discuz, this._user);

  _DiscuzPortalState createState() {
    return _DiscuzPortalState(_discuz, _user);
  }
}

class _DiscuzPortalState extends State<DiscuzPortalStatefulWidget> {
  Discuz _discuz;
  User? _user;
  late Dio _dio;
  late MobileApiClient _client;
  bool _isLoading = false;
  DiscuzIndexResult? result = null;
  DiscuzError? _error;
  bool _loaded = false;

  late EasyRefreshController _controller;
  late ScrollController _scrollController;

  // 反向
  bool _reverse = false;
  // 方向
  Axis _direction = Axis.vertical;
  // Header浮动
  bool _headerFloat = false;
  // 无限加载
  bool _enableInfiniteLoad = false;
  // 控制结束
  bool _enableControlFinish = false;
  // 任务独立
  bool _taskIndependence = false;
  // 震动
  bool _vibration = true;
  // 是否开启刷新
  bool _enableRefresh = true;
  // 是否开启加载
  bool _enableLoad = false;
  // 顶部回弹
  bool _topBouncing = true;
  // 底部回弹
  bool _bottomBouncing = true;

  _DiscuzPortalState(this._discuz, this._user) {
    this._dio = Dio();
    this._client = MobileApiClient(_dio, baseUrl: _discuz.baseURL);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _loadPortalContent();
  }

  void _loadPortalContent() {
    setState(() {
      _isLoading = true;
    });



    _client.getDiscuzPortalResult().then((value) {
      // render page
      setState(() {
        result = value;
        _isLoading = false;

      });
      if(value.getErrorString()!= null){
        EasyLoading.showError(value.getErrorString()!);
      }
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      if (!_enableControlFinish) {
        _controller.finishLoad(noMore: true);
      }
    }).catchError((onError) {
      EasyLoading.showError('${onError}');
      log(onError);
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      setState(() {
        _error =
            DiscuzError(onError.runtimeType.toString(), onError.toString());
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!_loaded){
      _loaded = true;
      _loadPortalContent();
    }

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
      header: _enableRefresh? ClassicalHeader(
        enableInfiniteRefresh: false,
        bgColor:
        _headerFloat ? Theme.of(context).primaryColor : Colors.transparent,
        infoColor: _headerFloat ? Colors.black87 : Colors.teal,
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
        _loadPortalContent();
        if (!_enableControlFinish) {
          _controller.resetLoadState();
          _controller.finishRefresh();
        }

      } : null,
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
        if(_error!=null)
          ErrorCard(_error!.key, _error!.content,(){
            _loadPortalContent();
          }
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
                  List<ForumPartition> forumPartitionList =
                      result!.discuzIndexVariables.forumPartitionList;
                  List<Forum> _allForumList =
                      result!.discuzIndexVariables.forumList;
                  ForumPartition forumPartition = forumPartitionList[index];
                  //log("Forum partition length ${result!.discuzIndexVariables.forumPartitionList.length} all ${_allForumList.length}" );
                  return ForumPartitionWidget(_discuz,_user,forumPartition, _allForumList);
            },
            childCount: result == null
                ? 0
                : result!.discuzIndexVariables.forumPartitionList.length,
          ),
        ),
      ],
    );
  }
}
