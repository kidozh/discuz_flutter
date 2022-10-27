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
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../widget/ErrorCard.dart';
import '../widget/NewThreadWidget.dart';
import 'EmptyListScreen.dart';
import 'NullDiscuzScreen.dart';

class NewThreadScreen extends StatelessWidget {
  NewThreadScreen();

  @override
  Widget build(BuildContext context) {
    return NewThreadStatefulWidget(key: UniqueKey());
  }
}

class NewThreadStatefulWidget extends StatefulWidget {
  NewThreadStatefulWidget({required Key key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
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
    log("Recv fids ${fids}");

    return await _client.newThreadsResult(fids, (_page - 1) * 20).then((value) {
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
      _controller.finishRefresh();
      _controller.finishLoad(value.variables.newThreadList.isEmpty
          ? IndicatorResult.noMore
          : IndicatorResult.success);
      // check for loaded all?
      log("Get NewThread ${_newThreadList.length}");


      if (user != null && value.variables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle, errorType: ErrorType.userExpired);
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
      if(value.variables.newThreadList.isEmpty){
        return IndicatorResult.noMore;
      }
      else{
        return IndicatorResult.success;
      }
    }).catchError((onError) {
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
            ErrorCard(_error!, () {
              _controller.callRefresh();
            }, errorType: _error!.errorType,),

          Expanded(
              child: getEasyRefreshWidget(
                  discuzAndUser.discuz!, discuzAndUser.user)),
          if(_newThreadList.isEmpty)
            EmptyListScreen(EmptyItemType.thread),
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
      child: ListView.builder(
        itemBuilder: (context, index) {
          return NewThreadWidget(discuz, user, _newThreadList[index]);
        },
        itemCount: _newThreadList.length,
      ),
    );
  }
}
