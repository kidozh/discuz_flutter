import 'package:discuz_flutter/widget/PostRatingsInline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/page/PostRatingsPage.dart';

void main() {
  test(
    'automatic first-post ratings are limited to Keylol with more than 50 views',
    () {
      expect(
        shouldLoadFirstPostRatings('https://keylol.com', '51', true),
        isTrue,
      );
      expect(
        shouldLoadFirstPostRatings('https://www.keylol.com', '100', true),
        isTrue,
      );
      expect(
        shouldLoadFirstPostRatings('https://keylol.com', '50', true),
        isFalse,
      );
      expect(
        shouldLoadFirstPostRatings('https://keylol.com', '100', false),
        isFalse,
      );
      expect(
        shouldLoadFirstPostRatings(
          'https://keylol.com.other.test',
          '100',
          true,
        ),
        isFalse,
      );
      expect(
        shouldLoadFirstPostRatings('https://other.test', '100', true),
        isFalse,
      );
      expect(
        shouldLoadFirstPostRatings('https://keylol.com', '', true),
        isFalse,
      );
    },
  );
  test(
    'ratings parse XML-wrapped records without counting header as a rating',
    () {
      final result = PostRatings.parse('''<root><![CDATA[
<div class="floatwrap"><table class="list"><thead><tr><td>Credits</td><td>User</td><td>Date</td><td>Reason</td></tr></thead>
<tr><td>Coins +2</td><td><a href="home.php?uid=1">A &amp; B</a></td><td>2026-09-13</td><td>Useful &lt;answer&gt;</td></tr>
<tr><td>Coins -1</td><td>Other user</td><td>2026-09-14</td><td></td></tr></table></div>
<div class="o pns">Total: Coins +1</div>]]></root>''');
      expect(result.records.length, 2);
      expect(result.records.first.author, 'A & B');
      expect(result.records.first.reason, 'Useful <answer>');
      expect(result.records.last.credit, 'Coins -1');
      expect(result.records.last.reason, isEmpty);
      expect(result.total, 'Total: Coins +1');
    },
  );
  test(
    'login and unsupported pages are not misrepresented as empty ratings',
    () {
      expect(
        () => PostRatings.parse('<div>Please log in</div>'),
        throwsFormatException,
      );
    },
  );
}
