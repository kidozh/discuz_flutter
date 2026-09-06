import 'package:discuz_flutter/utility/KeylolPortalParser.dart';
import 'package:flutter_test/flutter_test.dart';

String module(int tid, {bool category = false}) => '''
<div class="module cl xl xl1"><ul><li>
<a href="suid-42">A&amp;B</a><a href="f1">Forum</a>
${category ? '<a href="category">Category</a>' : ''}
<a href="t$tid-1-1" title="Forum:Games&#10;Author:A&#10;Date:Today&#10;Last:B"><b>Title</b> &amp; text</a>
</li><li>invalid item</li></ul></div>''';

void main() {
  test('parses three/four-link items and decodes visible text', () {
    final topics = parseKeylolPortalTopics('''
<div class="titletext"><a><b>Latest</b> &amp; news</a></div>
<div class="titletext"><a>Shopping</a></div>
${module(123)}${module(456, category: true)}''');
    expect(topics.map((e) => e.title), ['Latest & news', 'Shopping']);
    expect(topics.map((e) => e.threads.single.tid), [123, 456]);
    final item = topics.first.threads.single;
    expect(item.title, 'Title & text');
    expect(item.author, 'A&B');
    expect(item.authorId, 42);
    expect(item.convertToForumThread().tid, '123');
  });

  test('missing label slots do not shift remaining title/list pairs', () {
    final topics = parseKeylolPortalTopics('''
<div class="titletext"></div><div class="titletext"><a>Second</a></div>
<div class="titletext"><a>Unmatched</a></div>
${module(123)}${module(456)}''');
    expect(topics.single.title, 'Second');
    expect(topics.single.threads.single.tid, 456);
  });

  test('empty or mobile HTML returns no topics', () {
    expect(parseKeylolPortalTopics(''), isEmpty);
    expect(parseKeylolPortalTopics('<div>Mobile page</div>'), isEmpty);
  });

  test('repeated parsing replaces data instead of accumulating lists', () {
    final source = '<div class="titletext"><a>Latest</a></div>${module(123)}';
    expect(parseKeylolPortalTopics(source), hasLength(1));
    expect(parseKeylolPortalTopics(source), hasLength(1));
  });
}
