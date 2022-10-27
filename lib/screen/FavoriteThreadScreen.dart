
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../utility/EasyRefreshUtils.dart';

class FavoriteThreadScreen extends StatelessWidget {


  FavoriteThreadScreen();

  @override
  Widget build(BuildContext context) {
    return FavoriteThreadStatefulWidget();
  }
}

class FavoriteThreadStatefulWidget extends StatefulWidget {


  FavoriteThreadStatefulWidget();

  _FavoriteThreadState createState() {
    return _FavoriteThreadState();
  }
}

class _FavoriteThreadState extends State<FavoriteThreadStatefulWidget> {

  late Dio _dio;
  late MobileApiClient _client;
  FavoriteThreadResult result = FavoriteThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<FavoriteThread> _pmList = [];

  late EasyRefreshController _controller;


  // 控制结束
  bool _enableControlFinish = false;

  _FavoriteThreadState();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);

  }

  Future<IndicatorResult> _invalidateHotThreadContent(Discuz discuz) async{
    _page = 1;
    return await _loadPortalPrivateMessage(discuz);
  }

  Future<IndicatorResult> _loadPortalPrivateMessage(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.hotThreadRaw(_page).then((value){
    //   log(value);
    //   result = HotThreadResult.fromJson(jsonDecode(value));
    //
    // });

    return await _client.favoriteThreadResult(_page).then((value){
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
      if (!_enableControlFinish) {
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get HotThread ${_pmList.length} ${value.variables.count}");
      if (!_enableControlFinish) {
        _controller.finishLoad(_pmList.length >= value.variables.count? IndicatorResult.noMore: IndicatorResult.success);
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
      if(_pmList.length >= value.variables.count){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }

    })
    .catchError((onError,stacktrace){
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        //_controller.resetLoadState();
        _controller.finishRefresh();
        _controller.finishLoad(IndicatorResult.fail);
      }
      setState(() {
        _error = DiscuzError(
            onError.runtimeType.toString(), onError.toString());
      });
      return IndicatorResult.fail;
      throw(onError);
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
      return Column(
        children: [
          if(_error!=null)
            ErrorCard(_error!,(){
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
    return EasyRefresh(

      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,
      onRefresh: () async {
        return await _invalidateHotThreadContent(discuz);

      } ,
      onLoad:  () async {
        return await _loadPortalPrivateMessage(discuz);
      },
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  FavoriteThread favoriteThread = _pmList[index];
                  return Container(
                    child: ListTile(
                      leading: InkWell(
                        child: ClipRRect(

                          borderRadius: BorderRadius.circular(10000.0),
                          child: CachedNetworkImage(
                            imageUrl: URLUtils.getAvatarURL(discuz, favoriteThread.uid.toString()),
                            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                CircleAvatar(

                                  backgroundColor: CustomizeColor.getColorBackgroundById(favoriteThread.uid),
                                  child: Text(favoriteThread.author.length !=0 ? favoriteThread.author[0].toUpperCase()
                                      : S.of(context).anonymous,
                                      style: TextStyle(color: Colors.white)),
                                )
                            ,
                          ),
                        ),
                        onTap: () async{
                          VibrationUtils.vibrateWithClickIfPossible();
                          User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                          await Navigator.push(
                              context,
                              platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz,user, favoriteThread.uid)));
                        },
                      ),
                      title: Text(favoriteThread.title,style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: RichText(
                        text: TextSpan(
                          text: favoriteThread.author,
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
                            TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
                            TextSpan(text: favoriteThread.description),
                            TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
                            TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,favoriteThread.publishAt)),
                          ],
                        ),
                      ),

                      onTap: () async {
                        VibrationUtils.vibrateWithClickIfPossible();
                        await Navigator.push(
                            context,
                            platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( discuz,  user, favoriteThread.id,))
                        );
                      },


                    ),
                  );
                },
                childCount: _pmList.length
            ),
          ),
        ],
      ),

    );
  }
}
