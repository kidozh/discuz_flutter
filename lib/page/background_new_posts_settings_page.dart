import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/background_new_posts.dart';

class BackgroundNewPostsSettingsPage extends StatefulWidget {
  const BackgroundNewPostsSettingsPage({
    super.key,
    this.monitor,
    this.loadSites,
    this.requestNotifications,
    this.openNotificationSettings,
  });
  final BackgroundNewPosts? monitor;
  final Future<List<Discuz>> Function()? loadSites;
  final Future<bool> Function()? requestNotifications;
  final Future<void> Function()? openNotificationSettings;
  @override
  State<BackgroundNewPostsSettingsPage> createState() =>
      _BackgroundNewPostsSettingsPageState();
}

class _BackgroundNewPostsSettingsPageState
    extends State<BackgroundNewPostsSettingsPage>
    with WidgetsBindingObserver {
  late final monitor = widget.monitor ?? BackgroundNewPosts.instance;
  NewPostMonitorState? _state;
  bool _busy = false, _error = false, _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy) _load();
  }

  Future<void> _load() => _update(() async {
    final sites = widget.loadSites != null
        ? await widget.loadSites!()
        : (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
    final state = await monitor.synchronize(sites);
    if (mounted) setState(() => _permissionDenied = false);
    return state;
  });

  Future<void> _update(Future<NewPostMonitorState> Function() save) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final state = await save();
      if (mounted) setState(() => _state = state);
    } catch (error) {
      if (mounted) {
        setState(() {
          if (error is PlatformException &&
              error.code == 'notifications_disabled') {
            _permissionDenied = true;
          } else {
            _error = true;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enable(bool value) => _update(() async {
    if (value) {
      final granted = widget.requestNotifications != null
          ? await widget.requestNotifications!()
          : (await Permission.notification.request()).isGranted;
      if (!granted) {
        if (mounted) setState(() => _permissionDenied = true);
        return monitor.load();
      }
    }
    final state = await monitor.setEnabled(value);
    if (mounted) setState(() => _permissionDenied = false);
    return state;
  });

  String _status(MonitoredForum site) {
    final s = S.of(context);
    if (site.failed) return s.backgroundNewPostsCheckFailed;
    if (site.lastCheck == null) return s.backgroundNewPostsWaiting;
    return s.backgroundNewPostsLastCheck(
      DateFormat.yMd().add_Hm().format(site.lastCheck!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = _state;
    final sites = [...?state?.sites]..sort((a, b) => a.name.compareTo(b.name));
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(s.backgroundNewPostsTitle),
        liquidGlassUseNativeToolbar: false,
      ),
      iosContentPadding: true,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          PlatformCard(
            child: PlatformListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(s.backgroundNewPostsTitle),
              trailing: PlatformSwitch(
                key: const ValueKey('new-posts-master'),
                value: state?.enabled ?? false,
                onChanged: state == null || _busy ? null : _enable,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.backgroundNewPostsDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  s.backgroundNewPostsPublicOnly,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (_permissionDenied ||
              (state?.enabled == true && !state!.notificationsAllowed))
            PlatformCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.backgroundNewPostsPermissionRequired),
                    PlatformTextButton(
                      onPressed: () async {
                        if (widget.openNotificationSettings != null) {
                          await widget.openNotificationSettings!();
                        } else {
                          await openAppSettings();
                        }
                      },
                      child: Text(s.backgroundNewPostsSystemSettings),
                    ),
                  ],
                ),
              ),
            ),
          if (_error)
            PlatformCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(s.backgroundNewPostsLoadFailed),
                    PlatformTextButton(
                      onPressed: _busy ? null : _load,
                      child: Text(s.retry),
                    ),
                  ],
                ),
              ),
            ),
          if (_busy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              s.backgroundNewPostsSites,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (state != null && sites.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(s.backgroundNewPostsNoSites),
            ),
          if (state?.enabled == true &&
              sites.isNotEmpty &&
              sites.every((site) => !site.enabled))
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(s.backgroundNewPostsSelectSites),
            ),
          for (final site in sites)
            PlatformCard(
              child: PlatformListTile(
                title: Text(site.name),
                subtitle: Text('${site.url}\n${_status(site)}'),
                trailing: PlatformSwitch(
                  key: ValueKey('new-posts-site:${site.url}'),
                  value: site.enabled,
                  onChanged: _busy
                      ? null
                      : (value) => _update(
                          () => monitor.setSiteEnabled(site.url, value),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
