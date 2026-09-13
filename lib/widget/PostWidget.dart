import '../entity/SpecialThread.dart';
import '../page/ForumListsPage.dart';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ReportContentPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/FoundationModelFrameworkUtils.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:discuz_flutter/utility/PostTextUtils.dart';
import 'package:discuz_flutter/utility/ReadingPerformanceProbe.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/PostCommentWidget.dart';
import 'package:discuz_flutter/widget/post_status_badges.dart';
import 'package:discuz_flutter/widget/reading_glass_sliver_card.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../utility/NetworkUtils.dart';
import '../utility/UserPreferencesUtils.dart';
import 'UserAvatar.dart';

int POST_BLOCKED = 1;
int POST_WARNED = 2;
int POST_REVISED = 4;
int POST_MOBILE = 8;

class PostWidget extends StatelessWidget {
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;
  int? fid;
  final bool asSliver;
  final VoidCallback? onBodyReady;
  final VoidCallback? onContentChanged;
  final int? commentCount;
  final RewardInfo? reward;
  final VoidCallback? onAddComment;

  PostWidget(
    this._discuz,
    this._post,
    this._authorId,
    this.formhash, {
    super.key,
    this.asSliver = false,
    this.onBodyReady,
    this.onContentChanged,
    this.commentCount,
    this.reward,
    this.onAddComment,
    this.onAuthorSelectedCallback,
    this.postCommentList,
    this.ignoreFontCustomization,
    this.jumpToPidCallback,
    this.fid,
    this.tid,
  });

  @override
  Widget build(BuildContext context) {
    return PostStatefulWidget(
      this._discuz,
      this._post,
      this._authorId,
      this.formhash,
      onAuthorSelectedCallback: this.onAuthorSelectedCallback,
      postCommentList: this.postCommentList,
      ignoreFontCustomization: this.ignoreFontCustomization,
      jumpToPidCallback: this.jumpToPidCallback,
      fid: this.fid,
      tid: this.tid,
      asSliver: asSliver,
      onBodyReady: onBodyReady,
      onContentChanged: onContentChanged,
      commentCount: commentCount,
      reward: reward,
      onAddComment: onAddComment,
    );
  }
}

class PostStatefulWidget extends StatefulWidget {
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;
  int? fid;
  final bool asSliver;
  final VoidCallback? onBodyReady;
  final VoidCallback? onContentChanged;
  final int? commentCount;
  final RewardInfo? reward;
  final VoidCallback? onAddComment;

  PostStatefulWidget(
    this._discuz,
    this._post,
    this._authorId,
    this.formhash, {
    this.asSliver = false,
    this.onBodyReady,
    this.onContentChanged,
    this.commentCount,
    this.reward,
    this.onAddComment,
    this.onAuthorSelectedCallback,
    this.postCommentList,
    this.ignoreFontCustomization,
    this.jumpToPidCallback,
    this.fid,
    this.tid,
  });

  @override
  PostState createState() {
    return PostState(
      this._discuz,
      this._post,
      this._authorId,
      this.formhash,
      onAuthorSelectedCallback: this.onAuthorSelectedCallback,
      postCommentList: this.postCommentList,
      ignoreFontCustomization: this.ignoreFontCustomization,
      jumpToPidCallback: this.jumpToPidCallback,
      fid: this.fid,
      tid: this.tid,
    );
  }
}

// ignore: must_be_immutable
class PostState extends State<PostStatefulWidget> {
  Post _post;
  Discuz _discuz;
  User? _user;
  int _authorId;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  String formhash;
  int? tid;
  int? fid;

  bool isFontStyleIgnored() {
    if (ignoreFontCustomization == null || ignoreFontCustomization == false) {
      return false;
    } else {
      return true;
    }
  }

  List<Comment> getCommentList() {
    if (postCommentList == null) {
      return [];
    }
    String pid = _post.pid.toString();
    if (postCommentList!.containsKey(pid)) {
      return postCommentList![pid]!;
    } else {
      return [];
    }
  }

  PostState(
    this._discuz,
    this._post,
    this._authorId,
    this.formhash, {
    this.onAuthorSelectedCallback,
    this.postCommentList,
    this.ignoreFontCustomization,
    this.jumpToPidCallback,
    this.fid,
    this.tid,
  });

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _loadDB();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostStatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A refreshed/cached first post keeps its key; do not retain stale content.
    _post = widget._post;
    _discuz = widget._discuz;
    _authorId = widget._authorId;
    formhash = widget.formhash;
    onAuthorSelectedCallback = widget.onAuthorSelectedCallback;
    postCommentList = widget.postCommentList;
    ignoreFontCustomization = widget.ignoreFontCustomization;
    jumpToPidCallback = widget.jumpToPidCallback;
    tid = widget.tid;
    fid = widget.fid;
  }

  late BlockUserDao _blockUserDao;
  bool isUserBlocked = false;
  String groupTitle = "";
  int groupStar = 0;

  _loadDB() async {
    _blockUserDao = await AppDatabase.getBlockUserDao();
    // need to remove
    groupTitle = await UserPreferencesUtils.getDiscuzGroupNameById(
      _discuz,
      _post.groupId,
    );
    groupStar = await UserPreferencesUtils.getDiscuzGroupStarById(
      _discuz,
      _post.groupId,
    );
    groupTitle = groupTitle.replaceAll(RegExp(r'<.*?>'), "");
    // query whether use get blocked
    if (mounted) {
      Discuz discuz = Provider.of<DiscuzAndUserNotifier>(
        context,
        listen: false,
      ).discuz!;
      _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
      List<BlockUser> userBlockedInDB = await _blockUserDao.isUserBlocked(
        _post.authorId,
        discuz,
      );
      if (!mounted) return;
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
  }

  @override
  Widget build(BuildContext context) {
    if (this.isUserBlocked) {
      // show blocked user interface
      final blocked = PlatformWidgetBuilder(
        material: (_, child, __) => PlatformCard(
          elevation: 2,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.surface,
          child: child,
        ),
        cupertino: (_, child, __) => ReadingPostCard(
          padding: const EdgeInsets.all(8),
          child: child ?? const SizedBox.shrink(),
        ),
        child: Padding(
          padding: isMaterial(context)
              ? const EdgeInsets.all(8)
              : EdgeInsets.zero,
          child: Column(
            children: [
              Text(
                S.of(context).contentPostByBlockUserTitle(_post.author),
                style: Theme.of(context).textTheme.headlineSmall,
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
                      await _blockUserDao.deleteBlockUserByUid(
                        _post.authorId,
                        _discuz,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      return CupertinoSeparatedItem(
        reading: true,
        sliver: widget.asSliver,
        child: widget.asSliver ? SliverToBoxAdapter(child: blocked) : blocked,
      );
    }

    return Consumer<TypeSettingNotifierProvider>(
      builder: (context, typesetting, _) {
        if (widget.asSliver) {
          return CupertinoSeparatedItem(
            reading: true,
            sliver: true,
            child: ReadingGlassSliverCard(
              sliver: getPostContent(
                context,
                typesetting.useCompactParagraph,
                asSliver: true,
              ),
            ),
          );
        }
        // should return the container
        return CupertinoSeparatedItem(
          reading: true,
          child: PlatformWidgetBuilder(
            material: (_, child, platform) => PlatformCard(
              //surfaceTintColor: Theme.of(context).colorScheme.background,
              surfaceTintColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black38,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.white24,
              elevation: _post.first ? 0 : 8.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: child,
              ),
            ),
            cupertino: (_, child, platform) => ReadingPostCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: child ?? const SizedBox.shrink(),
            ),
            child: getPostContent(context, typesetting.useCompactParagraph),
          ),
        );
      },
    );
  }

  Future<void> translatePostMessage() async {
    final preferences = context.read<UserPreferenceNotifierProvider>();
    if (!preferences.appleIntelligenceEnabled ||
        !preferences.appleIntelligenceAvailable) {
      return;
    }
    EasyLoading.show(status: S.of(context).loading);
    try {
      final translatedText = await OnDeviceAiService.translate(
        _post.message,
        guardrailLevel: FoundationModelFrameworkUtils.guardrailLevelFromName(
          preferences.appleIntelligenceGuardrail,
        ),
      );
      await EasyLoading.dismiss();
      if (!mounted || translatedText.isEmpty) return;
      await showPlatformModalSheet<void>(
        context: context,
        material: const MaterialModalSheetData(isScrollControlled: true),
        builder: (sheetContext) => SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(sheetContext).appleIntelligenceTranslate,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DiscuzHtmlWidget(_discuz, translatedText),
                ],
              ),
            ),
          ),
        ),
      );
    } on OnDeviceAiException catch (error) {
      await EasyLoading.dismiss();
      if (!mounted) return;
      final message = switch (error.code) {
        'request_too_large' => S.of(context).onDeviceAiRequestTooLarge,
        'model_downloadable' || 'model_downloading' =>
          S.of(context).appleIntelligenceUnavailableModelNotReady,
        _ => S.of(context).onDeviceAiRequestFailed,
      };
      EasyLoading.showError(message);
    } catch (_) {
      await EasyLoading.dismiss();
      if (mounted) {
        EasyLoading.showError(S.of(context).onDeviceAiRequestFailed);
      }
    }
  }

  Widget getPostContent(
    BuildContext context,
    bool compactParagraph, {
    bool asSliver = false,
  }) {
    if (ReadingPerformanceProbe.enabled) {
      ReadingPerformanceProbe.record('post.content', {
        'pid': _post.pid,
        'first': _post.first,
        'number': _post.number,
        'html_chars': _post.message.length,
        'sliver': asSliver,
      });
    }
    String _html = _post.message;
    log("Original HTML ${_html}");

    if (Provider.of<TypeSettingNotifierProvider>(
      context,
      listen: false,
    ).ignoreCustomFontStyle) {
      // regex
      // _html = _html
      //     .replaceAll(RegExp(r'<font.*?>', multiLine: true), "")
      //     .replaceAll(RegExp(r'</font.*?>'), "")
      //     .replaceAll(RegExp(r'<span style="display:none">.+</span>'), "")
      //     //.replaceAll(RegExp(r'\\n'), '<br />')
      // ;
      _html = PostTextUtils.decodePostMessage(_html);
    }

    if (compactParagraph) {
      _html = _html.replaceAll(RegExp("[\r\n]+"), "");
      _html = _html.replaceAll(
        RegExp(r"<br.?/>(<br.?/>)+", multiLine: true),
        "<br />",
      )
      //.replaceAll(RegExp(r"\s+$"), "")
      //.replaceAll(RegExp(r"[(<br.?/>)]+$"), "")
      ;

      _html = _html.replaceAllMapped(RegExp("<br\\W+/>"), (match) {
        //print("match! ${match.group(0)} ${match.end} ${_html.length}");
        if (_html.length - match.end < 3) {
          return "";
        } else {
          return "<br />";
        }
      });

      // _html = _html.replaceAll(RegExp(r"<br.?/>$"), "");
      _html = _html.replaceAll(RegExp(r"\s+$"), "");
    }

    log("AFTER HTML ${_html}");

    final header = <Widget>[
      // post header
      getPostHeader(context),
      PostStatusBadges(
        blocked: _post.blocked,
        warned: _post.warned,
        revised: _post.revised,
        reward: widget.reward,
        onSelectPost: jumpToPidCallback,
      ),
      const SizedBox(height: 8),
    ];
    final body = DiscuzHtmlWidget(
      _discuz,
      _html,
      tid: this.tid,
      callback: jumpToPidCallback,
      asSliver: asSliver,
      onBodyReady: widget.onBodyReady,
      onContentChanged: widget.onContentChanged,
    );
    final footer = <Widget>[
      if (_post.attachmentMapper.isNotEmpty)
        ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            Attachment attachment = _post.getAttachmentList()[index];
            return AttachmentWidget(
              _discuz,
              attachment,
              onContentChanged: widget.onContentChanged,
            );
          },
          itemCount: _post.getAttachmentList().length,
          physics: new NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      if (getCommentList().length != 0)
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                Comment comment = getCommentList()[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PostCommentWidget(
                      comment,
                      textColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                    if (index != getCommentList().length - 1 &&
                        (!isCupertino(context) ||
                            Theme.of(context).brightness == Brightness.light))
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                  ],
                );
              },
              itemCount: getCommentList().length,
              physics: new NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          ),
        ),
      if (tid != null && ((widget.commentCount ?? getCommentList().length) > 0))
        PlatformTextButton(
          onPressed: () => Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (_) => ForumListsPage(
                discuz: _discuz,
                user: context.read<DiscuzAndUserNotifier>().user,
                tid: tid,
                pid: _post.pid,
              ),
            ),
          ),
          child: Text(
            '${S.of(context).forumAllComments}${widget.commentCount == null ? '' : ' (${widget.commentCount})'}',
          ),
        ),
      getPostTailWidget(context),
    ];
    if (asSliver) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Column(mainAxisSize: MainAxisSize.min, children: header),
          ),
          body,
          SliverToBoxAdapter(
            child: Column(mainAxisSize: MainAxisSize.min, children: footer),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [...header, body, ...footer],
    );
  }

  Widget getPostPopupMenu(BuildContext context) {
    return PlatformPopupMenu(
      icon: Icon(
        PlatformIcons(context).ellipsis,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      options: [
        PopupMenuOption(
          label: S.of(context).replyPost,
          onTap: (option) {
            VibrationUtils.vibrateWithClickIfPossible();
            Provider.of<ReplyPostNotifierProvider>(
              context,
              listen: false,
            ).setPost(_post);
          },
        ),
        PopupMenuOption(
          label: S.of(context).viewUserInfo(_post.author),
          onTap: (option) {
            VibrationUtils.vibrateWithClickIfPossible();
            User? user = Provider.of<DiscuzAndUserNotifier>(
              context,
              listen: false,
            ).user;
            Navigator.push(
              context,
              platformPageRoute(
                context: context,
                iosTitle: S.of(context).userProfile,
                builder: (context) => UserProfilePage(
                  _discuz,
                  user,
                  _post.authorId,
                  username: _post.author,
                ),
              ),
            );
          },
        ),
        PopupMenuOption(
          label: S.of(context).onlyViewAuthor,
          onTap: (option) {
            VibrationUtils.vibrateWithClickIfPossible();
            if (onAuthorSelectedCallback != null) {
              VibrationUtils.vibrateWithClickIfPossible();
              onAuthorSelectedCallback!();
            }
          },
        ),
        if (!this.isUserBlocked)
          PopupMenuOption(
            label: S.of(context).blockUser,
            onTap: (option) async {
              VibrationUtils.vibrateWithClickIfPossible();
              // block user
              setState(() {
                this.isUserBlocked = true;
              });
              BlockUser blockUser = BlockUser(
                _post.authorId,
                _post.author,
                DateTime.now(),
                _discuz,
              );
              int insertId = await _blockUserDao.insertBlockUser(blockUser);
            },
            material: (context, platform) => MaterialPopupMenuOptionData(
              textStyle: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            cupertino: (context, platform) =>
                CupertinoPopupMenuOptionData(isDestructiveAction: true),
          ),
        if (this.isUserBlocked)
          PopupMenuOption(
            label: S.of(context).unblockUser,
            onTap: (option) {
              VibrationUtils.vibrateWithClickIfPossible();
              setState(() {
                this.isUserBlocked = false;
              });
              _blockUserDao.deleteBlockUserByUid(_post.authorId, _discuz);
            },
            cupertino: (context, platform) =>
                CupertinoPopupMenuOptionData(isDestructiveAction: true),
          ),
      ],
    );
  }

  Widget getUserAvatar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _post.first ? 4 : 2,
        horizontal: 8.0,
      ),
      child: UserAvatar(
        _discuz,
        _post.authorId,
        _post.author,
        size: _post.first ? 30.0 : 24.0,
      ),
    );
  }

  Widget getPostFunctionWidget(BuildContext context) {
    final notification = Provider.of<DiscuzNotificationProvider>(context);
    final intelligence = Provider.of<UserPreferenceNotifierProvider>(context);
    final actionColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final actions = <Widget>[
      if (widget.onAddComment != null)
        PlatformIconButton(
          liquidGlassSymbol: 'text.bubble',
          liquidGlassIconSize: 18,
          icon: Icon(
            Icons.mode_comment_outlined,
            size: 18,
            color: actionColor,
            semanticLabel: S.of(context).postAddComment,
          ),
          onPressed: widget.onAddComment,
        ),
    ];
    if (intelligence.appleIntelligenceEnabled &&
        intelligence.appleIntelligenceAvailable) {
      actions.add(
        PlatformIconButton(
          liquidGlassSymbol: 'character.bubble',
          liquidGlassIconSize: 18,
          icon: Icon(
            PlatformIcons(context).translate,
            size: 18,
            color: actionColor,
            semanticLabel: S.of(context).appleIntelligenceTranslate,
          ),
          onPressed: translatePostMessage,
        ),
      );
    }

    if (notification.baseVariableResult.isModerator == 0) {
      if (_user != null) {
        actions.add(
          PlatformIconButton(
            liquidGlassSymbol: 'flag',
            liquidGlassIconSize: 18,
            icon: Icon(
              PlatformIcons(context).flag,
              size: 18,
              color: actionColor,
              semanticLabel: S.of(context).reportContentTitle(_post.author),
            ),
            onPressed: () {
              VibrationUtils.vibrateWithClickIfPossible();
              Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  iosTitle: S.of(context).reportThreadTooltip,
                  builder: (context) =>
                      ReportContentPage(_post.author, _post.pid, 0, formhash),
                ),
              );
            },
          ),
        );
      }
    } else if (fid != null) {
      actions.add(adminPostPopupMenu);
    }

    actions.add(getPostPopupMenu(context));
    return PlatformLiquidGlassToolbarGroup(children: actions);
  }

  WidgetSpan getGroupWidgetSpan(BuildContext context) {
    return WidgetSpan(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (groupStar != 0)
            Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "Lv ${groupStar}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              right: 6.0,
              left: groupStar == 0 ? 6.0 : 0.0,
            ),
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: EdgeInsets.all(2.0),
              child: Text(
                groupTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.normal,
                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPostHeader(BuildContext context) {
    // get star and member title

    if (_post.first) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getUserAvatar(context),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // username and OP come first
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: "",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: _post.author,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_authorId == _post.authorId)
                            TextSpan(
                              text: ' ' + S.of(context).postAuthorLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),

                    RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: TimeDisplayUtils.getLocaledTimeDisplay(
                          context,
                          _post.publishAt,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          if (_post.status & POST_REVISED != 0)
                            TextSpan(
                              text: ' · ' + S.of(context).editedPost,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          if (_post.ipLocation != "")
                            TextSpan(
                              text: ' ' + _post.ipLocation,
                              style: TextStyle(fontSize: 14),
                            ),
                          if (groupTitle != "") getGroupWidgetSpan(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          getPostFunctionWidget(context),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getUserAvatar(context),
          Expanded(
            // the author
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: "",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: _post.author,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  if (groupTitle != "") getGroupWidgetSpan(context),
                  if (_authorId == _post.authorId)
                    TextSpan(
                      text: ' ' + S.of(context).postAuthorLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _post.position.toString(),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget getPostTailWidget(BuildContext context) {
    if (_post.first) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: "",
                  children: [
                    TextSpan(
                      text: TimeDisplayUtils.getLocaledTimeDisplay(
                        context,
                        _post.publishAt,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    if (_post.status & POST_REVISED != 0)
                      TextSpan(
                        text: ' · ' + S.of(context).editedPost,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    if (_post.ipLocation != "")
                      TextSpan(
                        text: ' ' + _post.ipLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // reports etcs
            getPostFunctionWidget(context),
          ],
        ),
      );
    }
  }

  Widget get adminPostPopupMenu => PlatformPopupMenu(
    liquidGlassSymbol: 'shield',
    icon: Icon(
      AppPlatformIcons(context).adminPostSolid,
      size: 18,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    options: [
      PopupMenuOption(
        label: _post.warned
            ? S.of(context).adminUnwarnPost
            : S.of(context).adminWarnPost,
        onTap: (option) {
          VibrationUtils.vibrateWithClickIfPossible();
          toggleAdminWarnRequest();
        },
      ),
      PopupMenuOption(
        label: _post.blocked
            ? S.of(context).adminUnblockPost
            : S.of(context).adminBlockPost,
        onTap: (option) {
          VibrationUtils.vibrateWithClickIfPossible();
          toggleAdminBlockRequest();
        },
      ),
      PopupMenuOption(
        label: S.of(context).adminDeletePost,
        cupertino: (context, platform) =>
            CupertinoPopupMenuOptionData(isDestructiveAction: true),
        onTap: (option) {
          VibrationUtils.vibrateWithClickIfPossible();
          adminDeletePostRequest();
        },
      ),
    ],
  );

  bool isSendingAdminRequest = false;

  Future<void> toggleAdminBlockRequest() async {
    setState(() {
      isSendingAdminRequest = true;
    });
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz;
    if (discuz == null || fid == null) {
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.blocked ? 0 : 1;

    client
        .banPostResult(formhash, fid!, _post.tid, [_post.pid], banned, "")
        .then((value) {
          if (!mounted) return;
          if (value.errorResult?.key == "admin_succeed") {
            // it should be banned
            Post newPostStage = _post;
            newPostStage.status = newPostStage.status ^ POST_BLOCKED;
            setState(() {
              _post = newPostStage;
            });
            EasyLoading.showSuccess(
              value.errorResult?.content == null
                  ? S.of(context).ok
                  : value.errorResult!.content,
            );
          } else {
            EasyLoading.showError(
              value.errorResult?.content == null
                  ? S.of(context).error
                  : value.errorResult!.content,
            );
          }
          setState(() {
            isSendingAdminRequest = false;
          });
        });
  }

  Future<void> toggleAdminWarnRequest() async {
    setState(() {
      isSendingAdminRequest = true;
    });
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz;
    if (discuz == null || fid == null) {
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.warned ? 0 : 1;

    client
        .warnPostResult(formhash, fid!, _post.tid, [_post.pid], banned, "")
        .then((value) {
          if (!mounted) return;
          if (value.errorResult?.key == "admin_succeed") {
            // it should be banned
            Post newPostStage = _post;
            newPostStage.status = newPostStage.status ^ POST_WARNED;
            setState(() {
              _post = newPostStage;
            });
            EasyLoading.showSuccess(
              value.errorResult?.content == null
                  ? S.of(context).ok
                  : value.errorResult!.content,
            );
          } else {
            EasyLoading.showError(
              value.errorResult?.content == null
                  ? S.of(context).error
                  : value.errorResult!.content,
            );
          }
          setState(() {
            isSendingAdminRequest = false;
          });
        });
  }

  Future<void> adminDeletePostRequest() async {
    setState(() {
      isSendingAdminRequest = true;
    });
    User? user = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).user;
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(
      context,
      listen: false,
    ).discuz;
    if (discuz == null || fid == null) {
      return;
    }
    Dio dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    int banned = _post.blocked ? 0 : 1;

    client
        .deletePostResult(formhash, fid!, _post.tid, [_post.pid], banned, "")
        .then((value) {
          if (!mounted) return;
          if (value.errorResult?.key == "admin_succeed") {
            // it should be banned
            Post newPostStage = _post;
            newPostStage.status = newPostStage.status ^ POST_BLOCKED;
            setState(() {
              _post = newPostStage;
            });
            EasyLoading.showSuccess(
              value.errorResult?.content == null
                  ? S.of(context).ok
                  : value.errorResult!.content,
            );
          } else {
            EasyLoading.showError(
              value.errorResult?.content == null
                  ? S.of(context).error
                  : value.errorResult!.content,
            );
          }
          setState(() {
            isSendingAdminRequest = false;
          });
          // Navigator.of(context).pop();
        });
  }
}
