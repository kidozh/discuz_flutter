import 'dart:async';

import '../utility/post_signature_service.dart';
import '../utility/post_editor_controller.dart';
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
  bool _sending = false;
  bool _configuring = false;
  bool _confirming = false;
  ForumVoiceOptions? _recordingVoice;
  final _voicePreviews = <RecordedForumVoice>[];
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
    final account = context.read<DiscuzAndUserNotifier>();
    final user = account.userFor(discuz);
    if (user == null) return false;
    final session = account.sessionIdentity;
    bool current() => mounted && identical(session, account.sessionIdentity);
    final s = S.of(context);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      if (!current()) return false;
      await EasyLoading.show(
        status: s.uploadingAttachment,
        maskType: EasyLoadingMaskType.clear,
      );
      final aid = await uploadPendingForumAttachment(
        api: MobileApiClient(dio, baseUrl: discuz.baseURL),
        strings: s,
        fid: fid,
        tid: 0,
        uid: user.uid,
        file: voice.file,
        name: voice.name,
        image: false,
        isCurrent: current,
        replying: false,
      );
      if (!current()) return false;
      _controller.restoreFilePath(aid, voice.file.path);
      _controller.insertFile(aid, voice.name);
      _voicePreviews.add(voice);
      return true;
    } finally {
      dio.close();
      await EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    if (draft != null) {
      _titleEditingController.text = draft!.title;
      _controller.text = draft!.text;
      _controller.restoreFileNames(draft!.attachmentNames);
      selectedTypeId = draft!.typeid;
      _pollDraft = PollDraft.decode(draft!.pollJson);
      _specialDraft = SpecialThreadDraft.decode(draft!.specialThreadJson);
    }
    if (widget.navigationTypes == null) _loadForumInfo();
    // add backup option
    backupDraftIfPossible();
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
      final permission = await api.request('newthread', {
        'fid': fid,
        'special': 1,
      });
      permission.requireData('formhash');
      if ('${permission.variables['member_uid']}' != '${user.uid}')
        throw const ForumApiException('account_changed', '');
      if (!isCurrent()) return;
      final value = await Navigator.push<PollDraft>(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => PollComposerPage(initial: _pollDraft),
        ),
      );
      if (isCurrent() && value != null) {
        setState(() {
          _pollDraft = value;
          _specialDraft = null;
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
      final value = await Navigator.push<SpecialThreadDraft>(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => SpecialThreadComposerPage(
            kind: kind,
            form: form,
            initial: _specialDraft?.kind == kind ? _specialDraft : null,
          ),
        ),
      );
      if (!isCurrent() || value == null) return;
      setState(() {
        _specialDraft = value;
        _pollDraft = null;
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

  @override
  Widget build(BuildContext context) {
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
      body: PlatformLiquidGlassPageBackdrop(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_threadTypeEntries.isNotEmpty) ...[
                      Builder(
                        builder: (buttonContext) {
                          final button = PlatformTextButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            onPressed: _showThreadTypePicker,
                            child: Row(
                              children: [
                                Icon(PlatformIcons(context).tagSolid, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedThreadTypeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  PlatformIcons(context).downArrow,
                                  size: 14,
                                ),
                              ],
                            ),
                          );
                          if (usesAppleTranslucentSurface(buttonContext) &&
                              !usesLiquidGlass(buttonContext)) {
                            return PlatformLiquidGlassCard(
                              borderRadius: BorderRadius.circular(22),
                              child: button,
                            );
                          }
                          return button;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    Wrap(
                      children: [
                        PlatformTextButton(
                          onPressed: _sending || _configuring
                              ? null
                              : _configurePoll,
                          child: Text(
                            _pollDraft == null
                                ? S.of(context).createPoll
                                : S.of(context).editPoll,
                          ),
                        ),
                        for (final kind in SpecialThreadKind.values)
                          PlatformTextButton(
                            onPressed: _sending || _configuring
                                ? null
                                : () => _configureSpecial(kind),
                            child: Text(switch ((
                              kind,
                              _specialDraft?.kind == kind,
                            )) {
                              (SpecialThreadKind.reward, false) =>
                                S.of(context).createReward,
                              (SpecialThreadKind.reward, true) =>
                                S.of(context).editReward,
                              (SpecialThreadKind.activity, false) =>
                                S.of(context).createActivity,
                              (SpecialThreadKind.activity, true) =>
                                S.of(context).editActivity,
                            }),
                          ),
                        if (_pollDraft != null || _specialDraft != null)
                          PlatformTextButton(
                            onPressed: _sending
                                ? null
                                : () {
                                    setState(() {
                                      _pollDraft = null;
                                      _specialDraft = null;
                                    });
                                    backupDraft();
                                  },
                            child: Text(S.of(context).removeSpecialPost),
                          ),
                      ],
                    ),
                    PlatformTextField(
                      controller: _titleEditingController,
                      textInputAction: TextInputAction.next,
                      hintText: S.of(context).pushThreadTitle,
                    ),
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
                                icon: Icon(PlatformIcons(context).formatQuote),
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
                                              _controller.insertFile(aid, name);
                                          },
                                          onReplyWithHostedImage:
                                              (imageUrl, path) {
                                                if (mounted &&
                                                    imageUrl.isNotEmpty) {
                                                  _controller.insertHostedImage(
                                                    imageUrl,
                                                    path,
                                                  );
                                                }
                                              },
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
        if (_forumLoadError == null) _displayForumResult = value;
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
      backupDraft();
    }

    _titleEditingController.addListener(saveChangedText);
    _controller.addListener(saveChangedText);
  }

  Future<void> backupDraft() {
    final title = _titleEditingController.text;
    final content = _controller.text;
    final category = selectedTypeId ?? '';
    final poll = _pollDraft?.encode() ?? '';
    final special = _specialDraft?.encode() ?? '';
    final attachmentNames = _controller.attachedFileNames;
    _draftWrite = _draftWrite.catchError((Object _) {}).then((_) async {
      draft ??= Draft(title, content, fid, category, DateTime.now(), discuz);
      draft!
        ..title = title
        ..text = content
        ..typeid = category
        ..updateTime = DateTime.now()
        ..pollJson = poll
        ..specialThreadJson = special
        ..attachmentNames = attachmentNames;
      final dao = await AppDatabase.getDraftDao();
      draft = await dao.insertDraftAndReturnInsertObj(draft!);
    });
    return _draftWrite;
  }

  Future<void> _confirmPost() async {
    if (_confirming || _sending || _configuring) return;
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
        final confirmed = await _showPostConfirmation();
        if (!mounted || confirmed != true) {
          if (mounted) captchaController.reloadCaptcha(requiredByServer: false);
          return;
        }
      } while (await _postThread());
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<bool?> _showPostConfirmation() async {
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
            content: dio == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: CaptchaWidget(
                      dio,
                      discuz,
                      user,
                      'post',
                      captchaController: captchaController,
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

  Future<bool> _postThread() async {
    if (_sending) return false;
    setState(() => _sending = true);
    try {
      return await _submitThread();
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

  Future<bool> _submitThread() async {
    // prepare client
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    final user = account.userFor(discuz);
    if (user == null) return false;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    try {
      return await _sendThread(dio, user.uid, isCurrent);
    } finally {
      dio.close();
    }
  }

  Future<bool> _sendThread(Dio dio, int uid, bool Function() isCurrent) async {
    MobileApiClient client = MobileApiClient(dio, baseUrl: discuz.baseURL);

    String submitHash = '';
    try {
      final permission = await client.checkPost(fid, null);
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
    String title = _titleEditingController.text;
    final content = await PostSignatureService.append(
      context,
      PostTextFieldUtils.getPostMessage(_controller.text),
    );
    if (!isCurrent()) return false;
    // need to process aid
    List<String> aidList = PostTextFieldUtils.getAttachmentAidList(
      _controller.text,
    );
    final dataMap = <String, dynamic>{...?_pollDraft?.fields};
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
