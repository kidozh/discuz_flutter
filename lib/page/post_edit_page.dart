import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/post_edit_client.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../screen/ExtraFuncInThreadScreen.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/PostTextFieldUtils.dart';
import '../utility/forum_error.dart';
import '../utility/post_editor_controller.dart';
import '../widget/ErrorCard.dart';
import '../widget/PostTextField.dart';
import 'InternalWebviewBrowserPage.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage(
    this.discuz,
    this.user,
    this.fid,
    this.tid,
    this.pid, {
    super.key,
  });
  final Discuz discuz;
  final User user;
  final int fid, tid, pid;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  late final DiscuzAndUserNotifier account;
  late final Object session;
  final subject = TextEditingController();
  final editor = PostEditorController();
  final composerFocus = FocusNode();
  final uploader = GlobalKey<ExtraFuncInThreadState>();
  final settings = <String, TextEditingController>{};
  final removed = <String>{}, added = <String>{};
  PostEditForm? form;
  DiscuzError? error;
  var busy = true;

  bool get current =>
      mounted &&
      identical(account.sessionIdentity, session) &&
      account.userFor(widget.discuz)?.uid == widget.user.uid;

  @override
  void initState() {
    super.initState();
    account = context.read<DiscuzAndUserNotifier>();
    session = account.sessionIdentity;
    Future.microtask(load);
  }

  @override
  void dispose() {
    subject.dispose();
    editor.dispose();
    composerFocus.dispose();
    for (final controller in settings.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<T> request<T>(Future<T> Function(PostEditClient) run) async {
    final dio = await NetworkUtils.getDioWithPersistCookieJar(widget.user);
    try {
      if (!current) throw const ForumApiException('account_changed', '');
      return await run(
        PostEditClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.discuz.baseURL)),
          uid: widget.user.uid,
          fid: widget.fid,
          tid: widget.tid,
          pid: widget.pid,
        ),
      );
    } finally {
      dio.close();
    }
  }

  Future<void> load() async {
    if (!current) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final existing = await request((client) => client.load());
      if (!current) return;
      subject.text = existing.subject;
      editor.restoreFileNames(existing.attachments);
      editor.text = existing.text;
      if (form == null) {
        for (final field in existing.settings) {
          settings[field.key] = TextEditingController(text: field.value);
        }
      }
      setState(() => form = existing);
    } catch (failure) {
      if (current)
        setState(() => error = forumRequestError(S.of(context), failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    final original = form;
    if (!current || busy || original == null) return;
    final s = S.of(context);
    if (editor.text.trim().isEmpty ||
        (original.first &&
            original.hasSubject &&
            subject.text.trim().isEmpty)) {
      setState(() => error = DiscuzError('post_edit_empty', s.editPostEmpty));
      return;
    }
    if (removed.isNotEmpty) {
      var confirmed = false;
      await showPlatformAlert(
        context: context,
        title: s.editPostSave,
        message: s.editPostRemoveConfirm(removed.length),
        actions: [
          PlatformAlertAction(label: s.cancel, isCancelAction: true),
          PlatformAlertAction(
            label: s.forumConfirm,
            onPressed: () => confirmed = true,
          ),
        ],
      );
      if (!confirmed || !current || busy) return;
    }
    final title = subject.text;
    final text = PostTextFieldUtils.getPostMessage(editor.text);
    final updates = settings.map(
      (name, control) => MapEntry(name, control.text),
    );
    final newIds = {...added};
    final removeIds = {...removed};
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await request(
        (client) => client.save(
          original: original,
          subject: title,
          text: text,
          settings: updates,
          newAttachments: newIds,
          removeAttachments: removeIds,
          isCurrent: () => current,
        ),
      );
      if (!current) return;
      if (result.moderated) EasyLoading.showInfo(s.editPostModeration);
      Navigator.pop(context, true);
    } catch (failure) {
      if (current) {
        final display = forumRequestError(s, failure, submitted: true);
        setState(() => error = display);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String fieldLabel(S s, String key, int index) {
    if (key.startsWith('polloption[')) return s.editPostPollOption(index + 1);
    return switch (key) {
      'rewardprice' => s.specialRewardAmount,
      'maxchoices' => s.editPostPollMaximum,
      'expiration' => s.editPostPollDays,
      'visibilitypoll' => s.editPostPollVisibility,
      'overt' => s.editPostPollVoterList,
      'tags' => s.forumThreadTagsHint,
      'activityclass' => s.activityCategory,
      'activityplace' => s.activityLocation,
      'starttimefrom[0]' || 'starttimefrom[1]' => s.activityStarts,
      'starttimeto' => s.activityEnds,
      'activityexpiration' => s.activityDeadline,
      'activitynumber' => s.activityCapacity,
      'cost' => s.activityCost,
      'activitycredit' => s.activityCredits,
      'extfield' => s.activityRegistrationFields,
      _ => key,
    };
  }

  bool get cannotRetry => {
    'edit_post_attachment_partial',
    'edit_post_verify',
    'edit_post_changed',
  }.contains(error?.key);

  Future<void> openWebsite() async {
    final uri = PostEditClient.websiteUri(
      Uri.parse(widget.discuz.getBaseURLWithAfterfix()),
      widget.fid,
      widget.tid,
      widget.pid,
    );
    await Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => InternalWebviewBrowserPage(
          widget.discuz,
          widget.user,
          uri.toString(),
        ),
      ),
    );
    if (current) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final existing = form;
    final editable = !busy && !cannotRetry;
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(title: Text(s.editPostTitle)),
      body: !current
          ? Center(child: Text(s.forumAccountChanged))
          : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
                if (error case final failure?)
                  ErrorCard(
                    failure,
                    existing == null ? load : null,
                    largeSize: false,
                  ),
                if (existing != null) ...[
                  if (existing.hasSubject)
                    PlatformTextField(
                      controller: subject,
                      enabled: editable,
                      hintText: s.editPostSubject,
                      maxLength: 80,
                    ),
                  Text(s.editPostPlainText),
                  SizedBox(
                    height: 200,
                    child: AbsorbPointer(
                      absorbing: !editable,
                      child: PostTextField(
                        widget.discuz,
                        editor,
                        focusNode: composerFocus,
                        expanded: true,
                      ),
                    ),
                  ),
                  Wrap(
                    children: [
                      PlatformTextButton(
                        onPressed: editable
                            ? () => uploader.currentState?.pickFile()
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons.attachment),
                            const SizedBox(width: 4),
                            Text(s.selectAttachmentFile),
                          ],
                        ),
                      ),
                      PlatformTextButton(
                        onPressed: editable
                            ? () =>
                                  uploader.currentState?.pickImageFromGallery()
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons.collectionsSolid),
                            const SizedBox(width: 4),
                            Text(s.addAPhoto),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Offstage(
                    child: ExtraFuncInThreadScreen(
                      widget.discuz,
                      widget.tid,
                      widget.fid,
                      key: uploader,
                      showHistoricalAttachment: false,
                      onAttachFile: (aid, name) {
                        if (current) {
                          added.add(aid);
                          editor.insertFile(aid, name);
                        }
                      },
                      onReplyWithImage: (aid, path) {
                        if (current) {
                          added.add(aid);
                          editor.insertAttachment(aid, path);
                        }
                      },
                      onReplyWithHostedImage: (url, path) {
                        if (current) editor.insertHostedImage(url, path);
                      },
                    ),
                  ),
                  if (existing.attachments.isNotEmpty)
                    Text(s.editPostKeepAttachments),
                  for (final item in existing.attachments.entries)
                    PlatformListTile(
                      title: Text(item.value.isEmpty ? item.key : item.value),
                      trailing: Icon(
                        removed.contains(item.key)
                            ? icons.pick(
                                Icons.delete_outline,
                                CupertinoIcons.trash,
                              )
                            : icons.checkMarkCircledSolid,
                      ),
                      onTap: !editable
                          ? null
                          : () => setState(() {
                              if (!removed.add(item.key))
                                removed.remove(item.key);
                            }),
                    ),
                  for (final (index, field) in existing.settings.indexed)
                    if (field.toggle)
                      PlatformListTile(
                        title: Text(fieldLabel(s, field.key, index)),
                        trailing: Icon(
                          settings[field.key]!.text.isEmpty
                              ? icons.pick(
                                  Icons.radio_button_unchecked,
                                  CupertinoIcons.circle,
                                )
                              : icons.checkMarkCircledSolid,
                        ),
                        onTap: !editable
                            ? null
                            : () => setState(() {
                                final control = settings[field.key]!;
                                control.text = control.text.isEmpty ? '1' : '';
                              }),
                      )
                    else ...[
                      Text(fieldLabel(s, field.key, index)),
                      PlatformTextField(
                        controller: settings[field.key],
                        enabled: editable,
                        maxLines: field.key == 'extfield' ? 3 : 1,
                      ),
                    ],
                  PlatformTextButton(
                    onPressed: editable ? save : null,
                    child: Text(s.editPostSave),
                  ),
                ],
                if (busy)
                  const Center(child: PlatformCircularProgressIndicator()),
                PlatformTextButton(
                  onPressed: busy ? null : openWebsite,
                  child: Text(s.editPostWeb),
                ),
              ],
            ),
    );
  }
}
