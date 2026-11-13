import 'dart:async';

import 'package:discuz_flutter/page/DiscuzUserNotificationPage.dart';
import 'package:discuz_flutter/page/PrivateMessageDetailPage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/apple_watch_companion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppleWatchCompanionHost extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const AppleWatchCompanionHost({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<AppleWatchCompanionHost> createState() =>
      _AppleWatchCompanionHostState();
}

class _AppleWatchCompanionHostState extends State<AppleWatchCompanionHost> {
  AppleWatchCompanion? _companion;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final companion = AppleWatchCompanion(
        selection: context.read<DiscuzAndUserNotifier>(),
        openItem: (discuz, user, section, item) {
          final navigator = widget.navigatorKey.currentState;
          if (navigator == null) return false;
          final Widget page;
          switch (section) {
            case 'threads':
              page = ViewThreadSliverPage(discuz, user, item['id'] as int);
            case 'messages':
              page = PrivateMessageDetailPage(
                toUid: item['id'] as int,
                toUsername: item['title'] as String,
                forum: discuz,
              );
            case 'notifications':
              page = DiscuzUserNotificationPage();
            default:
              return false;
          }
          unawaited(
            navigator.push(
              platformPageRoute(
                context: navigator.context,
                builder: (_) => page,
              ),
            ),
          );
          return true;
        },
      );
      _companion = companion;
      unawaited(companion.start());
    });
  }

  @override
  void dispose() {
    _companion?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
