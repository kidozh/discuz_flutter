import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/PublicMessagePortalResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../utility/EasyRefreshUtils.dart';

class PublicMessagePortalScreen extends StatelessWidget {
  PublicMessagePortalScreen();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PublicMessagePortalStatefulWidget();
  }
}

class PublicMessagePortalStatefulWidget extends StatefulWidget {
  PublicMessagePortalStatefulWidget();

  _PublicMessagePortalState createState() {
    return _PublicMessagePortalState();
  }
}

class _PublicMessagePortalState
    extends State<PublicMessagePortalStatefulWidget> {
  late Dio _dio;
  late MobileApiClient _client;
  PublicMessagePortalResult result = PublicMessagePortalResult();
  DiscuzError? _error;
  int _page = 1;
  List<PublicMessagePortal> _pmList = [];

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

  _PublicMessagePortalState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _scrollController = ScrollController();
  }

  _invalidateHotThreadContent(Discuz discuz) async {
    _page = 1;
    await _loadPortalPublicMessage(discuz);
  }

  Future<void> _loadPortalPublicMessage(Discuz discuz) async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.hotThreadRaw(_page).then((value){
    //   log(value);
    //   result = HotThreadResult.fromJson(jsonDecode(value));
    //
    // });

    _client.publicMessagePortalResult(_page).then((value) {
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
        //_controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get HotThread ${_pmList.length} ${value.variables.count}");
      if (!_enableControlFinish) {
        _controller.finishLoad(_pmList.length >= value.variables.count
            ? IndicatorResult.noMore
            : IndicatorResult.success);
      }

      if (user != null && value.variables.member_uid != user.uid) {
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username),
              S.of(context).userExpiredSubtitle);
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
    }).catchError((onError, stacktrace) {
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        //_controller.resetLoadState();
        _controller.finishRefresh();
      }
      setState(() {
        _error =
            DiscuzError(onError.runtimeType.toString(), onError.toString());
      });
      throw (onError);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<DiscuzAndUserNotifier>(
        builder: (context, discuzAndUser, child) {
      if (discuzAndUser.discuz == null) {
        return NullDiscuzScreen();
      } else if (discuzAndUser.user == null) {
        return NullUserScreen();
      }
      return Column(
        children: [
          if (_error != null)
            ErrorCard(_error!.key, _error!.content, () {
              _controller.callRefresh();
            }),
          Expanded(
              child: getEasyRefreshWidget(
                  discuzAndUser.discuz!, discuzAndUser.user))
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
      onRefresh: _enableRefresh
          ? () async {
              await _invalidateHotThreadContent(discuz);
              if (!_enableControlFinish) {
                //_controller.resetLoadState();
                _controller.finishRefresh();
              }
            }
          : null,
      onLoad: _enableLoad
          ? () async {
              await _loadPortalPublicMessage(discuz);
            }
          : null,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(PlatformIcons(context).mail),
            title: Text(_pmList[index].message),
            subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(
                context, _pmList[index].publishAt)),
          );
        },
        itemCount: _pmList.length,
      ),
    );
  }
}
