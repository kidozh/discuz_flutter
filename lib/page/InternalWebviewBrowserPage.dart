import 'dart:io' show Cookie;
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:provider/provider.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/DiscuzWebviewCookieManager.dart';

import 'package:webview_flutter/webview_flutter.dart';

class InternalWebviewBrowserPage extends StatefulWidget {
  final Discuz _discuz;
  final User? _user;
  final String initialURL;

  InternalWebviewBrowserPage(this._discuz, this._user, this.initialURL);

  @override
  InternalWebviewBrowserState createState() {
    return InternalWebviewBrowserState(
      this._discuz,
      this._user,
      this.initialURL,
    );
  }
}

class InternalWebviewBrowserState extends State<InternalWebviewBrowserPage> {
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  final webviewCookieManager = const DiscuzWebviewCookieManager();
  WebViewController _controller = WebViewController();

  final Discuz _discuz;
  final User? _user;
  final String initialURL;

  InternalWebviewBrowserState(this._discuz, this._user, this.initialURL);

  bool cookieLoaded = false;

  void loadCookieByUser() async {
    final account = context.read<DiscuzAndUserNotifier?>();
    final session = account?.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account?.sessionIdentity);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress1) {
            if (!isCurrent()) return;
            setState(() {
              this.progress = progress1;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            VibrationUtils.vibrateWithClickIfPossible();
            print('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            if (!isCurrent()) return;
            setState(() {
              progress = 0;
            });
            String? title = await this._controller.getTitle();
            if (!isCurrent()) return;
            setState(() {
              webTitle = title;
            });
            print('Page finished loading: $url');
          },
        ),
      );

    final user = account == null ? _user : account.userFor(_discuz);
    final cookies = user != null && _discuz.isSameSite(user.discuz)
        ? await (await NetworkUtils.getPersistentCookieJarByUser(user))
            .loadForRequest(Uri.parse(_discuz.getBaseURLWithAfterfix()))
        : <Cookie>[];
    if (!isCurrent()) return;
    await webviewCookieManager.loadWithCookies(
      cookies,
      origin: _discuz.baseURL,
      isCurrent: isCurrent,
      load: () => _controller.loadRequest(Uri.parse(initialURL)),
    );
    if (!isCurrent()) return;

    setState(() {
      cookieLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCookieByUser();
  }

  int progress = 0;

  String? webTitle;

  @override
  Widget build(BuildContext context) {
    if (!cookieLoaded) {
      return Container(child: BlankScreen());
    } else {
      return PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: webTitle == null
              ? Text(
                  S.of(context).openViaInternalBrowser,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(webTitle!, overflow: TextOverflow.ellipsis),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          trailingActions: <Widget>[
            //NavigationControls(this._controller),
            PlatformIconButton(
              liquidGlassSymbol: 'square.and.arrow.up',
              icon: Icon(
                PlatformIcons(context).share,
                size: 20,
                semanticLabel: S.of(context).share,
              ),
              onPressed: () async {
                String? url = await this._controller.currentUrl();
                if (url != null) {
                  bool canOpen = await canLaunchUrl(Uri.parse(url));
                  if (canOpen) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    await launchUrl(Uri.parse(url));
                  } else {
                    VibrationUtils.vibrateErrorIfPossible();
                    EasyLoading.showToast(S.of(context).linkUnableToOpen(url));
                  }
                }
              },
            ),
            // SampleMenu(_controller.future),
          ],
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                if (progress != 0 && progress != 100)
                  LinearProgressIndicator(value: progress / 100),
                Expanded(child: WebViewWidget(controller: this._controller)),
              ],
            );
          },
        ),
        //floatingActionButton: checkButton(),
      );
    }
  }
}

// class NavigationControls extends StatelessWidget {
//   const NavigationControls(this._webViewControllerFuture)
//       : assert(_webViewControllerFuture != null);
//
//   final WebViewController _webViewControllerFuture;
//
//   @override
//   Widget build(BuildContext context) {
//
//     return FutureBuilder<WebViewController>(
//       future: _webViewControllerFuture,
//       builder:
//           (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
//         final bool webViewReady =
//             snapshot.connectionState == ConnectionState.done;
//         if(snapshot.data == null){
//           return Row(
//             children: [],
//           );
//         }
//         final WebViewController controller = snapshot.data!;
//
//         return Row(
//           children: <Widget>[
//             // IconButton(
//             //   icon: const Icon(Icons.arrow_back),
//             //   onPressed: !webViewReady
//             //       ? null
//             //       : () async {
//             //     VibrationUtils.vibrateWithClickIfPossible();
//             //     if (await controller.canGoBack()) {
//             //       await controller.goBack();
//             //     } else {
//             //       // ignore: deprecated_member_use
//             //       Scaffold.of(context).showSnackBar(
//             //         const SnackBar(content: Text("No back history item")),
//             //       );
//             //       return;
//             //     }
//             //   },
//             // ),
//             // IconButton(
//             //   icon: const Icon(Icons.arrow_forward),
//             //   onPressed: !webViewReady
//             //       ? null
//             //       : () async {
//             //     VibrationUtils.vibrateWithClickIfPossible();
//             //     if (await controller.canGoForward()) {
//             //       await controller.goForward();
//             //     } else {
//             //       // ignore: deprecated_member_use
//             //       Scaffold.of(context).showSnackBar(
//             //         const SnackBar(
//             //             content: Text("No forward history item")),
//             //       );
//             //       return;
//             //     }
//             //   },
//             // ),
//             IconButton(
//               icon: Icon(PlatformIcons(context).refresh, size: 24,),
//               onPressed: !webViewReady
//                   ? null
//                   : () {
//                 VibrationUtils.vibrateWithClickIfPossible();
//                 controller.reload();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
