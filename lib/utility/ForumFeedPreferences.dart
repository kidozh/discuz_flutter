import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import 'discuz_json.dart';

class ForumFeedPreferences {
  static final revision = ValueNotifier<int>(0);
  static String scope(Discuz discuz, User? user) =>
      '${discuz.baseURL.replaceAll(RegExp(r'/+$'), '')}:${user?.uid ?? 0}';
  static String _key(String scope, String type) => 'forum_feed_v1:$scope:$type';
  static List<String> ids(Iterable<String> values) =>
      values.where((id) => (int.tryParse(id) ?? 0) > 0).toSet().toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  static Future<List<String>> _knownIds(String scope) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(
        _key(scope, 'forums'),
      );
      return raw == null
          ? []
          : ids(
              forumRows(discuzMap(jsonDecode(raw))['rows'])
                  .map((row) => discuzString(discuzMap(row)['fid'])),
            );
    } catch (_) {
      return [];
    }
  }

  static Future<Set<String>> _excluded(
    String scope,
    Iterable<String> available,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key(scope, 'excluded'));
    if (stored != null) return stored.toSet();
    final legacy = prefs.getStringList(_key(scope, 'selection'));
    if (legacy == null) return {};
    final known = await _knownIds(scope);
    final baseline = (known.isEmpty ? available : known).toList();
    if (baseline.isEmpty) return {};
    final excluded = baseline.where((id) => !legacy.contains(id)).toSet();
    await prefs.setStringList(_key(scope, 'excluded'), ids(excluded));
    return excluded;
  }

  // Remember opt-outs, so previously unseen forums are always enabled.
  static Future<Set<String>> selectedFor(
    String scope,
    Iterable<String> available,
  ) async {
    final all = ids(available);
    final excluded = await _excluded(scope, all);
    return all.where((id) => !excluded.contains(id)).toSet();
  }

  static Future<List<String>?> selection(String scope) async {
    final known = await _knownIds(scope);
    final excluded = await _excluded(scope, known);
    return excluded.isEmpty
        ? null
        : known.where((id) => !excluded.contains(id)).toList();
  }

  static Future<void> saveSelection(
    String scope,
    List<String>? selected, {
    Iterable<String>? knownIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final known = ids(knownIds ?? await _knownIds(scope));
    final excluded = selected == null
        ? <String>{}
        : await _excluded(scope, known);
    if (selected != null) {
      // Keep exclusions for temporarily absent forums; only edit visible choices.
      excluded.removeAll(known);
      excluded.addAll(known.where((id) => !selected.contains(id)));
    }
    await prefs.setStringList(_key(scope, 'excluded'), ids(excluded));
    await prefs.remove(_key(scope, 'selection'));
    await prefs.remove(_key(scope, 'feed'));
    revision.value++;
  }

  static Future<Map<String, dynamic>?> _read(
    String scope,
    String type,
    Duration age,
  ) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(
        _key(scope, type),
      );
      if (raw == null) return null;
      final data = discuzMap(jsonDecode(raw));
      if (DateTime.now().millisecondsSinceEpoch - discuzInt(data['time']) >
          age.inMilliseconds)
        return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _write(
    String scope,
    String type,
    Map<String, dynamic> data,
  ) async => (await SharedPreferences.getInstance()).setString(
    _key(scope, type),
    jsonEncode({...data, 'time': DateTime.now().millisecondsSinceEpoch}),
  );
  static Future<List<Map<String, dynamic>>?> cachedForums(String scope) async {
    final data = await _read(scope, 'forums', const Duration(days: 1));
    return data == null
        ? null
        : forumRows(data['rows']).map(discuzMap).toList();
  }

  static Future<List<Map<String, dynamic>>> forums(
    String scope,
    ForumInteractionClient client, {
    bool refresh = false,
  }) async {
    if (!refresh) {
      final data = await _read(scope, 'forums', const Duration(minutes: 10));
      if (data?['includesSubforums'] == true) {
        return forumRows(data?['rows']).map(discuzMap).toList();
      }
    }
    final reply = await client.request('forumindex', {});
    reply.requireData('forumlist');
    final rows = _forumDirectory(reply.variables['forumlist']);
    await _excluded(scope, rows.map((row) => discuzString(row['fid'])));
    await _write(scope, 'forums', {'rows': rows, 'includesSubforums': true});
    return rows;
  }

  static List<Map<String, dynamic>> _forumDirectory(Object? directory) {
    final entries = <String, String>{};
    final parents = <String, String>{};

    void collect(Object? list, [String? parent]) {
      for (final item in forumRows(list)) {
        final row = discuzMap(item);
        final fid = discuzInt(row['fid']);
        if (fid <= 0) continue;
        final id = '$fid';
        entries.putIfAbsent(id, () => discuzString(row['name']));
        if (parent != null && parent != id) {
          parents.putIfAbsent(id, () => parent);
        }
        collect(row['sublist'], id);
      }
    }

    collect(directory);
    final children = <String, List<String>>{};
    for (final entry in parents.entries) {
      (children[entry.value] ??= []).add(entry.key);
    }
    final rows = <Map<String, dynamic>>[];
    final visited = <String>{};

    void append(String id, int depth) {
      if (!visited.add(id)) return;
      rows.add({
        'fid': id,
        'name': entries[id]!,
        if (depth > 0) 'depth': depth,
      });
      for (final child in children[id] ?? const <String>[]) {
        append(child, depth + 1);
      }
    }

    for (final id in entries.keys.where((id) => !parents.containsKey(id))) {
      append(id, 0);
    }
    for (final id in entries.keys.where((id) => !visited.contains(id))) {
      append(id, 0);
    }
    return rows;
  }

  static Future<String> resolveFids(
    String scope,
    ForumInteractionClient client,
  ) async {
    List<Map<String, dynamic>> available;
    try {
      available = await forums(scope, client);
    } catch (_) {
      final cached = await cachedForums(scope);
      if (cached == null) rethrow;
      available = cached;
    }
    final all = ids(available.map((row) => discuzString(row['fid'])));
    final selected = await selectedFor(scope, all);
    return all.where(selected.contains).join(',');
  }

  static Future<Map<String, dynamic>?> cachedFeed(
    String scope,
    String fids,
  ) async {
    final data = await _read(scope, 'feed', const Duration(minutes: 30));
    return data?['fids'] == fids ? discuzMap(data?['response']) : null;
  }

  static Future<void> saveFeed(
    String scope,
    String fids,
    Map<String, dynamic> response,
  ) => _write(scope, 'feed', {'fids': fids, 'response': response});
}
