import 'ForumInteractionClient.dart';
import 'discuz_web_client.dart';

typedef PollVoter = ({int uid, String name});
typedef PollVoterBatch = ({List<PollVoter> voters, int? next});

class PollVotersClient {
  const PollVotersClient(this.web);

  final DiscuzWebClient web;

  Future<PollVoterBatch> load(int tid, int option, int page) async {
    final result = await web.read(
      web.page('forum.php', {
        'mod': 'misc',
        'action': 'viewvote',
        'tid': '$tid',
        'polloptionid': '$option',
        'page': '$page',
      }),
    );
    final list = result.document.querySelector('.voterlist');
    if (list == null ||
        list.querySelector('select option[selected]')?.attributes['value'] !=
            '$option' ||
        list.querySelector('ul.voterl') == null) {
      web.rejected(result.document, 'poll_voters_unavailable');
    }
    final voters = <int, PollVoter>{};
    for (final anchor in list.querySelectorAll('ul.voterl li a[href]')) {
      final uri = web.siteLink(
        result.uri,
        anchor.attributes['href'],
        'home.php',
      );
      if (uri?.queryParameters['mod'] != 'space') continue;
      final uid = int.tryParse(uri!.queryParameters['uid'] ?? '') ?? 0;
      final name = anchor.text.trim();
      if (uid > 0 && name.isNotEmpty) voters[uid] = (uid: uid, name: name);
    }
    final more = web
        .siteLink(
          result.uri,
          list.parent?.querySelector('.pg a.nxt')?.attributes['href'],
          'forum.php',
        )
        ?.queryParameters;
    int? next;
    if (more?['mod'] == 'misc' &&
        more?['action'] == 'viewvote' &&
        more?['tid'] == '$tid' &&
        more?['polloptionid'] == '$option') {
      final parsed = int.tryParse(more?['page'] ?? '') ?? 0;
      if (parsed > page) next = parsed;
    }
    if (list.querySelector('ul.voterl li a[href]') != null && voters.isEmpty) {
      throw const ForumApiException('poll_voters_unavailable', '');
    }
    return (voters: voters.values.toList(), next: next);
  }
}

/// Resolve old votes only through the voter lists the site allows us to read.
Future<Set<int>?> findOwnPollVote({
  required int uid,
  required List<int> options,
  required int maximumChoices,
  required Future<PollVoterBatch> Function(int option, int page) load,
  required bool Function() isCurrent,
  int requestLimit = 20,
}) async {
  final selected = <int>{};
  var requests = 0;
  for (final option in options) {
    int? page = 1;
    while (page != null) {
      if (!isCurrent() || requests++ >= requestLimit) return null;
      final result = await load(option, page);
      if (!isCurrent()) return null;
      if (result.voters.any((voter) => voter.uid == uid)) {
        selected.add(option);
        if (selected.length == maximumChoices) return selected;
        break;
      }
      page = result.next;
    }
  }
  return selected;
}
