import 'dart:convert';

import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('compact defaults hide account details and retain statistics', () async {
    final value = await UserPreferencesUtils.getForumDisplayPreference();
    expect(value.compactHeader, isTrue);
    expect(value.showAccountInfo, isFalse);
    expect(value.showForumName, isTrue);
    expect(value.showThreadStats, isTrue);
  });
  test('display options persist independently across launches', () async {
    final value = const ForumDisplayPreferences().copyWith(
      compactHeader: false,
      showForumName: false,
      showAccountInfo: true,
      showThreadStats: false,
      showCarousel: false,
    );
    await UserPreferencesUtils.putForumDisplayPreference(value);
    expect(
      (await UserPreferencesUtils.getForumDisplayPreference()).toJson(),
      value.toJson(),
    );
    expect(value.copyWith(showAccountInfo: false).showForumName, isFalse);
  });
  test('partial and malformed settings preserve privacy defaults', () async {
    for (final raw in [
      false,
      '[1]',
      'invalid',
      jsonEncode({'showAccountInfo': 'true'}),
    ]) {
      SharedPreferences.setMockInitialValues({
        UserPreferencesUtils.forumDisplayPreferenceKey: raw,
      });
      expect(
        (await UserPreferencesUtils.getForumDisplayPreference())
            .showAccountInfo,
        isFalse,
      );
    }
  });
}
