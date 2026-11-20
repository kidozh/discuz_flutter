import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/Draft.dart';
import '../entity/User.dart';
import '../entity/ViewHistory.dart';
import '../entity/ViewThreadCache.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/post_editor_controller.dart';
import '../utility/reply_draft_store.dart';
import 'LoginPage.dart';
import 'PostThreadPage.dart';
import 'ViewThreadSliverPage.dart';

class DraftInboxEntry {
  const DraftInboxEntry(
    this.forum,
    this.uid,
    this.title,
    this.text,
    this.updated,
    this.names, {
    this.topic,
    this.reply,
  });
  final Discuz forum;
  final int uid;
  final String title, text;
  final DateTime updated;
  final List<String> names;
  final Draft? topic;
  final ReplyDraftSummary? reply;
}

class DraftInboxPage extends StatefulWidget {
  const DraftInboxPage({super.key});
  @override
  State<DraftInboxPage> createState() => _DraftInboxPageState();
}

class _DraftInboxPageState extends State<DraftInboxPage> {
  List<DraftInboxEntry> entries = [];
  List<User> users = [];
  bool busy = true;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      final topics = (await AppDatabase.getDraftDao()).draftBox.values.toList();
      final accounts = (await AppDatabase.getUserDao()).findAllUsers();
      final forums = (await AppDatabase.getDiscuzDao()).findAllDiscuzs();
      final result = <DraftInboxEntry>[
        for (final draft in topics)
          if (draft.title.trim().isNotEmpty ||
              draft.text.trim().isNotEmpty ||
              draft.replyRewardJson.isNotEmpty ||
              draft.classifiedJson.isNotEmpty ||
              draft.rushJson.isNotEmpty ||
              draft.pollJson.isNotEmpty ||
              draft.specialThreadJson.isNotEmpty)
            DraftInboxEntry(
              draft.discuz,
              draft.uid,
              draft.title,
              draft.text,
              draft.updateTime,
              draft.attachmentNames.values.toList(),
              topic: draft,
            ),
      ];
      final indexed = await ReplyDraftStore.indexedAccounts();
      for (final forum in forums) {
        final known = <int, String>{
          for (final cache
              in AppDatabase.viewThreadCacheBox?.values ??
                  const <ViewThreadCache>[])
            if (cache.discuz.isSameSite(forum)) cache.tid: '',
          for (final history
              in AppDatabase.viewHistoryBox?.values ?? const <ViewHistory>[])
            if (history.discuz.isSameSite(forum) && history.type == 'thread')
              history.identification: history.title,
        };
        final uids = {
          ...?indexed[forum.siteIdentity],
          for (final user in accounts.where((u) => u.discuz.isSameSite(forum)))
            user.uid,
        };
        for (final uid in uids) {
          final replies = await ReplyDraftStore.listFor(
            forum.siteIdentity,
            uid,
            knownThreads: known,
          );
          for (final reply in replies) {
            result.add(
              DraftInboxEntry(
                forum,
                uid,
                reply.title,
                reply.draft.text,
                reply.updated,
                [
                  for (final attachment in reply.draft.attachments)
                    attachment.name,
                ],
                reply: reply,
              ),
            );
          }
        }
      }
      result.sort((a, b) => b.updated.compareTo(a.updated));
      if (mounted)
        setState(() {
          entries = result;
          users = accounts;
        });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  User? userFor(DraftInboxEntry entry) => users
      .where((u) => u.discuz.isSameSite(entry.forum) && u.uid == entry.uid)
      .firstOrNull;

  Future<void> open(DraftInboxEntry entry) async {
    var user = userFor(entry);
    final s = S.of(context);
    if (entry.uid == 0) {
      // Old topic drafts did not store an account. Require an explicit choice
      // instead of silently attributing uploaded attachments to the active user.
      user = await showPlatformModalSheet<User>(
        context: context,
        builder: (sheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.draftChooseAccount),
              ),
              for (final candidate in users.where(
                (u) => u.discuz.isSameSite(entry.forum),
              ))
                PlatformListTile(
                  title: Text(candidate.username),
                  onTap: () => Navigator.pop(sheet, candidate),
                ),
            ],
          ),
        ),
      );
      if (user == null || !mounted) return;
      entry.topic!.uid = user.uid;
      await entry.topic!.save();
    }
    if (!mounted) return;
    final account = context.read<DiscuzAndUserNotifier>();
    account.initDiscuz(entry.forum, user: user);
    if (user == null) {
      await Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => LoginPage(entry.forum, null),
        ),
      );
      if (!mounted) return;
      user = account.userFor(entry.forum);
      if (user?.uid != entry.uid) return;
    }
    await Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => entry.topic != null
            ? PostThreadPage(
                entry.forum,
                entry.topic!.fid,
                0,
                draft: entry.topic,
              )
            : ViewThreadSliverPage(
                entry.forum,
                user,
                entry.reply!.tid,
                passedSubject: entry.title,
              ),
      ),
    );
    if (mounted) await load();
  }

  Future<void> remove(DraftInboxEntry entry) async {
    final s = S.of(context);
    final confirmed = await showPlatformDialog<bool>(
      context: context,
      builder: (dialog) => PlatformAlertDialog(
        title: Text(s.draftDelete),
        content: Text(entry.title.isEmpty ? s.draftUntitled : entry.title),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.pop(dialog),
            child: Text(s.cancel),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(s.draftDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      if (entry.topic case final topic?) {
        await (await AppDatabase.getDraftDao()).deleteDraft(topic);
      } else {
        await ReplyDraftStore(
          entry.forum.siteIdentity,
          entry.uid,
          entry.reply!.tid,
        ).delete();
      }
      if (mounted) await load();
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final groups = <(String, int), List<DraftInboxEntry>>{};
    for (final entry in entries) {
      (groups[(entry.forum.siteIdentity, entry.uid)] ??= []).add(entry);
    }
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(s.draftInbox),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'arrow.clockwise',
            icon: Icon(icons.pick(Icons.refresh, CupertinoIcons.refresh)),
            onPressed: busy ? null : load,
          ),
        ],
      ),
      body: busy
          ? const Center(child: PlatformCircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (failed) Text(s.replyDraftRestoreFailed),
                if (!failed && entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(s.draftEmpty),
                  ),
                for (final group in groups.values) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '${group.first.forum.siteName} · ${group.first.uid == 0 ? s.draftUnknownAccount : userFor(group.first)?.username ?? 'UID ${group.first.uid}'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  PlatformCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final entry in group)
                          PlatformListTile(
                            leading: Icon(
                              icons.pick(
                                entry.topic != null
                                    ? Icons.edit_note
                                    : Icons.reply,
                                entry.topic != null
                                    ? CupertinoIcons.doc_text
                                    : CupertinoIcons.reply,
                              ),
                            ),
                            title: Text(
                              entry.title.isEmpty
                                  ? entry.reply != null
                                        ? '#${entry.reply!.tid}'
                                        : s.draftUntitled
                                  : entry.title,
                            ),
                            subtitle: Text(
                              [
                                '${entry.topic != null ? s.postThread : s.draftReply} · ${DateFormat.yMd().add_Hm().format(entry.updated)}',
                                entry.text
                                    .replaceAll(PostEditorToken.pattern, '')
                                    .trim(),
                                if (entry.reply?.draft.quote case final quote?)
                                  s.draftQuote(quote.author),
                                ...entry.names,
                              ].where((text) => text.isNotEmpty).join('\n'),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PlatformIconButton(
                              icon: Icon(
                                icons.pick(
                                  Icons.delete_outline,
                                  CupertinoIcons.trash,
                                ),
                                semanticLabel: s.draftDelete,
                              ),
                              onPressed: () => remove(entry),
                            ),
                            onTap: () => open(entry),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
