
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/FavoriteForumDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/FavoriteForumInDatabase.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'EmptyScreen.dart';

class DiscuzPortalScreen extends StatelessWidget {


  DiscuzPortalScreen({required Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DiscuzPortalStatefulWidget(key: UniqueKey());
  }
}

class DiscuzPortalStatefulWidget extends StatefulWidget {


  DiscuzPortalStatefulWidget({required Key key}):super(key: key);

  _DiscuzPortalState createState() {
    return _DiscuzPortalState();
  }
}

class _DiscuzPortalState extends State<DiscuzPortalStatefulWidget> {

  late Dio _dio;
  late MobileApiClient _client;
  DiscuzIndexResult? result = null;
  DiscuzError? _error;
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

  _DiscuzPortalState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _loadFavoriteForum();
  }

  FavoriteForumDao? favoriteForumDao;

  void _loadFavoriteForum() async{
    FavoriteForumDao dao = await AppDatabase.getFavoriteForumDao();
    setState(() {
      favoriteForumDao = dao;
    });

  }

  Future<void> _loadPortalContent(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    _client.getDiscuzPortalResult().then((value) {
      // render page
      setState(() {
        result = value;
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

      // check with user
      if(user != null && value.discuzIndexVariables.member_uid != user.uid){
        log("Recv user ${value.discuzIndexVariables.member_uid} ${user.uid}");
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username), S.of(context).userExpiredSubtitle);
        });
      }

    }).catchError((onError) {
      // VibrationUtils.vibrateErrorIfPossible();
      // if (!_enableControlFinish) {
      //   _controller.resetLoadState();
      //   try{
      //     _controller.finishRefresh();
      //   }
      //   catch (e){
      //
      //   }
      //
      // }
      // try{
      //   setState(() {
      //     _error =
      //         DiscuzError(onError.runtimeType.toString(), onError.toString());
      //   });
      // }
      // catch (e){
      //
      // }

    });
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
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
      emptyWidget: result == null? EmptyScreen(): null,
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
        _loadPortalContent(discuz);
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
        if(favoriteForumDao != null)
        ValueListenableBuilder(
          valueListenable: favoriteForumDao!.favoriteForumBox.listenable(),
          builder: (BuildContext context, value, Widget? child) {
            List<
                FavoriteForumInDatabase> favoriteForumInDbList = favoriteForumDao!
                .getFavoriteForumList(discuz);
            return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return FavoriteForumCardWidget(
                      discuz, user, favoriteForumInDbList[index]);
                },
                    childCount: favoriteForumInDbList.length
                )
            );
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
              return ForumPartitionWidget(discuz,user,forumPartition, _allForumList);
            },
            childCount: result == null
                ? 0
                : result!.discuzIndexVariables.forumPartitionList.length,
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if(this.mounted) {
      super.setState(fn);
    }
  }


}

class FavoriteForumCardWidget extends StatelessWidget{
  FavoriteForumInDatabase favoriteForumInDatabase;
  Discuz discuz;
  User? user;
  FavoriteForumCardWidget(this.discuz, this.user,this.favoriteForumInDatabase);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 2.0,
      child: ListTile(
        leading: Icon(Icons.favorite, color: Theme.of(context).primaryTextTheme.bodyText1?.color?.withAlpha(200),),
        title: Hero(
          tag: ConstUtils.HERO_TAG_FORUM_TITLE,
          child: Text(favoriteForumInDatabase.title, style: Theme.of(context).primaryTextTheme.headline6,),
        ),
        subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, favoriteForumInDatabase.date),
          style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith(
            color: Theme.of(context).primaryTextTheme.bodyText2?.color?.withAlpha(150)
          ),),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => DisplayForumSliverPage(discuz, user, favoriteForumInDatabase.idKey))
          );
        },
        trailing: Icon(Icons.arrow_forward, color: Theme.of(context).primaryTextTheme.bodyText1?.color,),


      ),
    );
  }



}
