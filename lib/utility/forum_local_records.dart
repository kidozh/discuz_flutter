import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';

typedef ForumRecord = Map<String, dynamic>;

/// Account-local lists. Updates are serialized so a download finishing while
/// another starts cannot replace the other entry.
class ForumLocalRecords extends ValueNotifier<List<ForumRecord>> {
  ForumLocalRecords._(this._key) : super(const []) {
    _pending = _load();
  }

  static final _lists = <String, ForumLocalRecords>{};

  factory ForumLocalRecords(String category, Discuz forum, User? user) {
    final key =
        'forum_local_v1_${jsonEncode([category, forum.siteIdentity, user?.uid ?? 0])}';
    return _lists.putIfAbsent(key, () => ForumLocalRecords._(key));
  }

  final String _key;
  late Future<void> _pending;
  Future<void> get ready => _pending;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final records = <ForumRecord>[];
    for (final entry in raw) {
      try {
        if (jsonDecode(entry) case final ForumRecord record) {
          records.add(Map.unmodifiable(record));
        }
      } on FormatException {
        continue;
      }
    }
    value = List.unmodifiable(records);
  }

  Future<void> update(List<ForumRecord> Function(List<ForumRecord>) change) {
    final write = _pending.then((_) async {
      final next = change(value);
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setStringList(_key, next.map(jsonEncode).toList())) {
        throw StateError('Could not save forum records');
      }
      value = List.unmodifiable(next.map(Map<String, dynamic>.unmodifiable));
    });
    _pending = write.catchError((Object _) {});
    return write;
  }

  Future<void> put(ForumRecord record, {int? limit}) => update((records) {
    final next = [record, ...records.where((r) => r['id'] != record['id'])];
    return limit == null ? next : next.take(limit).toList();
  });

  Future<void> remove(Object id) =>
      update((records) => records.where((r) => r['id'] != id).toList());
}
