import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../utility/reply_draft_store.dart';
import '../utility/forum_composer_capabilities.dart';

import '../utility/post_signature_service.dart';
import '../utility/post_editor_controller.dart';
import '../client/reply_reward_form.dart';
import '../client/thread_post_options.dart';
import 'thread_post_options_sheets.dart';
import '../widget/post_settings_sheet.dart';
import 'reply_reward_page.dart';
import 'PollComposerPage.dart';
import 'SpecialThreadComposerPage.dart';
import 'InternalWebviewBrowserPage.dart';
import '../entity/PollDraft.dart';
import '../client/ForumInteractionClient.dart';
import '../client/SpecialThreadForm.dart';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/screen/SmileyListScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/CaptchaWidget.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:provider/provider.dart';

import '../JsonResult/DisplayForumResult.dart';
import '../widget/PostPermissionGate.dart';
import '../database/AppDatabase.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/Draft.dart';
import '../entity/ImageAttachment.dart';
import '../entity/Smiley.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../screen/ExtraFuncInThreadScreen.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PostTextFieldUtils.dart';
import '../utility/UserPreferencesUtils.dart';
import '../utility/forum_error.dart';
import '../utility/forum_pending_upload.dart';
import '../utility/forum_voice.dart';
import '../utility/discuz_json.dart';
import '../widget/ErrorCard.dart';
import '../widget/forum_voice_recorder.dart';

class PostThreadPage extends StatelessWidget {
  int fid;
  int tid;
  Discuz discuz;
  Draft? draft;
  final Map<String, dynamic>? navigationTypes;

  PostThreadPage(
    this.discuz,
    this.fid,
    this.tid, {
    this.draft,
    this.navigationTypes,
  });

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (draft != null &&
        (draft!.uid != user?.uid || !draft!.discuz.isSameSite(discuz))) {
      return PlatformScaffold(
        appBar: PlatformAppBar(title: Text(S.of(context).draftInbox)),
        body: Center(child: Text(S.of(context).forumAccountChanged)),
      );
    }
    return PostPermissionGate(
      key: ValueKey((discuz.siteIdentity, fid, account.sessionIdentity)),
      reply: false,
      fullPage: true,
      voiceScope: user == null
          ? null
          : (site: discuz.siteIdentity, uid: user.uid, fid: fid),
      load: () async => MobileApiClient(
        await NetworkUtils.getDioWithPersistCookieJar(user),
        baseUrl: discuz.baseURL,
      ).checkPost(fid, null),
      child: PostThreadStatefulWidget(
        discuz,
        fid,
        tid,
        draft: draft,
        navigationTypes: navigationTypes,
      ),
    );
  }
}

class PostThreadStatefulWidget extends StatefulWidget {
  int fid;
  Discuz discuz;
  int tid;
  Draft? draft;
  final Map<String, dynamic>? navigationTypes;

  PostThreadStatefulWidget(
    this.discuz,
    this.fid,
    this.tid, {
    this.draft,
    this.navigationTypes,
  });

  @override
  PostThreadState createState() {
    return PostThreadState(this.discuz, this.fid, this.tid, draft: draft);
  }
}

enum _PostSetting {
  category,
  poll,
  bounty,
  activity,
  replyReward,
  clearType,
  clearReward,
  classified,
  rush,
  clearRush,
}

class PostThreadState extends State<PostThreadStatefulWidget> {
  Discuz discuz;
  int fid;
  int tid;
  final _controller = PostEditorController();
  TextEditingController _titleEditingController = TextEditingController();
  CaptchaController captchaController = CaptchaController(
    new CaptchaFields("", "post", ""),
  );
  FocusNode focusNode = FocusNode();
  Draft? draft;
  PollDraft? _pollDraft;
  SpecialThreadDraft? _specialDraft;
  ReplyRewardDraft? _replyReward;
  ClassifiedPostDraft? _classified;
  RushPostDraft? _rush;
  Map<String, dynamic> _sortConfig = {};
  int get _specialId => _specialDraft?.kind.id ?? (_pollDraft == null ? 0 : 1);
  Future<ReplyRewardForm?> _rewardForm() async {
    final user = context.read<DiscuzAndUserNotifier>().userFor(discuz);
    if (user == null || !_draftCurrent)
      throw const ForumApiException('account_changed', '');
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      return await ReplyRewardForm.load(
        ForumInteractionClient(dio, discuz.baseURL),
        fid,
        user.uid,
        _specialId,
      );
    } finally {
      dio.close();
    }
  }

  Future<void> _configureReplyReward() async {
    if (_configuring || !_draftCurrent) return;
    setState(() => _configuring = true);
    try {
      final form = await _rewardForm();
      if (!_draftCurrent) return;
      if (form == null) {
        EasyLoading.showError(S.of(context).replyRewardUnavailable);
        return;
      }
      final value = await showPostSettingsSheet<ReplyRewardDraft>(
        context,
        (_) => ReplyRewardPage(form, _replyReward),
      );
      if (value != null && _draftCurrent) {
        setState(() => _replyReward = value);
        await backupDraft();
      }
    } catch (e) {
      if (_draftCurrent)
        await showForumActionError(
          context,
          forumRequestError(S.of(context), e),
        );
    } finally {
      if (mounted) setState(() => _configuring = false);
    }
  }

  bool _sending = false;
  bool _configuring = false;
  bool _confirming = false;
  ForumVoiceOptions? _recordingVoice;
  final _voicePreviews = <RecordedForumVoice>[];
  final _pending = <String, ReplyDraftAttachment>{};
  late final int _draftUid;
  late final Object _draftSession;
  bool _restoringAssets = false, _draftCompleted = false;
  ReplyDraftStore? _assetStore;
  bool get _draftCurrent =>
      mounted &&
      identical(
        _draftSession,
        context.read<DiscuzAndUserNotifier>().sessionIdentity,
      );
  Future<void> _draftWrite = Future.value();
  // dropdown menu status
  String? selectedTypeId;

  PostThreadState(this.discuz, this.fid, this.tid, {this.draft});

  void _recordVoice(ForumVoiceOptions options) {
    if (_sending || _confirming || _recordingVoice != null) return;
    FocusScope.of(context).unfocus();
    setState(() => _recordingVoice = options);
  }

  Future<bool> _attachVoice(RecordedForumVoice voice) async {
    if (!_draftCurrent) return false;
    await _addDraftAttachment(voice.name, voice.file.openRead(), false);
    if (!_draftCurrent) return false;
    _voicePreviews.add(voice);
    return true;
  }

  Future<ReplyDraftStore> _assets() async {
    if (_assetStore != null) return _assetStore!;
    await backupDraft();
    return _assetStore ??= ReplyDraftStore(
      discuz.siteIdentity,
      _draftUid,
      -(draft!.key as int) - 1,
    );
  }

  Future<void> _restoreAssets() async {
    try {
      final items = jsonDecode(draft!.pendingAttachmentsJson);
      if (items is! List)
        throw const FormatException('Invalid draft attachments');
      final store = await _assets();
      for (final raw in items) {
        final item = ReplyDraftAttachment.fromJson(raw);
        if (item == null)
          throw const FormatException('Invalid draft attachment');
        final file = await store.file(item);
        if (!_draftCurrent) return;
        _pending[item.id] = item;
        if (item.image) {
          _controller.restoreImagePath(item.token, file.path);
        } else {
          _controller.restoreFileNames({item.id: item.name});
          _controller.restoreFilePath(item.id, file.path);
        }
      }
    } catch (_) {
      if (mounted) EasyLoading.showError(S.of(context).replyDraftRestoreFailed);
    } finally {
      if (mounted) setState(() => _restoringAssets = false);
    }
  }

  Future<void> _addDraftAttachment(
    String name,
    Stream<List<int>> bytes,
    bool image,
  ) async {
    if (!_draftCurrent) return;
    final store = await _assets();
    final item = await store.add(name: name, bytes: bytes, image: image);
    final file = await store.file(item);
    if (!_draftCurrent) {
      await file.delete();
      return;
    }
    _pending[item.id] = item;
    if (image) {
      _controller.restoreImagePath(item.token, file.path);
    } else {
      _controller.restoreFileNames({item.id: name});
      _controller.restoreFilePath(item.id, file.path);
    }
    _controller.insertText(item.token, image: true);
    await backupDraft();
  }

  Future<String> _resolveAttachments(
    MobileApiClient api,
    int uid,
    bool Function() isCurrent,
  ) async {
    var source = _controller.text;
    final uploaded = <String, String>{};
    for (final token in PostEditorToken.inText(
      source,
    ).where((t) => t.isPending)) {
      if (uploaded.containsKey(token.text)) continue;
      final item = _pending[token.content];
      if (item == null || item.image != token.isAttachment) {
        throw DiscuzError(
          'attachment_unreadable',
          S.of(context).replyDraftUploadMissing,
        );
      }
      final aid = await uploadPendingForumAttachment(
        api: api,
        strings: S.of(context),
        fid: fid,
        tid: 0,
        uid: uid,
        file: await (await _assets()).file(item),
        name: item.name,
        image: item.image,
        isCurrent: isCurrent,
        replying: false,
        capabilityScope: (site: discuz.siteIdentity, uid: uid, fid: fid),
      );
      final tag = item.image ? 'attachimg' : 'attach';
      uploaded[token.text] = '[$tag]$aid[/$tag]';
    }
    return source.replaceAllMapped(
      PostEditorToken.pattern,
      (match) => uploaded[match[0]] ?? match[0]!,
    );
  }

  @override
  void initState() {
    super.initState();
    final account = context.read<DiscuzAndUserNotifier>();
    _draftUid = account.userFor(discuz)?.uid ?? 0;
    _draftSession = account.sessionIdentity;
    if (draft != null) {
      _titleEditingController.text = draft!.title;
      _controller.text = draft!.text;
      _controller.restoreFileNames(draft!.attachmentNames);
      selectedTypeId = draft!.typeid;
      _classified = ClassifiedPostDraft.decode(draft!.classifiedJson);
      _rush = RushPostDraft.decode(draft!.rushJson);
      _replyReward = ReplyRewardDraft.decode(draft!.replyRewardJson);
      _pollDraft = PollDraft.decode(draft!.pollJson);
      _specialDraft = SpecialThreadDraft.decode(draft!.specialThreadJson);
    }
    _loadForumInfo();
    // add backup option
    backupDraftIfPossible();
    if (draft?.pendingAttachmentsJson.isNotEmpty == true) {
      _restoringAssets = true;
      Future.microtask(_restoreAssets);
    }
  }

  Future<void> _configurePoll() async {
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (user == null || _configuring) return;
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    setState(() => _configuring = true);
    Dio? dio;
    try {
      dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final api = ForumInteractionClient(dio, discuz.baseURL);
      final form = await loadThreadPostForm(api, fid, user.uid, special: 1);
      final rules = PollPostingRules.parse(form, fid, user.uid);
      if (!isCurrent()) return;
      final store = await _assets();
      if (!isCurrent()) return;
      final value = await showPostSettingsSheet<PollDraft>(
        context,
        (_) =>
            PollComposerPage(initial: _pollDraft, rules: rules, store: store),
      );
      if (isCurrent() && value != null) {
        setState(() {
          _pollDraft = value;
          _specialDraft = null;
          _classified = null;
        });
        await backupDraft();
      }
    } catch (e) {
      if (isCurrent()) {
        final strings = S.of(context);
        await showForumActionError(
          context,
          forumRequestError(strings, e, fallback: strings.pollUnavailable),
        );
      }
    } finally {
      dio?.close();
      if (mounted) setState(() => _configuring = false);
    }
  }

  Future<void> _configureSpecial(SpecialThreadKind kind) async {
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (user == null || _configuring) return;
    final session = account.sessionIdentity;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    setState(() => _configuring = true);
    Dio? dio;
    try {
      dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final form = await SpecialThreadForm.load(
        ForumInteractionClient(dio, discuz.baseURL),
        fid,
        user.uid,
        kind,
      );
      if (!isCurrent()) return;
      final value = await showPostSettingsSheet<SpecialThreadDraft>(
        context,
        (_) => SpecialThreadComposerPage(
          kind: kind,
          form: form,
          initial: _specialDraft?.kind == kind ? _specialDraft : null,
        ),
      );
      if (!isCurrent() || value == null) return;
      setState(() {
        _specialDraft = value;
        _pollDraft = null;
        _classified = null;
      });
      await backupDraft();
    } catch (error) {
      if (isCurrent()) {
        final strings = S.of(context);
        if (error is ForumApiException &&
            error.code == 'special_post_form_unavailable') {
          final open = await showPlatformDialog<bool>(
            context: context,
            builder: (dialogContext) => PlatformAlertDialog(
              content: Text(strings.specialPostFormUnavailable),
              actions: [
                PlatformDialogAction(
                  child: Text(strings.cancel),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                PlatformDialogAction(
                  child: Text(strings.navigateToWebPage),
                  onPressed: () => Navigator.pop(dialogContext, true),
                ),
              ],
            ),
          );
          if (open == true && isCurrent()) {
            final uri = SpecialThreadForm.website(
              Uri.parse(discuz.getBaseURLWithAfterfix()),
              fid,
              kind,
            );
            await Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (_) =>
                    InternalWebviewBrowserPage(discuz, user, '$uri'),
              ),
            );
          }
          return;
        }
        await showForumActionError(
          context,
          forumRequestError(
            strings,
            error,
            fallback: strings.specialPostFormUnavailable,
          ),
        );
      }
    } finally {
      dio?.close();
      if (mounted) setState(() => _configuring = false);
    }
  }

  Map<String, dynamic> get _classifications => discuzMap(_sortConfig['types']);

  Future<int?> _chooseClassification() =>
      showPostSettingsSheet<int>(context, (sheet) {
        final strings = S.of(sheet);
        return PostSettingsSheet(
          title: strings.specialClassified,
          children: [
            for (final e in _classifications.entries)
              if (int.tryParse(e.key) case final int sortId)
                PlatformListTile(
                  title: Text(discuzString(e.value)),
                  onTap: () => Navigator.pop(sheet, sortId),
                ),
          ],
        );
      });

  Future<void> _configurePostingForm({int? sortId}) async {
    final user = context.read<DiscuzAndUserNotifier>().userFor(discuz);
    if (!_draftCurrent || user == null || _configuring) return;
    setState(() => _configuring = true);
    Dio? dio;
    try {
      dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      if (!_draftCurrent) return;
      final api = ForumInteractionClient(dio, discuz.baseURL);
      final form = await loadThreadPostForm(
        api,
        fid,
        user.uid,
        special: sortId == null ? _specialId : 0,
        sortId: sortId ?? _classified?.sortId ?? 0,
      );
      if (!_draftCurrent) return;
      if (sortId != null) {
        final config = ClassifiedPostingForm.parse(form, sortId);
        final value = await showPostSettingsSheet<ClassifiedPostDraft>(
          context,
          (_) => ClassifiedPostSheet(
            sortId,
            discuzString(_classifications['$sortId']),
            config,
            _classified?.sortId == sortId ? _classified : null,
          ),
        );
        if (!_draftCurrent || value == null) return;
        setState(() {
          _classified = value;
          _pollDraft = null;
          _specialDraft = null;
        });
      } else {
        if (!RushPostDraft.supported(form)) {
          EasyLoading.showError(S.of(context).rushSettingsUnavailable);
          return;
        }
        final value = await showPostSettingsSheet<RushPostDraft>(
          context,
          (_) => RushPostSheet(
            _rush,
            form.querySelector('label[for=creditlimit]')?.text.trim() ?? '',
          ),
        );
        if (!_draftCurrent || value == null) return;
        setState(() => _rush = value);
      }
      await backupDraft();
    } catch (error) {
      if (!_draftCurrent) return;
      final strings = S.of(context);
      if (sortId != null &&
          error is ForumApiException &&
          error.code == 'classified_post_unsupported') {
        final open = await showPlatformDialog<bool>(
          context: context,
          builder: (dialog) => PlatformAlertDialog(
            content: Text(strings.classifiedUnsupported),
            actions: [
              PlatformDialogAction(
                child: Text(strings.cancel),
                onPressed: () => Navigator.pop(dialog),
              ),
              PlatformDialogAction(
                child: Text(strings.navigateToWebPage),
                onPressed: () => Navigator.pop(dialog, true),
              ),
            ],
          ),
        );
        if (open == true && _draftCurrent) {
          final uri = Uri.parse(discuz.getBaseURLWithAfterfix())
              .resolve('forum.php')
              .replace(
                queryParameters: {
                  'mod': 'post',
                  'action': 'newthread',
                  'fid': '$fid',
                  'sortid': '$sortId',
                  'mobile': 'no',
                },
              );
          await Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (_) => InternalWebviewBrowserPage(discuz, user, '$uri'),
            ),
          );
        }
        return;
      }
      await showForumActionError(
        context,
        forumRequestError(
          strings,
          error,
          fallback: strings.specialPostFormUnavailable,
        ),
      );
    } finally {
      dio?.close();
      if (mounted) setState(() => _configuring = false);
    }
  }

  Widget _buildSettingsEntry(BuildContext context) {
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final summary = [
      if (_threadTypeEntries.isNotEmpty &&
          selectedTypeId != null &&
          selectedTypeId != '0')
        _selectedThreadTypeLabel,
      if (_pollDraft != null) s.pollTitle,
      if (_specialDraft?.kind == SpecialThreadKind.reward) s.createReward,
      if (_specialDraft?.kind == SpecialThreadKind.activity) s.createActivity,
      if (_classified case final classified?)
        discuzString(_classifications['${classified.sortId}']).isEmpty
            ? s.specialClassified
            : discuzString(_classifications['${classified.sortId}']),
      if (_replyReward != null) s.replyCreditTitle,
      if (_rush != null) s.rushReplyTitle,
    ];
    return PlatformListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(s.postSettings),
      subtitle: summary.isEmpty ? null : Text(summary.join(' · ')),
      leading: Icon(icons.settings, size: 20),
      trailing: _configuring
          ? const SizedBox.square(
              dimension: 18,
              child: PlatformCircularProgressIndicator(),
            )
          : Icon(
              icons.pick(Icons.chevron_right, CupertinoIcons.chevron_forward),
              size: 18,
            ),
      onTap: _configuring || _sending || _confirming || _recordingVoice != null
          ? null
          : _showPostSettings,
    );
  }

  Future<void> _showPostSettings() async {
    FocusScope.of(context).unfocus();
    final selected = await showPostSettingsSheet<_PostSetting>(context, (
      sheet,
    ) {
      final s = S.of(sheet);
      final icons = PlatformIcons(sheet);
      Widget entry(
        _PostSetting action,
        IconData icon,
        String label, {
        bool active = false,
      }) => PlatformListTile(
        leading: Icon(icon, size: 20),
        title: Text(label),
        trailing: Icon(active ? icons.checkMark : icons.forward, size: 17),
        onTap: () => Navigator.pop(sheet, action),
      );
      return PostSettingsSheet(
        title: s.postSettings,
        children: [
          if (_threadTypeEntries.isNotEmpty)
            entry(
              _PostSetting.category,
              icons.tagSolid,
              _selectedThreadTypeLabel,
            ),
          entry(
            _PostSetting.poll,
            icons.chart,
            s.pollTitle,
            active: _pollDraft != null,
          ),
          entry(
            _PostSetting.bounty,
            icons.bounty,
            s.createReward,
            active: _specialDraft?.kind == SpecialThreadKind.reward,
          ),
          entry(
            _PostSetting.activity,
            icons.pick(Icons.event_outlined, CupertinoIcons.calendar),
            s.createActivity,
            active: _specialDraft?.kind == SpecialThreadKind.activity,
          ),
          entry(
            _PostSetting.replyReward,
            icons.replyReward,
            s.replyCreditTitle,
            active: _replyReward != null,
          ),
          if (_classifications.isNotEmpty)
            entry(
              _PostSetting.classified,
              icons.category,
              s.specialClassified,
              active: _classified != null,
            ),
          entry(
            _PostSetting.rush,
            icons.flag,
            s.rushReplyTitle,
            active: _rush != null,
          ),
          if (_pollDraft != null ||
              _specialDraft != null ||
              _classified != null ||
              _replyReward != null ||
              _rush != null)
            const Divider(),
          if (_pollDraft != null ||
              _specialDraft != null ||
              _classified != null)
            entry(_PostSetting.clearType, icons.delete, s.removeSpecialPost),
          if (_replyReward != null)
            entry(_PostSetting.clearReward, icons.delete, s.removeReplyReward),
          if (_rush != null)
            entry(_PostSetting.clearRush, icons.delete, s.removeRushSettings),
        ],
      );
    });
    if (!_draftCurrent || selected == null) return;
    switch (selected) {
      case _PostSetting.category:
        await _showThreadTypePicker();
      case _PostSetting.poll:
        await _configurePoll();
      case _PostSetting.bounty:
        await _configureSpecial(SpecialThreadKind.reward);
      case _PostSetting.activity:
        await _configureSpecial(SpecialThreadKind.activity);
      case _PostSetting.replyReward:
        await _configureReplyReward();
      case _PostSetting.classified:
        final sortId = await _chooseClassification();
        if (sortId != null && _draftCurrent)
          await _configurePostingForm(sortId: sortId);
      case _PostSetting.rush:
        await _configurePostingForm();
      case _PostSetting.clearRush:
        setState(() => _rush = null);
        await backupDraft();
      case _PostSetting.clearType:
        setState(() {
          _pollDraft = null;
          _specialDraft = null;
          _classified = null;
        });
        await backupDraft();
      case _PostSetting.clearReward:
        setState(() => _replyReward = null);
        await backupDraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restoringAssets)
      return PlatformScaffold(
        appBar: PlatformAppBar(title: Text(S.of(context).draftInbox)),
        body: const Center(child: PlatformCircularProgressIndicator()),
      );

    if (_forumLoadError != null) {
      return PlatformScaffold(
        appBar: PlatformAppBar(title: Text(S.of(context).pushThreadTitle)),
        body: Center(
          child: ErrorCard(_forumLoadError!, _loadForumInfo, largeSize: false),
        ),
      );
    }
    if (_displayForumResult == null && widget.navigationTypes == null) {
      return Container(
        width: 64,
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: PlatformCircularProgressIndicator(),
            ),
            SizedBox(height: 32),
            Text(S.of(context).loadingForumInformation),
          ],
        ),
      );
    }

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(S.of(context).pushThreadTitle),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'paperplane',
            icon: Icon(
              AppPlatformIcons(context).postThreadSolid,
              size: 20,
              semanticLabel: S.of(context).pushThreadTitle,
            ),
            onPressed:
                _sending ||
                    _configuring ||
                    _confirming ||
                    _recordingVoice != null
                ? null
                : () {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _confirmPost();
                  },
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _sending || _confirming || _configuring,
        child: PlatformLiquidGlassPageBackdrop(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlatformTextField(
                        controller: _titleEditingController,
                        textInputAction: TextInputAction.next,
                        hintText: S.of(context).pushThreadTitleHint,
                      ),
                      const SizedBox(height: 4),
                      _buildSettingsEntry(context),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: PostTextField(
                      discuz,
                      _controller,
                      focusNode: focusNode,
                      expanded: true,
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _recordingVoice != null
                        ? ForumVoiceRecorder(
                            options: _recordingVoice!,
                            onRecorded: _attachVoice,
                            onClosed: () =>
                                setState(() => _recordingVoice = null),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: PlatformLiquidGlassToolbarGroup(
                              children: [
                                PlatformIconButton(
                                  liquidGlassSymbol: 'bold',
                                  icon: Icon(PlatformIcons(context).bold),
                                  onPressed: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    String insertedText = "[b][/b]";
                                    insertString(insertedText);
                                  },
                                ),
                                PlatformIconButton(
                                  liquidGlassSymbol: 'italic',
                                  icon: Icon(PlatformIcons(context).italic),
                                  onPressed: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    String insertedText = "[i][/i]";
                                    insertString(insertedText);
                                  },
                                ),
                                PlatformIconButton(
                                  liquidGlassSymbol: 'quote.bubble',
                                  icon: Icon(
                                    PlatformIcons(context).formatQuote,
                                  ),
                                  onPressed: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    String insertedText = "[quote][/quote]";
                                    insertString(insertedText);
                                  },
                                ),
                                PlatformIconButton(
                                  liquidGlassSymbol: 'face.smiling',
                                  icon: Icon(PlatformIcons(context).smiley),
                                  onPressed: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    // popup a smiley dialog
                                    showPlatformModalSheet(
                                      context: context,
                                      builder: (context) => SmileyListScreen(
                                        insertSmiley,
                                        onAttachmentPressed:
                                            _handleReplyWithImage,
                                      ),
                                    );
                                  },
                                ),
                                PlatformIconButton(
                                  liquidGlassSymbol: 'paperclip',
                                  icon: Icon(
                                    PlatformIcons(context).attachment,
                                    semanticLabel: S
                                        .of(context)
                                        .composerAttachmentLabel,
                                  ),
                                  onPressed: () {
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    showPlatformModalSheet(
                                      context: context,
                                      builder: (context) =>
                                          ExtraFuncInThreadScreen(
                                            discuz,
                                            tid,
                                            fid,
                                            onReplyWithImage:
                                                _handleReplyWithImage,
                                            onAttachFile: (aid, name) {
                                              if (mounted)
                                                _controller.insertFile(
                                                  aid,
                                                  name,
                                                );
                                            },
                                            onReplyWithHostedImage:
                                                (imageUrl, path) {
                                                  if (mounted &&
                                                      imageUrl.isNotEmpty) {
                                                    _controller
                                                        .insertHostedImage(
                                                          imageUrl,
                                                          path,
                                                        );
                                                  }
                                                },
                                            saveDraftAttachment:
                                                _addDraftAttachment,
                                            showHistoricalAttachment: false,
                                          ),
                                    );
                                  },
                                ),
                                if (PostPermissionGate.voiceOptionsOf(context)
                                    case final voice?)
                                  ForumVoiceButton(
                                    onPressed: () => _recordVoice(voice),
                                  ),
                                // PlatformIconButton(
                                //   icon: Icon(Icons.settings_backup_restore),
                                // ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DisplayForumResult? _displayForumResult = null;
  DiscuzError? _forumLoadError;

  Future<void> _loadForumInfo() async {
    final user = context.read<DiscuzAndUserNotifier>().userFor(discuz);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    try {
      if (mounted) setState(() => _forumLoadError = null);
      final value = await client.displayForumResult(fid.toString(), 1, {});
      if (!mounted) return;
      setState(() {
        _forumLoadError = forumResponseError(S.of(context), value);
        if (_forumLoadError == null) {
          _displayForumResult = value;
          _sortConfig = value.discuzIndexVariables.threadSorts;
        }
      });
    } catch (error) {
      if (mounted)
        setState(
          () => _forumLoadError = forumRequestError(S.of(context), error),
        );
    } finally {
      dio.close();
    }
  }

  List<MapEntry<String, String>> get _threadTypeEntries =>
      (_displayForumResult?.discuzIndexVariables.threadType?.idNameMap ??
              discuzMap(widget.navigationTypes?['types']))
          .entries
          .map((entry) => MapEntry(entry.key, entry.value.toString()))
          .toList();

  String get _selectedThreadTypeLabel {
    for (final entry in _threadTypeEntries) {
      if (entry.key == selectedTypeId) return entry.value;
    }
    return S.of(context).forumFilterTypeIdTitle;
  }

  Future<void> _showThreadTypePicker() async {
    final entries = _threadTypeEntries;
    if (entries.isEmpty) return;
    VibrationUtils.vibrateWithClickIfPossible();
    final selected = await showPlatformModalSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.62,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Text(
                  S.of(context).forumFilterTypeIdTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final entry in entries)
                      PlatformListTile(
                        contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
                        title: Text(
                          entry.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedTypeId == entry.key
                            ? Icon(
                                PlatformIcons(sheetContext).checkMark,
                                color: Theme.of(sheetContext)
                                    .colorScheme
                                    .primary,
                                size: 18,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, entry.key),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => selectedTypeId = selected);
    }
  }

  // utilities
  void insertSmiley(Smiley smiley) {
    if (!mounted) return;
    _controller.insertText(
      '${SmileyText.smileyStartFlag}$smiley${SmileyText.smileyEndFlag}',
    );
  }

  Future<void> _handleReplyWithImage(String aid, String path) async {
    if (!mounted || aid.isEmpty) return;
    _controller.insertAttachment(aid, path);
    if (!await UserPreferencesUtils.getRecordHistoryEnabled()) return;

    final dao = await AppDatabase.getImageAttachmentDao();
    final attachment = dao.findImageAttachmentByDiscuzAndAid(discuz, aid);
    if (attachment == null) {
      await dao.insertImageAttachment(ImageAttachment(aid, discuz, path));
    } else {
      attachment.updateAt = DateTime.now();
      await dao.insertImageAttachmentWithKey(attachment.key, attachment);
    }
  }

  void insertString(String string) {
    if (!mounted) return;
    _controller.insertText(string);
  }

  @override
  void dispose() {
    for (final clip in _voicePreviews) {
      unawaited(clip.delete());
    }
    _controller.dispose();
    _titleEditingController.dispose();
    focusNode.dispose();
    captchaController.dispose();
    super.dispose();
  }

  void backupDraftIfPossible() {
    var previousTitle = _titleEditingController.text;
    var previousText = _controller.text;
    void saveChangedText() {
      final title = _titleEditingController.text;
      final text = _controller.text;
      if (title == previousTitle && text == previousText) return;
      previousTitle = title;
      previousText = text;
      unawaited(
        backupDraft().catchError((Object error) {
          if (mounted)
            EasyLoading.showError(S.of(context).replyDraftSaveFailed);
        }),
      );
    }

    _titleEditingController.addListener(saveChangedText);
    _controller.addListener(saveChangedText);
  }

  Future<void> backupDraft() {
    if (_draftCompleted || _draftUid <= 0 || _restoringAssets)
      return _draftWrite;
    final pendingJson = jsonEncode([
      for (final token in PostEditorToken.inText(
        _controller.text,
      ).where((t) => t.isPending))
        if (_pending[token.content] case final item?) item.toJson(),
    ]);
    final title = _titleEditingController.text;
    final content = _controller.text;
    final category = selectedTypeId ?? '';
    final poll = _pollDraft?.encode() ?? '';
    final replyReward = _replyReward?.encode() ?? '';
    final classified = _classified?.encode() ?? '';
    final rush = _rush?.encode() ?? '';
    final special = _specialDraft?.encode() ?? '';
    final attachmentNames = _controller.attachedFileNames;
    _draftWrite = _draftWrite.catchError((Object _) {}).then((_) async {
      draft ??= Draft(title, content, fid, category, DateTime.now(), discuz);
      draft!
        ..uid = _draftUid
        ..pendingAttachmentsJson = pendingJson
        ..title = title
        ..text = content
        ..typeid = category
        ..updateTime = DateTime.now()
        ..pollJson = poll
        ..replyRewardJson = replyReward
        ..classifiedJson = classified
        ..rushJson = rush
        ..specialThreadJson = special
        ..attachmentNames = attachmentNames;
      final dao = await AppDatabase.getDraftDao();
      draft = await dao.insertDraftAndReturnInsertObj(draft!);
    });
    return _draftWrite;
  }

  Future<void> _confirmPost() async {
    if (_confirming ||
        _sending ||
        _configuring ||
        _restoringAssets ||
        !_draftCurrent)
      return;
    if (_specialId == 0 &&
        _classified == null &&
        discuzPermission(_sortConfig['required']) == true) {
      EasyLoading.showError(S.of(context).classifiedRequired);
      return;
    }
    final selected = selectedTypeId;
    final typeRequired =
        _displayForumResult?.discuzIndexVariables.threadType?.typeRequired() ==
            true ||
        discuzPermission(widget.navigationTypes?['required']) == true;
    if (typeRequired &&
        (selected == null ||
            selected == '0' ||
            !_threadTypeEntries.any((type) => type.key == selected))) {
      EasyLoading.showError(S.of(context).forumFilterTypeIdTitle);
      return;
    }
    setState(() => _confirming = true);
    try {
      do {
        ReplyRewardForm? quote;
        if (_replyReward case final d?) {
          try {
            quote = await _rewardForm();
            if (!_draftCurrent) return;
            if (quote == null || !quote.accepts(d)) {
              EasyLoading.showError(S.of(context).specialPostRulesChanged);
              return;
            }
          } catch (e) {
            if (_draftCurrent)
              await showForumActionError(
                context,
                forumRequestError(S.of(context), e),
              );
            return;
          }
        }
        final confirmed = await _showPostConfirmation(quote);
        if (!mounted || confirmed != true) {
          if (mounted) captchaController.reloadCaptcha(requiredByServer: false);
          return;
        }
        if (!await _postThread(quote)) break;
      } while (_draftCurrent);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<bool?> _showPostConfirmation(ReplyRewardForm? quote) async {
    final requiresCaptcha = captchaController.requiredByServer;
    final user = context.read<DiscuzAndUserNotifier>().userFor(discuz);
    final dio = requiresCaptcha
        ? await NetworkUtils.getDioWithPersistCookieJar(user)
        : null;
    if (!mounted) {
      dio?.close();
      return null;
    }
    try {
      return await showPlatformDialog<bool>(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text(S.of(context).pushThreadTitle),
            content: dio == null && quote == null
                ? null
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (quote != null && _replyReward != null)
                          Text(
                            '${S.of(context).replyCreditTitle} · ${_replyReward!.amount} × ${_replyReward!.times}\n${S.of(context).rewardFee}: ${quote.total(_replyReward!) - _replyReward!.pool} ${quote.unit}\n${S.of(context).rewardTotal("${quote.total(_replyReward!)} ${quote.unit}")}',
                          ),
                        if (dio != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: CaptchaWidget(
                              dio,
                              discuz,
                              user,
                              'post',
                              captchaController: captchaController,
                            ),
                          ),
                      ],
                    ),
                  ),
            actions: [
              PlatformDialogAction(
                child: Text(S.of(context).send),
                onPressed: () {
                  final captcha = captchaController.value;
                  if (requiresCaptcha &&
                      (captcha == null ||
                          captcha.captchaFormHash.isEmpty ||
                          captcha.verification.trim().isEmpty)) {
                    EasyLoading.showError(S.of(context).captchaRequired);
                    return;
                  }
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.of(context).pop(true);
                },
              ),
              PlatformDialogAction(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      dio?.close();
    }
  }

  Future<bool> _postThread(ReplyRewardForm? quote) async {
    if (_sending) return false;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      return await _submitThread(quote);
    } catch (error) {
      if (!mounted) return false;
      final strings = S.of(context);
      final failure = forumRequestError(strings, error, submitted: true);
      if (failure.key == 'submit_seccode_invalid') {
        captchaController.reloadCaptcha(requiredByServer: true);
      }
      await showForumActionError(context, failure);
      return false;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool> _submitThread(ReplyRewardForm? quote) async {
    // prepare client
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    final user = account.userFor(discuz);
    if (user == null || user.uid != _draftUid || !_draftCurrent) return false;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      return await _sendThread(dio, user.uid, isCurrent, quote);
    } finally {
      dio.close();
    }
  }

  Future<bool> _sendThread(
    Dio dio,
    int uid,
    bool Function() isCurrent,
    ReplyRewardForm? quote,
  ) async {
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    String submitHash = '';
    try {
      final permission = await client.checkPost(fid, null);
      if (!isCurrent()) return false;
      await ForumComposerCapabilityCache.remember((
        site: discuz.siteIdentity,
        uid: uid,
        fid: fid,
      ), permission);
      if (!isCurrent()) return false;
      if (permission.variables.member_uid != 0 &&
          permission.variables.member_uid != uid)
        return false;
      submitHash = permission.variables.formHash;
      final strings = S.of(context);
      final failure = forumResponseError(strings, permission);
      if (failure != null || permission.variables.allowPerm.allowPost != true) {
        await showForumActionError(
          context,
          failure ??
              DiscuzError(
                'post_permission',
                permission.variables.allowPerm.allowPost == false
                    ? strings.postPermissionDenied
                    : strings.postPermissionUnknown,
              ),
        );
        return false;
      }
    } catch (error) {
      if (isCurrent())
        await showForumActionError(
          context,
          forumRequestError(S.of(context), error),
        );
      return false;
    }
    if (!isCurrent()) return false;
    final api = ForumInteractionClient(dio, discuz.baseURL);
    final poll = _pollDraft;
    final classified = _classified;
    final rush = _rush;
    final dataMap = <String, dynamic>{};
    if (poll != null || classified != null || rush != null) {
      final form = await loadThreadPostForm(
        api,
        fid,
        uid,
        special: _specialId,
        sortId: classified?.sortId ?? 0,
      );
      if (!isCurrent()) return false;
      submitHash = form
          .querySelector('input[name=formhash]')!
          .attributes['value']!;
      const changed = ForumApiException(
        'post_options_changed',
        '',
        fromForum: true,
      );
      if (rush != null) {
        if (!rush.valid || !RushPostDraft.supported(form)) throw changed;
        dataMap.addAll(rush.submission);
      }
      if (classified != null) {
        final rules = ClassifiedPostingForm.parse(form, classified.sortId);
        if (!rules.accepts(classified)) throw changed;
        dataMap.addAll(rules.submission(classified));
      }
      if (poll != null) {
        final rules = PollPostingRules.parse(form, fid, uid);
        if (!rules.accepts(poll)) throw changed;
        dataMap.addAll(poll.fields);
        if (poll.images.isNotEmpty) {
          final store = await _assets();
          final files = <int, (ReplyDraftAttachment, String)>{};
          for (final e in poll.images.entries) {
            final file = await store.file(e.value);
            if (!await file.exists() ||
                !rules.acceptsImage(e.value.name, await file.length())) {
              throw const ForumApiException(
                'poll_picture_rejected',
                '',
                fromForum: true,
              );
            }
            files[e.key] = (e.value, file.path);
          }
          for (final e in files.entries) {
            if (!isCurrent()) return false;
            final (image, path) = e.value;
            final aid = await rules.upload(
              api,
              fid,
              uid,
              File(path),
              image.name,
            );
            dataMap['pollimage[${e.key}]'] = '$aid';
          }
        }
      }
    }
    if (!isCurrent()) return false;
    String title = _titleEditingController.text;
    final source = await _resolveAttachments(client, uid, isCurrent);
    if (!isCurrent()) return false;
    final content = await PostSignatureService.append(
      context,
      PostTextFieldUtils.getPostMessage(source),
    );
    if (!isCurrent()) return false;
    // need to process aid
    List<String> aidList = PostTextFieldUtils.getAttachmentAidList(source);
    final special = _specialDraft;
    if (special != null) {
      if (!isCurrent()) return false;
      final strings = S.of(context);
      try {
        final form = await SpecialThreadForm.load(
          ForumInteractionClient(dio, discuz.baseURL),
          fid,
          uid,
          special.kind,
        );
        if (!isCurrent()) return false;
        if (!form.accepts(special)) {
          throw ForumApiException(
            'special_post_rules',
            strings.specialPostRulesChanged,
          );
        }
        submitHash = form.formhash;
        if (form.reward case final reward?) {
          final amount = int.parse(special.fields['rewardprice']!);
          final confirmed = await showPlatformDialog<bool>(
            context: context,
            builder: (dialogContext) => PlatformAlertDialog(
              title: Text(strings.createReward),
              content: Text(
                strings.rewardTotal(
                  '${reward.total(amount)} ${reward.credit}'.trim(),
                ),
              ),
              actions: [
                PlatformDialogAction(
                  child: Text(strings.cancel),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                PlatformDialogAction(
                  child: Text(strings.forumConfirm),
                  onPressed: () => Navigator.pop(dialogContext, true),
                ),
              ],
            ),
          );
          if (!isCurrent() || confirmed != true) return false;
          final fresh = await SpecialThreadForm.load(
            ForumInteractionClient(dio, discuz.baseURL),
            fid,
            uid,
            special.kind,
          );
          if (!isCurrent()) return false;
          if (fresh.reward?.rules != reward.rules || !fresh.accepts(special)) {
            throw ForumApiException(
              'special_post_rules',
              strings.specialPostRulesChanged,
            );
          }
          submitHash = fresh.formhash;
        }
        dataMap.addAll(form.submissionFields(special));
      } catch (error) {
        if (isCurrent()) {
          await showForumActionError(
            context,
            forumRequestError(
              strings,
              error,
              fallback: strings.specialPostFormUnavailable,
            ),
          );
        }
        return false;
      }
    }
    for (var aid in aidList) {
      String key = "attachnew[${aid}][description]";
      dataMap[key] = "";
    }

    String typeId = selectedTypeId == null ? "" : selectedTypeId!;
    CaptchaFields? captchaFields = captchaController.value;
    String captchaHash = "";
    String captchaMod = "";
    String verification = "";
    if (captchaFields != null && captchaFields.captchaFormHash.isNotEmpty) {
      captchaHash = captchaFields.captchaFormHash;
      verification = captchaFields.verification;
      captchaMod = "forum::post";
    }

    if (_replyReward case final d?) {
      final fresh = await ReplyRewardForm.load(
        ForumInteractionClient(dio, discuz.baseURL),
        fid,
        uid,
        _specialId,
      );
      if (!isCurrent()) return false;
      if (quote == null ||
          fresh == null ||
          !fresh.accepts(d) ||
          fresh.tax != quote.tax ||
          fresh.unit != quote.unit) {
        EasyLoading.showError(S.of(context).specialPostRulesChanged);
        return false;
      }
      submitHash = fresh.hash;
      dataMap.addAll(d.fields);
    }
    final value = await client.postNewThread({
      ...dataMap,
      'formhash': submitHash,
      'fid': fid,
      'typeid': typeId,
      'subject': title,
      'message': content,
      'seccodehash': captchaHash,
      'seccodemodid': captchaMod,
      'seccodeverify': verification,
    });
    if (!isCurrent()) return false;
    final result = value.errorResult;
    final strings = S.of(context);
    final code = forumMessageKey(result?.key ?? '');
    if (code == 'submit_seccode_invalid') {
      captchaController.reloadCaptcha(requiredByServer: true);
      if (captchaHash.isNotEmpty) {
        EasyLoading.showError(forumResponseError(strings, value)!.content);
      }
      return true;
    }
    if (code == 'post_newthread_succeed' ||
        code == 'post_newthread_mod_succeed') {
      _draftCompleted = true;
      await _draftWrite;
      if (draft?.key != null)
        await (await AppDatabase.getDraftDao()).deleteDraft(draft!);
      if (!mounted) return false;
      EasyLoading.showSuccess(result!.content);
      Navigator.of(context).pop();
    } else {
      final failure = forumResponseError(strings, value);
      await showForumActionError(
        context,
        failure ??
            forumRequestError(
              strings,
              const FormatException(),
              submitted: true,
            ),
      );
    }
    return false;
  }
}
