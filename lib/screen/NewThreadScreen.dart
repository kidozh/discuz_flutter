import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/NewThreadResult.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/NewThread.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/DiscuzNotificationProvider.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/MobileSignUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PostTextFieldUtils.dart';
import '../widget/AppBannerAdWidget.dart';
import '../widget/ErrorCard.dart';
import '../widget/LoadingStateWidget.dart';
import '../widget/NewThreadWidget.dart';
import '../widget/ThreadSlideShowCarouselWidget.dart';
import 'EmptyListScreen.dart';
import 'NullDiscuzScreen.dart';

class NewThreadScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTid;
  NewThreadScreen({this.onSelectTid}){
    log("New thread When create it ${onSelectTid}");
  }

  @override
  Widget build(BuildContext context) {
    return NewThreadStatefulWidget(onSelectTid: onSelectTid,);
  }
}

class NewThreadStatefulWidget extends StatefulWidget {
  final ValueChanged<int>? onSelectTid;
  NewThreadStatefulWidget({this.onSelectTid});

  _NewThreadState createState() {

    return _NewThreadState(onSelectTid: onSelectTid);
  }
}

class _NewThreadState extends State<NewThreadStatefulWidget> {
  late Dio _dio;
  late MobileApiClient _client;
  bool _isFirstLoading = true;
  NewThreadResult result = NewThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<NewThread> _newThreadList = [];
  final ValueChanged<int>? onSelectTid;

  _NewThreadState({this.onSelectTid});

  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
  }

  Future<IndicatorResult> _invalidateNewThreadContent(Discuz discuz) async {
    _page = 1;
    return await _loadNewThreadContent(discuz);
  }

  Future<IndicatorResult> _loadNewThreadContent(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.NewThreadRaw(_page).then((value){
    //   log(value);
    //   result = NewThreadResult.fromJson(jsonDecode(value));
    //
    // });
    String fids = await UserPreferencesUtils.getDiscuzForumFids(discuz);
    if(fids.isEmpty){
      // if discuz forum list is not fully retrieved
      setState(() {
        _error = DiscuzError(S.of(context).noForumIsCachedTitle,
            S.of(context).noForumIsCachedSubtitle);
        _isFirstLoading = false;
      });
      _controller.finishRefresh(IndicatorResult.noMore);
      _controller.finishLoad(IndicatorResult.noMore);
      return IndicatorResult.none;
    }

    return await _client.newThreadsResult(fids, (_page - 1) * 20).then((value) async {
      Provider.of<DiscuzNotificationProvider>(context, listen: false).setNotificationCount(value.variables.noticeCount);
      setState(() {
        _isFirstLoading = false;
        result = value;
        _error = null;
        if (_page == 1) {
          _newThreadList = value.variables.newThreadList;
        } else {
          _newThreadList.addAll(value.variables.newThreadList);
        }
      });
      _page += 1;
      _controller.finishRefresh();
      _controller.finishLoad(value.variables.newThreadList.isEmpty
          ? IndicatorResult.noMore
          : IndicatorResult.success);
      // check for loaded all?
      log("Get NewThread ${_newThreadList.length}");

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

      if (value.variables.newThreadList.isEmpty) {
        return IndicatorResult.noMore;
      } else {
        return IndicatorResult.success;
      }
    }).catchError((onError, stacktrace) {
      if(mounted){
        setState(() {
          _isFirstLoading = false;
        });
      }

      print(onError.toString());
      print(stacktrace);

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
        return await _invalidateNewThreadContent(discuz);
      },
      onLoad: () async {
        return await _loadNewThreadContent(discuz);
      },
      child: CustomScrollView(
        slivers: [
          if (_newThreadList.isEmpty)
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) => _isFirstLoading? LoadingStateWidget():EmptyListScreen(EmptyItemType.thread),
                    childCount: 1)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => Column(
                      children: [
                        if(index == 0) ThreadSlideShowCarouselWidget(onSelectTid: onSelectTid),
                        NewThreadWidget(discuz, user, _newThreadList[index], this.onSelectTid,
                            afterTid: index < _newThreadList.length - 1 ? _newThreadList[index+1].tid: null
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
                childCount: _newThreadList.length),
          )
        ],
      ),
    );
  }
}
