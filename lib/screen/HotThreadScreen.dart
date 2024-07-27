import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/HotThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:discuz_flutter/widget/HotThreadWidget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../provider/DiscuzNotificationProvider.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/MobileSignUtils.dart';
import '../utility/PostTextFieldUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/LoadingStateWidget.dart';
import '../widget/ThreadSlideShowCarouselWidget.dart';
import 'EmptyListScreen.dart';

class HotThreadScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTid;

  HotThreadScreen({this.onSelectTid}){
    log("Hot thread When create it ${onSelectTid}");
  }

  @override
  Widget build(BuildContext context) {
    return HotThreadStatefulWidget(onSelectTid: onSelectTid,);
  }
}

class HotThreadStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;
  HotThreadStatefulWidget({this.onSelectTid});

  _HotThreadState createState() {
    return _HotThreadState(onSelectTid: onSelectTid);
  }
}

class _HotThreadState extends State<HotThreadStatefulWidget> {
  final ValueChanged<int>? onSelectTid;
  bool _isFirstLoading = true;
  late Dio _dio;
  late MobileApiClient _client;
  HotThreadResult result = HotThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<HotThread> _hotThreadList = [];


  late EasyRefreshController _controller;

  _HotThreadState({this.onSelectTid});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
  }

  Future<IndicatorResult> _invalidateHotThreadContent(Discuz discuz) async {
    _page = 1;
    return await _loadHotThreadContent(discuz);
  }

  Future<IndicatorResult> _loadHotThreadContent(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    return await _client.hotThreadResult(_page).then((value) async {
      _controller.finishRefresh();
      Provider.of<DiscuzNotificationProvider>(context, listen: false).setNotificationCount(value.variables.noticeCount);
      setState(() {
        _isFirstLoading = false;
        result = value;
        _error = null;
        if (_page == 1) {
          _hotThreadList = value.variables.hotThreadList;
        } else {
          _hotThreadList.addAll(value.variables.hotThreadList);
        }
      });
      _page += 1;
      _controller.finishRefresh();

      // check for loaded all?
      log("Get HotThread ${_hotThreadList.length} ${value.variables.perPage}");
      _controller.finishLoad(
          value.variables.hotThreadList.length < value.variables.perPage
              ? IndicatorResult.noMore
              : IndicatorResult.success);

      if (user != null && value.variables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle,
              errorType: ErrorType.userExpired);
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
      if(user!= null && value.variables.member_uid == user.uid){
        // conduct mobile sign
        await MobileSignUtils.conductMobileSign(context, discuz, user, value.variables.formHash);
      }
      if (value.variables.hotThreadList.length < value.variables.perPage) {
        return IndicatorResult.noMore;
      } else {
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
            setState(() {
              _error = DiscuzError(dioError.message==null?S.of(context).error: dioError.message!, dioError.type.name,
                  dioError: dioError);
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
    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return NullDiscuzScreen();
      }
      return Column(
        children: [
          if (_error != null)
            ErrorCard(
              _error!,
              () {
                _controller.callRefresh();
              },
              errorType: _error!.errorType,
            ),
          Expanded(
              child: getEasyRefreshWidget(
                  discuzAndUser.discuz!, discuzAndUser.user)),
        ],
      );
    });
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user) {
    return EasyRefresh(
      header: EasyRefreshUtils.i18nClassicHeader(context),
      footer: EasyRefreshUtils.i18nClassicFooter(context),
      refreshOnStart: true,
      controller: _controller,
      onRefresh: () async {
        IndicatorResult indicatorResult =
            await _invalidateHotThreadContent(discuz);
        _controller.finishRefresh();
        return indicatorResult;
      },
      onLoad: () async {
        return await _loadHotThreadContent(discuz);
      },
      child: CustomScrollView(
        slivers: [


          if (_hotThreadList.isEmpty && result.errorResult == null)
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) => _isFirstLoading? LoadingStateWidget(): EmptyListScreen(EmptyItemType.thread),
                    childCount: 1)),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                        children: [
                          if(index == 0) ThreadSlideShowCarouselWidget(onSelectTid: onSelectTid,),
                          HotThreadWidget(discuz, user, _hotThreadList[index], onSelectTid,
                              afterTid: index < _hotThreadList.length - 1 ? _hotThreadList[index+1].tid: null
                          ),
                          if (index % 15 == 0 && index != 0)
                            Consumer<UserPreferenceNotifierProvider>(builder: (context, value, child){
                              if(value.signature == PostTextFieldUtils.USE_APP_SIGNATURE && index > 20){
                                return Container();
                              }
                              else{
                                return AppBannerAdWidget();
                              }
                            })
                        ],
                      ),
                  childCount: _hotThreadList.length))
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
