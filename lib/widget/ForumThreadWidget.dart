import '../utility/forum_thread_preview.dart';
import '../provider/UserPreferenceNotifierProvider.dart';
import 'compact_thread_list_tile.dart';

import 'dart:developer';

import '../utility/thread_selection_colors.dart';
import 'thread_list_surface.dart';

import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../entity/ViewHistory.dart';
import '../page/ViewThreadSliverPage.dart';
import 'forum_image.dart';

class ForumThreadWidget extends StatelessWidget {
  final ForumThread _forumThread;
  final Discuz _discuz;
  final User? _user;
  final ThreadType? threadType;
  final ValueChanged<int>? onSelectTid;
  final int? afterTid;

  ForumThreadWidget(
    this._discuz,
    this._user,
    this._forumThread,
    this.threadType,
    this.onSelectTid, {
    this.afterTid,
  });

  @override
  Widget build(BuildContext context) {
    return ForumThreadStatefulWidget(
      this._discuz,
      this._user,
      this._forumThread,
      this.threadType,
      onSelectTid,
      afterTid: afterTid,
      key: ValueKey((
        _discuz.baseURL,
        _user?.uid,
        _forumThread.getTid(),
        _forumThread.getAuthorId(),
      )),
    );
  }
}

class ForumThreadStatefulWidget extends StatefulWidget {
  final ForumThread _forumThread;
  final Discuz _discuz;
  final User? _user;
  final ThreadType? threadType;
  final ValueChanged<int>? onSelectTid;
  final int? afterTid;

  ForumThreadStatefulWidget(
    this._discuz,
    this._user,
    this._forumThread,
    this.threadType,
    this.onSelectTid, {
    super.key,
    this.afterTid,
  });

  @override
  ForumThreadState createState() => ForumThreadState();
}

class ForumThreadState extends State<ForumThreadStatefulWidget> {
  ForumThread get _forumThread => widget._forumThread;
  Discuz get _discuz => widget._discuz;
  User? get _user => widget._user;
  ThreadType? get threadType => widget.threadType;
  int? get afterTid => widget.afterTid;
  ValueChanged<int>? get onSelectTid => widget.onSelectTid;
  bool read = false;

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  ViewHistoryDao? dao;
  late BlockUserDao blockUserDao;
  bool isUserBlocked = false;

  void loadDatabase() async {
    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    if (!mounted) return;
    setState(() {
      dao = viewHistoryDao;
    });
    blockUserDao = await AppDatabase.getBlockUserDao();
    if (!mounted) return;
    // check with block information
    List<BlockUser> userBlockedInDB = blockUserDao.isUserBlocked(
      _forumThread.getAuthorId(),
      _discuz,
    );
    if (userBlockedInDB.isEmpty) {
      setState(() {
        this.isUserBlocked = false;
      });
    } else {
      setState(() {
        this.isUserBlocked = true;
      });
    }
  }

  void markThreadAsRead() {
    setState(() {
      read = true;
    });
  }

  Widget getForumThreadCard(bool viewed) {
    return Consumer<SelectedTidNotifierProvider>(
      builder: (context, selectedTid, child) {
        bool selected = selectedTid.tid == _forumThread.getTid();
        bool lastSelected = selectedTid.tid == afterTid;
        log(
          "Select changed ${_forumThread.tid} ${selected} ${afterTid} ${lastSelected}",
        );
        return CupertinoSeparatedItem(
          reading: true,
          includeLiquidGlass: false,
          child: ThreadListSurface(
            selected: selected,
            child: getForumThreadListTile(viewed, selected),
            onTap: () async {
              triggerTapFunction();
            },
            onLongPress: () async {
              triggerLongPressFunction();
            },
          ),
        );
      },
    );
  }

  Widget getAttachmentPreviewWidget(AttachmentPreview attachmentPreview) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: ForumImage(
        forum: _discuz,
        threadId: _forumThread.getTid(),
        fit: BoxFit.cover,
        url:
            "${_discuz.getBaseURLWithAfterfix()}data/attachment/forum/${attachmentPreview.attachment}",
        loading: (context, progress) => Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: PlatformCircularProgressIndicator(
            material: (context, platform) => MaterialProgressIndicatorData(
              value: progress,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            cupertino: (context, platform) => CupertinoProgressIndicatorData(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        error: (context) {
          return Container(
            width: 64 / 0.618,
            height: 64,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                AppPlatformIcons(context).imageSolid,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getForumThreadListTile(bool viewed, bool selected) {
    final colors = Theme.of(context).colorScheme;
    final selection = ThreadSelectionColors(colors);
    final textColor = selected
        ? selection.foreground
        : viewed
        ? colors.onSurfaceVariant
        : colors.onSurface;
    final metadataColor = selected
        ? selection.secondary
        : colors.onSurfaceVariant;
    final category =
        threadType?.idNameMap[_forumThread.typeId] ?? _forumThread.typeName;
    final restricted = _forumThread.readPerm > (_user?.readPerm ?? 0);
    final showStats = context
        .watch<UserPreferenceNotifierProvider>()
        .forumDisplay
        .showThreadStats;
    final message = forumThreadPreview(_forumThread.message);
    final attachments = _forumThread.attachmentImagePreviewList;
    final reply = _forumThread.reply.firstOrNull;
    final metadata = [
      if (category.isNotEmpty) category,
      _forumThread.author,
      TimeDisplayUtils.getLocaledTimeDisplay(
        context,
        _forumThread.dbdatelineMinutes,
      ),
    ].join(' · ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_forumThread.getDisplayOrder() > 0)
          getStickyThreadHead(viewed, selected),
        CompactThreadListTile(
          leading: UserAvatar(
            _discuz,
            _forumThread.getAuthorId(),
            _forumThread.author,
            size: 18,
            disableTap: true,
          ),
          title: Text(
            _forumThread.decodedSubject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              height: 1.22,
              color: textColor,
              fontWeight: viewed && !selected
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
          metadata: Text(
            metadata,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11, color: metadataColor),
          ),
          statistics: showStats
              ? ThreadListStatistics(
                  views: _forumThread.views,
                  replies: _forumThread.replies,
                  color: selected ? selection.secondary : null,
                )
              : null,
          badges: [
            if (restricted)
              Tooltip(
                message: S.of(context).threadReadAccess(_forumThread.readPerm),
                child: Semantics(
                  label: S.of(context).threadReadAccess(_forumThread.readPerm),
                  child: Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: selected ? selection.secondary : colors.error,
                  ),
                ),
              ),
          ],
          message: message,
          previewColor: selected ? selection.secondary : null,
          thumbnail: attachments.isEmpty
              ? null
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    getAttachmentPreviewWidget(attachments.first),
                    if (attachments.length > 1)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            child: Text(
                              '+${attachments.length - 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          replyPreview: reply == null
              ? null
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${reply.author}: ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: forumThreadPreview(reply.message)),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: metadataColor),
                ),
        ),
      ],
    );
  }

  void triggerTapFunction() async {
    VibrationUtils.vibrateWithClickIfPossible();
    markThreadAsRead();
    // recall
    if (onSelectTid != null) {
      onSelectTid!(_forumThread.getTid());
    } else {
      await pushDetailPage(
        context,
        platformPageRoute(
          context: context,
          iosTitle: S.of(context).viewThreadTitle,
          builder: (context) => ViewThreadSliverPage(
            _discuz,
            _user,
            _forumThread.getTid(),
            passedSubject: _forumThread.subject,
          ),
        ),
      );
    }
  }

  void triggerLongPressFunction() async {
    VibrationUtils.vibrateSuccessfullyIfPossible();
    setState(() {
      this.isUserBlocked = true;
    });
    BlockUser blockUser = BlockUser(
      _forumThread.getAuthorId(),
      _forumThread.author,
      DateTime.now(),
      _discuz,
    );
    int insertId = await blockUserDao.insertBlockUser(blockUser);
    log("insert id into block user ${insertId}");
  }

  @override
  Widget build(BuildContext context) {
    if (isUserBlocked) {
      return CupertinoSeparatedItem(
        reading: true,
        includeLiquidGlass: false,
        child: ThreadListSurface(
          selected: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  S
                      .of(context)
                      .contentPostByBlockUserTitle(_forumThread.author),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PlatformTextButton(
                      child: Text(S.of(context).unblockContent),
                      onPressed: () async {
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() {
                          this.isUserBlocked = false;
                        });
                      },
                    ),
                    PlatformTextButton(
                      child: Text(S.of(context).unblockUser),
                      onPressed: () async {
                        // unblock user
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() {
                          this.isUserBlocked = false;
                        });
                        await blockUserDao.deleteBlockUserByUid(
                          _forumThread.getAuthorId(),
                          _discuz,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (read == true) {
      return getForumThreadCard(true);
    }
    if (dao == null) {
      return getForumThreadCard(false);
    } else {
      return ValueListenableBuilder(
        valueListenable: dao!.viewHistoryBox.listenable(),
        builder: (BuildContext context, Box<ViewHistory> value, Widget? child) {
          bool exist = dao!.threadHistoryExistInDatabase(
            _discuz,
            _forumThread.getTid(),
          );
          return getForumThreadCard(exist);
        },
      );
    }
  }

  Widget getStickyThreadHead(bool viewed, bool selected) {
    final selection = ThreadSelectionColors(Theme.of(context).colorScheme);
    return SizedBox(
      width: double.infinity,
      child: Container(
        color: selected
            ? selection.background
            : viewed
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.secondary,
        padding: EdgeInsets.symmetric(
          horizontal: isCupertino(context) ? 16.0 : 8.0,
          vertical: 4.0,
        ),
        child: RichText(
          text: TextSpan(
            text: "",
            children: [
              WidgetSpan(
                child: Icon(
                  AppPlatformIcons(context).stickyPostSolid,
                  size: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  color: selected
                      ? selection.foreground
                      : viewed
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              TextSpan(text: "  "),
              TextSpan(
                text: S.of(context).stickyThread,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  fontWeight: FontWeight.normal,
                  color: selected
                      ? selection.foreground
                      : viewed
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
