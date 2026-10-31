import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../database/AppDatabase.dart';
import '../page/ViewThreadSliverPage.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/background_new_posts.dart';

class BackgroundNewPostsHost extends StatefulWidget {
  const BackgroundNewPostsHost({
    super.key,
    required this.navigatorKey,
    required this.child,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<BackgroundNewPostsHost> createState() => _BackgroundNewPostsHostState();
}

class _BackgroundNewPostsHostState extends State<BackgroundNewPostsHost> {
  final monitor = BackgroundNewPosts.instance;

  @override
  void initState() {
    super.initState();
    if (!monitor.supported) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_start());
    });
  }

  Future<void> _start() async {
    try {
      monitor.listen(_open);
      final sites = (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
      await monitor.synchronize(sites);
      if (!mounted) return;
      final target = await monitor.takeNotification();
      if (target != null && mounted) await _open(target);
    } catch (error, stack) {
      log(
        'Background post monitor setup failed',
        error: error,
        stackTrace: stack,
      );
    }
  }

  Future<void> _open(NewPostNotificationTarget target) async {
    if (!mounted) return;
    final sites = (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
    final site = sites
        .where((site) => canonicalMonitorUrl(site.baseURL) == target.url)
        .firstOrNull;
    if (site == null || !mounted) return;
    final users = (await AppDatabase.getUserDao()).findAllUsersByDiscuz(site);
    final navigator = widget.navigatorKey.currentState;
    if (!mounted || navigator == null) return;
    unawaited(
      navigator.push(
        platformPageRoute(
          context: navigator.context,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => DiscuzAndUserNotifier()
              ..initDiscuz(site)
              ..setUser(users.firstOrNull),
            child: ViewThreadSliverPage(site, users.firstOrNull, target.tid),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    monitor.listen(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
