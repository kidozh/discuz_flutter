import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/client/PostReviewClient.dart';
import 'package:discuz_flutter/utility/rating_allowance_cache.dart';

RatingForm form(int remaining) => RatingForm('hash', '', [
  RatingCredit('score1', 'Coins', -2, 2, remaining),
], false);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('parsed allowance is valid only on its calendar date', () async {
    final day = DateTime(2026, 9, 13);
    RatingAllowanceCache.remember('date', form(0), now: day);
    expect(
      RatingAllowanceCache.available(
        'date',
        now: day.add(const Duration(hours: 20)),
      ),
      false,
    );
    expect(
      RatingAllowanceCache.available('date', now: DateTime(2026, 9, 14)),
      null,
    );
    expect(RatingAllowanceCache.available('unknown'), null);
    await RatingAllowanceCache.flush();
  });
  test('remaining points are persisted without login credentials', () async {
    final key = RatingAllowanceCache.key('https://keylol.com/', 7, 'secret');
    RatingAllowanceCache.remember(key, form(2), used: {'score1': 2});
    expect(RatingAllowanceCache.available(key), false);
    await RatingAllowanceCache.flush();
    final raw = (await SharedPreferences.getInstance()).getString(
      'rating_allowance_by_date_v1',
    )!;
    expect(raw, contains('"score1":0'));
    expect(raw, isNot(contains('secret')));
    expect(
      RatingAllowanceCache.key('https://keylol.com', 7, 'new-session'),
      key,
    );
    expect(
      RatingAllowanceCache.available(
        RatingAllowanceCache.key('https://keylol.com', 8, ''),
      ),
      null,
    );
  });
}
