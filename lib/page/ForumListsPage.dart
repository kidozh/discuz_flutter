import 'package:flutter/cupertino.dart' show CupertinoIcons;

import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import '../widget/PostCommentWidget.dart';
import '../JsonResult/ViewThreadResult.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' show parseFragment;

import '../client/ForumInteractionClient.dart';
import '../client/forum_guide.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import '../widget/forum_image.dart';
import 'ViewThreadSliverPage.dart';

enum ForumDirectory { friends, hotForums, pinnedThreads }

enum ForumGuideSection {
  digest('dz_digest'),
  replies('dz_newreply'),
  photos('dz_newpic');

  const ForumGuideSection(this.identifier);
  final String identifier;

  String title(S strings) => switch (this) {
    digest => strings.guideDigest,
    replies => strings.guideRecentReplies,
    photos => strings.guidePhotos,
  };
}

/// mythread exposes thread summaries, including for type=reply; it has no PID.
class ForumListsPage extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final String type;
  final int? tid, pid, fid;
  final bool pickFriend;
  final ForumDirectory? directory;
  final ForumGuideSection? guide;
  final Future<void> Function()? onAddComment;
  final Future<ForumInteractionClient> Function()? createClient;
  const ForumListsPage({
    super.key,
    required this.discuz,
    required this.user,
    this.createClient,
    this.type = 'thread',
    this.pickFriend = false,
    this.directory,
    this.guide,
    this.onAddComment,
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
  bool composing = false;
  DiscuzError? error;
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
              widget.guide == null &&
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
      if (widget.guide case final guide?) {
        batch = await client.guideThreads(guide.identifier, page);
      } else if (widget.directory != null) {
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
        if (widget.pickFriend &&
            discuzInt(result.variables['member_uid']) != widget.user?.uid) {
          throw const ForumApiException('account_changed', '');
        }
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
      final previous = rows.length;
      for (final row in batch) {
        final id = discuzString(row[idKey]);
        if (id.isNotEmpty && ids.add(id)) rows.add(row);
      }
      // Reply results group posts into threads, so a short batch isn't the end.
      more =
          batch.isNotEmpty &&
          ((widget.guide == null && !widget.pickFriend) || rows.length > previous) &&
          (total == null || rows.length < total) &&
          widget.directory != ForumDirectory.hotForums &&
          widget.directory != ForumDirectory.pinnedThreads;
      page++;
    } catch (e) {
      if (mounted && ticket == generation)
        error = forumRequestError(S.of(context), e);
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
      iosContentPadding: true,
      appBar: PlatformAppBar(
        trailingActions: comments
            ? [
                PlatformIconButton(
                  liquidGlassSymbol: 'arrow.clockwise',
                  icon: Icon(
                    PlatformIcons(context).refresh,
                    semanticLabel: s.forumRefresh,
                  ),
                  onPressed: loading ? null : () => load(refresh: true),
                ),
                if (sameAccount &&
                    widget.user != null &&
                    widget.onAddComment != null)
                  PlatformIconButton(
                    liquidGlassSymbol: 'square.and.pencil',
                    icon: Icon(
                      isCupertino(context)
                          ? CupertinoIcons.square_pencil
                          : Icons.edit_outlined,
                      semanticLabel: s.postAddComment,
                    ),
                    onPressed: composing
                        ? null
                        : () async {
                            setState(() => composing = true);
                            try {
                              await widget.onAddComment!();
                              if (mounted && sameAccount)
                                await load(refresh: true);
                            } finally {
                              if (mounted) setState(() => composing = false);
                            }
                          },
                  ),
              ]
            : null,
        title: Text(
          widget.guide != null
              ? widget.guide!.title(s)
              : widget.directory != null
              ? switch (widget.directory!) {
                  ForumDirectory.friends =>
                    widget.pickFriend ? s.mentionFriend : s.friendList,
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
                if (!comments)
                  PlatformTextButton(
                    onPressed: loading ? null : () => load(refresh: true),
                    child: Text(s.forumRefresh),
                  ),
                if (!comments &&
                    widget.directory == null &&
                    widget.guide == null &&
                    widget.type == 'reply')
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(s.forumReplyThreadsHint),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: comments
                        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 8)
                        : null,
                    itemCount: rows.length + 1,
                    itemBuilder: (context, index) {
                      if (index == rows.length)
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: loading
                                ? const PlatformCircularProgressIndicator()
                                : error != null
                                ? ErrorCard(error!, load, largeSize: false)
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
                      if (widget.pickFriend &&
                          widget.directory == ForumDirectory.friends) {
                        final name = plain(row['username']);
                        return PlatformListTile(
                          title: Text(name),
                          onTap: name.isEmpty || !sameAccount
                              ? null
                              : () => Navigator.pop(context, name),
                        );
                      }
                      if (widget.directory == ForumDirectory.friends)
                        return PlatformListTile(
                          title: Text(plain(row['username'])),
                          onTap: () => pushDetailPage(
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
                        leading:
                            widget.guide == ForumGuideSection.photos &&
                                discuzString(row['image']).isNotEmpty
                            ? SizedBox(
                                height: 48,
                                width: 64,
                                child: ForumImage(
                                  url: discuzString(row['image']),
                                  forum: widget.discuz,
                                  fit: BoxFit.cover,
                                  loading: (_, _) => const SizedBox.shrink(),
                                  error: (_) => Icon(
                                    PlatformIcons(context).unavailableImage,
                                  ),
                                ),
                              )
                            : null,
                        title: Text(plain(row['subject'])),
                        subtitle: Text(
                          '${plain(row['author'])} · ${plain(row['replies'])} ${s.forumReplies}',
                        ),
                        onTap: comments
                            ? null
                            : () => pushDetailPage(
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
