import 'discuz_web_client.dart';

typedef ForumAnnouncement = ({int id, String title, String date, String body});
typedef ForumThreadTag = ({String name, Uri uri});

class ForumBrowseClient {
  const ForumBrowseClient(this.web);

  final DiscuzWebClient web;

  Future<List<ForumAnnouncement>> announcements() async {
    final page = await web.read(web.page('forum.php', {'mod': 'announcement'}));
    if (page.document.querySelector('#annonav') == null) {
      web.rejected(page.document, 'forum_announcements_unavailable');
    }
    final announcements = <ForumAnnouncement>[];
    for (final header in page.document.querySelectorAll(
      '.umh[id^="announce"]',
    )) {
      final id = RegExp(r'^announce(\d+)_c$').firstMatch(header.id)?.group(1);
      final title = header.querySelector('h3')?.clone(true);
      final body = id == null
          ? null
          : page.document.getElementById('announce$id');
      if (id == null || title == null || body == null) continue;
      final date = title.querySelector('em');
      final dateText = date?.text.trim() ?? '';
      date?.remove();
      final name = title.text.trim();
      if (name.isEmpty) continue;
      announcements.add((
        id: int.parse(id),
        title: name,
        date: dateText,
        body: body.innerHtml,
      ));
    }
    return announcements;
  }

  Future<List<ForumThreadTag>> tags(int tid) async {
    final page = await web.read(
      web.page('forum.php', {'mod': 'viewthread', 'tid': '$tid', 'page': '1'}),
    );
    if (page.document.querySelector('#postlist') == null) {
      web.rejected(page.document, 'thread_tags_unavailable');
    }
    final tags = <Uri, ForumThreadTag>{};
    for (final anchor in page.document.querySelectorAll(
      '#postlist .ptg > a[href]',
    )) {
      final uri = web.siteLink(page.uri, anchor.attributes['href'], 'misc.php');
      final id = int.tryParse(uri?.queryParameters['id'] ?? '') ?? 0;
      final name = anchor.text.trim();
      if (uri == null ||
          uri.queryParameters['mod'] != 'tag' ||
          id <= 0 ||
          name.isEmpty) {
        continue;
      }
      tags[uri] = (
        name: name,
        uri: web.page('misc.php', {
          'mod': 'tag',
          'id': '$id',
          'type': 'thread',
        }),
      );
    }
    return tags.values.toList();
  }
}
