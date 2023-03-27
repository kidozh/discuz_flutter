
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
import 'package:discuz_flutter/utility/ConstUtils.dart';
import 'package:discuz_flutter/utility/MobileSignUtils.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/ForumPartitionWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

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
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _loadFavoriteForum();
  }

  FavoriteForumDao? favoriteForumDao;

  void _loadFavoriteForum() async{
    FavoriteForumDao dao = await AppDatabase.getFavoriteForumDao();
    setState(() {
      favoriteForumDao = dao;
    });

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
      // get fids;
      if(value.discuzIndexVariables.forumList.isNotEmpty){
        String fids = "";
        for(var forum in value.discuzIndexVariables.forumList){
          fids += "${forum.fid},";
        }
        UserPreferencesUtils.putDiscuzForumFids(discuz, fids);
        log("Save fids ${fids} to User Preference");
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

      _controller.finishLoad(IndicatorResult.fail);
      switch (onError.runtimeType) {
        case DioError:
          {
            DioError dioError = onError;
            log("${dioError.message} >-> ${dioError.type}");
            EasyLoading.showError("${dioError.message} (${dioError})");
            setState((){
              _error =
                  DiscuzError(dioError.message,dioError.type.name, dioError: dioError);
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
        slivers: [if(favoriteForumDao != null)
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



          if(result.discuzIndexVariables.forumPartitionList.isEmpty)
            SliverList(delegate: SliverChildBuilderDelegate((context, index){
              return EmptyListScreen(EmptyItemType.forum);
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
              childCount: result == null
                  ? 0
                  : result.discuzIndexVariables.forumPartitionList.length,
            ),
          ),
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
  FavoriteForumCardWidget(this.discuz, this.user,this.favoriteForumInDatabase);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2.0,
      child: ListTile(
        leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.onPrimaryContainer,),
        title: Hero(
          tag: ConstUtils.HERO_TAG_FORUM_TITLE,
          child: Text(favoriteForumInDatabase.title,
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer
            ),
          ),
        ),
        subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(context, favoriteForumInDatabase.date),
          style: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer
          ),
        ),
        onTap: () async {
          VibrationUtils.vibrateWithClickIfPossible();
          await Navigator.push(
              context,
              platformPageRoute(context:context,builder: (context) => DisplayForumTwoPanePage(discuz, user, favoriteForumInDatabase.idKey))
          );
        },
        trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onPrimaryContainer,),


      ),
    );
  }



}
