import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'AiPostText.dart';
import 'NetworkUtils.dart';
import 'apple_watch_reader.dart';

import 'package:discuz_flutter/client/ForumInteractionClient.dart';
import 'package:dio/dio.dart';

/// Only presentation data crosses the bridge. Cookies, auth and formhash stay
/// in the iPhone's existing account-specific network stack.
class WatchSection {
  final BaseVariableResult variables;
  final List<Map<String, Object>> items;

  const WatchSection(this.variables, this.items);
}

String watchPreview(String text, [int limit = 350]) {
  final plain = AiPostText.plainText(text);
  final runes = plain.runes;
  return runes.length <= limit
      ? plain
      : '${String.fromCharCodes(runes.take(limit))}…';
}

Future<WatchSection> loadWatchSection(
  Discuz discuz,
  User? user,
  String section,
) async {
  final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 12);
  final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
  try {
    switch (section) {
      case 'threads':
        final result = await client.hotThreadResult(1);
        if (result.variables.member_uid == (user?.uid ?? 0) &&
            result.getErrorString() != null) {
          throw StateError('api_error');
        }
        return WatchSection(result.variables, [
          for (final thread
              in result.variables.hotThreadList
                  .where((thread) => thread.tid > 0)
                  .take(8))
            {
              'id': thread.tid,
              'title': watchPreview(thread.subject, 100),
              'subtitle': watchPreview(thread.author, 50),
              'body': watchPreview(thread.message),
              'unread': false,
              'replies': thread.replies,
            },
        ]);
      case 'notifications':
        final result = await client.userNotificationResult(1);
        if (result.variables.member_uid == (user?.uid ?? 0) &&
            result.getErrorString() != null) {
          throw StateError('api_error');
        }
        return WatchSection(result.variables, [
          for (final notice
              in result.variables.notificationList
                  .where((notice) => notice.id > 0)
                  .take(8))
            {
              'id': notice.id,
              'title': watchPreview(notice.author, 50),
              'subtitle': '',
              'body': watchPreview(notice.note),
              'unread': notice.isNew == '1',
              'replies': 0,
              'threadID': watchNotificationThreadID(
                discuz.baseURL,
                notice.fromId,
                notice.fromIdType,
                notice.note,
              ),
            },
        ]);
      case 'messages':
        final result = await client.privateMessagePortalResult(1);
        if (result.variables.member_uid == (user?.uid ?? 0) &&
            result.getErrorString() != null) {
          throw StateError('api_error');
        }
        return WatchSection(result.variables, [
          for (final message
              in result.variables.pmList
                  .where((message) => message.toUid > 0)
                  .take(8))
            {
              'id': message.toUid,
              'title': watchPreview(message.toUserName, 50),
              'subtitle': watchPreview(message.subject, 100),
              'body': watchPreview(message.message),
              'unread': message.isNew,
              'replies': 0,
            },
        ]);
      default:
        throw ArgumentError.value(section, 'section');
    }
  } finally {
    dio.close(force: true);
  }
}

typedef WatchSectionLoader = Future<WatchSection> Function(
  Discuz discuz,
  User? user,
  String section,
);
typedef WatchItemOpener = bool Function(
  Discuz discuz,
  User? user,
  String section,
  Map<String, Object> item,
);

class AppleWatchCompanion with WidgetsBindingObserver {
  static const channel = MethodChannel('com.kidozh.discuz_flutter/apple_watch');
  static const sections = {'threads', 'notifications', 'messages'};

  final DiscuzAndUserNotifier selection;
  final WatchSectionLoader loadSection;
  final WatchItemOpener openItem;
  final Map<String, WatchSection> _content = {};
  final Map<String, String> _errors = {};
  final Map<String, Future<void>> _requests = {};
  final Map<String, Future<Map<String, Object>>> _writes = {};
  final List<String> _completedWrites = [];
  Timer? _refreshTimer;
  Timer? _selectionTimer;
  String _identity = '';
  int _generation = 0;
  int _revision = 0;
  int _updatedAt = 0;
  NoticeCount _notice = NoticeCount();
  bool _sessionExpired = false;
  bool _installed = false;
  bool _disposed = false;
  bool _foreground = true;

  AppleWatchCompanion({
    required this.selection,
    required this.openItem,
    this.loadSection = loadWatchSection,
  });

  User? get _user => selection.user;

  String get _currentIdentity =>
      jsonEncode([selection.discuz?.baseURL ?? '', _user?.uid ?? 0]);

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    selection.addListener(_selectionChanged);
    channel.setMethodCallHandler(_handleCall);
    _selectionChanged();
    try {
      _installed = await channel.invokeMethod<bool>('ready') ?? false;
      if (_installed && !_disposed) await refresh();
    } on MissingPluginException {
      // Allows the phone UI to run in tests and before a native rebuild.
    } on PlatformException {
      log('Apple Watch connection is unavailable');
    }
    if (_disposed) return;
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_foreground && _installed) unawaited(refresh());
    });
  }

  void _selectionChanged() {
    if (_disposed) return;
    _generation++;
    _identity = _currentIdentity;
    _content.clear();
    _requests.clear();
    _writes.clear();
    _completedWrites.clear();
    _errors.clear();
    _notice = NoticeCount();
    _updatedAt = 0;
    _sessionExpired = false;
    unawaited(_publish());
    _selectionTimer?.cancel();
    _selectionTimer = Timer(const Duration(milliseconds: 300), () {
      if (_installed) unawaited(refresh());
    });
  }

  Map<String, Object> get snapshot => {
    'schema': 1,
    'revision': _revision,
    'contextID': _identity,
    'siteName': watchPreview(selection.discuz?.siteName ?? '', 60),
    'username': watchPreview(_user?.username ?? '', 50),
    'hasSite': selection.discuz != null,
    'signedIn': _user != null,
    'sessionExpired': _sessionExpired,
    'updatedAt': _updatedAt,
    'notices': (_notice.newprompt + _notice.newmypost).clamp(0, 9999),
    'messagesUnread': _notice.newpm.clamp(0, 9999),
    'loadedSections': _content.keys.toList(),
    'errors': Map<String, String>.of(_errors),
    for (final section in sections) section: _content[section]?.items ?? [],
  };

  Future<void> _publish() async {
    if (_disposed) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    _revision = now > _revision ? now : _revision + 1;
    try {
      await channel.invokeMethod<void>('publishSnapshot', snapshot);
    } on MissingPluginException {
      // The service is only started on iOS by its host.
    } on PlatformException {
      log('Apple Watch snapshot could not be delivered');
    }
  }

  Future<void> refresh([String section = 'threads']) {
    if (_disposed || !sections.contains(section)) return Future.value();
    final existing = _requests[section];
    if (existing != null) return existing;
    final discuz = selection.discuz;
    final user = _user;
    if (discuz == null || (section != 'threads' && user == null)) {
      return _publish();
    }
    final generation = _generation;
    final request = _load(discuz, user, section, generation);
    _requests[section] = request;
    unawaited(
      request.whenComplete(() {
        if (generation == _generation) _requests.remove(section);
      }),
    );
    return request;
  }

  Future<void> _load(
    Discuz discuz,
    User? user,
    String section,
    int generation,
  ) async {
    try {
      final result = await loadSection(
        discuz,
        user,
        section,
      ).timeout(const Duration(seconds: 20));
      if (_disposed || generation != _generation) return;
      // Never publish data returned for a different or expired cookie session.
      if (result.variables.member_uid != (user?.uid ?? 0)) {
        // Invalidate other sections already in flight for this session too.
        _generation++;
        _requests.clear();
        _content.clear();
        _errors.clear();
        _notice = NoticeCount();
        _sessionExpired = true;
      } else {
        _sessionExpired = false;
        _content[section] = result;
        _notice = result.variables.noticeCount;
        _errors.remove(section);
        _updatedAt = DateTime.now().millisecondsSinceEpoch;
      }
    } catch (_) {
      if (_disposed || generation != _generation) return;
      _errors[section] = 'load_failed';
    }
    await _publish();
  }

  Future<Object?> _handleCall(MethodCall call) async {
    if (_disposed) return false;
    switch (call.method) {
      case 'loadDetail':
      case 'sendReply':
        return _readerCommand(call.method, call.arguments);
      case 'watchStateChanged':
        _installed = call.arguments == true;
        if (_installed) await refresh();
        return null;
      case 'refresh':
        _installed = true;
        final args = call.arguments;
        final section = args is Map ? args['section'] : null;
        await refresh(section is String ? section : 'threads');
        return snapshot;
      case 'openItem':
        final args = call.arguments;
        if (args is! Map ||
            args['contextID'] != _currentIdentity ||
            _sessionExpired) {
          return false;
        }
        final section = args['section'];
        final discuz = selection.discuz;
        if (section is! String || discuz == null) return false;
        final items = _content[section]?.items ?? [];
        for (final item in items) {
          if (item['id'] == args['id']) {
            return openItem(discuz, _user, section, item);
          }
        }
        return false;
      default:
        throw MissingPluginException();
    }
  }

  Future<Map<String, Object>> _readerCommand(
    String command,
    Object? arguments,
  ) async {
    if (arguments is! Map ||
        arguments['contextID'] != _currentIdentity ||
        _sessionExpired) {
      return {'error': 'account_changed'};
    }
    final section = arguments['section'];
    final discuz = selection.discuz;
    final user = _user;
    if (section is! String ||
        !sections.contains(section) ||
        discuz == null ||
        (section != 'threads' && user == null)) {
      return {'error': 'account_changed'};
    }
    if (command == 'sendReply' && user == null) {
      return {'error': 'reply_unavailable'};
    }
    final items = _content[section]?.items.where(
      (item) => item['id'] == arguments['id'],
    );
    if (items == null || items.isEmpty) return {'error': 'content_changed'};
    final item = Map<String, Object>.of(items.first);
    final generation = _generation;
    bool current() =>
        !_disposed &&
        generation == _generation &&
        arguments['contextID'] == _currentIdentity;
    final page = arguments['page'] ?? 1;
    final part = arguments['part'] ?? 0;
    if (page is! int ||
        page < 1 ||
        page > 100000 ||
        part is! int ||
        part < 0 ||
        part > 100000) {
      return {'error': 'invalid_request'};
    }
    Future<Map<String, Object>> perform() async {
      try {
        return await withWatchReader(discuz, user, current, (reader) async {
          if (command == 'sendReply') {
            if (user == null) return {'error': 'reply_unavailable'};
            final text = arguments['text'];
            if (text is! String ||
                text.trim().isEmpty ||
                text.runes.length > 1000) {
              return {'error': 'invalid_reply'};
            }
            await reader.send(section, item, text);
            return {'sent': true};
          }
          final detail = await reader.load(section, item, page, part);
          if (!current()) return {'error': 'account_changed'};
          return {'detail': detail};
        });
      } on WatchSessionExpired {
        if (current()) {
          _generation++;
          _requests.clear();
          _content.clear();
          _errors.clear();
          _notice = NoticeCount();
          _sessionExpired = true;
          await _publish();
        }
        return {'error': 'session_expired'};
      } on DioException {
        return {
          'error': command == 'sendReply' ? 'send_unknown' : 'load_failed',
        };
      } on ForumApiException catch (error) {
        return {
          'error': command == 'sendReply'
              ? ({
                      'invalid_response',
                      'empty_response',
                      'invalid_response_format',
                      'unexpected_markup_response',
                    }.contains(error.code)
                    ? 'send_unknown'
                    : 'send_rejected')
              : 'load_failed',
          'message': watchPreview(error.message, 180),
        };
      } catch (_) {
        return {
          'error': current()
              ? (command == 'sendReply' ? 'reply_unavailable' : 'load_failed')
              : 'account_changed',
        };
      }
    }

    if (command != 'sendReply') return perform();
    final requestID = arguments['requestID'];
    if (requestID is! String ||
        !RegExp(r'^[a-zA-Z0-9-]{16,80}$').hasMatch(requestID)) {
      return {'error': 'invalid_request'};
    }
    // Keep indeterminate outcomes too: transport retries must never duplicate a POST.
    if (_writes.containsKey(requestID)) return _writes[requestID]!;
    final result = perform();
    _writes[requestID] = result;
    unawaited(
      result.then((_) {
        if (!current()) return;
        _completedWrites.add(requestID);
        if (_completedWrites.length > 100) {
          _writes.remove(_completedWrites.removeAt(0));
        }
      }),
    );
    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _installed) unawaited(refresh());
  }

  void dispose() {
    _disposed = true;
    _generation++;
    _refreshTimer?.cancel();
    _selectionTimer?.cancel();
    selection.removeListener(_selectionChanged);
    WidgetsBinding.instance.removeObserver(this);
    channel.setMethodCallHandler(null);
  }
}
