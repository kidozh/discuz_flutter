import 'package:discuz_flutter/utility/forum_thread_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'plain and HTML previews preserve word boundaries and decode entities',
    () {
      expect(
        forumThreadPreview('First\nline   second line'),
        'First line second line',
      );
      expect(
        forumThreadPreview(
          '<p>First &amp; second</p><div>Third<br>Fourth</div>',
        ),
        'First & second Third Fourth',
      );
    },
  );
  test('empty HTML selects the title-only layout; image tags do not masquerade as text', () {
    for (final value in [
      '',
      ' \n ',
      '<p><br>&nbsp;</p>',
      '<img src="image.jpg">',
    ]) {
      expect(forumThreadPreview(value), '');
    }
  });
  test('only explicit edit-status elements are removed', () {
    expect(
      forumThreadPreview('<i class="pstatus">本帖最后由 User 于昨天编辑</i><p>正文</p>'),
      '正文',
    );
    expect(forumThreadPreview('这里讨论本帖最后由某人编辑的提示'), '这里讨论本帖最后由某人编辑的提示');
    expect(
      forumThreadPreview(
        '<script>alert(1)</script><style>p{color:red}</style><p>Visible</p>',
      ),
      'Visible',
    );
  });
}
