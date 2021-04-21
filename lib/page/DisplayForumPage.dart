import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:form_validator/form_validator.dart';
import 'package:discuz_flutter/generated/l10n.dart';

class DisplayForumPage extends StatelessWidget {
  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  DisplayForumPage(
      {Key? key, required this.discuz, this.user, required this.fid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayForumStatefulWidget(key: this.key, discuz: discuz, user: user, fid: fid);
  }
}

class DisplayForumStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  DisplayForumStatefulWidget(
      {Key? key, required this.discuz, this.user, required this.fid})
      : super(key: key);

  @override
  _DisplayForumState createState() {
    // TODO: implement createState
    return _DisplayForumState(this.discuz, this.user, this.fid);
  }
}

class _DisplayForumState extends State<DisplayForumStatefulWidget> {
  DisplayForumResult? _displayForumResult = null;
  DiscuzError? _error = null;
  bool _isLoading = false;
  List<ForumThread> _forumThreadList = [];
  int _page = 1;

  late final Discuz discuz;
  late final User? user;
  int fid = 0;

  _DisplayForumState(this.discuz, this.user, this.fid);

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
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    //_invalidateContent();
  }

  void _invalidateContent() {
    setState(() {
      _page = 1;
    });
    _loadForumContent();
  }

  void _loadForumContent() {
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    final dio = Dio();
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    setState(() {
      _isLoading = true;
    });

    client.displayForumRaw(fid.toString(), _page).then((value){
      DisplayForumResult result = DisplayForumResult.fromJson(jsonDecode(value));
    });

    client.displayForumResult(fid.toString(), _page).then((value) {
      setState(() {
        _displayForumResult = value;
        _error = null;
        if (_page == 1) {
          _forumThreadList = value.discuzIndexVariables.forumThreadList;
        } else {
          _forumThreadList.addAll(value.discuzIndexVariables.forumThreadList);
          _forumThreadList = _forumThreadList;
        }
        _page += 1;
      });


      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _forumThreadList.length >=
                value.discuzIndexVariables.forum.getThreadCount());
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

      log("set successful result ${_displayForumResult} ${_forumThreadList.length}");
    }).catchError((onError) {
      log(onError);
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      switch (onError.runtimeType) {
        case DioError:
          {
            _error =
                DiscuzError(onError.runtimeType.toString(), onError.toString());
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: _displayForumResult == null ? Text(S.of(context).forumDisplayTitle): Text(_displayForumResult!.discuzIndexVariables.forum.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if(_error!=null)
            ErrorCard(_error!.key, _error!.content,(){_invalidateContent();}),
          Expanded(
              child: Container(
                //height: _direction == Axis.vertical ? double.infinity : 210.0,
                child: EasyRefresh.custom(
                  enableControlFinishRefresh: true,
                  enableControlFinishLoad: true,
                  taskIndependence: _taskIndependence,
                  controller: _controller,
                  scrollController: _scrollController,
                  reverse: _reverse,
                  scrollDirection: _direction,
                  topBouncing: _topBouncing,
                  bottomBouncing: _bottomBouncing,
                  header: _enableRefresh
                      ? ClassicalHeader(
                    enableInfiniteRefresh: false,
                    bgColor: _headerFloat
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
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
                    _invalidateContent();
                    if (!_enableControlFinish) {
                      _controller.resetLoadState();
                      _controller.finishRefresh();
                    }
                  }
                      : null,
                  onLoad: _enableLoad
                      ? () async {
                    _loadForumContent();
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
                          log("${_forumThreadList[index].subject} ${_forumThreadList}");
                          return Column(
                            children: [
                              ForumThreadWidget(
                                  discuz, user, _forumThreadList[index]),
                              Divider()
                            ],
                          );
                          return ForumThreadWidget(
                              discuz, user, _forumThreadList[index]);
                        },
                        childCount: _forumThreadList.length,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );



  }
}
