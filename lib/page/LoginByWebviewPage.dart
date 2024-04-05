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
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';


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
  final webviewCookieManager = WebviewCookieManager();
  WebViewController _controller = WebViewController();


  final Discuz discuz;

  _LoginByWebviewState(this.discuz);

  @override
  void initState() {
    super.initState();
    webviewCookieManager.clearCookies();
    _triggerNotificationDialog();
    _loadWidgetControllerSetting();

  }

  void _loadWidgetControllerSetting(){
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
        )
      );

    _controller.loadRequest(Uri.parse(discuz.baseURL+"/member.php?mod=logging&action=login"));
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
              icon: Icon(PlatformIcons(context).checkMark, size: 24,),
              onPressed: () {
                VibrationUtils.vibrateWithClickIfPossible();
                _checkUserLogined();
              },
            ),
          if(!websiteLoaded)
            Container(
              width: 24,
              height: 24,
              child: PlatformCircularProgressIndicator(),
            ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebViewWidget(
          controller: _controller,
        );
      }),
      //floatingActionButton: checkButton(),
    );
  }

  Widget checkButton() {
    return FloatingActionButton(
      onPressed: () async {
        // final String url = (await controller.data!.currentUrl())!;
        // ignore: deprecated_member_use
        _checkUserLogined();
      },
      child: const Icon(Icons.login),
    );
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
          final dao = await AppDatabase.getUserDao();
          User user = value.variables.getUser(discuz);
          user.discuz = discuz;
          // search in database first
          User? userInDataBase = dao.findUsersByDiscuzAndUid(discuz, value.variables.member_uid);
          if(userInDataBase != null){
            user = userInDataBase;
          }
          else{
            await dao.insert(user);
          }




          // save it in cookiejar
          List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUser(user);
          print("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          EasyLoading.showSuccess(S.of(context).signInSuccessTitle(user.username, discuz.siteName));
          Navigator.pop(context);
        }
        catch(e){
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
            IconButton(
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
            IconButton(
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