import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/DiscuzWebviewCookieManager.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as DioCookieManager;
import 'package:discuz_flutter/client/MobileApiClient.dart';


class LoginByWebviewPage extends StatelessWidget{

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
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final webviewCookieManager = WebviewCookieManager();


  final Discuz discuz;

  _LoginByWebviewState(this.discuz);

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    webviewCookieManager.clearCookies();
    _triggerNotificationDialog();
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
          if(websiteLoaded)
            IconButton(
              icon: Icon(PlatformIcons(context).checkMark),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _checkUserLogined();
              },
            ),
          if(!websiteLoaded)
            PlatformCircularProgressIndicator(),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: discuz.baseURL+"/member.php?mod=logging&action=login",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async{
            _controller.complete(webViewController);

          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
            setState(() {
              websiteLoaded = false;
            });
          },
          onPageFinished: (String url) async{
            print('Page finished loading: $url');
            setState(() {
              websiteLoaded = true;
            });
            final gotCookies = await webviewCookieManager.getCookies(url);

            // for (var item in gotCookies) {
            //   print(item);
            // }
          },
          gestureNavigationEnabled: true,
        );
      }),
      //floatingActionButton: checkButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget checkButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                // final String url = (await controller.data!.currentUrl())!;
                // ignore: deprecated_member_use
                _checkUserLogined();
              },
              child: const Icon(Icons.login),
            );
          }
          return Container();
        });
  }

  void _triggerNotificationDialog() async{

    print("show dialog");
    await Future.delayed(Duration(seconds: 1));
    await showPlatformDialog(context: context, builder: (context){
      return PlatformAlertDialog(
        title: Text(S.of(context).loginByWebTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).loginByWebMessage),
          ],
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop(false);
          }, child: Text(S.of(context).ok))
        ],
      );
    });
  }

  void _checkUserLogined() async{
    Dio _dio = Dio();
    var controller = await _controller.future;
    // trigger an alert
    EasyLoading.showInfo(S.of(context).checkUserLoginStatus);
    // transfer from webview to cookiejar
    // split by ;
    List<Cookie> webviewCookie = [];
    try{
       webviewCookie = await webviewCookieManager.getCookies(discuz.baseURL);
    }
    catch (e){
      EasyLoading.showError(S.of(context).invalidCookie);
      return;
    }


    PersistCookieJar cookieJar = await NetworkUtils.getTemporaryCookieJar();
    // transfer from cookie string
    print("webcookie list ${webviewCookie}");
    await cookieJar.saveFromResponse(Uri.parse(discuz.baseURL), webviewCookie);

    _dio.interceptors.add(DioCookieManager.CookieManager(cookieJar));

    final client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    client.checkLoginResult().then((value) async {
      if(value.variables.member_uid!=0){
        // it's a success
        try{
          final db = await DBHelper.getAppDb();
          final dao = db.userDao;
          User user = value.variables.getUser(discuz);
          // search in database first
          User? userInDataBase = await dao.findUsersByDiscuzIdAndUid(discuz.id!, value.variables.member_uid);
          if(userInDataBase != null){
            user.id = userInDataBase.id;
          }

          int primaryKey = await dao.insert(user);

          // save it in cookiejar
          List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUserId(primaryKey);
          print("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          EasyLoading.showSuccess(S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          Navigator.pop(context);
        }
        catch(e,s){
          VibrationUtils.vibrateErrorIfPossible();
          EasyLoading.showError(e.toString());
        }
      }
      else{
        print("Get auth ${value.variables.auth} ${value.variables.formHash} ${value}");
        // trigger a alert
        EasyLoading.showToast(S.of(context).websiteNotLogined);
      }
    })
    .catchError((e,s){
      print("${e}");
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError(S.of(context).networkFailed);

    });

  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data!, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data!, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data!, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data!, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data!, context);
                break;
              case MenuOptions.navigationDelegate:
                // _onNavigationDelegateExample(controller.data!, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies = await controller.evaluateJavascript('document.cookie');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  // void _onNavigationDelegateExample(
  //     WebViewController controller, BuildContext context) async {
  //   final String contentBase64 =
  //   base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
  //   await controller.loadUrl('data:text/html;base64,$contentBase64');
  // }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  // ignore: deprecated_member_use
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("No back history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                } else {
                  // ignore: deprecated_member_use
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No forward history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
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