import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/PushTokenListResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';

class PushServicePage extends StatelessWidget {
  PushServicePage();

  @override
  Widget build(BuildContext context) {
    return PushServiceStateWidget();
  }
}

class PushServiceStateWidget extends StatefulWidget {
  PushServiceStateWidget();

  @override
  PushServiceState createState() {
    return PushServiceState();
  }
}

class PushServiceState extends State<PushServiceStateWidget> {
  PushServiceState();

  late EasyRefreshController _controller;
  late Dio _dio;
  late MobileApiClient _client;

  PushTokenListResult result = PushTokenListResult();

  // 控制结束
  bool _enableControlFinish = false;
  bool _enableRefresh = true;
  PushTokenChannel? pushTokenChannel = null;

  bool _isSupportPushService = true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    pushTokenChannel = await PushServiceUtils.getPushToken(context);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        //iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(S.of(context).pushNotification),
        ),
        body: SafeArea(
          child: Consumer<DiscuzAndUserNotifier>(
            builder: (context, discuzAndUser, child) {
              if (discuzAndUser.discuz == null || discuzAndUser.user == null) {
                return NullUserScreen();
              } else {
                Discuz discuz = discuzAndUser.discuz!;
                User user = discuzAndUser.user!;
                if (!_isSupportPushService) {
                  // display a page which does not support DHP
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Icon(
                          PlatformIcons(context).error,
                          color: Theme.of(context).colorScheme.error,
                          size: 64,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Text(discuzError.content, style: Theme.of(context).textTheme.headlineSmall),
                          Text(
                            S
                                .of(context)
                                .pushServiceSiteNotSupport(discuz.siteName),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      PlatformElevatedButton(
                        child: Text(S.of(context).viewPushServiceHomePage),
                        onPressed: () {
                          VibrationUtils.vibrateWithClickIfPossible();
                          URLUtils.launchURL("https://dhp.kidozh.com");
                        },
                      )
                    ],
                  );
                }
                // start to trigger
                return EasyRefresh(
                  header: EasyRefreshUtils.i18nClassicHeader(context),
                  footer: EasyRefreshUtils.i18nClassicFooter(context),
                  refreshOnStart: true,
                  controller: _controller,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (result.list[index].token != pushTokenChannel?.token) {
                        return ListTile(
                          title: Text(result.list[index].deviceName),
                          subtitle: Text(TimeDisplayUtils.getLocaledTimeDisplay(
                              context, result.list[index].updateAt)),
                          trailing: result.list[index].token ==
                                  pushTokenChannel?.token
                              ? Icon(AppPlatformIcons(context).thisDeviceSolid)
                              : null,
                        );
                      } else {
                        return Card(
                          color: Theme.of(context).primaryColor,
                          child: ListTile(
                            textColor: Theme.of(context)
                                .primaryTextTheme
                                .bodyLarge
                                ?.color,
                            title: Text(result.list[index].deviceName),
                            subtitle: Text(
                                TimeDisplayUtils.getLocaledTimeDisplay(
                                    context, result.list[index].updateAt)),
                            trailing: result.list[index].token ==
                                    pushTokenChannel?.token
                                ? Icon(
                                    AppPlatformIcons(context).thisDeviceSolid,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyLarge
                                        ?.color,
                                  )
                                : null,
                          ),
                        );
                      }
                    },
                    itemCount: result.list.length,
                  ),
                  onRefresh: _enableRefresh
                      ? () async {
                          await _loadTokenList(discuz, user);
                        }
                      : null,
                );
              }
            },
          ),
        ));
  }

  Future<void> _loadTokenList(Discuz discuz, User user) async {
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    _client.getPushTokenListResult().then((value) async {
      await PushServiceUtils.putDiscuzPushPluginEnabled(discuz, true);
      setState(() {
        result = value;
      });
      if (!_enableControlFinish) {
        //_controller.resetLoadState();
        _controller.finishRefresh();
        _controller.finishRefresh(IndicatorResult.noMore);
      }
      // check with token
      PushTokenChannel? pushTokenChannel =
          await PushServiceUtils.getPushToken(context);
      bool refreshToken = true;
      DateTime now = DateTime.now();
      for (var tokenInfo in result.list) {
        // if time interval > 6, we need to refresh the page
        if (tokenInfo.token == pushTokenChannel?.token &&
            now.difference(tokenInfo.updateAt).inDays < 6) {
          refreshToken = false;
        }
      }
      if (refreshToken || true) {
        _sendTokenList(discuz, user);
      }
    }).catchError((e, StackTrace stackTrace) {
      log(stackTrace.toString());
      EasyLoading.showError(S.of(context).siteDoesNotSupportPushService);
      if (mounted) {
        setState(() {
          _isSupportPushService = false;
        });
      }
    });
  }

  Future<void> _sendTokenList(Discuz discuz, User user) async {
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);
    // send it
    // check with token
    PushTokenChannel? _pushTokenChannel =
        await PushServiceUtils.getPushToken(context);
    if (_pushTokenChannel != null) {
      // prepare to send token

      log("Get formhash ${result.formhash}");
      _client
          .sendToken(
              result.formhash,
              _pushTokenChannel.token,
              _pushTokenChannel.deviceName,
              _pushTokenChannel.packageId,
              _pushTokenChannel.channelName)
          .then((value) async {
        if (value.result == "success") {
          EasyLoading.showSuccess(S.of(context).uploadTokenSuccessful);
          await PushServiceUtils.putDiscuzPushPluginEnabled(discuz, true);
        }
      }).catchError((Object object, StackTrace stackTrace) {
        log(stackTrace.toString());
        EasyLoading.showError(S.of(context).uploadTokenUnsuccessful);
      });
    }
  }
}
