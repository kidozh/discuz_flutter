import 'package:discuz_flutter/JsonResult/PushTokenListResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';

class PushServicePage extends StatelessWidget {
  PushServicePage();

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    return PushServiceStateWidget(key: ValueKey(account.sessionIdentity));
  }
}

class PushServiceStateWidget extends StatefulWidget {
  const PushServiceStateWidget({super.key});

  @override
  PushServiceState createState() {
    return PushServiceState();
  }
}

class PushServiceState extends State<PushServiceStateWidget> {
  PushServiceState();

  final _controller = EasyRefreshController();
  PushTokenListResult result = PushTokenListResult();
  PushTokenChannel? pushTokenChannel;
  DiscuzError? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      //iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(S.of(context).pushNotification)),
      body: SafeArea(
        child: Consumer<DiscuzAndUserNotifier>(
          builder: (context, discuzAndUser, child) {
            if (discuzAndUser.discuz == null || discuzAndUser.user == null) {
              return NullUserScreen();
            } else {
              Discuz discuz = discuzAndUser.discuz!;
              User user = discuzAndUser.user!;
              return Column(
                children: [
                  if (_error != null)
                    ErrorCard(_error!, () => _controller.callRefresh()),
                  Expanded(
                    child: EasyRefresh(
                      header: EasyRefreshUtils.i18nClassicHeader(context),
                      refreshOnStart: true,
                      controller: _controller,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          if (result.list[index].token !=
                              pushTokenChannel?.token) {
                            return PlatformListTile(
                              title: Text(result.list[index].deviceName),
                              subtitle: Text(
                                TimeDisplayUtils.getLocaledTimeDisplay(
                                  context,
                                  result.list[index].updateAt,
                                ),
                              ),
                              trailing:
                                  result.list[index].token ==
                                      pushTokenChannel?.token
                                  ? Icon(
                                      AppPlatformIcons(context).thisDeviceSolid,
                                    )
                                  : null,
                            );
                          } else {
                            return PlatformCard(
                              color: Theme.of(context).primaryColor,
                              child: PlatformListTile(
                                textColor: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyLarge
                                    ?.color,
                                title: Text(result.list[index].deviceName),
                                subtitle: Text(
                                  TimeDisplayUtils.getLocaledTimeDisplay(
                                    context,
                                    result.list[index].updateAt,
                                  ),
                                ),
                                trailing:
                                    result.list[index].token ==
                                        pushTokenChannel?.token
                                    ? Icon(
                                        AppPlatformIcons(context)
                                            .thisDeviceSolid,
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
                      onRefresh: () => _loadTokenList(discuz, user),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<IndicatorResult> _loadTokenList(Discuz discuz, User user) async {
    if (_loading) return IndicatorResult.fail;
    _loading = true;
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      var response = await client.getPushTokenListResult();
      if (!isCurrent()) return IndicatorResult.fail;
      if (response.formhash.isEmpty) {
        setState(
          () => _error = DiscuzError(
            S.of(context).pushNotification,
            S.of(context).siteDoesNotSupportPushService,
          ),
        );
        return IndicatorResult.fail;
      }
      final channel = await PushServiceUtils.getPushToken();
      if (!isCurrent()) return IndicatorResult.fail;
      if (channel != null &&
          !response.list.any(
            (entry) =>
                entry.token == channel.token &&
                DateTime.now().difference(entry.updateAt).inDays < 6,
          )) {
        final registration = await client.sendToken(
          response.formhash,
          channel.token,
          channel.deviceName,
          channel.packageId,
          channel.channelName,
        );
        if (!isCurrent()) return IndicatorResult.fail;
        if (registration.result == 'success') {
          response = await client.getPushTokenListResult();
          if (!isCurrent()) return IndicatorResult.fail;
          if (response.formhash.isEmpty) {
            setState(
              () => _error = DiscuzError(
                S.of(context).pushNotification,
                S.of(context).loadFailed,
              ),
            );
            return IndicatorResult.fail;
          }
        } else {
          EasyLoading.showError(S.of(context).uploadTokenUnsuccessful);
        }
      }

      setState(() {
        pushTokenChannel = channel;
        result = response;
        _error = null;
      });
      await PushServiceUtils.putDiscuzPushPluginEnabled(discuz, true);
      return IndicatorResult.success;
    } catch (error) {
      if (isCurrent()) {
        setState(() => _error = EasyRefreshUtils.requestError(context, error));
      }
      return IndicatorResult.fail;
    } finally {
      _loading = false;
    }
  }
}
