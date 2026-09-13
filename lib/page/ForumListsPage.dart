import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import '../widget/PostCommentWidget.dart';
import '../JsonResult/ViewThreadResult.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' show parseFragment;
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import 'ViewThreadSliverPage.dart';

enum ForumDirectory { friends, hotForums, pinnedThreads }

/// mythread exposes thread summaries, including for type=reply; it has no PID.
class ForumListsPage extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final String type;
  final int? tid, pid, fid;
  final ForumDirectory? directory;
  final Future<ForumInteractionClient> Function()? createClient;
  const ForumListsPage({
    super.key,
    required this.discuz,
    required this.user,
    this.createClient,
    this.type = 'thread',
    this.directory,
    this.fid,
    this.tid,
    this.pid,
  });
  @override
  State<ForumListsPage> createState() => _ForumListsPageState();
}

class _ForumListsPageState extends State<ForumListsPage> {
  final List<Map<String, dynamic>> rows = [];
  int page = 1, generation = 0;
  bool loading = false, more = true;
  String? error;
  bool get comments => widget.pid != null;
  bool get sameAccount {
    final state = context.read<DiscuzAndUserNotifier>();
    return state.discuz?.baseURL == widget.discuz.baseURL &&
        state.user?.uid == widget.user?.uid &&
        state.user?.auth == widget.user?.auth;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (!refresh && (loading || !more)) return;
    final ticket = ++generation;
    if (refresh) {
      page = 1;
      more = true;
      rows.clear();
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (!sameAccount ||
          (!comments &&
              widget.user == null &&
              (widget.directory == null ||
                  widget.directory == ForumDirectory.friends)))
        throw const ForumApiException('account_changed', '');
      final client = widget.createClient != null
          ? await widget.createClient!()
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(widget.user),
              widget.discuz.baseURL,
            );
      List<Map<String, dynamic>> batch;
      int? total;
      if (widget.directory != null) {
        final module = switch (widget.directory!) {
          ForumDirectory.friends => 'friend',
          ForumDirectory.hotForums => 'hotforum',
          ForumDirectory.pinnedThreads => 'toplist',
        };
        final field = switch (widget.directory!) {
          ForumDirectory.friends => 'list',
          ForumDirectory.hotForums => 'data',
          ForumDirectory.pinnedThreads => 'forum_threadlist',
        };
        final result = await client.request(module, {
          'page': page,
          if (widget.fid != null) 'fid': widget.fid,
        });
        result.requireData(field);
        batch = forumRows(result.variables[field]).map(discuzMap).toList();
        total = int.tryParse(discuzString(result.variables['count']));
      } else if (comments) {
        final result = await client.comments(widget.tid!, widget.pid!, page);
        batch = forumRows(
          discuzMap(result.variables['comments'])['${widget.pid}'],
        ).map(discuzMap).toList();
        total = int.tryParse(discuzString(result.variables['count']));
      } else {
        batch = await client.myThreads(widget.type, page);
      }
      if (!mounted || ticket != generation || !sameAccount) return;
      final idKey = widget.directory == ForumDirectory.friends
          ? 'uid'
          : widget.directory == ForumDirectory.hotForums
          ? 'fid'
          : comments
          ? 'id'
          : 'tid';
      final ids = rows.map((r) => discuzString(r[idKey])).toSet();
      for (final row in batch) {
        final id = discuzString(row[idKey]);
        if (id.isNotEmpty && ids.add(id)) rows.add(row);
      }
      // Reply results group posts into threads, so a short batch isn't the end.
      more =
          batch.isNotEmpty &&
          (total == null || rows.length < total) &&
          widget.directory != ForumDirectory.hotForums &&
          widget.directory != ForumDirectory.pinnedThreads;
      page++;
    } catch (e) {
      if (mounted && ticket == generation)
        error = e is ForumApiException && e.message.isNotEmpty
            ? e.message
            : S.of(context).forumLoadFailed;
    } finally {
      if (mounted && ticket == generation) setState(() => loading = false);
    }
  }

  String plain(Object? value) => parseFragment(discuzString(value)).text ?? '';
  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          widget.directory != null
              ? switch (widget.directory!) {
                  ForumDirectory.friends => s.friendList,
                  ForumDirectory.hotForums => s.hotForums,
                  ForumDirectory.pinnedThreads => s.pinnedThreads,
                }
              : comments
              ? s.forumAllComments
              : widget.type == 'reply'
              ? s.forumMyReplies
              : s.forumMyThreads,
        ),
      ),
      body: !sameAccount
          ? Center(child: Text(s.forumAccountChanged))
          : Column(
              children: [
                PlatformTextButton(
                  onPressed: loading ? null : () => load(refresh: true),
                  child: Text(s.forumRefresh),
                ),
                if (!comments &&
                    widget.directory == null &&
                    widget.type == 'reply')
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(s.forumReplyThreadsHint),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rows.length + 1,
                    itemBuilder: (context, index) {
                      if (index == rows.length)
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: loading
                                ? const CircularProgressIndicator()
                                : error != null
                                ? Column(
                                    children: [
                                      Text(error!),
                                      PlatformTextButton(
                                        onPressed: load,
                                        child: Text(s.retry),
                                      ),
                                    ],
                                  )
                                : more
                                ? PlatformTextButton(
                                    onPressed: load,
                                    child: Text(s.forumLoadMore),
                                  )
                                : Text(
                                    rows.isEmpty ? s.forumEmpty : s.forumNoMore,
                                  ),
                          ),
                        );
                      final row = rows[index];
                      if (widget.directory == ForumDirectory.friends)
                        return PlatformListTile(
                          title: Text(plain(row['username'])),
                          onTap: () => Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              builder: (_) => UserProfilePage(
                                widget.discuz,
                                widget.user,
                                discuzInt(row['uid']),
                                username: plain(row['username']),
                              ),
                            ),
                          ),
                        );
                      if (widget.directory == ForumDirectory.hotForums)
                        return PlatformListTile(
                          title: Text(plain(row['name'])),
                          subtitle: Text(
                            '${s.directoryTodayPosts}: ${plain(row['todayposts'])}',
                          ),
                          onTap: () => Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              builder: (_) => DisplayForumSliverPage(
                                widget.discuz,
                                widget.user,
                                discuzInt(row['fid']),
                                forumTitle: plain(row['name']),
                              ),
                            ),
                          ),
                        );

                      if (comments) {
                        final comment = Comment.fromJson(row);
                        return PostCommentWidget(
                          comment,
                          key: ValueKey('comment-${comment.id}'),
                        );
                      }
                      return PlatformListTile(
                        title: Text(plain(row['subject'])),
                        subtitle: Text(
                          '${plain(row['author'])} · ${plain(row['replies'])} ${s.forumReplies}',
                        ),
                        onTap: comments
                            ? null
                            : () => Navigator.push(
                                context,
                                platformPageRoute(
                                  context: context,
                                  builder: (_) => ViewThreadSliverPage(
                                    widget.discuz,
                                    widget.user,
                                    discuzInt(row['tid']),
                                    passedSubject: plain(row['subject']),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
