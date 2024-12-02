
import 'package:discuz_flutter/JsonResult/SubscribeChannelResult.dart';
import 'package:discuz_flutter/client/PushServiceClient.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/page/SetPushNotificationPage.dart';
import 'package:discuz_flutter/screen/LoadingScreen.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import '../screen/NullDiscuzScreen.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PushServiceUtils.dart';
import '../widget/ErrorCard.dart';

class SubscribeChannelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).subscribeChannel),
        automaticallyImplyLeading: true,
      ),
      body: SubscribeChannelStatefulWidget(),
    );
  }
}

class SubscribeChannelStatefulWidget extends StatefulWidget {
  @override
  SubscribeChannelState createState() {
    return SubscribeChannelState();
  }
}

class SubscribeChannelState extends State<SubscribeChannelStatefulWidget> {
  SubscribeChannelResult subscribeChannelResult = SubscribeChannelResult();
  DiscuzError? discuzError = null;
  bool isRefreshing = true;
  bool isSubmitting = false;

  String pushServerBaseUrl = "https://dhp.kidozh.com";
  //String pushServerBaseUrl = "http://localhost:9000";

  void _loadChannel() async {
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = PushServiceClient(dio, baseUrl: pushServerBaseUrl);
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    PushTokenChannel? pushTokenChannel =
        await PushServiceUtils.getPushToken(context);

    if (discuz != null && pushTokenChannel != null) {
      String baseUrl = discuz.baseURL;
      String? host = Uri.tryParse(baseUrl)?.host;
      String token = pushTokenChannel.token;

      if (host != null) {
        client.getAllChannelByHost(host, token).then((value) {
          setState(() {
            isRefreshing = false;
            subscribeChannelResult = value;
            if (!subscribeChannelResult.isSuccess()) {
              discuzError = DiscuzError(
                  subscribeChannelResult.result, subscribeChannelResult.reason);
            }
          });
        }).catchError((onError) {
          setState(() {
            isRefreshing = false;
            discuzError =
                DiscuzError(S.of(context).networkFail, onError.toString());
          });
        });
      }
    }
  }

  Future<void> _saveSubscriptionId(List<String> addId, List<String> removeId) async{
    List<String> subscribedIdList = await UserPreferencesUtils.getSubscribedChannelList();
    subscribedIdList = [subscribedIdList, addId].expand((element) => element).toList();
    subscribedIdList.removeWhere((element) => removeId.contains(element));
    await UserPreferencesUtils.putSubscribedChannelList(subscribedIdList);
    // attempt to send the information already
    await UserPreferencesUtils.putLastPushSecond();
  }

  void _subscribeChannels() async {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    PushTokenChannel? pushTokenChannel =
        await PushServiceUtils.getPushToken(context);
    String? baseUrl = discuz?.baseURL;
    String? host = Uri.tryParse(baseUrl == null ? "" : baseUrl)?.host;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(null);
    final client = PushServiceClient(dio, baseUrl: pushServerBaseUrl);
    print("subscribe to the list ${host} R: ${pushTokenChannel}");

    if (host != null && pushTokenChannel != null) {
      String token = pushTokenChannel.token;
      String pushPlatform = pushTokenChannel.channelName;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageId = packageInfo.packageName;
      List<String> addId = [];
      List<String> removeId = [];
      for (var i = 0; i < subscribeChannelResult.channelList.length; i++) {
        if (subscribeChannelResult.channelList[i].subscribe) {
          addId.add(subscribeChannelResult.channelList[i].id);
        } else {
          removeId.add(subscribeChannelResult.channelList[i].id);
        }
      }

      await _saveSubscriptionId(addId, removeId);

      print("subscribe to the list ${addId} R: ${removeId}");

      setState(() {
        isSubmitting = true;
      });

      // check with add or remove
      client
          .changeSubscribeChannelByHost(
              host, token, addId, removeId, packageId, pushPlatform)
          .then((value) {
        if (value.isSuccess()) {
          EasyLoading.showSuccess(S.of(context).subscriptionSuccess);
        } else {
          EasyLoading.showError(
              S.of(context).discuzOperationMessage(value.result, value.reason));
        }
        setState(() {
          isSubmitting = false;
        });
      });
    }
  }

  @override
  void initState() {
    _loadChannel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferenceNotifierProvider>(builder: (context, settings, child){
      if(settings.allowPush){
        return Consumer<DiscuzAndUserNotifier>(
            builder: (context, discuzAndUser, child) {
              if (discuzAndUser.discuz == null) {
                return NullDiscuzScreen();
              } else {
                if (discuzError != null) {
                  return ErrorCard(discuzError!, () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _loadChannel();
                  });
                } else {
                  if (isRefreshing) {
                    return LoadingScreen();
                  } else {
                    if (subscribeChannelResult.channelList.length != 0) {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          //shrinkWrap: true,
                          itemCount: subscribeChannelResult.channelList.length,
                          itemBuilder: (context, index) {
                            SubscribeChannel subscribeChannel =
                            subscribeChannelResult.channelList[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlatformListTile(
                                  title: Text(subscribeChannel.description),
                                  subtitle: Text(subscribeChannel.note),
                                  trailing: PlatformSwitch(
                                    value: subscribeChannel.subscribe,
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    onChanged: (value) {
                                      setState(() {
                                        VibrationUtils.vibrateWithClickIfPossible();
                                        subscribeChannelResult
                                            .channelList[index].subscribe = value;
                                      });
                                    },
                                  ),
                                ),
                                Divider(),
                                if (index ==
                                    subscribeChannelResult.channelList.length - 1 &&
                                    isSubmitting == false)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Container(
                                      width: double.infinity,
                                      child: PlatformElevatedButton(
                                        child: Text(S.of(context).subscribe),
                                        onPressed: () {
                                          VibrationUtils.vibrateWithClickIfPossible();
                                          _subscribeChannels();

                                        },
                                      ),
                                    ),
                                  ),
                                if (index ==
                                    subscribeChannelResult.channelList.length - 1 &&
                                    isSubmitting == true)
                                  PlatformCircularProgressIndicator(),
                              ],
                            );
                          });
                    } else {
                      // no channel
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).noSubscribeChannelProvided(
                                      discuzAndUser.discuz!.siteName),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(
                                  height: 32,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                                  child: Container(
                                    width: double.infinity,
                                    child: PlatformElevatedButton(
                                      child: Text(S.of(context).emailUsToAddChannel(
                                          discuzAndUser.discuz!.siteName)),
                                      onPressed: () async {
                                        VibrationUtils.vibrateWithClickIfPossible();
                                        // send email
                                        final Uri uri = Uri(
                                            scheme: "mailto",
                                            path: "kidozh@gmail.com",
                                            queryParameters: {
                                              'subject': S.of(context).emailChannelTitle(
                                                  discuzAndUser.discuz!.siteName),
                                              'body': S.of(context).emailChannelBody(
                                                  discuzAndUser.discuz!.siteName,
                                                  discuzAndUser.discuz!.baseURL),
                                            });

                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        } else {
                                          print("Error in sending ${uri.toString()}");
                                          EasyLoading.showError(
                                              S.of(context).emailChannelFailed);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      );
                    }
                  }
                }
              }
            });
      }
      else{
        // enable it
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).pushServiceNotEnabled,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                    child: Container(
                      width: double.infinity,
                      child: PlatformElevatedButton(
                        child: Text(S.of(context).goToPushSetting),
                        onPressed: () async {
                          VibrationUtils.vibrateWithClickIfPossible();

                          Navigator.push(
                              context,
                              platformPageRoute(
                                  iosTitle: S.of(context).goToPushSetting,
                                  context: context, builder: (context) => SetPushNotificationPage()));

                        },
                      ),
                    ),
                  ),
                ]),
          ),
        );
      }

    });

  }
}
