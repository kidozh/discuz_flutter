import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as DioCookieManager;
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../provider/DiscuzAndUserNotifier.dart';

class LoginByWebviewPage extends StatelessWidget {
  final Discuz discuz;

  LoginByWebviewPage(this.discuz);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LoginByWebviewStatefulWidget(discuz);
  }
}

class LoginByWebviewStatefulWidget extends StatefulWidget {
  final Discuz discuz;

  LoginByWebviewStatefulWidget(this.discuz);

  @override
  _LoginByWebviewState createState() => _LoginByWebviewState(discuz);
}

class _LoginByWebviewState extends State<LoginByWebviewStatefulWidget> {
  final webviewCookieManager = WebviewCookieManager();
  late final WebViewController _controller;

  final Discuz discuz;

  _LoginByWebviewState(this.discuz);

  @override
  void initState() {
    super.initState();
    _loadWidgetControllerSetting();
    unawaited(_prepareWebLogin());
    unawaited(_triggerNotificationDialog());
  }

  Future<void> _prepareWebLogin() async {
    // Clearing and loading used to run concurrently. On a fast connection the
    // cookie clear could finish after the login page had started and erase the
    // new session, making a successful browser login appear to have failed.
    try {
      await webviewCookieManager.clearCookies();
    } catch (error) {
      debugPrint('Unable to clear WebView cookies before login: $error');
    }
    if (!mounted) return;
    await _controller.loadRequest(
      Uri.parse('${discuz.baseURL}/member.php?mod=logging&action=login'),
    );
  }

  void _loadWidgetControllerSetting() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          print('Page started loading: $url');
          if (!mounted) return;
          setState(() {
            websiteLoaded = false;
          });
        },
        onPageFinished: (String url) async {
          print('Page finished loading: $url');
          if (!mounted) return;
          setState(() {
            websiteLoaded = true;
          });
        },
      ));
  }

  bool websiteLoaded = false;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).signInViaBrowser),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        trailingActions: <Widget>[
          //NavigationControls(_controller.future),
          if (websiteLoaded)
            PlatformIconButton(
              liquidGlassSymbol: 'checkmark',
              icon: Icon(
                PlatformIcons(context).checkMark,
                size: 20,
                semanticLabel: S.of(context).ok,
              ),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _checkUserLogined();
              },
            ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (!websiteLoaded)
              const PositionedDirectional(
                top: 12,
                end: 12,
                child: IgnorePointer(
                  child: PlatformLiquidGlassSurface(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: PlatformCircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
      //floatingActionButton: checkButton(),
    );
  }

  Future<void> _triggerNotificationDialog() async {
    print("show dialog");
    await Future.delayed(Duration(seconds: 1));
    if (!mounted) return;
    await showPlatformAlert(
      context: context,
      title: S.of(context).loginByWebTitle,
      message: S.of(context).loginByWebMessage,
      actions: [
        PlatformAlertAction(
          label: S.of(context).ok,
          isDefaultAction: true,
        ),
      ],
    );
  }

  void _checkUserLogined() async {
    Dio _dio = Dio();
    // trigger an alert
    EasyLoading.showInfo(S.of(context).checkUserLoginStatus);
    // transfer from webview to cookiejar
    // split by ;
    List<Cookie> webviewCookie = [];
    try {
      webviewCookie = await webviewCookieManager.getCookies(discuz.baseURL);
    } catch (e) {
      EasyLoading.showError(S.of(context).invalidCookie);
      return;
    }

    PersistCookieJar cookieJar = await NetworkUtils.getTemporaryCookieJar();
    // transfer from cookie string
    print("webcookie list ${webviewCookie}");
    await cookieJar.saveFromResponse(Uri.parse(discuz.baseURL), webviewCookie);

    _dio.interceptors.add(DioCookieManager.CookieManager(cookieJar));

    final client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    client.userProfileResult(0).then((value) async {
      if (value.variables.member_uid != 0) {
        // it's a success
        try {
          final dao = await AppDatabase.getUserDao();
          User user = value.variables.getUser(discuz);
          user.discuz = discuz;
          // search in database first
          User? userInDataBase =
              dao.findUsersByDiscuzAndUid(discuz, value.variables.member_uid);
          if (userInDataBase != null) {
            user = userInDataBase;
          } else {
            int id = await dao.insert(user);
            // User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, value.variables.member_uid);
            // if(userInDataBase != null){
            //   user = userInDataBase;
            // }
          }

          // save it in cookiejar
          List<Cookie> cookies =
              await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar =
              await NetworkUtils.getPersistentCookieJarByUser(user);
          print("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          EasyLoading.showSuccess(
              S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).user =
              user;

          Navigator.pop(context);
        } catch (e) {
          VibrationUtils.vibrateErrorIfPossible();
          EasyLoading.showError(e.toString());
        }
      } else {
        print(
            "Get auth ${value.variables.auth} ${value.variables.formHash} ${value}");
        // trigger a alert
        EasyLoading.showToast(S.of(context).websiteNotLogined);
      }
    }).catchError((e, s) {
      print("${e}");
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError(S.of(context).networkFailed);
    });

    // client.checkLoginResult().then((value) async {
    //   if(value.variables.member_uid!=0){
    //     // it's a success
    //     try{
    //       final dao = await AppDatabase.getUserDao();
    //       User user = value.variables.getUser(discuz);
    //       user.discuz = discuz;
    //       // search in database first
    //       User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, value.variables.member_uid);
    //       if(userInDataBase != null){
    //         user = userInDataBase;
    //       }
    //       else{
    //         await dao.insert(user);
    //       }
    //
    //
    //
    //
    //       // save it in cookiejar
    //       List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
    //       PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUser(user);
    //       print("cookies ${cookies}");
    //       savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
    //       // pop the activity
    //       EasyLoading.showSuccess(S.of(context).signInSuccessTitle(user.username, discuz.siteName));
    //       Navigator.pop(context);
    //     }
    //     catch(e){
    //       VibrationUtils.vibrateErrorIfPossible();
    //       EasyLoading.showError(e.toString());
    //     }
    //   }
    //   else{
    //     print("Get auth ${value.variables.auth} ${value.variables.formHash} ${value}");
    //     // trigger a alert
    //     EasyLoading.showToast(S.of(context).websiteNotLogined);
    //   }
    // })
    // .catchError((e,s){
    //   print("${e}");
    //   VibrationUtils.vibrateErrorIfPossible();
    //   EasyLoading.showError(S.of(context).networkFailed);
    //
    // });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data!;
        return Row(
          children: <Widget>[
            PlatformIconButton(
              liquidGlassSymbol: 'chevron.backward',
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        // ignore: deprecated_member_use

                        return;
                      }
                    },
            ),
            PlatformIconButton(
              liquidGlassSymbol: 'chevron.forward',
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        // ignore: deprecated_member_use
                        return;
                      }
                    },
            ),
            PlatformIconButton(
              liquidGlassSymbol: 'arrow.clockwise',
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
