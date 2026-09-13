import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../client/PostReviewClient.dart';

/// Today's parsed allowance is a UI hint; every submission is revalidated.
class RatingAllowanceCache {
  static final revision = ValueNotifier<int>(0);
  static final _entries = <String, Map<String, dynamic>>{};
  static Future<void>? _loading;
  static Future<void> _writes = Future.value();
  static const _storageKey = 'rating_allowance_by_date_v1';
  static String key(String site, int uid, String auth) =>
      '${site.replaceAll(RegExp(r'/+$'), '')}:$uid';
  static String _day(DateTime time) => '${time.year}-${time.month}-${time.day}';
  static bool? available(String key, {DateTime? now}) {
    final entry = _entries[key];
    if (entry == null || entry['date'] != _day(now ?? DateTime.now()))
      return null;
    return entry['available'] as bool?;
  }

  static Future<void> load() => _loading ??= (() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonDecode(prefs.getString(_storageKey) ?? '{}');
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.value is Map &&
              entry.value['date'] == _day(DateTime.now()) &&
              entry.value['available'] is bool) {
            _entries.putIfAbsent(
              '${entry.key}',
              () => Map<String, dynamic>.from(entry.value),
            );
          }
        }
      }
      revision.value++;
    } catch (_) {
      /* Missing or malformed cache keeps the shortcut visible. */
    }
  })();
  static void remember(
    String key,
    RatingForm form, {
    Map<String, int> used = const {},
    DateTime? now,
  }) {
    final remaining = <String, int>{};
    final canRate = form.credits
        .map((c) {
          final left = (c.remaining - (used[c.field] ?? 0).abs()).clamp(
            0,
            c.remaining,
          );
          remaining[c.field] = left;
          return left > 0 &&
              ((c.max >= 1 && c.min <= left) ||
                  (c.min <= -1 && c.max >= -left));
        })
        .toList()
        .any((value) => value);
    _entries[key] = {
      'date': _day(now ?? DateTime.now()),
      'remaining': remaining,
      'available': canRate,
    };
    revision.value++;
    _writes = _writes
        .then((_) async {
          await load();
          final prefs = await SharedPreferences.getInstance();
          final today = _day(DateTime.now());
          await prefs.setString(
            _storageKey,
            jsonEncode(
              Map.fromEntries(
                _entries.entries.where((e) => e.value['date'] == today),
              ),
            ),
          );
        })
        .catchError((_) {});
  }

  @visibleForTesting
  static Future<void> flush() => _writes;
}
