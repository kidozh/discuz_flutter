import 'package:flutter/widgets.dart';

import '../entity/Discuz.dart';
import '../entity/User.dart';
import 'forum_local_records.dart';

ForumLocalRecords forumFeedFilters(Discuz forum, User? user) =>
    ForumLocalRecords('feed_filters', forum, user);

Widget withForumFeedFilters(
  Discuz forum,
  User? user,
  Widget Function(BuildContext, List<ForumRecord>) builder,
) {
  final filters = forumFeedFilters(forum, user);
  return ValueListenableBuilder(
    valueListenable: filters,
    builder: (context, rules, _) => builder(context, rules),
  );
}

String normalizeForumKeyword(String word) =>
    word.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

bool hidesForumThread(
  List<ForumRecord> filters,
  int tid,
  String title, {
  int? fid,
  String? excerpt,
}) {
  if (filters.isEmpty) return false;
  final subject = normalizeForumKeyword(title);
  final body = excerpt == null ? '' : normalizeForumKeyword(excerpt);
  return filters.any((rule) {
    if (rule['tid'] == tid) return true;
    final word = rule['word'];
    return word is String &&
        word.isNotEmpty &&
        (rule['fid'] == null || rule['fid'] == fid) &&
        (subject.contains(word) || body.contains(word));
  });
}
