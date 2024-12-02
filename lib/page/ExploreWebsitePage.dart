import 'dart:async';
import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/RewriteRuleUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../generated/l10n.dart';
import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import 'ViewThreadSliverPage.dart';

class ExploreWebsitePage extends StatefulWidget {

  final String? initialURL;

  final ValueChanged<int>? onSelectTid;

  ExploreWebsitePage({this.initialURL, required Key key, this.onSelectTid}): super(key: key);

  @override
  ExploreWebsiteState createState() {
    return ExploreWebsiteState(initialURL: this.initialURL, onSelectTid: this.onSelectTid);
  }
}

class ExploreWebsiteState extends State<ExploreWebsitePage> {

  String? initialURL;

  final ValueChanged<int>? onSelectTid;
  ExploreWebsiteState({this.initialURL, this.onSelectTid});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
      }
      else{

        return SafeArea(
            child: InnerWebviewScreen(ValueKey(discuzAndUser.discuz),discuzAndUser.discuz!,
                discuzAndUser.user,
                initialURL: initialURL,
                onSelectTid: this.onSelectTid,
              )
        );
      }
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
        if(snapshot.data == null){
          return Row(
            children: [],
          );
        }
        final WebViewController controller = snapshot.data!;

        return Row(
          children: <Widget>[
            // IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: !webViewReady
            //       ? null
            //       : () async {
            //     VibrationUtils.vibrateWithClickIfPossible();
            //     if (await controller.canGoBack()) {
            //       await controller.goBack();
            //     } else {
            //       // ignore: deprecated_member_use
            //       Scaffold.of(context).showSnackBar(
            //         const SnackBar(content: Text("No back history item")),
            //       );
            //       return;
            //     }
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.arrow_forward),
            //   onPressed: !webViewReady
            //       ? null
            //       : () async {
            //     VibrationUtils.vibrateWithClickIfPossible();
            //     if (await controller.canGoForward()) {
            //       await controller.goForward();
            //     } else {
            //       // ignore: deprecated_member_use
            //       Scaffold.of(context).showSnackBar(
            //         const SnackBar(
            //             content: Text("No forward history item")),
            //       );
            //       return;
            //     }
            //   },
            // ),
            IconButton(
              icon: Icon(PlatformIcons(context).refresh, size: 24,),
              onPressed: !webViewReady
                  ? null
                  : () {
                VibrationUtils.vibrateWithClickIfPossible();
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}

class InnerWebviewScreen extends StatefulWidget{
  Discuz _discuz;
  User? _user;
  String? initialURL;
  final ValueChanged<int>? onSelectTid;

  InnerWebviewScreen(Key key,this._discuz,this._user, {this.initialURL, this.onSelectTid}):super(key: key);

  @override
  InnerWebviewState createState() {
    return InnerWebviewState(this._discuz,this._user,initialURL: this.initialURL, onSelectTid: this.onSelectTid);
  }

}

class InnerWebviewState extends State<InnerWebviewScreen>{
  Discuz _discuz;
  User? _user;
  final ValueChanged<int>? onSelectTid;

  final webviewCookieManager = WebviewCookieManager();
  WebViewController _controller = WebViewController();

  String? initialURL;

  int progress = 0;

  String? webTitle;

  bool cookieLoaded = false;

  InnerWebviewState(this._discuz,this._user,{this.initialURL, this.onSelectTid});

  void loadCookieByUser(Discuz _discuz,User? _user, String initialURL) async {
    if(_user!=null){
      PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUser(_user);
      List<Cookie> cookies =
      await savedCookieJar.loadForRequest(Uri.parse(_discuz.baseURL));
      webviewCookieManager.setCookies(cookies, origin: _discuz.baseURL);

    }
    else{
      webviewCookieManager.clearCookies();
    }


    _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                this.progress = progress;
              });
              print("WebView is loading (progress : $progress%)");
            },
            onNavigationRequest: (NavigationRequest request){
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              VibrationUtils.vibrateWithClickIfPossible();
              print('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              setState(() {
                progress = 0;
              });


              String? title = await _controller.getTitle();
              setState(() {
                webTitle = title;
              });
              print('Page finished loading: $url');
              // check for if link is parsable
              VibrationUtils.vibrateWithClickIfPossible();
              checkIfLinkIsParsable(context, url);

            },


          )
        );

    setState(() {
      cookieLoaded = true;
    });

    _controller.loadRequest(Uri.parse(initialURL));

  }

  @override
  void initState() {
    //log("ExploreWebsite Inner onSelectTid: ${onSelectTid}");
    super.initState();


    if(initialURL == null){
      initialURL = _discuz.baseURL;

    }
    loadCookieByUser(_discuz, _user, initialURL!);

  }

  @override
  Widget build(BuildContext context) {
    if(!cookieLoaded){
      return BlankScreen();
    }
    else{
      return Column(
        children: [
          if(progress!=0 && progress!= 100)
            LinearProgressIndicator(
              value: progress/100,
            ),
          Expanded(
              child: WebViewWidget(
                controller: _controller,
              ))
        ],
      );
    }

  }

  void checkIfLinkIsParsable(BuildContext context,String urlString) async{
    urlString = urlString.replaceAll("&amp;", "&");
    bool urlLauchable = await canLaunchUrl(Uri.parse(urlString));
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    // judge if it is a path
    Uri? tryUri = Uri.tryParse(urlString);
    log("${Uri.parse(urlString).isAbsolute}");
    if(!Uri.parse(urlString).isAbsolute){
      // add a prefix to test if it's a url
      urlString = discuz.baseURL+ "/" + urlString;
      log("Press after link ${urlString} ");
      urlLauchable = await canLaunchUrl(Uri.parse(urlString));
    }


    if(urlLauchable){
      // parse url
      Uri uri = Uri.parse(urlString);
      // check host
      log("Pressed url ${urlString} host ${uri.host}");
      if(uri.host != Uri.parse(discuz.baseURL).host){
        // not website
        return ;
      }

      // check query parameters for full url
      if(uri.queryParameters.containsKey("mod")){
        String modParamter = uri.queryParameters["mod"]!;
        log("recv modParamter ${modParamter}");
        // check forum display
        switch (modParamter){
          case "redirect":{
            if(uri.queryParameters.containsKey("ptid")){
              String tidString = uri.queryParameters["ptid"]!;
              // trigger tid
              if(int.tryParse(tidString) != null){
                int tid = int.tryParse(tidString)!;
                if(onSelectTid == null){
                  await Navigator.push(
                      context,
                      platformPageRoute(context:context,
                          iosTitle: S.of(context).viewThreadTitle,
                          builder: (context) => ViewThreadSliverPage( discuz,user, tid))
                  );
                }
                else{
                  onSelectTid!(tid);
                }

                return;
              }
            }
            break;
          }
          case "viewthread":{
            // check for forum, query fid
            if(uri.queryParameters.containsKey("tid")){
              String tidString = uri.queryParameters["tid"]!;
              // trigger tid
              if(int.tryParse(tidString) != null){
                int tid = int.tryParse(tidString)!;
                if(onSelectTid == null){
                  await Navigator.push(
                      context,
                      platformPageRoute(
                          context:context,
                          iosTitle: S.of(context).viewThreadTitle,
                          builder: (context) => ViewThreadSliverPage( discuz,user, tid))
                  );
                }
                else{
                  onSelectTid!(tid);
                }
                return;
              }
            }
            break;
          }
          case "forumdisplay":{
            // check for forum, query fid
            if(uri.queryParameters.containsKey("fid")){
              String fidString = uri.queryParameters["fid"]!;
              // trigger fid
              if(int.tryParse(fidString) != null){
                int fid = int.tryParse(fidString)!;
                await Navigator.push(
                    context,
                    platformPageRoute(context:context,
                        iosTitle: S.of(context).forumDisplayTitle,
                        builder: (context) => DisplayForumTwoPanePage(discuz,user, fid))
                );
                return;
              }
            }
            break;
          }
          case "space":{
            // check for forum, query fid
            if(uri.queryParameters.containsKey("uid") && !uri.queryParameters.containsKey("do")){
              String uidString = uri.queryParameters["uid"]!;
              // trigger tid
              if(int.tryParse(uidString) != null){
                int uid = int.tryParse(uidString)!;
                await Navigator.push(
                    context,
                    platformPageRoute(
                        context:context,
                        iosTitle: S.of(context).userProfileTitle,
                        builder: (context) => UserProfilePage(discuz,user,uid))
                );
                return;
              }
            }
            break;
          }
        }

      }
      // check short
      String? fid = await RewriteRuleUtils.findFidInURL(discuz, urlString);
      log("read fid: ${fid} from url");
      if(fid!=null && int.tryParse(fid) != null){
        await Navigator.push(
            context,
            platformPageRoute(
                context:context,
                iosTitle: S.of(context).forumDisplayTitle,
                builder: (context) => DisplayForumTwoPanePage(discuz, user, int.tryParse(fid)!))
        );
        return;
      }

      // check short
      String? tid = await RewriteRuleUtils.findTidInURL(discuz, urlString);
      log("read tid: ${fid} from url");
      if(tid!=null && int.tryParse(tid) != null){
        if(onSelectTid == null){
          await Navigator.push(
              context,
              platformPageRoute(
                  context:context,
                  iosTitle: S.of(context).viewThreadTitle,
                  builder: (context) => ViewThreadSliverPage(discuz, user, int.tryParse(tid)!))
          );
        }
        else{
          onSelectTid!(int.tryParse(tid)!);
        }

        return;
      }

      String? uid = await RewriteRuleUtils.findUidInURL(discuz, urlString);
      if(uid!=null && int.tryParse(uid) != null){
        await Navigator.push(
            context,
            platformPageRoute(
                context:context,
                iosTitle: S.of(context).userProfileTitle,
                builder: (context) => UserProfilePage(discuz, user, int.tryParse(uid)!))
        );
        return;
      }
    }
    else{
      // show the link
      // EasyLoading.showError(S.of(context).linkUnableToOpen(urlString));
    }
  }

  @override
  void setState(fn) {
    if(this.mounted) {
      super.setState(fn);
    }
  }
}
