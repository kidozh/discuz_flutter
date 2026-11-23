import 'forum_account_actions.dart';
import '../widget/post_settings_sheet.dart';

import 'package:flutter/cupertino.dart' show CupertinoIcons;

import 'DisplayForumSliverPage.dart';
import 'UserProfilePage.dart';
import '../widget/PostCommentWidget.dart';
import '../JsonResult/ViewThreadResult.dart';

import 'package:easy_refresh/easy_refresh.dart';
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
import '../utility/EasyRefreshUtils.dart';
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

/// Personal replies are grouped by topic. Comment rows carry their target PID.
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
  final _controller = EasyRefreshController();
  final List<Map<String, dynamic>> rows = [];
  int page = 1, generation = 0;
  bool loading = false, more = true;
  bool composing = false;
  bool _failedRefresh = false;
  late String _myType = widget.type;
  String? _myFilter;
  DiscuzError? error;
  bool get comments => widget.pid != null;
  bool get personal =>
      !comments && widget.directory == null && widget.guide == null;
  bool get personalComments => personal && _myType == 'postcomment';
  bool get paginated =>
      widget.directory != ForumDirectory.hotForums &&
      widget.directory != ForumDirectory.pinnedThreads;
  bool get sameAccount {
    final state = context.read<DiscuzAndUserNotifier>();
    return state.discuz?.baseURL == widget.discuz.baseURL &&
        state.user?.uid == widget.user?.uid &&
        state.user?.auth == widget.user?.auth;
  }

  @override
  void initState() {
    super.initState();
    load(refresh: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> load({bool refresh = false}) async {
    if (!refresh && loading) return IndicatorResult.fail;
    if (!refresh && !more) return IndicatorResult.noMore;
    final ticket = ++generation;
    final requestedPage = refresh ? 1 : page;
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
      try {
        if (widget.guide case final guide?) {
          batch = await client.guideThreads(guide.identifier, requestedPage);
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
            'page': requestedPage,
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
          final result = await client.comments(
            widget.tid!,
            widget.pid!,
            requestedPage,
          );
          batch = forumRows(
            discuzMap(result.variables['comments'])['${widget.pid}'],
          ).map(discuzMap).toList();
          total = int.tryParse(discuzString(result.variables['count']));
        } else {
          batch = await client.myThreads(
            _myType,
            requestedPage,
            filter: _myFilter,
            uid: widget.user?.uid,
          );
        }
        if (!personalComments &&
            (widget.directory == null ||
                widget.directory == ForumDirectory.friends) &&
            mounted &&
            ticket == generation &&
            sameAccount) {
          await _fillMissingNames(client, batch);
        }
      } finally {
        if (widget.createClient == null) client.dio.close();
      }
      if (!mounted || ticket != generation || !sameAccount) {
        return IndicatorResult.fail;
      }
      final idKey = widget.directory == ForumDirectory.friends
          ? 'uid'
          : widget.directory == ForumDirectory.hotForums
          ? 'fid'
          : comments || personalComments
          ? 'id'
          : 'tid';
      if (refresh) rows.clear();
      String identity(Map<String, dynamic> row) {
        final id = discuzString(row[idKey]);
        return id.isNotEmpty || !personalComments
            ? id
            : '${row['tid']}|${row['pid']}|${row['dateline']}|${row['comment']}';
      }

      final ids = rows.map(identity).toSet();
      final previous = rows.length;
      for (final row in batch) {
        final id = identity(row);
        if (id.isNotEmpty && ids.add(id)) rows.add(row);
      }
      // Reply results group posts into threads, so a short batch isn't the end.
      more =
          batch.isNotEmpty &&
          ((widget.guide == null && !widget.pickFriend) ||
              rows.length > previous) &&
          (total == null || rows.length < total) &&
          paginated;
      page = requestedPage + 1;
      if (refresh) _controller.resetFooter();
      return refresh || more ? IndicatorResult.success : IndicatorResult.noMore;
    } catch (e) {
      if (mounted && ticket == generation && sameAccount) {
        error = forumRequestError(S.of(context), e);
        _failedRefresh = refresh;
      }
      return IndicatorResult.fail;
    } finally {
      if (mounted && ticket == generation) setState(() => loading = false);
    }
  }

  Future<void> _fillMissingNames(
    ForumInteractionClient client,
    List<Map<String, dynamic>> rows,
  ) async {
    final friends = widget.directory == ForumDirectory.friends;
    final nameKey = friends ? 'username' : 'author';
    final idKey = friends ? 'uid' : 'authorid';
    final missing = rows
        .where(
          (row) =>
              discuzString(row[nameKey]).trim().isEmpty &&
              discuzPermission(row['anonymous']) != true &&
              discuzInt(row[idKey]) > 0,
        )
        .toList();
    if (missing.isEmpty) return;
    try {
      final names = await client.profileNames({
        for (final row in missing) discuzInt(row[idKey]),
      }, uid: widget.user?.uid ?? 0);
      for (final row in missing) {
        final name = names[discuzInt(row[idKey])];
        if (name != null) row[nameKey] = name;
      }
    } catch (_) {
      // Profile enrichment is optional on older mobile plugins.
    }
  }

  Map<String?, String> _statusOptions(S s) => {
    null: s.forumAll,
    'common': s.myContentPublished,
    'aduit': s.myContentPending,
    'close': s.myContentClosed,
    'save': s.myContentServerDrafts,
  };

  void _changePersonal({String? type, String? status}) {
    setState(() {
      if (type != null) _myType = type;
      _myFilter = status;
      rows.clear();
      page = 1;
      more = true;
    });
    load(refresh: true);
  }

  Future<void> _pickStatus() async {
    final s = S.of(context);
    final options = _statusOptions(s);
    final selection = await showPostSettingsSheet<MapEntry<String?, String>>(
      context,
      (sheet) => PostSettingsSheet(
        title: s.myContentStatus,
        children: [
          for (final entry in options.entries)
            PlatformListTile(
              title: Text(entry.value),
              trailing: entry.key == _myFilter
                  ? Icon(PlatformIcons(context).checkMark)
                  : null,
              onTap: () => Navigator.pop(sheet, entry),
            ),
        ],
      ),
    );
    if (mounted &&
        sameAccount &&
        selection != null &&
        selection.key != _myFilter) {
      _changePersonal(status: selection.key);
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
              : s.myContentTitle,
        ),
      ),
      body: !sameAccount
          ? Center(child: Text(s.forumAccountChanged))
          : Column(
              children: [
                if (personal &&
                    !{
                      'guide_status_off',
                      'my_content_unavailable',
                      'module_not_exists',
                    }.contains(error?.key))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        PlatformSegmentedControl(
                          labels: [
                            s.forumMyThreads,
                            s.forumMyReplies,
                            s.myContentComments,
                          ],
                          selectedIndex: [
                            'thread',
                            'reply',
                            'postcomment',
                          ].indexOf(_myType),
                          onValueChanged: (index) {
                            final type = [
                              'thread',
                              'reply',
                              'postcomment',
                            ][index];
                            if (type != _myType) _changePersonal(type: type);
                          },
                        ),
                        if (!personalComments)
                          PlatformChoiceChip(
                            label: Text(
                              s.myContentStatusValue(
                                _statusOptions(s)[_myFilter]!,
                              ),
                            ),
                            selected: _myFilter != null,
                            onSelected: (_) => _pickStatus(),
                          ),
                      ],
                    ),
                  ),
                if (personal && _myType == 'reply' && error == null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(s.forumReplyThreadsHint),
                  ),
                Expanded(
                  child: EasyRefresh(
                    controller: _controller,
                    header: EasyRefreshUtils.i18nClassicHeader(context),
                    footer: EasyRefreshUtils.i18nClassicFooter(context),
                    onRefresh: () => load(refresh: true),
                    onLoad: paginated ? load : null,
                    child: ListView.builder(
                      padding: comments
                          ? const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            )
                          : null,
                      itemCount:
                          rows.length + (rows.isEmpty || error != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == rows.length)
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: error != null
                                  ? ErrorCard(
                                      error!,
                                      () => load(refresh: _failedRefresh),
                                      largeSize: false,
                                    )
                                  : loading
                                  ? const PlatformCircularProgressIndicator()
                                  : Text(s.forumEmpty),
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
                            trailing: PlatformIconButton(
                              icon: Icon(
                                PlatformIcons(context).ellipsis,
                                semanticLabel: s.friendManage,
                              ),
                              onPressed: !sameAccount
                                  ? null
                                  : () async {
                                      final id = discuzInt(row['uid']);
                                      final operation =
                                          await showPostSettingsSheet<String>(
                                            context,
                                            (sheet) => PostSettingsSheet(
                                              title: plain(row['username']),
                                              children: [
                                                for (final (op, label) in [
                                                  (
                                                    'changegroup',
                                                    s.friendChangeGroup,
                                                  ),
                                                  (
                                                    'editnote',
                                                    s.friendEditNote,
                                                  ),
                                                  ('request', s.friendRequests),
                                                ])
                                                  PlatformListTile(
                                                    title: Text(label),
                                                    onTap: () => Navigator.pop(
                                                      sheet,
                                                      op,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                      if (!context.mounted ||
                                          !sameAccount ||
                                          operation == null ||
                                          id <= 0)
                                        return;
                                      await openForumAccountPage(
                                        context,
                                        widget.discuz,
                                        widget.user!,
                                        {
                                          'mod': 'spacecp',
                                          'ac': 'friend',
                                          'op': operation,
                                          if (operation != 'request')
                                            'uid': '$id',
                                        },
                                      );
                                      if (mounted && sameAccount)
                                        await load(refresh: true);
                                    },
                            ),
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
                                    threadId: discuzInt(row['tid']),
                                    fit: BoxFit.cover,
                                    loading: (_, _) => const SizedBox.shrink(),
                                    error: (_) => Icon(
                                      PlatformIcons(context).unavailableImage,
                                    ),
                                  ),
                                )
                              : null,
                          title: Text(plain(row['subject'])),
                          subtitle: personalComments
                              ? Text(
                                  plain(row['comment']),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
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
                                      initialPid:
                                          personalComments &&
                                              discuzInt(row['pid']) > 0
                                          ? discuzInt(row['pid'])
                                          : null,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
