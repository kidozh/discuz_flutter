import 'package:dio/dio.dart' show MultipartFile;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_settings_forms.dart';
import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import 'InternalWebviewBrowserPage.dart';

Future<bool?> openForumSettingsForm(
  BuildContext context,
  Discuz forum,
  ForumSettingsKind kind, {
  int fid = 0,
}) => pushDetailPage<bool>(
  context,
  platformPageRoute(
    context: context,
    builder: (_) => ForumSettingsFormPage(forum, kind, fid: fid),
  ),
);

class ForumSettingsFormPage extends StatefulWidget {
  const ForumSettingsFormPage(this.forum, this.kind, {super.key, this.fid = 0});

  final Discuz forum;
  final ForumSettingsKind kind;
  final int fid;

  @override
  State<ForumSettingsFormPage> createState() => _ForumSettingsFormPageState();
}

class _ForumSettingsFormPageState extends State<ForumSettingsFormPage> {
  late final account = context.read<DiscuzAndUserNotifier>();
  late final user = account.userFor(widget.forum);
  late final session = account.sessionIdentity;
  final inputs = <String, TextEditingController>{};
  final selected = <int>{};
  final friendsQuery = TextEditingController();
  ForumSettingsForm? form;
  XFile? icon;
  Object? failure;
  String tab = 'base';
  bool busy = true, submitted = false;
  int readGeneration = 0;

  bool get current => mounted && identical(session, account.sessionIdentity);
  bool get invite => widget.kind == ForumSettingsKind.invite;

  @override
  void initState() {
    super.initState();
    final _ = session;
    Future.microtask(load);
  }

  @override
  void dispose() {
    for (final controller in inputs.values) {
      controller.dispose();
    }
    friendsQuery.dispose();
    super.dispose();
  }

  Future<T> request<T>(Future<T> Function(ForumSettingsClient) action) async {
    final member = user;
    if (!current || member == null)
      throw const ForumApiException('not_loggedin', '', fromForum: true);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(member);
    try {
      if (!current)
        throw const ForumApiException('account_changed', '', fromForum: true);
      return await action(
        ForumSettingsClient(
          DiscuzWebClient(ForumInteractionClient(dio, widget.forum.baseURL)),
          member.uid,
        ),
      );
    } finally {
      dio.close();
    }
  }

  Future<void> load() async {
    if (!current) return;
    final ticket = ++readGeneration;
    final selection = tab;
    setState(() {
      busy = true;
      failure = null;
      submitted = false;
    });
    try {
      final (result, activeTab) = await request((client) async {
        final data = await client.load(widget.kind, widget.fid, selection);
        if (data.tabs.isEmpty || data.tabs.containsKey(selection))
          return (data, selection);
        final first = data.tabs.keys.first;
        return (await client.load(widget.kind, widget.fid, first), first);
      });
      if (!current || ticket != readGeneration) return;
      setState(() {
        form = result;
        tab = activeTab;
        for (final field in result.fields) {
          inputs.putIfAbsent(field.name, TextEditingController.new).text =
              field.value;
        }
      });
    } catch (error) {
      if (current && ticket == readGeneration) setState(() => failure = error);
    } finally {
      if (current && ticket == readGeneration) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    final original = form;
    if (!current || busy || original == null) return;
    final changes = <String, String>{
      for (final field in original.fields)
        if (inputs[field.name]!.text != field.value)
          field.name: inputs[field.name]!.text,
    };
    final photo = icon;
    if (changes.isEmpty && selected.isEmpty && photo == null) return;
    final s = S.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      final upload = photo == null
          ? null
          : MultipartFile.fromBytes(
              await photo.readAsBytes(),
              filename: photo.name,
            );
      if (!current) return;
      submitted = true;
      await request(
        (client) => client.save(
          widget.kind,
          widget.fid,
          tab,
          original,
          changes,
          icon: upload,
          invites: {...selected},
          isCurrent: () => current,
        ),
      );
      if (!mounted || !current) return;
      EasyLoading.showSuccess(s.forumSettingsSaved);
      Navigator.pop(context, true);
    } catch (error) {
      if (current) setState(() => failure = error);
    } finally {
      if (current) setState(() => busy = false);
    }
  }

  Future<void> website() async {
    final uri = ForumSettingsClient.website(
      Uri.parse(widget.forum.getBaseURLWithAfterfix()),
      widget.kind,
      widget.fid,
      tab,
    );
    await pushDetailPage<void>(
      context,
      platformPageRoute(
        context: context,
        builder: (_) =>
            InternalWebviewBrowserPage(widget.forum, user, uri.toString()),
      ),
    );
    if (current) await load();
  }

  Future<String?> choose(
    String title,
    Map<String, String> entries,
    String value,
  ) => showPlatformModalSheet<String>(
    context: context,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(sheet).textTheme.titleMedium),
          ),
          for (final entry in entries.entries)
            PlatformListTile(
              title: Text(entry.value),
              trailing: entry.key == value
                  ? Icon(PlatformIcons(sheet).checkMark)
                  : null,
              onTap: () => Navigator.pop(sheet, entry.key),
            ),
        ],
      ),
    ),
  );

  Future<void> pickIcon() async {
    try {
      final result = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (result != null && current) setState(() => icon = result);
    } catch (error) {
      if (current) setState(() => failure = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final icons = PlatformIcons(context);
    final existing = form;
    final profile = widget.kind == ForumSettingsKind.profile;
    final defaultSections = Map.fromIterables(ForumSettingsClient.profileTabs, [
      s.forumProfileBasic,
      s.forumProfileContact,
      s.forumProfileEducation,
      s.forumProfileWork,
      s.forumProfileOther,
    ]);
    final sections = existing == null || existing.tabs.isEmpty
        ? defaultSections
        : {
            for (final item in existing.tabs.entries)
              item.key: item.value.isEmpty
                  ? defaultSections[item.key]!
                  : item.value,
          };
    final title = switch (widget.kind) {
      ForumSettingsKind.profile => s.forumEditProfile,
      ForumSettingsKind.group => s.communityManageGroup,
      ForumSettingsKind.invite => s.forumInviteFriends,
    };
    final query = friendsQuery.text.trim().toLowerCase();
    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      appBar: PlatformAppBar(
        title: Text(title),
        trailingActions: [
          PlatformIconButton(
            liquidGlassSymbol: 'safari',
            icon: Icon(
              icons.pick(Icons.open_in_browser, CupertinoIcons.compass),
              semanticLabel: s.navigateToWebPage,
            ),
            onPressed: !current || busy ? null : website,
          ),
        ],
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: !current
            ? Center(child: Text(s.forumAccountChanged))
            : ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                children: [
                  if (profile)
                    PlatformListTile(
                      title: Text(sections[tab]!),
                      trailing: Icon(icons.forward, size: 16),
                      onTap: busy
                          ? null
                          : () async {
                              final choice = await choose(title, sections, tab);
                              if (choice == null || choice == tab || !current)
                                return;
                              setState(() {
                                tab = choice;
                                form = null;
                              });
                              await load();
                            },
                    ),
                  if (failure case final error?)
                    ErrorCard(
                      forumRequestError(s, error, submitted: submitted),
                      existing == null ? load : null,
                      largeSize: false,
                    ),
                  if (existing != null) ...[
                    if (invite) ...[
                      PlatformTextField(
                        controller: friendsQuery,
                        enabled: !busy,
                        hintText: s.communityFindUsers,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (existing.friends.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(s.forumEmpty),
                        ),
                      for (final friend in existing.friends.entries)
                        if (friend.value.toLowerCase().contains(query))
                          PlatformListTile(
                            title: Text(friend.value),
                            selected: selected.contains(friend.key),
                            trailing: selected.contains(friend.key)
                                ? Icon(icons.checkMark)
                                : null,
                            onTap:
                                busy ||
                                    (selected.length >= 20 &&
                                        !selected.contains(friend.key))
                                ? null
                                : () => setState(() {
                                    if (!selected.add(friend.key))
                                      selected.remove(friend.key);
                                  }),
                          ),
                    ],
                    if (existing.fields.isNotEmpty || existing.canUploadIcon)
                      PlatformCard(
                        semanticContainer: false,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            for (final field in existing.fields)
                              if (field.choices.isEmpty) ...[
                                Text(
                                  field.label,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                PlatformTextField(
                                  controller: inputs[field.name],
                                  enabled: !busy,
                                  maxLines: field.multiline ? 4 : 1,
                                  inputFormatters: [
                                    if (field.maxLength case final length?
                                        when length > 0)
                                      LengthLimitingTextInputFormatter(length),
                                  ],
                                ),
                              ] else
                                PlatformListTile(
                                  title: Text(field.label),
                                  subtitle: Text(
                                    field.choices[inputs[field.name]!.text] ??
                                        inputs[field.name]!.text,
                                  ),
                                  trailing: Icon(icons.forward, size: 16),
                                  onTap: busy
                                      ? null
                                      : () async {
                                          final choices =
                                              Map<String, String>.of(
                                                field.choices,
                                              );
                                          if (field.name == 'jointypenew' &&
                                              field.value != '-1')
                                            choices.remove('-1');
                                          final value = await choose(
                                            field.label,
                                            choices,
                                            inputs[field.name]!.text,
                                          );
                                          if (value != null && current)
                                            setState(
                                              () => inputs[field.name]!.text =
                                                  value,
                                            );
                                        },
                                ),
                            if (existing.canUploadIcon)
                              PlatformListTile(
                                title: Text(s.forumGroupChangeIcon),
                                subtitle: icon == null
                                    ? null
                                    : Text(icon!.name),
                                trailing: Icon(
                                  icons.pick(
                                    Icons.photo_outlined,
                                    CupertinoIcons.photo,
                                  ),
                                ),
                                onTap: busy ? null : pickIcon,
                              ),
                          ],
                        ),
                      ),
                    if (!invite &&
                        existing.fields.isEmpty &&
                        !existing.canUploadIcon)
                      Center(child: Text(s.forumEmpty)),
                    PlatformTextButton(
                      onPressed: busy || (invite && selected.isEmpty)
                          ? null
                          : save,
                      child: Text(
                        invite
                            ? '${s.forumInviteFriends} (${selected.length}/20)'
                            : s.editPostSave,
                      ),
                    ),
                  ],
                  if (busy)
                    const Center(child: PlatformCircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
