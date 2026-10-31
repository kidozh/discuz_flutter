import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../entity/Discuz.dart';
import 'discuz_json.dart';

String canonicalMonitorUrl(String url) {
  final uri = Uri.parse(url.trim());
  if (!{'https', 'http'}.contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    throw const FormatException('Invalid forum URL');
  }
  return uri
      .replace(query: '', fragment: '')
      .toString()
      .replaceFirst(RegExp(r'[?#]+$'), '')
      .replaceFirst(RegExp(r'/+$'), '');
}

class MonitoredForum {
  const MonitoredForum({
    required this.url,
    required this.name,
    this.enabled = false,
    this.seeded = false,
    this.lastCheck,
    this.failed = false,
  });

  final String url, name;
  final bool enabled, seeded, failed;
  final DateTime? lastCheck;

  factory MonitoredForum.fromMap(Map<String, dynamic> data) => MonitoredForum(
    url: canonicalMonitorUrl(discuzString(data['url'])),
    name: discuzString(data['name']),
    enabled: data['enabled'] == true,
    seeded: data['seeded'] == true,
    lastCheck: discuzInt(data['lastCheck']) > 0
        ? DateTime.fromMillisecondsSinceEpoch(discuzInt(data['lastCheck']))
        : null,
    failed: data['failed'] == true,
  );
}

class NewPostMonitorState {
  const NewPostMonitorState({
    this.enabled = false,
    this.notificationsAllowed = false,
    this.sites = const [],
  });
  final bool enabled, notificationsAllowed;
  final List<MonitoredForum> sites;

  factory NewPostMonitorState.fromMap(Map<String, dynamic> data) =>
      NewPostMonitorState(
        enabled: data['enabled'] == true,
        notificationsAllowed: data['notificationsAllowed'] == true,
        sites: (data['sites'] as List? ?? [])
            .map((row) => MonitoredForum.fromMap(discuzMap(row)))
            .toList(),
      );
}

class NewPostNotificationTarget {
  const NewPostNotificationTarget(this.url, this.tid);
  final String url;
  final int tid;

  static NewPostNotificationTarget? parse(Object? value) {
    try {
      final data = discuzMap(value);
      final tid = discuzInt(data['tid']);
      if (tid <= 0) return null;
      return NewPostNotificationTarget(
        canonicalMonitorUrl(discuzString(data['site_url'])),
        tid,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Android owns the scheduler, SQLite deduplication and notifications. No
/// foreground timers or background Flutter engine are needed for a crawl.
class BackgroundNewPosts {
  BackgroundNewPosts({MethodChannel? channel, bool? supported})
    : channel =
          channel ??
          const MethodChannel('com.kidozh.discuz_flutter/background_new_posts'),
      supported = supported ?? Platform.isAndroid;

  static final instance = BackgroundNewPosts();
  final MethodChannel channel;
  final bool supported;

  Future<NewPostMonitorState> _state(String method, [Object? arguments]) async {
    if (!supported) return const NewPostMonitorState();
    final value = await channel.invokeMethod<Object?>(method, arguments);
    if (value is! Map) throw const FormatException('Invalid monitor state');
    return NewPostMonitorState.fromMap(discuzMap(value));
  }

  Future<NewPostMonitorState> synchronize(List<Discuz> sites) =>
      _state('syncSites', [
        for (final site in sites)
          {
            'url': canonicalMonitorUrl(site.baseURL),
            'name': site.siteName,
            'charset': site.charset,
          },
      ]);
  Future<NewPostMonitorState> load() => _state('getState');
  Future<NewPostMonitorState> setEnabled(bool value) =>
      _state('setEnabled', value);
  Future<NewPostMonitorState> setSiteEnabled(String url, bool value) => _state(
    'setSiteEnabled',
    {'url': canonicalMonitorUrl(url), 'enabled': value},
  );
  Future<void> removeSite(String url) async {
    if (supported) await _state('removeSite', canonicalMonitorUrl(url));
  }

  void listen(Future<void> Function(NewPostNotificationTarget)? onOpen) {
    if (!supported) return;
    channel.setMethodCallHandler(
      onOpen == null
          ? null
          : (call) async {
              if (call.method != 'openPost') return;
              final target = NewPostNotificationTarget.parse(call.arguments);
              if (target != null) await onOpen(target);
            },
    );
  }

  Future<NewPostNotificationTarget?> takeNotification() async => !supported
      ? null
      : NewPostNotificationTarget.parse(
          await channel.invokeMethod<Object?>('takeNotification'),
        );
}
