import 'dart:convert';

import 'package:discuz_flutter/entity/forum_display_preferences.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('defaults keep separate navigation and hide account details', () async {
    final value = await UserPreferencesUtils.getForumDisplayPreference();
    expect(value.mergeHomeNavigation, isFalse);
    expect(value.compactCarousel, isTrue);
    expect(value.showAccountInfo, isFalse);
    expect(value.showForumName, isTrue);
    expect(value.showThreadStats, isTrue);
  });
  test('display options persist independently across launches', () async {
    final value = const ForumDisplayPreferences().copyWith(
      mergeHomeNavigation: true,
      compactCarousel: false,
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
    expect(value.copyWith(showAccountInfo: false).mergeHomeNavigation, isTrue);
  });
  test('legacy defaults never opt users into merged navigation', () async {
    for (final compact in [false, true]) {
      for (final key in ['compactHeader', 'compactCarousel']) {
        SharedPreferences.setMockInitialValues({
          UserPreferencesUtils.forumDisplayPreferenceKey: jsonEncode({
            key: compact,
          }),
        });
        final value = await UserPreferencesUtils.getForumDisplayPreference();
        expect(value.compactCarousel, compact);
        expect(value.mergeHomeNavigation, isFalse);
        expect(value.toJson().containsKey('compactHeader'), isFalse);
      }
    }
  });
  test('partial and malformed settings preserve privacy defaults', () async {
    for (final raw in [
      false,
      '[1]',
      'invalid',
      jsonEncode({'showAccountInfo': 'true'}),
      jsonEncode({'mergeHomeNavigation': 'true'}),
    ]) {
      SharedPreferences.setMockInitialValues({
        UserPreferencesUtils.forumDisplayPreferenceKey: raw,
      });
      expect(
        (await UserPreferencesUtils.getForumDisplayPreference())
            .showAccountInfo,
        isFalse,
      );
      expect(
        (await UserPreferencesUtils.getForumDisplayPreference())
            .mergeHomeNavigation,
        isFalse,
      );
    }
  });
}
