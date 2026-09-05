import 'package:discuz_flutter/widget/KeylolMobileTopicWidget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Keylol topic titles stay aligned with parsed topic lists', () {
    expect(
      keylolTopicTitlesForCount(['最新发表'], 2),
      ['最新发表', '专题 2'],
    );
    expect(
      keylolTopicTitlesForCount(['最新发表', '最新热门', '多余标题'], 2),
      ['最新发表', '最新热门'],
    );
  });
}
