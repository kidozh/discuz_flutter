import 'package:html/dom.dart';

import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

enum CommunitySection {
  groups('group.php', {'mod': 'index'}),
  joinedGroups('group.php', {'mod': 'my', 'view': 'join'}),
  managedGroups('group.php', {'mod': 'my', 'view': 'manager'}),
  group('forum.php', {'mod': 'group'}),
  groupMembers('forum.php', {'mod': 'group', 'action': 'memberlist'}),
  groupRequests('forum.php', {
    'mod': 'group',
    'action': 'manage',
    'op': 'checkuser',
  }),
  groupSearch('search.php', {'mod': 'group'}),
  followingFeed('home.php', {'mod': 'follow', 'do': 'feed'}),
  following('home.php', {'mod': 'follow', 'do': 'following'}),
  followers('home.php', {'mod': 'follow', 'do': 'follower'}),
  findUsers('home.php', {'mod': 'spacecp', 'ac': 'search'}),
  friendRequests('home.php', {
    'mod': 'spacecp',
    'ac': 'friend',
    'op': 'request',
  }),
  myCollections('forum.php', {'mod': 'collection', 'op': 'my'}),
  allCollections('forum.php', {'mod': 'collection', 'op': 'all'}),
  collection('forum.php', {'mod': 'collection', 'action': 'view'}),
  pendingThreads('forum.php', {
    'mod': 'modcp',
    'action': 'moderate',
    'op': 'threads',
  }),
  pendingReplies('forum.php', {
    'mod': 'modcp',
    'action': 'moderate',
    'op': 'replies',
  }),
  reports('forum.php', {'mod': 'modcp', 'action': 'report'}),
  tasks('home.php', {'mod': 'task', 'item': 'new'}),
  activeTasks('home.php', {'mod': 'task', 'item': 'doing'}),
  completedTasks('home.php', {'mod': 'task', 'item': 'done'}),
  medals('home.php', {'mod': 'medal'}),
  myMedals('home.php', {'mod': 'medal', 'action': 'log'}),
  rankings('misc.php', {'mod': 'ranklist'}),
  portal('portal.php', {'mod': 'index'}),
  myActivities('home.php', {'mod': 'space', 'do': 'activity', 'view': 'me'});

  const CommunitySection(this.file, this.query);

  final String file;
  final Map<String, String> query;

  bool get searchable => this == findUsers || this == groupSearch;
}

enum CommunityTarget {
  thread,
  person,
  group,
  groupCategory,
  collection,
  ranking,
  portalCategory,
  article,
  web,
}

typedef CommunityItem = ({
  CommunityTarget kind,
  String title,
  String? detail,
  Uri uri,
  int? id,
  int? post,
});

typedef CommunityPageData = ({
  List<CommunityItem> items,
  Uri? next,
  String title,
  String? detail,
  Uri? image,
  bool canJoin,
  bool canLeave,
  bool canManage,
  bool canCreate,
  bool canReadGroup,
  String? groupStatus,
});

class ForumCommunityClient {
  ForumCommunityClient(this.web);

  final DiscuzWebClient web;

  Uri page(CommunitySection section, [Map<String, String> params = const {}]) =>
      web.page(section.file, {...section.query, ...params});

  Future<CommunityPageData> load(
    CommunitySection section,
    Map<String, String> params, {
    Uri? next,
    String keyword = '',
  }) async {
    if (next != null &&
        (web.siteLink(web.base, next.toString(), section.file) == null ||
            !_matchesPage(section, params, next))) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
    final target = next == null
        ? page(section, {
            ...params,
            if (keyword.isNotEmpty &&
                section == CommunitySection.findUsers) ...{
              'username': keyword,
              'searchsubmit': 'yes',
            },
          })
        : next.replace(
            queryParameters: {...next.queryParametersAll, 'mobile': 'no'},
          );
    final groupSearch =
        section == CommunitySection.groupSearch &&
        keyword.isNotEmpty &&
        next == null;
    final result = groupSearch
        ? await _searchGroups(target, keyword)
        : await web.read(target);
    final document = result.document;
    final content =
        document.querySelector('#ct') ??
        (section == CommunitySection.portal
            ? document.querySelector('#wp')
            : null);
    if (document.querySelector('#messagetext') != null ||
        content == null ||
        (section.searchable && DiscuzWebClient.hasCaptcha(content)) ||
        content.querySelector('input[name="cppwd"]') != null) {
      web.rejected(document, 'forum_api_unavailable');
    }
    if (section == CommunitySection.myActivities &&
        (content.querySelector(
                  '.mn .tb a[href*="do=activity"][href*="view=me"]',
                ) ==
                null ||
            !_matchesPage(section, params, result.uri))) {
      web.rejected(document, 'forum_api_unavailable');
    }
    final items = <(CommunityTarget, Object?, int?), CommunityItem>{};
    if (section == CommunitySection.medals ||
        section == CommunitySection.myMedals) {
      for (final row in content.querySelectorAll(
        section == CommunitySection.medals ? '.mgcl > li' : '.mn ul.el > li',
      )) {
        final title = row.querySelector('p.xw1, strong')?.text.trim() ?? '';
        if (title.isEmpty) continue;
        final detail = section == CommunitySection.myMedals
            ? row.text.trim()
            : [
                    row.querySelector('.tip_c')?.text.trim(),
                    row.querySelector('p.xw1 + p')?.text.trim(),
                  ]
                  .whereType<String>()
                  .where((part) => part.isNotEmpty)
                  .join(' · ');
        items[(CommunityTarget.web, title, null)] = (
          kind: CommunityTarget.web,
          title: title,
          detail: detail.isEmpty ? null : detail,
          uri: target,
          id: null,
          post: null,
        );
      }
    }
    final anchors = [
      ...content.querySelectorAll(_selector(section)),
      if (section == CommunitySection.portal)
        ...document.querySelectorAll('#nv a[href], #mu a[href]'),
    ];
    for (final anchor in anchors) {
      final item = _item(section, result.uri, anchor);
      if (item == null) continue;
      items.putIfAbsent((
        item.kind,
        item.id ?? item.uri,
        item.post,
      ), () => item);
    }
    final pageNext = content.querySelector('.pg a.nxt[href]');
    final nextUri =
        web.siteLink(result.uri, pageNext?.attributes['href'], section.file) ??
        (section == CommunitySection.groupSearch
            ? content
                  .querySelectorAll('a[href*="viewgroup=1"]')
                  .map(
                    (link) => web.siteLink(
                      result.uri,
                      link.attributes['href'],
                      'search.php',
                    ),
                  )
                  .whereType<Uri>()
                  .firstOrNull
            : null);
    final group = section == CommunitySection.group;
    final heading = group
        ? content.querySelector('#gh h1, .mn .xlda dt')
        : content.querySelector('h1.mt, h1.xs2');
    final rawBanner = group
        ? content.querySelector('#gh > img')?.attributes['src']
        : null;
    final banner = rawBanner == null ? null : web.base.resolve(rawBanner);
    final fid = params['fid'];
    bool linkExists(String file, bool Function(Map<String, String>) matches) =>
        content.querySelectorAll('a[href]').any((a) {
          final link = web.siteLink(result.uri, a.attributes['href'], file);
          return link != null && matches(link.queryParameters);
        });
    return (
      items: items.values.toList(),
      next:
          nextUri != null &&
              nextUri != result.uri &&
              _matchesPage(section, params, nextUri)
          ? nextUri
          : null,
      title: heading?.text.trim() ?? '',
      detail: group
          ? content
                .querySelector('#gh .bm_c > div.pbn, .mn .xlda dd:not([class])')
                ?.text
                .trim()
          : null,
      image:
          banner != null &&
              {'http', 'https'}.contains(banner.scheme) &&
              banner.userInfo.isEmpty
          ? banner
          : null,
      canJoin:
          group && content.querySelector('form[id^="groupjoinform_"]') != null,
      canLeave:
          group && content.querySelector('form[id^="groupexitform_"]') != null,
      canManage:
          group &&
          linkExists(
            'forum.php',
            (p) =>
                p['mod'] == 'group' &&
                p['action'] == 'manage' &&
                p['fid'] == fid,
          ),
      canCreate:
          section == CommunitySection.groups &&
          linkExists(
            'forum.php',
            (p) => p['mod'] == 'group' && p['action'] == 'create',
          ),
      groupStatus: group
          ? content
                .querySelector('#gh p.mtm.xi1, .mn .xlda dd.xi1')
                ?.text
                .trim()
          : null,
      canReadGroup:
          group &&
          linkExists(
            'forum.php',
            (p) => p['mod'] == 'forumdisplay' && p['fid'] == fid,
          ),
    );
  }

  Future<({Uri uri, Document document, String source})> _searchGroups(
    Uri target,
    String keyword,
  ) async {
    final first = await web.read(target);
    final form = first.document.querySelector('form.searchform');
    if (DiscuzWebClient.hasCaptcha(form)) {
      web.rejected(first.document, 'forum_search_captcha');
    }
    if (form == null || form.attributes['method']?.toLowerCase() != 'post') {
      web.rejected(first.document, 'forum_api_unavailable');
    }
    final action = web.siteLink(
      first.uri,
      form.attributes['action'],
      'search.php',
    );
    if (action == null || action.queryParameters['mod'] != 'group') {
      web.rejected(first.document, 'forum_api_unavailable');
    }
    final fields = DiscuzWebClient.formFields(form);
    return web.read(
      action.replace(
        queryParameters: {...action.queryParameters, 'mobile': 'no'},
      ),
      body: {...fields, 'srchtxt': keyword, 'searchsubmit': 'yes'},
    );
  }

  bool _matchesPage(
    CommunitySection section,
    Map<String, String> params,
    Uri uri,
  ) {
    final query = uri.queryParameters;
    if (section == CommunitySection.groupRequests &&
        uri.queryParametersAll.entries.any(
          (entry) =>
              !{
                'mod',
                'action',
                'op',
                'fid',
                'page',
                'mobile',
              }.contains(entry.key) ||
              entry.value.length != 1,
        )) {
      return false;
    }
    return {...section.query, ...params}.entries.every(
      (entry) =>
          query[entry.key] == entry.value ||
          (entry.key == 'mod' &&
              section == CommunitySection.groups &&
              !query.containsKey('mod')),
    );
  }

  String _selector(CommunitySection section) => switch (section) {
    CommunitySection.group => '.mn a[href*="mod=viewthread"]',
    CommunitySection.groupMembers => '.mn a[href*="mod=space"]',
    CommunitySection.groupRequests => '.mn dt a[href*="mod=space"]',
    CommunitySection.followingFeed => '#followlist a[href*="mod=viewthread"]',
    CommunitySection.myActivities => '.mn table.acl tr h4 a[href]',
    CommunitySection.findUsers => '.mn a[href*="mod=space"][href*="uid="]',
    CommunitySection.friendRequests =>
      '#friend_ul li[id^="friend_tbody_"] a[href*="mod=space"]',
    CommunitySection.collection => 'a.xst[href*="mod=viewthread"]',
    CommunitySection.pendingThreads || CommunitySection.pendingReplies =>
      '#moderate .um[id^="pid_"] a[href*="modthreadkey="]',
    CommunitySection.reports => '#reportform a[href]',
    CommunitySection.myCollections ||
    CommunitySection.allCollections => '.clct_list dt a[href*="action=view"]',
    CommunitySection.tasks ||
    CommunitySection.activeTasks ||
    CommunitySection.completedTasks => 'h3 a[href*="mod=task"]',
    _ => 'a[href]',
  };

  CommunityItem? _item(CommunitySection section, Uri from, Element anchor) {
    final href = anchor.attributes['href'];
    Uri? uri;
    for (final file in [
      'forum.php',
      'home.php',
      'group.php',
      'misc.php',
      'portal.php',
    ]) {
      uri = web.siteLink(from, href, file);
      if (uri != null) break;
    }
    if (uri == null &&
        section == CommunitySection.myActivities &&
        href != null) {
      final rewritten = from.resolveUri(Uri.tryParse(href) ?? Uri());
      final filename = rewritten.pathSegments.lastOrNull;
      final match = RegExp(r'^thread-(\d+)-\d+-\d+\.html$')
          .firstMatch(filename ?? '');
      final original = match == null
          ? null
          : web.siteLink(from, href, filename!);
      if (original != null) {
        uri = web.page('forum.php', {
          'mod': 'viewthread',
          'tid': match!.group(1)!,
        });
      }
    }
    if (uri == null && section == CommunitySection.portal && href != null) {
      final rewritten = from.resolveUri(Uri.tryParse(href) ?? Uri());
      final fileName = rewritten.pathSegments.lastOrNull;
      if (fileName != null) {
        final match = RegExp(r'^article-(\d+)-\d+\.html$').firstMatch(fileName);
        final safe = match == null ? null : web.siteLink(from, href, fileName);
        if (safe != null && anchor.text.trim().isNotEmpty) {
          return (
            kind: CommunityTarget.article,
            title: anchor.text.trim(),
            id: _id(match!.group(1)),
            post: null,
            uri: safe,
            detail: null,
          );
        }
      }
    }
    if (uri == null) return null;
    final p = uri.queryParameters;
    final mod = p['mod'];
    final title = anchor.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty || int.tryParse(title) != null) return null;
    final file = uri.pathSegments.last;
    var detail = '';
    var label = title;
    CommunityTarget? kind;
    int? id, pid;
    if ({
      CommunitySection.groups,
      CommunitySection.joinedGroups,
      CommunitySection.managedGroups,
      CommunitySection.groupSearch,
    }.contains(section)) {
      if (file == 'forum.php' &&
          mod == 'group' &&
          (p['action'] == null || p['action'] == 'index')) {
        kind = CommunityTarget.group;
        id = _id(p['fid']);
      } else if (section == CommunitySection.groups &&
          file == 'group.php' &&
          (p['gid'] != null || p['sgid'] != null) &&
          !anchor.classes.contains('y')) {
        kind = CommunityTarget.groupCategory;
      }
    } else if ({
      CommunitySection.groupMembers,
      CommunitySection.groupRequests,
      CommunitySection.following,
      CommunitySection.followers,
      CommunitySection.findUsers,
      CommunitySection.friendRequests,
    }.contains(section)) {
      if (file == 'home.php' &&
          mod == 'space' &&
          (p['do'] == null || p['do'] == 'profile')) {
        kind = CommunityTarget.person;
        id = _id(p['uid']);
      }
    } else if (section == CommunitySection.myCollections ||
        section == CommunitySection.allCollections) {
      if (file == 'forum.php' &&
          mod == 'collection' &&
          p['action'] == 'view' &&
          p['op'] == null) {
        kind = CommunityTarget.collection;
        id = _id(p['ctid']);
        final heading = anchor.parent?.parent;
        final role = heading?.querySelector('.ctag')?.text.trim();
        final summary = heading?.parent
            ?.querySelector('dt + dd > p')
            ?.text
            .trim();
        detail = [
          role,
          summary,
        ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
      }
    } else if (section == CommunitySection.portal) {
      if (file == 'portal.php' && mod == 'view') {
        kind = CommunityTarget.article;
        id = _id(p['aid']);
      } else if (file == 'portal.php' &&
          mod == 'list' &&
          _id(p['catid']) != null) {
        kind = CommunityTarget.portalCategory;
        id = _id(p['catid']);
      }
    } else if (section == CommunitySection.medals ||
        section == CommunitySection.myMedals) {
      return null;
    } else if (section == CommunitySection.tasks ||
        section == CommunitySection.activeTasks ||
        section == CommunitySection.completedTasks) {
      if (file == 'home.php' &&
          mod == 'task' &&
          p['do'] == 'view' &&
          _id(p['id']) != null) {
        kind = CommunityTarget.web;
        final row = anchor.parent?.parent?.parent;
        detail =
            [
                  row?.querySelector('.pbg')?.text.trim(),
                  row?.querySelector('td.xi1')?.text.trim(),
                ]
                .whereType<String>()
                .where((part) => part.isNotEmpty)
                .map((part) => part.replaceAll(RegExp(r'\s+'), ' '))
                .join(' · ');
      }
    } else if (section == CommunitySection.rankings &&
        file == 'misc.php' &&
        mod == 'ranklist' &&
        p['type'] != null) {
      final kindName = p['type'];
      if (!{'thread', 'activity', 'poll', 'group'}.contains(kindName)) {
        return null;
      }
      kind = CommunityTarget.ranking;
      // The overview uses generic “More” links. Use the section heading.
      final heading = anchor.parent?.parent?.querySelector('h2')?.text.trim();
      return (
        kind: kind,
        title: heading != null && heading.isNotEmpty ? heading : title,
        detail: null,
        uri: uri,
        id: null,
        post: null,
      );
    } else if (section == CommunitySection.rankings &&
        file == 'forum.php' &&
        mod == 'group' &&
        p['action'] == null) {
      kind = CommunityTarget.group;
      id = _id(p['fid']);
    } else if (file == 'forum.php' &&
        {'viewthread', 'redirect'}.contains(mod)) {
      kind = CommunityTarget.thread;
      id = _id(p['tid'] ?? p['ptid']);
      pid = _id(p['pid']) ?? _id(uri.fragment.replaceFirst('pid', ''));
      if (section == CommunitySection.pendingThreads ||
          section == CommunitySection.pendingReplies) {
        final row = anchor.parent?.parent?.parent;
        label = row?.querySelector('p.pbn > span.xw1')?.text.trim() ?? title;
        detail = row?.querySelector('[id^="list_note_"]')?.text.trim() ?? '';
      } else if (section == CommunitySection.reports) {
        detail = anchor.parent?.text.trim() ?? '';
      } else if (section == CommunitySection.myActivities) {
        final row = anchor.parent?.parent?.parent;
        final date =
            row?.parent?.parent?.querySelector('caption h3') ??
            row?.parent?.querySelector('caption h3');
        detail = [
          if (date != null)
            date.nodes
                .whereType<Text>()
                .map((part) => part.text.trim())
                .where((part) => part.isNotEmpty)
                .join(' '),
          ...?row
              ?.querySelector('td.addr')
              ?.nodes
              .map((part) => part.text?.trim() ?? '')
              .where((part) => part.isNotEmpty),
        ].where((part) => part.isNotEmpty).join(' · ');
      } else if (section == CommunitySection.followingFeed) {
        final row = anchor.parent?.parent;
        detail =
            row?.querySelector('.flw_author, .flw_author a')?.text.trim() ?? '';
      }
      if (detail.length > 240) detail = '${detail.substring(0, 240)}…';
    }
    if (kind == null ||
        id == null &&
            {
              CommunityTarget.thread,
              CommunityTarget.person,
              CommunityTarget.group,
              CommunityTarget.collection,
              CommunityTarget.portalCategory,
              CommunityTarget.article,
            }.contains(kind)) {
      return null;
    }
    return (
      kind: kind,
      title: label,
      detail: detail.isEmpty ? null : detail,
      id: id,
      post: pid,
      uri: uri,
    );
  }

  Future<Uri?> rssLink(int fid) async {
    final page = await web.read(
      web.page('forum.php', {'mod': 'forumdisplay', 'fid': '$fid'}),
    );
    for (final link in page.document.querySelectorAll('a[href*="mod=rss"]')) {
      final uri = web.siteLink(page.uri, link.attributes['href'], 'forum.php');
      if (uri?.queryParameters['mod'] == 'rss' &&
          uri?.queryParameters['fid'] == '$fid') {
        return uri;
      }
    }
    return null;
  }

  static int? _id(String? value) {
    final id = int.tryParse(value ?? '');
    return id != null && id > 0 ? id : null;
  }

  Future<void> changeGroup(
    int uid,
    int fid,
    bool join,
    bool Function() current,
  ) async {
    final formPage = page(CommunitySection.group, {'fid': '$fid'});
    final result = await web.read(formPage);
    final action = join ? 'join' : 'out';
    final field = join ? 'groupjoin' : 'groupexit';
    final target = web.page('forum.php', {
      'mod': 'group',
      'action': action,
      'fid': '$fid',
    });
    final response = await _submitForm(
      uid,
      result.document,
      result.uri,
      target,
      {field},
      current,
    );
    _check(current);
    final reloaded = await load(CommunitySection.group, {'fid': '$fid'});
    if (join ? reloaded.canJoin : reloaded.canLeave) {
      web.rejected(response, 'forum_api_unavailable');
    }
  }

  Future<void> friend(
    int account,
    int uid, {
    required bool accept,
    String? note,
    required bool Function() current,
  }) async {
    final target = web.page('home.php', {
      'mod': 'spacecp',
      'ac': 'friend',
      'op': 'add',
      'uid': '$uid',
    });
    final result = await web.read(target);
    await _submitForm(
      account,
      result.document,
      result.uri,
      target,
      {accept ? 'add2submit' : 'addsubmit'},
      current,
      note: note,
    );
  }

  Future<void> ignoreFriend(
    int account,
    int uid,
    bool Function() current,
  ) async {
    final target = web.page('home.php', {
      'mod': 'spacecp',
      'ac': 'friend',
      'op': 'ignore',
      'uid': '$uid',
    });
    final result = await web.read(target);
    await _submitForm(
      account,
      result.document,
      result.uri,
      target,
      {'friendsubmit'},
      current,
      moreParams: const {'confirm': '1'},
    );
  }

  Future<bool?> followStatus(int uid) async {
    final target = page(CommunitySection.findUsers, {
      'uid': '$uid',
      'searchsubmit': 'yes',
    });
    final result = await web.read(target);
    if (result.document.querySelector('#messagetext') != null) return null;
    for (final a in result.document.querySelectorAll('#ct a[href]')) {
      final p = web
          .siteLink(result.uri, a.attributes['href'], 'home.php')
          ?.queryParameters;
      if (p?['mod'] == 'spacecp' &&
          p?['ac'] == 'follow' &&
          p?['fuid'] == '$uid' &&
          p?['special'] == null) {
        if (p?['op'] == 'add') return false;
        if (p?['op'] == 'del') return true;
      }
    }
    return null;
  }

  Future<void> follow(
    int account,
    int uid,
    bool following,
    bool Function() current,
  ) async {
    final status = await followStatus(uid);
    if (status != following) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
    final hash = await web.accountHash(account);
    _check(current);
    await _submit(
      web.page('home.php', {
        'mod': 'spacecp',
        'ac': 'follow',
        'op': following ? 'del' : 'add',
        'fuid': '$uid',
        'hash': hash,
      }),
      {'formhash': hash},
    );
    _check(current);
    if (await followStatus(uid) != !following) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
  }

  Future<void> reviewGroup(
    int account,
    int fid,
    int uid,
    bool approve,
    bool Function() current,
  ) async {
    final params = {'fid': '$fid'};
    if (!await _hasGroupRequest(params, uid, current)) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
    final hash = await web.accountHash(account);
    _check(current);
    await _submit(
      page(CommunitySection.groupRequests, {
        'fid': '$fid',
        'uid': '$uid',
        'checktype': approve ? '1' : '2',
      }),
      {'formhash': hash},
    );
    if (await _hasGroupRequest(params, uid, current)) {
      throw const ForumApiException(
        'forum_api_unavailable',
        '',
        fromForum: true,
      );
    }
  }

  Future<bool> _hasGroupRequest(
    Map<String, String> params,
    int uid,
    bool Function() current,
  ) async {
    final visited = <Uri>{};
    Uri? next;
    while (true) {
      _check(current);
      final page = await load(
        CommunitySection.groupRequests,
        params,
        next: next,
      );
      _check(current);
      if (page.items.any((item) => item.id == uid)) return true;
      next = page.next;
      if (next == null) return false;
      if (!visited.add(next)) {
        throw const ForumApiException(
          'forum_api_unavailable',
          '',
          fromForum: true,
        );
      }
    }
  }

  Future<Document> _submitForm(
    int uid,
    Document document,
    Uri from,
    Uri target,
    Set<String> submitNames,
    bool Function() current, {
    String? note,
    Map<String, String> moreParams = const {},
  }) async {
    final hash = await web.accountHash(uid);
    for (final form in document.querySelectorAll('form[action]')) {
      final posted = web.siteLink(
        from,
        form.attributes['action'],
        target.pathSegments.last,
      );
      if (posted == null ||
          target.queryParameters.entries.any(
            (e) =>
                posted.queryParameters[e.key] != e.value && e.key != 'mobile',
          )) {
        continue;
      }
      if (DiscuzWebClient.hasCaptcha(form)) break;
      final fields = DiscuzWebClient.formFields(form);
      if (fields['formhash'] != hash || !submitNames.any(fields.containsKey)) {
        continue;
      }
      if (note != null && fields.containsKey('note')) fields['note'] = note;
      _check(current);
      return _submit(
        target.replace(
          queryParameters: {...target.queryParameters, ...moreParams},
        ),
        fields,
      );
    }
    web.rejected(document, 'forum_api_unavailable');
  }

  Future<Document> _submit(Uri uri, Map<String, dynamic> body) async {
    final response = await web.read(
      uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'inajax': '1',
          'handlekey': 'disfly_community',
        },
      ),
      body: body,
    );
    if (!response.source.contains("succeedhandle_disfly_community('")) {
      web.rejected(response.document, 'forum_api_unavailable');
    }
    return response.document;
  }

  void _check(bool Function() current) {
    if (!current()) {
      throw const ForumApiException('account_changed', '', fromForum: true);
    }
  }
}
