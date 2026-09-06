import 'dart:math' as math;

import 'package:html/parser.dart' as html;

import '../entity/ForumThread.dart';

class KeylolPortalTopic {
  final String title;
  final List<KeylolPortalThreadItem> threads;

  const KeylolPortalTopic(this.title, this.threads);
}

/// Keep title slots paired with their lists, including missing/empty titles.
List<KeylolPortalTopic> parseKeylolPortalTopics(String source) {
  final document = html.parse(source);
  final titles = document.querySelectorAll('.titletext');
  final modules = document.querySelectorAll('.module.cl.xl.xl1');
  final topics = <KeylolPortalTopic>[];
  for (var index = 0;
      index < math.min(titles.length, modules.length);
      index++) {
    final title = titles[index].querySelector('a')?.text.trim();
    if (title == null || title.isEmpty) continue;
    final threads = <KeylolPortalThreadItem>[];
    for (final item in modules[index].querySelectorAll('li')) {
      final links = item.querySelectorAll('a');
      if (links.length < 3) continue;
      final authorNode = links.first;
      // An optional category link can appear before the final thread link.
      final threadNode = links.last;
      final link = threadNode.attributes['href'] ?? '';
      final authorMatch =
          RegExp(r'suid-(\d+)').firstMatch(authorNode.attributes['href'] ?? '');
      final threadMatch = RegExp(r't(\d+)').firstMatch(link);
      final details = (threadNode.attributes['title'] ?? '').split('\n');
      if (authorMatch == null || threadMatch == null || details.length < 4) {
        continue;
      }
      final authorId = int.tryParse(authorMatch.group(1)!);
      final tid = int.tryParse(threadMatch.group(1)!);
      if (authorId == null || tid == null) continue;
      threads.add(KeylolPortalThreadItem(
        threadNode.text.trim(),
        details[0].split(':').last.trim(),
        authorNode.text.trim(),
        authorId,
        tid,
        link,
        details[3].split(':').last.trim(),
      ));
    }
    topics.add(KeylolPortalTopic(title, threads));
  }
  return topics;
}

class KeylolPortalThreadItem {
  final String title;
  final String forum;
  final String author;
  final int authorId;
  final int tid;
  final String link;
  final String lastPoster;

  const KeylolPortalThreadItem(this.title, this.forum, this.author,
      this.authorId, this.tid, this.link, this.lastPoster);

  ForumThread convertToForumThread() => ForumThread()
    ..authorId = authorId.toString()
    ..author = author
    ..subject = title
    ..tid = tid.toString();
}
