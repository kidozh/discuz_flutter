import 'package:html/dom.dart';

import 'discuz_web_client.dart';

enum ForumSiteFeature {
  collections('forum.php', {'mod': 'collection', 'op': 'my'}),
  tasks('home.php', {'mod': 'task', 'item': 'new'}),
  medals('home.php', {'mod': 'medal'});

  const ForumSiteFeature(this.file, this.query);

  final String file;
  final Map<String, String> query;

  bool available(DiscuzWebClient web, Uri uri, Document document) {
    if (document.querySelector('#messagetext') != null ||
        uri.queryParameters['mod'] != query['mod']) {
      return false;
    }
    final links = document.querySelectorAll('#ct a[href]');
    return links.any((link) {
      final target = web.siteLink(uri, link.attributes['href'], file);
      final params = target?.queryParameters;
      if (params?['mod'] != query['mod']) return false;
      return switch (this) {
        collections => params?['op'] == 'my' || params?['op'] == 'all',
        tasks => params?['item'] == 'doing' || params?['item'] == 'done',
        medals => params?['action'] == 'log',
      };
    });
  }
}
