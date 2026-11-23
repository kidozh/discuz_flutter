import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

typedef PollVoteKey = ({String site, int uid, int tid});

/// Keep the member's confirmed options on this device, including private polls.
class PollVoteStore {
  const PollVoteStore();

  String _key(PollVoteKey poll) =>
      'discuz_poll_receipt_v1_${jsonEncode([poll.site, poll.uid, poll.tid])}';

  Future<Set<int>> read(PollVoteKey poll) async {
    if (poll.uid <= 0 || poll.tid <= 0 || poll.site.isEmpty) return {};
    final entries = (await SharedPreferences.getInstance()).getStringList(
      _key(poll),
    );
    return {
      for (final value in entries ?? const <String>[])
        if (int.tryParse(value) case final id? when id > 0) id,
    };
  }

  Future<bool> save(PollVoteKey poll, Set<int> options) async {
    if (poll.uid <= 0 ||
        poll.tid <= 0 ||
        poll.site.isEmpty ||
        options.isEmpty ||
        options.any((id) => id <= 0)) {
      return false;
    }
    return (await SharedPreferences.getInstance()).setStringList(
      _key(poll),
      options.map((id) => '$id').toList(),
    );
  }
}
