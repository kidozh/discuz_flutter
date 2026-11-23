import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_feed_filters.dart';
import '../widget/forum_record_dialog.dart';

class ForumFeedFiltersPage extends StatelessWidget {
  const ForumFeedFiltersPage(this.forum, {this.fid, this.board, super.key});

  final Discuz forum;
  final int? fid;
  final String? board;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    final store = forumFeedFilters(forum, account.userFor(forum));
    final s = S.of(context);
    final icons = PlatformIcons(context);

    Future<void> write(Future<void> Function() operation) async {
      if (!identical(session, account.sessionIdentity)) return;
      try {
        await operation();
      } catch (_) {
        if (!context.mounted || !identical(session, account.sessionIdentity))
          return;
        await showPlatformAlert(
          context: context,
          title: s.forumLocalSaveFailed,
          actions: [PlatformAlertAction(label: s.ok)],
        );
      }
    }

    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(s.forumContentFilters)),
      body: ValueListenableBuilder(
        valueListenable: store,
        builder: (context, rules, _) {
          final muted = rules.where((rule) => rule['tid'] is int);
          final keywords = rules.where(
            (rule) =>
                rule['word'] is String && (fid == null || rule['fid'] == fid),
          );
          Widget section(String title, List<Widget> items) => PlatformCard(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            semanticContainer: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                ...items,
              ],
            ),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              section(s.forumBlockedKeywords, [
                for (final rule in keywords)
                  PlatformListTile(
                    title: Text(rule['label'] as String? ?? ''),
                    subtitle: Text(
                      rule['board'] as String? ?? s.forumSearchAllBoards,
                    ),
                    isThreeLine: true,
                    trailing: PlatformIconButton(
                      icon: Icon(
                        icons.pick(Icons.delete_outline, CupertinoIcons.trash),
                        semanticLabel: s.removeLocalRecord,
                      ),
                      onPressed: () => write(() => store.remove(rule['id'])),
                    ),
                  ),
                PlatformListTile(
                  leading: Icon(icons.pick(Icons.add, CupertinoIcons.plus)),
                  title: Text(s.forumAddBlockedKeyword),
                  subtitle: Text(board ?? s.forumSearchAllBoards),
                  isThreeLine: true,
                  onTap: () async {
                    final label = await showForumRecordDialog(
                      context,
                      s.forumAddBlockedKeyword,
                    );
                    if (label == null || !context.mounted) return;
                    final word = normalizeForumKeyword(label);
                    await write(
                      () => store.put({
                        'id': 'keyword:${fid ?? 0}:$word',
                        'word': word,
                        'label': label,
                        'fid': fid,
                        'board': board,
                      }),
                    );
                  },
                ),
              ]),
              if (fid == null)
                section(s.forumMutedThreads, [
                  if (muted.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(s.forumNoMutedThreads),
                    ),
                  for (final rule in muted)
                    PlatformListTile(
                      title: Text(
                        rule['label'] as String? ?? '#${rule['tid']}',
                      ),
                      trailing: PlatformTextButton(
                        onPressed: () => write(() => store.remove(rule['id'])),
                        child: Text(s.forumUnmuteThread),
                      ),
                    ),
                ]),
            ],
          );
        },
      ),
    );
  }
}
