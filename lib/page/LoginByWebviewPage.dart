import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
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

import '../utility/DiscuzWebviewCookieManager.dart';

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
  final webviewCookieManager = const DiscuzWebviewCookieManager();
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
      await webviewCookieManager.loadWithCookies(
        const [],
        origin: discuz.baseURL,
        isCurrent: () => mounted,
        load: () => _controller.loadRequest(
          Uri.parse(
            '${discuz.getBaseURLWithAfterfix()}member.php?mod=logging&action=login',
          ),
        ),
      );
    } catch (error) {
      debugPrint('Unable to clear WebView cookies before login: $error');
    }
  }

  void _loadWidgetControllerSetting() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
        ),
      );
  }

  bool websiteLoaded = false;
  bool _checkingLogin = false;

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
          if (websiteLoaded && !_checkingLogin)
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
      body: Builder(
        builder: (BuildContext context) {
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
        },
      ),
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
        PlatformAlertAction(label: S.of(context).ok, isDefaultAction: true),
      ],
    );
  }

  Future<void> _checkUserLogined() async {
    if (_checkingLogin) return;
    final selection = context.read<DiscuzAndUserNotifier>();
    final session = selection.sessionIdentity;
    setState(() => _checkingLogin = true);
    try {
      await _verifyWebLogin(selection, session);
    } catch (_) {
      if (mounted) EasyLoading.showError(S.of(context).networkFailed);
    } finally {
      if (mounted) setState(() => _checkingLogin = false);
    }
  }

  Future<void> _verifyWebLogin(
    DiscuzAndUserNotifier selection,
    Object session,
  ) async {
    EasyLoading.showInfo(S.of(context).checkUserLoginStatus);
    final webviewCookie = await _readWebViewCookies();
    if (!mounted) return;
    if (webviewCookie == null) {
      EasyLoading.showError(S.of(context).invalidCookie);
      return;
    }

    CookieJar cookieJar = await NetworkUtils.getTemporaryCookieJar();
    // transfer from cookie string
    debugPrint('Read ${webviewCookie.length} cookies from the login WebView');
    final origin = Uri.parse(discuz.getBaseURLWithAfterfix());
    await cookieJar.saveFromResponse(origin, webviewCookie);

    final dio = NetworkUtils.getDio();
    NetworkUtils.addCookieManager(dio, cookieJar);

    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    await client
        .userProfileResult(0)
        .then((value) async {
          if (!mounted ||
              (discuz.isSameSite(selection.discuz) &&
                  !identical(session, selection.sessionIdentity))) {
            if (mounted) EasyLoading.dismiss();
            return;
          }
          if (value.variables.member_uid != 0) {
            // it's a success
            try {
              final dao = await AppDatabase.getUserDao();
              final user = value.variables.getUser(discuz);
              // search in database first
              User? userInDataBase = dao.findUsersByDiscuzAndUid(
                discuz,
                value.variables.member_uid,
              );
              if (userInDataBase != null) {
                await dao.insertWithKey(userInDataBase.key, user);
              } else {
                await dao.insert(user);
              }

              // save it in cookiejar
              List<Cookie> cookies = await cookieJar.loadForRequest(origin);
              await NetworkUtils.replacePersistentCookiesForUser(
                user,
                origin,
                cookies,
              );
              if (!mounted) return;
              // pop the activity
              EasyLoading.showSuccess(
                S
                    .of(context)
                    .signInSuccessTitle(user.username, discuz.siteName),
              );
              selection.setUser(user, expectedSession: session);

              Navigator.pop(context);
            } catch (e) {
              VibrationUtils.vibrateErrorIfPossible();
              EasyLoading.showError(e.toString());
            }
          } else {
            debugPrint(
              'The login WebView did not return an authenticated user',
            );
            // trigger a alert
            EasyLoading.showToast(S.of(context).websiteNotLogined);
          }
        })
        .catchError((e, s) {
          print("${e}");
          VibrationUtils.vibrateErrorIfPossible();
          EasyLoading.showError(S.of(context).networkFailed);
        })
        .whenComplete(() => dio.close());

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

  Future<List<Cookie>?> _readWebViewCookies() async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await webviewCookieManager.getCookies(
          discuz.getBaseURLWithAfterfix(),
        );
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }
    }
    debugPrint(
      'Unable to read WebView cookies for ${discuz.host}: $lastError\n'
      '$lastStackTrace',
    );
    return null;
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
                  icon: Icon(PlatformIcons(context).back),
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
                  icon: Icon(PlatformIcons(context).forward),
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
                  icon: Icon(PlatformIcons(context).refresh),
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
