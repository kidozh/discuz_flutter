
import 'dart:convert';
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
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/MobileSignUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:discuz_flutter/widget/LoadingStateWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../utility/EasyRefreshUtils.dart';

class DiscuzPortalScreen extends StatelessWidget {


  DiscuzPortalScreen({required Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
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
  DiscuzIndexResult result = DiscuzIndexResult();
  DiscuzError? _error;
  late EasyRefreshController _controller;


  // 控制结束
  bool _enableControlFinish = false;

  bool _isFirstlyRefreshing = true;

  _DiscuzPortalState();

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _loadFavoriteForum();
    _loadPortalCache();
  }

  FavoriteForumDao? favoriteForumDao;

  void _loadFavoriteForum() async{
    FavoriteForumDao dao = await AppDatabase.getFavoriteForumDao();
    setState(() {
      favoriteForumDao = dao;
    });

  }

  void _loadPortalCache() async{
    // load cache first
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz != null) {
      String portalJson = await UserPreferencesUtils.getDiscuzPortalResultCacheJson(discuz);
      // try to recover from Simley
      if(portalJson == ""){
        return;
      }
      try{
        DiscuzIndexResult discuzIndexResult = DiscuzIndexResult.fromJson(jsonDecode(portalJson));
        setState(() {
          result = discuzIndexResult;
        });
      }
      catch (e){
        log("Loading portal json error ${portalJson} \n --- \n ${e} ");
      }
    }

  }


  Future<IndicatorResult> _loadPortalContent(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    IndicatorResult indictaorResult = await _client.getDiscuzPortalResult().then((value) async {
      // render page
      setState(() {
        result = value;
        _isFirstlyRefreshing = false;
      });
      Provider.of<DiscuzNotificationProvider>(context, listen: false).setNotificationCount(value.discuzIndexVariables.noticeCount);
      // get fids;
      if(value.discuzIndexVariables.forumList.isNotEmpty){
        String fids = "";
        for(var forum in value.discuzIndexVariables.forumList){
          fids += "${forum.fid},";
        }
        UserPreferencesUtils.putDiscuzForumFids(discuz, fids);
        log("Save fids ${fids} to User Preference");
        // save cache
        UserPreferencesUtils.putDiscuzPortalResultCacheJson(discuz, jsonEncode(value.toJson()));
        // save group title and id mapping
        if(value.discuzIndexVariables.groupInfo.getGroupId() != 0){
          UserPreferencesUtils.putDiscuzGroupNameById(discuz,
              value.discuzIndexVariables.groupInfo.getGroupId(),
              value.discuzIndexVariables.groupInfo.groupTitle);
        }
      }
      if(value.getErrorString()!= null){
        EasyLoading.showError(value.getErrorString()!);
      }
      if (!_enableControlFinish) {
        //_controller.resetLoadState();
        _controller.finishRefresh();
      }
      if (!_enableControlFinish) {
        _controller.finishLoad(IndicatorResult.noMore);

      }

      // check with user
      if(user != null && value.discuzIndexVariables.member_uid != user.uid){
        log("Recv user ${value.discuzIndexVariables.member_uid} ${user.uid}");
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username), S.of(context).userExpiredSubtitle, errorType: ErrorType.userExpired);
        });
      }

      if(user!= null && value.discuzIndexVariables.member_uid == user.uid){
        // conduct mobile sign
        await MobileSignUtils.conductMobileSign(context, discuz, user, value.discuzIndexVariables.formHash);
      }

      return IndicatorResult.noMore;

    }).catchError((onError) {
      if(mounted){
        setState(() {
          _isFirstlyRefreshing = false;
        });
      }
      _controller.finishLoad(IndicatorResult.fail);
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
    return indictaorResult;
  }



  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
      }
      else{
        return Column(
          children: [
            if(_error!=null)
              ErrorCard(_error!,(){
                _controller.callRefresh();
              }, errorType: _error!.errorType,
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
    return EasyRefresh(

      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,

      onRefresh: () async {
        IndicatorResult indicatorResult = await _loadPortalContent(discuz);
        if (!_enableControlFinish) {
          //_controller.resetLoadState();
          _controller.finishRefresh();
        }
        return indicatorResult;

      },
      child: CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index)=> SafeArea(child: Container(), bottom: false,),
              childCount: 1
          )),
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
                          discuz, user, favoriteForumInDbList[index], index == favoriteForumInDbList.length - 1);
                    },
                        childCount: favoriteForumInDbList.length
                    )
                );
              }
          ),



          if(result.discuzIndexVariables.forumPartitionList.isEmpty)
            SliverList(delegate: SliverChildBuilderDelegate((context, index){
              return _isFirstlyRefreshing? LoadingStateWidget(): EmptyListScreen(EmptyItemType.forum);
            }, childCount: 1)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                List<ForumPartition> forumPartitionList =
                    result.discuzIndexVariables.forumPartitionList;
                List<Forum> _allForumList =
                    result.discuzIndexVariables.forumList;
                ForumPartition forumPartition = forumPartitionList[index];
                //log("Forum partition length ${result!.discuzIndexVariables.forumPartitionList.length} all ${_allForumList.length}" );
                return ForumPartitionWidget(discuz,user,forumPartition, _allForumList);
              },
              childCount: result.discuzIndexVariables.forumPartitionList.length,
            ),
          ),
          SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index)=> SafeArea(child: Container(), top: false,),
              childCount: 1
          )),
        ],
      ),
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
  bool lastItem = false;
  FavoriteForumCardWidget(this.discuz, this.user,this.favoriteForumInDatabase, this.lastItem);

  @override
  Widget build(BuildContext context) {
    return PlatformWidgetBuilder(
      material: (context, child, platform){
        return Card(
          color: Theme.of(context).colorScheme.onPrimary,
          elevation: 4.0,
          child: child,
        );
      },
      cupertino: (context, child, platform){
        return Column(
          children: [
            if(child!=null) Container(
              child: child,
            ),
            if(!lastItem)
              Divider()
          ],
        );
      },
      child: PlatformListTile(

        //dense: true,
        leading: isCupertino(context)?
            Icon(PlatformIcons(context).favoriteSolid, color: Theme.of(context).colorScheme.primary,)
            :null,
        title: Text(favoriteForumInDatabase.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary
            //fontWeight: FontWeight.bold
          ),
        ),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,
                  iosTitle: favoriteForumInDatabase.title,
                  builder: (context) => DisplayForumTwoPanePage(discuz, user, favoriteForumInDatabase.idKey))
          );
        },
        trailing: Icon(PlatformIcons(context).forward, color: Theme.of(context).colorScheme.primary),


      ),
    );
  }



}
