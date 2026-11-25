import 'package:html/dom.dart';

import '../utility/discuz_json.dart';
import '../utility/post_locator.dart';
import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

enum ForumContentKind {
  memberThreads,
  memberReplies,
  polls,
  rewards,
  debates,
  drafts,
  article,
  articleComments,
  relatedThreads,
  moderation,
  buyers,
  trades,
  tradeItem,
}

typedef ForumContentItem = ({
  String title,
  String detail,
  ForumLink? thread,
  Uri? link,
  int? fid,
  int? article,
});

class ForumWebContent {
  const ForumWebContent({
    this.title = '',
    this.detail = '',
    this.body = '',
    this.image,
    this.items = const [],
    this.relatedArticles = const [],
    this.next,
    this.comments,
  });

  final String title, detail, body;
  final Uri? image, next, comments;
  final List<ForumContentItem> items, relatedArticles;
}

class ForumWebContentClient {
  const ForumWebContentClient(this.web);

  final DiscuzWebClient web;

  Uri target(ForumContentKind kind, {int id = 0, int pid = 0, String? filter}) {
    return targetFor(web.base, kind, id: id, pid: pid, filter: filter);
  }

  static Uri targetFor(
    Uri base,
    ForumContentKind kind, {
    int id = 0,
    int pid = 0,
    String? filter,
  }) {
    final (file, query) = switch (kind) {
      ForumContentKind.memberThreads || ForumContentKind.memberReplies => (
        'home.php',
        {
          'mod': 'space',
          'do': 'thread',
          'view': 'me',
          'uid': '$id',
          'from': 'space',
          'type': kind == ForumContentKind.memberThreads ? 'thread' : 'reply',
        },
      ),
      ForumContentKind.drafts => (
        'home.php',
        {
          'mod': 'space',
          'do': 'thread',
          'view': 'me',
          'uid': '$id',
          'type': 'thread',
          'filter': 'save',
        },
      ),
      ForumContentKind.polls ||
      ForumContentKind.debates ||
      ForumContentKind.rewards => (
        'home.php',
        {
          'mod': 'space',
          'view': 'me',
          'uid': '$id',
          'do': switch (kind) {
            ForumContentKind.polls => 'poll',
            ForumContentKind.debates => 'debate',
            _ => 'reward',
          },
          if (filter != null)
            (kind == ForumContentKind.polls
                    ? 'filter'
                    : kind == ForumContentKind.rewards
                    ? 'flag'
                    : 'type'):
                filter,
        },
      ),
      ForumContentKind.article => ('portal.php', {'mod': 'view', 'aid': '$id'}),
      ForumContentKind.articleComments => (
        'portal.php',
        {'mod': 'comment', 'id': '$id', 'idtype': 'aid'},
      ),
      ForumContentKind.relatedThreads => (
        'forum.php',
        {'mod': 'viewthread', 'tid': '$id'},
      ),
      ForumContentKind.moderation || ForumContentKind.buyers => (
        'forum.php',
        {
          'mod': 'misc',
          'tid': '$id',
          'action': kind == ForumContentKind.moderation
              ? 'viewthreadmod'
              : 'viewpayments',
        },
      ),
      ForumContentKind.trades => (
        'home.php',
        {
          'mod': 'space',
          'uid': '$id',
          'do': 'trade',
          'view': 'tradelog',
          'type': filter ?? 'sell',
        },
      ),
      ForumContentKind.tradeItem => (
        'forum.php',
        {'mod': 'viewthread', 'tid': '$id', 'do': 'tradeinfo', 'pid': '$pid'},
      ),
    };
    return base
        .resolve(file)
        .replace(queryParameters: {...query, 'mobile': 'no'});
  }

  Future<ForumWebContent> read(
    ForumContentKind kind,
    Uri initial, {
    Uri? next,
  }) async {
    if (next != null && !_samePage(initial, next)) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
    final result = await web.read(next ?? initial);
    if (!_samePage(initial, result.uri) ||
        result.document.querySelector('#messagetext') != null) {
      web.rejected(result.document, 'forum_api_unavailable');
    }
    final selector = switch (kind) {
      ForumContentKind.memberThreads ||
      ForumContentKind.memberReplies ||
      ForumContentKind.drafts => '#ct .mn .tl',
      ForumContentKind.debates => '#ct .mn',
      ForumContentKind.polls ||
      ForumContentKind.rewards => '#ct .mn .el.pll, #ct .mn .rwdl',
      ForumContentKind.article => '#article_content',
      ForumContentKind.articleComments => '#ct .vw .bm_c',
      ForumContentKind.relatedThreads => '#postlist',
      ForumContentKind.moderation ||
      ForumContentKind.buyers => '.f_c table.list',
      ForumContentKind.trades => '#list_trade_selles',
      ForumContentKind.tradeItem => '#ct .mn .act',
    };
    final container = result.document.querySelector(selector);
    if (container == null) {
      // Some space templates omit their list entirely when there are no rows.
      final body = result.document.querySelector('#ct .mn');
      final nav =
          body?.querySelectorAll('a[href]').any((anchor) {
            final url = web.siteLink(
              result.uri,
              anchor.attributes['href'],
              'home.php',
            );
            return url?.queryParameters['do'] ==
                    initial.queryParameters['do'] &&
                url?.queryParameters['view'] == 'me';
          }) ??
          false;
      if ({
            ForumContentKind.polls,
            ForumContentKind.rewards,
            ForumContentKind.debates,
            ForumContentKind.memberThreads,
            ForumContentKind.memberReplies,
            ForumContentKind.drafts,
          }.contains(kind) &&
          nav &&
          body!.querySelector('.emp') != null) {
        return const ForumWebContent();
      }
      web.rejected(result.document, 'forum_api_unavailable');
    }

    final ids = <Object>{};
    final anchors = container.querySelectorAll(switch (kind) {
      ForumContentKind.memberThreads ||
      ForumContentKind.drafts => 'tr th > a[href]',
      ForumContentKind.debates => '.ds > h3 > a[href], .tl tr th > a[href]',
      ForumContentKind.memberReplies =>
        'tr th > a[href], tr td[colspan] > a[href]',
      ForumContentKind.polls || ForumContentKind.rewards => 'h4 > a[href]',
      ForumContentKind.relatedThreads =>
        '.mtw.mbw > .pbm.bbda + ul.xl.xl2 a[href]',
      ForumContentKind.trades => 'a[href*="orderid="]',
      _ => ':not(*)',
    });
    final detailedReplies = <int>{};
    final items = <ForumContentItem>[];
    for (final anchor in anchors) {
      final a = anchor.attributes['href'];
      final title = _text(anchor);
      if (title.isEmpty) continue;
      final row = anchor.parent?.parent;
      if (kind == ForumContentKind.trades) {
        final url = web.siteLink(result.uri, a, 'forum.php');
        if (url?.queryParameters['mod'] != 'trade' ||
            url?.queryParameters['orderid']?.isNotEmpty != true ||
            !ids.add(url!))
          continue;
        final cells = _ancestor(anchor, 'tr')?.children ?? const <Element>[];
        items.add(_item(title, _join(cells.skip(2).take(3)), link: url));
        continue;
      }
      final thread = threadLink(result.uri, a);
      if (thread == null) continue;
      final fidLink = row?.querySelector('a[href*="mod=forumdisplay"]');
      final fid = int.tryParse(
        web
                .siteLink(result.uri, fidLink?.attributes['href'], 'forum.php')
                ?.queryParameters['fid'] ??
            '',
      );
      if (kind == ForumContentKind.memberThreads && ids.add(thread.tid)) {
        items.add(_item(title, _text(fidLink), thread: thread, fid: fid));
      } else if (kind == ForumContentKind.drafts &&
          fid != null &&
          ids.add(thread.tid)) {
        items.add(_item(title, _text(fidLink), thread: thread, fid: fid));
      } else if (kind == ForumContentKind.memberReplies) {
        if (anchor.parent?.localName == 'td' && thread.pid != null) {
          detailedReplies.add(thread.tid);
          if (ids.add(thread.pid!)) items.add(_item(title, '', thread: thread));
        } else if (anchor.parent?.localName == 'th') {
          items.add(
            _item(title, _text(fidLink), thread: thread, fid: fid ?? 0),
          );
        }
      } else if ({
            ForumContentKind.polls,
            ForumContentKind.debates,
            ForumContentKind.rewards,
            ForumContentKind.relatedThreads,
          }.contains(kind) &&
          ids.add(thread.tid)) {
        final detail = switch (kind) {
          ForumContentKind.polls => _text(
            anchor.parent?.parent?.parent?.querySelector('.joins'),
          ),
          ForumContentKind.rewards => _text(row?.querySelector('.uslvd')),
          ForumContentKind.debates =>
            row?.classes.contains('ds') == true
                ? _join(row!.querySelectorAll('.si_1 strong, .si_2 strong'))
                : _text(row?.children.lastOrNull),
          _ => '',
        };
        items.add(_item(title, detail, thread: thread));
      }
    }
    if (kind == ForumContentKind.memberReplies) {
      final headings = <int, String>{
        for (final item in items)
          if (item.fid != null) item.thread!.tid: item.title,
      };
      final grouped = <ForumContentItem>[];
      for (final item in items) {
        final thread = item.thread!;
        if (detailedReplies.contains(thread.tid)) {
          if (item.fid != null) continue;
          grouped.add(
            _item(
              headings[thread.tid] ?? item.title,
              headings[thread.tid] == null ? '' : item.title,
              thread: thread,
            ),
          );
        } else if (!grouped.any((row) => row.thread == thread)) {
          grouped.add(item);
        }
      }
      items
        ..clear()
        ..addAll(grouped);
    }
    if (kind == ForumContentKind.moderation ||
        kind == ForumContentKind.buyers) {
      for (final row in container.querySelectorAll('tr')) {
        final cells = row.children;
        if (cells.length != (kind == ForumContentKind.moderation ? 4 : 3) ||
            row.parent?.localName == 'thead')
          continue;
        final titleIndex = kind == ForumContentKind.moderation ? 2 : 0;
        items.add(
          _item(
            _text(cells[titleIndex]),
            _join([
              for (var i = 0; i < cells.length; i++)
                if (i != titleIndex) cells[i],
            ]),
          ),
        );
      }
    }
    if (kind == ForumContentKind.article ||
        kind == ForumContentKind.articleComments) {
      final aid = initial
          .queryParameters[kind == ForumContentKind.article ? 'aid' : 'id'];
      final comments = kind == ForumContentKind.article
          ? result.document.querySelectorAll(
              '#ct #comment a[href], #ct .vw .h a[href]',
            )
          : const <Element>[];
      final commentLink = comments
          .map(
            (el) =>
                web.siteLink(result.uri, el.attributes['href'], 'portal.php'),
          )
          .whereType<Uri>()
          .where(
            (url) =>
                url.queryParameters['mod'] == 'comment' &&
                url.queryParameters['id'] == aid &&
                url.queryParameters['idtype'] == 'aid',
          )
          .firstOrNull;
      final related = <ForumContentItem>[];
      for (final link in result.document.querySelectorAll(
        '#related_article li > a[href]',
      )) {
        final article = articleId(result.uri, link.attributes['href']);
        if (article != null && '$article' != aid && ids.add(article)) {
          related.add(_item(_text(link), '', article: article));
        }
      }
      for (final comment in result.document.querySelectorAll(
        '#ct dl[id^="comment_"]',
      )) {
        final meta = comment.querySelector('dt')?.clone(true);
        meta?.querySelectorAll('.y').forEach((el) => el.remove());
        final text = comment.querySelector('dd');
        if (_text(text).isNotEmpty) items.add(_item(_text(meta), _text(text)));
      }
      final metadata = kind == ForumContentKind.article
          ? result.document.querySelector('#ct .vw .h > p.xg1')?.clone(true)
          : null;
      metadata
          ?.querySelectorAll('a[href*="mod=portalcp"]')
          .forEach((action) => action.remove());
      for (final separator
          in metadata?.querySelectorAll('.pipe') ?? const <Element>[]) {
        separator.text = ' · ';
      }
      return ForumWebContent(
        title: _text(result.document.querySelector('#ct .vw h1.ph, #ct h1.ph')),
        detail: _text(metadata).replaceFirst(RegExp(r'(?:\s*·)+\s*$'), ''),
        body: kind == ForumContentKind.article
            ? _safeHtml(container, result.uri)
            : '',
        items: items,
        relatedArticles: related,
        next: _next(initial, result.uri, result.document),
        comments: commentLink,
      );
    }
    if (kind == ForumContentKind.tradeItem) {
      final rows = container.querySelectorAll('.spi dl > dt, .spi dl > dd');
      for (var i = 0; i + 1 < rows.length; i++) {
        if (rows[i].localName == 'dt' && rows[i + 1].localName == 'dd') {
          items.add(_item(_text(rows[i]), _text(rows[i + 1])));
        }
      }
      final image = _safeUrl(
        result.uri,
        container.querySelector('.spvimg img')?.attributes['src'],
      );
      return ForumWebContent(
        title: _text(result.document.querySelector('#ct h1.ph')),
        body: _safeHtml(
          result.document.querySelector('#ct .mn .act .cl.mtw > .c.pbm') ??
              Element.tag('div'),
          result.uri,
        ),
        image: image,
        items: items,
      );
    }
    return ForumWebContent(
      items: items,
      next: kind == ForumContentKind.relatedThreads
          ? null
          : _next(initial, result.uri, result.document),
    );
  }

  Future<int> draftPid(int uid, int fid, int tid) async {
    final response = await apiDraftPage(uid, fid, tid);
    if (response != null) return response;
    final result = await web.read(
      web.page('forum.php', {'mod': 'viewthread', 'tid': '$tid'}),
    );
    for (final link in result.document.querySelectorAll(
      '#postlist a[href], #ct a[href]',
    )) {
      final url = web.siteLink(
        result.uri,
        link.attributes['href'],
        'forum.php',
      );
      final q = url?.queryParameters;
      final post = q?['pid'];
      if (q?['mod'] == 'post' &&
          q?['action'] == 'edit' &&
          q?['tid'] == '$tid' &&
          q?['fid'] == '$fid' &&
          post != null &&
          (int.tryParse(post) ?? 0) > 0 &&
          result.document.querySelector('#post_$post .pi .authi') != null &&
          result.document.querySelector('#post_$post') ==
              result.document.querySelector('#postlist [id^="post_"]')) {
        return int.parse(post);
      }
    }
    web.rejected(result.document, 'forum_api_unavailable');
  }

  Future<int?> apiDraftPage(int uid, int fid, int tid) async {
    try {
      final result = await web.api.request('viewthread', {
        'tid': tid,
        'page': 1,
      });
      final v = result.variables;
      final thread = discuzMap(v['thread']);
      if (discuzInt(v['member_uid']) == uid &&
          discuzInt(v['fid']) == fid &&
          discuzInt(thread['tid']) == tid &&
          discuzInt(thread['authorid']) == uid &&
          discuzInt(thread['displayorder']) == -4) {
        for (final raw in forumRows(v['postlist'])) {
          final post = discuzMap(raw);
          if (discuzInt(post['first']) == 1 && discuzInt(post['pid']) > 0) {
            return discuzInt(post['pid']);
          }
        }
      }
    } on ForumApiException {
      return null;
    }
    return null;
  }

  ForumLink? threadLink(Uri from, String? href) {
    final direct = web.threadLink(from, href);
    if (direct != null) return direct;
    final uri = _safeUrl(from, href);
    final name = uri?.pathSegments.lastOrNull;
    if (name == null ||
        !name.startsWith('thread-') ||
        web.siteLink(from, href, name) == null)
      return null;
    final parsed = PostLinkTarget.parse(uri!);
    return parsed == null ? null : (tid: parsed.tid, pid: parsed.pid);
  }

  int? articleId(Uri from, String? href) {
    final standard = web.siteLink(from, href, 'portal.php')?.queryParameters;
    if (standard?['mod'] == 'view') {
      final id = int.tryParse(standard?['aid'] ?? '');
      return id != null && id > 0 ? id : null;
    }
    final name = _safeUrl(from, href)?.pathSegments.lastOrNull;
    if (name == null || web.siteLink(from, href, name) == null) return null;
    return int.tryParse(
      RegExp(r'^article-(\d+)-\d+\.html$').firstMatch(name)?.group(1) ?? '',
    );
  }

  bool _samePage(Uri expected, Uri actual) =>
      actual.origin == expected.origin &&
      actual.userInfo.isEmpty &&
      actual.path == expected.path &&
      expected.queryParameters.entries.every(
        (entry) =>
            entry.key == 'mobile' ||
            actual.queryParameters[entry.key] == entry.value,
      );

  Uri? _next(Uri initial, Uri from, Document document) {
    for (final link in document.querySelectorAll('#ct .mn .pg a.nxt[href]')) {
      final next = web.siteLink(
        from,
        link.attributes['href'],
        initial.pathSegments.last,
      );
      if (next != null &&
          _samePage(initial, next) &&
          (int.tryParse(next.queryParameters['page'] ?? '') ?? 0) >
              (int.tryParse(from.queryParameters['page'] ?? '') ?? 1))
        return next;
    }
    return null;
  }

  static Uri? _safeUrl(Uri from, String? href) {
    if (href == null || href.trim().isEmpty) return null;
    final parsed = Uri.tryParse(href);
    if (parsed == null) return null;
    final url = from.resolveUri(parsed);
    return {'http', 'https'}.contains(url.scheme) && url.userInfo.isEmpty
        ? url
        : null;
  }

  static String _safeHtml(Element element, Uri page) {
    final content = element.clone(true);
    for (final tag in content.querySelectorAll(
      'script, style, iframe, object, embed, form, input, button, [id^="ad_"]',
    )) {
      tag.remove();
    }
    for (final node in content.querySelectorAll('*')) {
      node.attributes.removeWhere(
        (key, _) =>
            '$key'.startsWith('on') || {'srcset', 'style'}.contains(key),
      );
      for (final attribute in ['src', 'href']) {
        if (!node.attributes.containsKey(attribute)) continue;
        final url = _safeUrl(page, node.attributes[attribute]);
        if (url == null) {
          node.attributes.remove(attribute);
        } else {
          node.attributes[attribute] = url.toString();
        }
      }
    }
    return content.innerHtml;
  }

  static ForumContentItem _item(
    String title,
    String detail, {
    ForumLink? thread,
    int? fid,
    Uri? link,
    int? article,
  }) => (
    title: title,
    detail: detail,
    thread: thread,
    fid: fid,
    link: link,
    article: article,
  );

  static Element? _ancestor(Element element, String tag) {
    for (var node = element.parent; node != null; node = node.parent) {
      if (node.localName == tag) return node;
    }
    return null;
  }

  static String _text(Element? element) =>
      element?.text.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';

  static String _join(Iterable<Element> elements) =>
      elements.map(_text).where((part) => part.isNotEmpty).join(' · ');
}
