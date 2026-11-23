import 'package:html/dom.dart';

import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

typedef ForumSearchHit = ({
  int tid,
  String title,
  String board,
  int? fid,
  String details,
  String excerpt,
  String attribution,
});
typedef ForumSearchBatch = ({List<ForumSearchHit> hits, Uri? next});

class ForumSearchOptions {
  const ForumSearchOptions({
    this.author = '',
    this.fullText = false,
    this.since = '0',
    this.order = 'lastpost',
    this.ascending = false,
    this.older = false,
  });
  final String author, since, order;
  final bool fullText, ascending, older;
  Map<String, String> get fields => {
    'srchtype': fullText ? 'fulltext' : 'title',
    if (author.trim().isNotEmpty) 'srchuname': author.trim(),
    'srchfrom': since,
    'orderby': order,
    'ascdesc': ascending ? 'asc' : 'desc',
    'before': older ? '1' : '0',
  };
}

class ForumSearchForm {
  const ForumSearchForm(
    this.hash,
    this.fullText,
    this.times,
    this.orders,
    this.notice,
  );
  final String hash, notice;
  final bool fullText;
  final Map<String, String> times, orders;
}

class ForumSearchClient {
  ForumSearchClient(this.web);

  final DiscuzWebClient web;

  static Uri website(
    Uri base,
    String keyword,
    int? fid, {
    ForumSearchOptions options = const ForumSearchOptions(),
  }) => base
      .resolve('search.php')
      .replace(
        queryParameters: {
          'mod': 'forum',
          'adv': '1',
          ...options.fields,
          'mobile': 'no',
          if (keyword.trim().isNotEmpty) 'srchtxt': keyword.trim(),
          if (fid != null) 'srchfid': '$fid',
        },
      );

  void _checkCaptcha(Document document) {
    final notice = document.querySelector('#messagetext > p')?.text ?? '';
    if (DiscuzWebClient.hasCaptcha(document.body) ||
        RegExp(
          r'验证码|驗證碼|captcha|verification code|security question|验证问答|驗證問答',
          caseSensitive: false,
        ).hasMatch(notice)) {
      throw const ForumApiException(
        'forum_search_captcha',
        '',
        fromForum: true,
      );
    }
  }

  Future<ForumSearchForm> loadForm() async {
    final response = await web.read(
      web.page('search.php', {'mod': 'forum', 'adv': '1'}),
    );
    _checkCaptcha(response.document);
    final form = response.document
        .querySelector('input[name="srchuname"]')
        ?.parent;
    Element? parent = form;
    while (parent != null && parent.localName != 'form') {
      parent = parent.parent;
    }
    final action = web.siteLink(
      response.uri,
      parent?.attributes['action'],
      'search.php',
    );
    final hash =
        parent?.querySelector('input[name="formhash"]')?.attributes['value'] ??
        '';
    if (parent == null ||
        action?.queryParameters['mod'] != 'forum' ||
        hash.isEmpty) {
      web.rejected(response.document, 'forum_webpage_redirect');
    }
    Map<String, String> choices(String name, Set<String> allowed) => {
      for (final option in parent!.querySelectorAll(
        'select[name="$name"]:not([disabled]) option:not([disabled])',
      ))
        if (allowed.contains(option.attributes['value']))
          option.attributes['value']!: option.text.trim(),
    };
    return ForumSearchForm(
      hash,
      parent.querySelector(
            'input[name="srchtype"][value="fulltext"]:not([disabled])',
          ) !=
          null,
      choices('srchfrom', {
        '0',
        '86400',
        '172800',
        '604800',
        '2592000',
        '7776000',
        '15552000',
        '31536000',
      }),
      choices('orderby', {'lastpost', 'dateline', 'replies', 'views'}),
      response.document.querySelector('form.searchform > p')?.text.trim() ?? '',
    );
  }

  Future<ForumSearchBatch> search(
    String keyword,
    int? fid, {
    Uri? next,
    ForumSearchOptions options = const ForumSearchOptions(),
  }) async {
    final query = keyword.trim();
    final start = web.page('search.php', {'mod': 'forum'});
    if (next != null && !_resultsLink(next)) {
      throw const ForumApiException(
        'forum_webpage_redirect',
        '',
        fromForum: true,
      );
    }
    final form = next == null ? await loadForm() : null;
    if (form != null &&
        ((options.fullText && !form.fullText) ||
            (options.since != '0' && !form.times.containsKey(options.since)) ||
            (options.order != 'lastpost' &&
                !form.orders.containsKey(options.order)))) {
      throw const ForumApiException(
        'search_forum_invalid',
        '',
        fromForum: true,
      );
    }
    final response = await web.read(
      next ?? start,
      body: next == null
          ? {
              'searchsubmit': 'yes',
              'formhash': form!.hash,
              ...options.fields,
              'srchtxt': query,
              if (fid != null) 'srchfid': '$fid',
            }
          : null,
    );
    final document = response.document;
    final notice = document.querySelector('#messagetext > p')?.text ?? '';
    if (DiscuzWebClient.hasCaptcha(document.body) ||
        RegExp(
          r'验证码|驗證碼|captcha|verification code|security question|验证问答|驗證問答',
          caseSensitive: false,
        ).hasMatch(notice)) {
      throw const ForumApiException(
        'forum_search_captcha',
        '',
        fromForum: true,
      );
    }
    final results = document.querySelector('#threadlist');
    if (results == null &&
        document.querySelector('.tl .sttl + .emp, .tl p.emp') == null) {
      web.rejected(document, 'forum_webpage_redirect');
    }
    final hits = <ForumSearchHit>[];
    final ids = <int>{};
    for (final title
        in results?.querySelectorAll('li.pbw h3 a[href]') ?? <Element>[]) {
      final link = web.threadLink(response.uri, title.attributes['href']);
      final row = title.parent?.parent;
      if (link == null || row == null || !ids.add(link.tid)) continue;
      final paragraphs = row.children
          .where((element) => element.localName == 'p')
          .toList();
      final board = row.querySelector('a[href*="mod=forumdisplay"]');
      hits.add((
        tid: link.tid,
        title: title.text.trim(),
        board: board?.text.trim() ?? '',
        fid: int.tryParse(
          web
                  .siteLink(
                    response.uri,
                    board?.attributes['href'],
                    'forum.php',
                  )
                  ?.queryParameters['fid'] ??
              '',
        ),
        details: paragraphs.firstOrNull?.text.trim() ?? '',
        excerpt: paragraphs.length > 1 ? paragraphs[1].text.trim() : '',
        attribution: paragraphs.length > 2
            ? paragraphs[2].children
                  .where(
                    (element) =>
                        element.localName == 'span' &&
                        element.querySelector('a[href*="mod=forumdisplay"]') ==
                            null,
                  )
                  .map((element) => element.text.trim())
                  .where((text) => text.isNotEmpty)
                  .join(' · ')
            : '',
      ));
    }
    if (results != null && hits.isEmpty)
      web.rejected(document, 'forum_webpage_redirect');
    final href = document.querySelector('.pg a.nxt')?.attributes['href'];
    final link = web.siteLink(response.uri, href, 'search.php');
    return (
      hits: hits,
      next: link != null && _resultsLink(link) && link != response.uri
          ? link.replace(
              queryParameters: {...link.queryParameters, 'mobile': 'no'},
            )
          : null,
    );
  }

  bool _resultsLink(Uri uri) =>
      web.siteLink(web.base, uri.toString(), 'search.php') != null &&
      uri.queryParameters['mod'] == 'forum' &&
      (int.tryParse(uri.queryParameters['searchid'] ?? '') ?? 0) > 0;
}

enum ActivityReviewAction {
  approve('', 'activity_auditing_completion'),
  replenish('replenish', 'activity_auditing_completion'),
  notify('notification', 'activity_notification_success'),
  reject('delete', 'activity_delete_completion');

  const ActivityReviewAction(this.operation, this.success);
  final String operation, success;
}

typedef ActivityApplicant = ({
  int? id,
  int uid,
  String name,
  String message,
  List<String> details,
  String status,
  bool approved,
});
typedef ActivityReviewForm = ({
  String hash,
  List<ActivityApplicant> applicants,
});

class ActivityReviewClient {
  ActivityReviewClient(this.web, this.tid, this.uid);

  final DiscuzWebClient web;
  final int tid, uid;

  Uri get website => web.page('forum.php', {
    'mod': 'misc',
    'action': 'activityapplylist',
    'tid': '$tid',
  });

  Future<ActivityReviewForm> load() async {
    final hash = await web.accountHash(uid, tid: tid);
    final response = await web.read(website);
    final form = response.document.querySelector('form#applylistform');
    if (form == null ||
        form.querySelector('input[name="formhash"]')?.attributes['value'] !=
            hash ||
        form.querySelector('button[name="applylistsubmit"]') == null) {
      web.rejected(response.document, 'activity_is_not_manager');
    }
    final action = web.siteLink(
      response.uri,
      form.attributes['action'],
      'forum.php',
    );
    if (action?.queryParameters['mod'] != 'misc' ||
        action?.queryParameters['action'] != 'activityapplylist' ||
        action?.queryParameters['tid'] != '$tid') {
      web.rejected(response.document, 'forum_webpage_redirect');
    }
    final applicants = <ActivityApplicant>[];
    for (final row in form.querySelectorAll('table.list tr')) {
      final cells = row.children
          .where((cell) => cell.localName == 'td')
          .toList();
      if (cells.length < 6) continue;
      final profile = cells[1].querySelector('a[href*="mod=space&uid="]');
      final link = web.siteLink(
        response.uri,
        profile?.attributes['href'],
        'home.php',
      );
      final profileUid = int.tryParse(link?.queryParameters['uid'] ?? '');
      if (profile == null || profileUid == null || profileUid <= 0) continue;
      final id = int.tryParse(
        cells.first
                .querySelector('input[name="applyidarray[]"]:not([disabled])')
                ?.attributes['value'] ??
            '',
      );
      applicants.add((
        id: id != null && id > 0 && profileUid != uid ? id : null,
        uid: profileUid,
        name: profile.text.trim(),
        message: cells[2].text.trim(),
        details: [
          ...cells[3].querySelectorAll('li').map((node) => node.text.trim()),
          for (final cell in cells.skip(4).take(cells.length - 5))
            if (cell.text.trim().isNotEmpty) cell.text.trim(),
        ],
        status: cells.last.text.trim(),
        approved: cells.last.querySelector('.fico-valid, .fc-v') != null,
      ));
    }
    return (hash: hash, applicants: applicants);
  }

  Future<void> review({
    required ActivityReviewAction action,
    required List<ActivityApplicant> selected,
    required String reason,
    required bool Function() isCurrent,
  }) async {
    final fresh = await load();
    final current = {
      for (final row in fresh.applicants)
        if (row.id != null) row.id!: row,
    };
    if (!isCurrent()) throw const ForumApiException('account_changed', '');
    if (selected.isEmpty ||
        (action == ActivityReviewAction.notify && reason.trim().isEmpty) ||
        selected.any(
          (row) =>
              row.id == null ||
              current[row.id]?.uid != row.uid ||
              current[row.id]?.status != row.status ||
              ((action == ActivityReviewAction.approve ||
                      action == ActivityReviewAction.replenish) &&
                  row.approved),
        )) {
      throw const ForumApiException(
        'activity_review_changed',
        '',
        fromForum: true,
      );
    }
    final reply = await web.api.request(
      'forummisc',
      {'action': 'activityapplylist', 'tid': tid, 't': 'output'},
      body: {
        'applylistsubmit': 'yes',
        'formhash': fresh.hash,
        'operation': action.operation,
        'applyidarray[]': selected.map((row) => '${row.id}').toList(),
        'reason': reason.trim(),
      },
    );
    reply.requireSuccess({action.success});
  }
}

typedef CreditEntry = ({
  String label,
  List<String> amounts,
  String details,
  String date,
  ForumLink? thread,
  Uri? rule,
});
typedef CreditBatch = ({List<CreditEntry> entries, Uri? next});
typedef CreditRulesBatch = ({
  List<CreditEntry> entries,
  Map<int, String> boards,
});

class CreditHistoryClient {
  CreditHistoryClient(this.web, this.uid);

  final DiscuzWebClient web;
  final int uid;

  static Uri website(Uri base, {bool rewards = false}) => base
      .resolve('home.php')
      .replace(
        queryParameters: {
          'mod': 'spacecp',
          'ac': 'credit',
          'op': 'log',
          'mobile': 'no',
          if (rewards) 'suboperation': 'creditrulelog',
        },
      );

  static Uri rulesWebsite(Uri base, {int? fid}) => base
      .resolve('home.php')
      .replace(
        queryParameters: {
          'mod': 'spacecp',
          'ac': 'credit',
          'op': 'rule',
          'mobile': 'no',
          if (fid != null) 'fid': '$fid',
        },
      );

  Future<CreditRulesBatch> loadRules({int? fid}) async {
    final hash = await web.accountHash(uid);
    final response = await web.read(rulesWebsite(web.base, fid: fid));
    final doc = response.document;
    final actual = response.uri.queryParameters;
    final accountLink = web.siteLink(
      response.uri,
      doc.querySelector('#um a[href*="action=logout"]')?.attributes['href'],
      'member.php',
    );
    if (actual['mod'] != 'spacecp' ||
        actual['ac'] != 'credit' ||
        actual['op'] != 'rule' ||
        actual['fid'] != fid?.toString() ||
        accountLink?.queryParameters['formhash'] != hash) {
      web.rejected(doc, 'forum_webpage_redirect');
    }
    final table = doc.querySelector('#ct .mn table.dt.valt');
    if (table == null) web.rejected(doc, 'forum_webpage_redirect');
    final headers = table
        .querySelectorAll('tr th')
        .map((cell) => cell.text.trim())
        .toList();
    if (headers.length < 3) web.rejected(doc, 'forum_webpage_redirect');
    final entries = <CreditEntry>[];
    for (final row in table.querySelectorAll('tr')) {
      final cells = row.children
          .where((cell) => cell.localName == 'td')
          .toList();
      if (cells.length != headers.length || cells.first.text.trim().isEmpty)
        continue;
      entries.add((
        label: cells.first.text.trim(),
        details: [
          for (var i = 1; i <= 2; i++)
            if (cells[i].text.trim().isNotEmpty)
              '${headers[i]} ${cells[i].text.trim()}',
        ].join(' · '),
        amounts: [
          for (var i = 3; i < cells.length; i++)
            if (cells[i].text.trim().isNotEmpty &&
                int.tryParse(cells[i].text.trim()) != 0)
              '${headers[i]} ${cells[i].text.trim()}',
        ],
        date: '',
        thread: null,
        rule: null,
      ));
    }
    final boards = <int, String>{
      for (final option in doc.querySelectorAll(
        '#ct .mn select[onchange*="op=rule"] option[value]',
      ))
        if (int.tryParse(option.attributes['value']!) case final id?)
          if (id > 0 && option.text.trim().isNotEmpty) id: option.text.trim(),
    };
    return (entries: entries, boards: boards);
  }

  Future<CreditBatch> load({bool rewards = false, Uri? next}) async {
    final hash = await web.accountHash(uid);
    if (next != null && !_isHistory(next, rewards)) {
      throw const ForumApiException(
        'forum_webpage_redirect',
        '',
        fromForum: true,
      );
    }
    final response = await web.read(
      next ?? website(web.base, rewards: rewards),
    );
    final doc = response.document;
    final pageHash = doc
        .querySelector('input[name="formhash"]')
        ?.attributes['value'];
    final table = rewards
        ? doc.querySelector('#ct .mn table.dt')
        : doc.querySelector('form table.dt[summary]');
    if (pageHash != hash || table == null) {
      web.rejected(doc, 'forum_webpage_redirect');
    }
    final labels = table
        .querySelectorAll('tr th')
        .map((cell) => cell.text.trim())
        .toList();
    final entries = <CreditEntry>[];
    for (final row in table.querySelectorAll('tr')) {
      final fields = row.children
          .where((cell) => cell.localName == 'td')
          .toList();
      if (fields.length < 4) continue;
      entries.add((
        label: fields.first.text.trim(),
        amounts: rewards ? _rewardAmounts(fields, labels) : _lines(fields[1]),
        details: rewards
            ? [
                for (var i = 1; i <= 2 && i < labels.length; i++)
                  '${labels[i]} ${fields[i].text.trim()}',
              ].join(' · ')
            : fields[2].text.trim(),
        date: fields.last.text.trim(),
        thread: rewards
            ? null
            : fields[2]
                  .querySelectorAll('a[href]')
                  .map(
                    (anchor) =>
                        web.threadLink(response.uri, anchor.attributes['href']),
                  )
                  .whereType<ForumLink>()
                  .firstOrNull,
        rule: rewards ? _ruleLink(response.uri, fields.first) : null,
      ));
    }
    final link = web.siteLink(
      response.uri,
      doc.querySelector('.pg a.nxt')?.attributes['href'],
      'home.php',
    );
    return (
      entries: entries,
      next: link != null && _isHistory(link, rewards)
          ? link.replace(
              queryParameters: {...link.queryParameters, 'mobile': 'no'},
            )
          : null,
    );
  }

  static List<String> _rewardAmounts(
    List<Element> fields,
    List<String> labels,
  ) {
    final amounts = <String>[];
    for (var i = 3; i < fields.length - 1 && i < labels.length; i++) {
      final text = fields[i].text.trim();
      final value = int.tryParse(text);
      if (text.isEmpty || value == 0) continue;
      final change = value != null && value > 0 ? '+$value' : text;
      amounts.add('${labels[i]} $change');
    }
    return amounts;
  }

  static List<String> _lines(Element cell) {
    final lines = <String>[];
    final line = StringBuffer();
    void finishLine() {
      final text = line.toString().trim();
      if (text.isNotEmpty) lines.add(text);
      line.clear();
    }

    for (final node in cell.nodes) {
      if (node is Element && node.localName == 'br') {
        finishLine();
      } else {
        line.write(node.text ?? '');
      }
    }
    finishLine();
    return lines;
  }

  Uri? _ruleLink(Uri page, Element field) {
    final uri = web.siteLink(
      page,
      field.querySelector('a[href]')?.attributes['href'],
      'home.php',
    );
    final query = uri?.queryParameters;
    if (uri == null ||
        query?['mod'] != 'spacecp' ||
        query?['ac'] != 'credit' ||
        query?['op'] != 'rule' ||
        (int.tryParse(query?['rid'] ?? '') ?? 0) <= 0) {
      return null;
    }
    return uri.replace(
      queryParameters: {...uri.queryParameters, 'mobile': 'no'},
    );
  }

  bool _isHistory(Uri uri, bool rewards) =>
      web.siteLink(web.base, uri.toString(), 'home.php') != null &&
      uri.queryParameters['mod'] == 'spacecp' &&
      uri.queryParameters['ac'] == 'credit' &&
      uri.queryParameters['op'] == 'log' &&
      (uri.queryParameters['suboperation'] == 'creditrulelog') == rewards;
}
