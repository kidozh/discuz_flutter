import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumThreadWidget.dart';
import 'package:discuz_flutter/widget/PostWidget.dart';
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
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class ViewThreadPage extends StatelessWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;

  ViewThreadPage(
      {Key? key, required this.discuz, this.user, required this.tid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewThreadStatefulWidget(key: UniqueKey(), discuz: discuz, user: user, tid: tid);
  }
}

class ViewThreadStatefulWidget extends StatefulWidget {
  late final Discuz discuz;
  late final User? user;
  int tid = 0;

  ViewThreadStatefulWidget(
      {Key? key, required this.discuz, this.user, required this.tid})
      : super(key: key);

  @override
  _ViewThreadState createState() {
    // TODO: implement createState
    return _ViewThreadState(this.discuz, this.user, this.tid);
  }
}

class _ViewThreadState extends State<ViewThreadStatefulWidget> {
  ViewThreadResult _viewThreadResult = ViewThreadResult();
  DiscuzError? _error = null;
  List<Post> _postList = [];
  int _page = 1;
  final TextEditingController _replyController = new TextEditingController();

  late final Discuz discuz;
  late final User? user;
  int tid = 0;

  _ViewThreadState(this.discuz, this.user, this.tid);

  late EasyRefreshController _controller;
  late ScrollController _scrollController;
  ButtonState _sendReplyStatus = ButtonState.idle;

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

  Future<void> _sendReply() async{
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    String formhash = _viewThreadResult.threadVariables.formHash;
    int fid = _viewThreadResult.threadVariables.fid;
    if(user == null){
      return ;
    }
    setState(() {
      _sendReplyStatus = ButtonState.loading;
    });
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    String message = _replyController.text;
    log("send ${tid}");

    // client.sendReplyRaw(fid, tid, formhash, message,"","").then((value){
    //   log(value);
    // });

    client.sendReplyResult(fid, tid, formhash, message, "", "").then((value){
      if(value.errorResult!.key == "post_reply_succeed"){
        EasyLoading.showSuccess('${value.errorResult!.content}(${value.errorResult!.key})');
        setState(() {
          _sendReplyStatus = ButtonState.success;
        });
        // delay
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _sendReplyStatus = ButtonState.idle;
            _replyController.clear();
          });
        });
      }
      else{
        setState(() {
          _sendReplyStatus = ButtonState.fail;
        });
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _sendReplyStatus = ButtonState.idle;
            //_replyController.clear();
          });
        });
        EasyLoading.showError('${value.errorResult!.content}(${value.errorResult!.key})');


      }
    })
    .catchError((onError){
      EasyLoading.showError('${onError}');
      setState(() {
        _sendReplyStatus = ButtonState.fail;
      });
    });



  }

  Future<void> _loadForumContent() async {
    // check the availability
    log("Base url ${discuz.baseURL} ${_page}");
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);


    // client.viewThreadRaw(tid, _page).then((value) {
    //
    //   log(value.toString());
    //   // convert string to json
    //   Map<String, dynamic> resultJson = jsonDecode(value);
    //   ViewThreadResult result = ViewThreadResult.fromJson(resultJson);
    //   log(result.threadVariables.member_username);
    // });

    client.viewThreadResult(tid, _page).then((value) {
      setState(() {
        _viewThreadResult = value;
        _error = null;
        if (_page == 1) {
          _postList = value.threadVariables.postList;
        } else {
          _postList.addAll(value.threadVariables.postList);
          _postList = _postList;
        }
      });
      _page += 1;

      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get list ${value.threadVariables.threadInfo.allreplies} ${_postList.length} ${value.threadVariables.threadInfo.replies}");
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _postList.length >=
                value.threadVariables.threadInfo.replies);
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
      if(user != null && value.threadVariables.member_uid != user.uid){
        log("recv user uid different! ${user.uid} ${value.threadVariables.member_uid} ${value.threadVariables.member_username}");
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username), S.of(context).userExpiredSubtitle);
        });
      }

      log("set successful result ${_viewThreadResult} ${_postList.length}");

      // save rewrite rule
      if(value.threadVariables.rewriteRule!= null){
        // save rewrite url in database
        RewriteRule rewriteRule = value.threadVariables.rewriteRule!;
        if(rewriteRule.forumDisplay.isNotEmpty){
          RewriteRuleUtils.putForumDisplayRule(discuz, rewriteRule.forumDisplay);
        }

        if(rewriteRule.viewThread.isNotEmpty){
          RewriteRuleUtils.putViewThreadRule(discuz, rewriteRule.viewThread);
        }
      }
    }).catchError((onError) {
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
        title: _viewThreadResult == null ? Text(S.of(context).viewThreadTitle): Text(_viewThreadResult.threadVariables.threadInfo.subject),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if(_error!=null)
            ErrorCard(_error!.key, _error!.content,(){_controller.callRefresh();}),
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
                    enableInfiniteLoad: _enableInfiniteLoad,
                    enableHapticFeedback: _vibration,
                    textColor: Theme.of(context).textTheme.headline1!.color == null? Theme.of(context).primaryColorDark: Theme.of(context).textTheme.headline1!.color!,
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
                          return Column(
                            children: [
                              PostWidget(
                                  discuz, _postList[index],_viewThreadResult.threadVariables.threadInfo.authorId),
                            ],
                          );
                        },
                        childCount: _postList.length,
                      ),
                    ),
                  ],
                ),
              )),
            Consumer<DiscuzAndUserNotifier>(
              builder: (context,discuzAndUser, child){
                if(discuzAndUser.user!= null){
                  return Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: TextField(
                              controller: _replyController,
                              decoration: InputDecoration(
                                  hintText: S.of(context).sendReplyHint
                              ),
                            ),
                          )

                      ),

                      ProgressButton.icon(
                        maxWidth: 90.0,
                        height: 25.0,
                        iconedButtons: {
                          ButtonState.idle:
                          IconedButton(
                              text: S.of(context).sendReply,
                              icon: Icon(Icons.send,color: Colors.white),
                              color: Theme.of(context).primaryColor),
                          ButtonState.loading:
                          IconedButton(
                              text: S.of(context).progressButtonReplySending,
                              color: Theme.of(context).primaryColorDark),
                          ButtonState.fail:
                          IconedButton(
                              text: S.of(context).progressButtonReplyFailed,
                              icon: Icon(Icons.cancel,color: Colors.white),
                              color: Colors.red.shade300),
                          ButtonState.success:
                          IconedButton(
                              text: S.of(context).progressButtonReplySuccess,
                              icon: Icon(Icons.check_circle,color: Colors.white,),
                              color: Colors.green.shade400)
                        },
                          onPressed: (){
                            _sendReply();
                          },
                          state: _sendReplyStatus
                      )
                    ],
                  );
                }
                else{
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }
              },
            )
        ],
      ),
    );
  }
}
