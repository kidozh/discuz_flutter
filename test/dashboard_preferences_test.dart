import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discuz_flutter/utility/DashboardPreferences.dart';

void main() {
  test(
    'dashboard order normalizes duplicates and gates Keylol by exact host',
    () {
      expect(DashboardPreferences.normalize(['hot', 'hot', 'bad', 'keylol']), [
        'hot',
        'keylol',
        'new',
      ]);
      expect(
        DashboardPreferences.visible(['keylol', 'hot', 'new'], keylol: false),
        ['hot', 'new'],
      );
      expect(DashboardPreferences.isKeylol('https://keylol.com'), isTrue);
      expect(
        DashboardPreferences.isKeylol('https://www.keylol.com/forum.php'),
        isTrue,
      );
      expect(
        DashboardPreferences.isKeylol('https://keylol.com.evil.test'),
        isFalse,
      );
    },
  );
  test('reordering persists and notifies the live dashboard', () async {
    SharedPreferences.setMockInitialValues({});
    await DashboardPreferences.save(['keylol', 'hot', 'new']);
    expect(DashboardPreferences.order.value, ['keylol', 'hot', 'new']);
    expect(
      (await SharedPreferences.getInstance()).getStringList(
        'dashboard_section_order',
      ),
      ['keylol', 'hot', 'new'],
    );
  });
}
