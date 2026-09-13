import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPreferences {
  static const defaults = ['new', 'hot', 'keylol'];
  static final order = ValueNotifier<List<String>>(List.of(defaults));
  static Future<void>? _loading;
  static bool _loaded = false;
  static bool isKeylol(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase();
    return host == 'keylol.com' || host == 'www.keylol.com';
  }

  static List<String> normalize(Iterable<String> values) => [
    ...{...values.where(defaults.contains), ...defaults},
  ];
  static List<String> visible(
    Iterable<String> values, {
    required bool keylol,
  }) => normalize(values).where((id) => id != 'keylol' || keylol).toList();
  static Future<void> load() {
    if (_loaded) return Future.value();
    return _loading ??= (() async {
      final prefs = await SharedPreferences.getInstance();
      order.value = normalize(
        prefs.getStringList('dashboard_section_order') ?? defaults,
      );
      _loaded = true;
    })().whenComplete(() => _loading = null);
  }

  static Future<void> save(List<String> values) async {
    final next = normalize(values);
    await (await SharedPreferences.getInstance()).setStringList(
      'dashboard_section_order',
      next,
    );
    order.value = next;
  }
}
