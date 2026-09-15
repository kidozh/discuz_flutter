import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';

class RatingCredit {
  final String field, title;
  final int min, max, remaining;
  RatingCredit(this.field, this.title, this.min, this.max, this.remaining);
}

class RatingForm {
  final String hash, notice;
  final List<RatingCredit> credits;
  final bool notifyRequired;
  RatingForm(this.hash, this.notice, this.credits, this.notifyRequired);
  static RatingForm parse(String source, int tid, int pid) {
    final cdata = RegExp(r'<!\[CDATA\[([\s\S]*?)\]\]>').firstMatch(source);
    final doc = html.parse(cdata?.group(1) ?? source);
    final form = doc.querySelector('form#rateform');
    String value(String name) =>
        form?.querySelector('input[name="$name"]')?.attributes['value'] ?? '';
    if (form == null ||
        value('tid') != '$tid' ||
        value('pid') != '$pid' ||
        value('formhash').isEmpty) {
      throw const ForumApiException('rating_unavailable', '');
    }
    final credits = <RatingCredit>[];
    for (final input in form.querySelectorAll('input')) {
      final name = input.attributes['name'] ?? '';
      if (!RegExp(r'^score[1-8]$').hasMatch(name)) continue;
      var row = input.parent;
      while (row != null && row.localName != 'tr') {
        row = row.parent;
      }
      final cells = row?.querySelectorAll('td') ?? [];
      if (cells.length != 4)
        throw const ForumApiException('rating_unavailable', '');
      final range = RegExp(
        r'^\s*(-?\d+)\s*~\s*(-?\d+)\s*$',
      ).firstMatch(cells[2].text);
      final remaining = int.tryParse(cells[3].text.trim());
      if (range == null || remaining == null || remaining < 0)
        throw const ForumApiException('rating_unavailable', '');
      credits.add(
        RatingCredit(
          name,
          cells[0].text.trim(),
          int.parse(range[1]!),
          int.parse(range[2]!),
          remaining,
        ),
      );
    }
    if (credits.isEmpty)
      throw const ForumApiException('rating_unavailable', '');
    final notify = form.querySelector('input[name="sendreasonpm"]');
    return RatingForm(
      value('formhash'),
      form.querySelector('.xg1')?.text.trim() ?? '',
      credits,
      notify?.attributes.containsKey('disabled') == true &&
          notify?.attributes.containsKey('checked') == true,
    );
  }

  bool sameTerms(RatingForm other) =>
      notice == other.notice &&
      notifyRequired == other.notifyRequired &&
      credits.length == other.credits.length &&
      credits.asMap().entries.every((entry) {
        final a = entry.value, b = other.credits[entry.key];
        return a.field == b.field &&
            a.title == b.title &&
            a.min == b.min &&
            a.max == b.max &&
            a.remaining == b.remaining;
      });
}

class PostReviewClient {
  final ForumInteractionClient api;
  PostReviewClient(this.api);
  Future<String> validate(
    int tid,
    int pid,
    int uid,
    bool Function() sameAccount, {
    bool replyOnly = false,
  }) async {
    final response = await api.request('viewthread', {
      'tid': tid,
      'viewpid': pid,
    });
    response.requireData('postlist');
    final posts = forumRows(response.variables['postlist'])
        .map(discuzMap)
        .where((p) => discuzInt(p['pid']) == pid && discuzInt(p['tid']) == tid);
    final hash = discuzString(response.variables['formhash']);
    if (!sameAccount() ||
        discuzInt(response.variables['member_uid']) != uid ||
        uid <= 0 ||
        hash.isEmpty ||
        posts.length != 1 ||
        discuzInt(posts.single['authorid']) == uid ||
        (replyOnly && discuzInt(posts.single['first']) != 0)) {
      throw const ForumApiException('post_review_unavailable', '');
    }
    return hash;
  }

  Future<void> vote(
    int tid,
    int pid,
    int uid,
    bool positive,
    bool Function() sameAccount,
  ) async {
    final hash = await validate(tid, pid, uid, sameAccount, replyOnly: true);
    if (!sameAccount()) throw const ForumApiException('account_changed', '');
    final result = await api.request(
      'forummisc',
      {
        'action': 'postreview',
        'do': positive ? 'support' : 'against',
        'tid': tid,
        'pid': pid,
        'hash': hash,
      },
      body: {'formhash': hash},
    );
    result.requireSuccess({'thread_poll_succeed'});
  }

  Future<RatingForm> ratingForm(int tid, int pid) async {
    final uri = api.endpoint
        .resolve('../../forum.php')
        .replace(
          queryParameters: {
            'mod': 'misc',
            'action': 'rate',
            'tid': '$tid',
            'pid': '$pid',
            'inajax': '1',
            'infloat': 'yes',
            'mobile': 'no',
          },
        );
    final response = await api.dio.getUri<String>(
      uri,
      options: Options(responseType: ResponseType.plain),
    );
    return RatingForm.parse(response.data ?? '', tid, pid);
  }

  Future<void> rate(
    int tid,
    int pid,
    RatingForm form,
    Map<String, int> scores,
    String reason,
    bool notify,
  ) async {
    if (scores.isEmpty ||
        !scores.values.any((v) => v != 0) ||
        scores.keys.any((k) => !form.credits.any((c) => c.field == k)))
      throw const ForumApiException('invalid_rating', '');
    for (final c in form.credits) {
      final score = scores[c.field] ?? 0;
      if (score != 0 &&
          (score < c.min || score > c.max || score.abs() > c.remaining))
        throw const ForumApiException('invalid_rating', '');
    }
    final response = await api.request(
      'forummisc',
      {
        'action': 'rate',
        // forummisc emits its JSON result from the output hook only when
        // t=output is requested; otherwise Discuz renders a message page.
        't': 'output',
        'tid': tid,
        'pid': pid,
        'inajax': 1,
        'ratesubmit': 'yes',
      },
      body: {
        'formhash': form.hash,
        'tid': tid,
        'pid': pid,
        ...scores,
        'reason': reason,
        if (notify || form.notifyRequired) 'sendreasonpm': 'on',
      },
    );
    response.requireSuccess({'thread_rate_succeed'});
  }
}
