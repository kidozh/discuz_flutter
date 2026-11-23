import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import '../utility/forum_error.dart';
import '../utility/forum_navigation.dart';
import '../widget/ErrorCard.dart';
import '../widget/post_settings_sheet.dart';

Map<String, dynamic> moderationFields(
  String action,
  String reason, {
  int? destination,
  String type = '0',
}) {
  final operations = {
    'stick': 'stick',
    'unstick': 'stick',
    'digest': 'digest',
    'undigest': 'digest',
    'close': 'close',
    'open': 'open',
    'move': 'move',
    'highlight': 'highlight',
    'unhighlight': 'highlight',
    'type': 'type',
  };
  final operation = operations[action];
  if (operation == null ||
      reason.trim().isEmpty ||
      (action == 'move' && (destination == null || destination <= 0)) ||
      (action == 'type' && (int.tryParse(type) ?? -1) < 0)) {
    throw const FormatException('Invalid moderation');
  }
  return {
    'operations[]': operation,
    'modsubmit': 'yes',
    'reason': reason.trim(),
    if (operation == 'stick') 'sticklevel': action == 'stick' ? '1' : '0',
    if (operation == 'digest') 'digestlevel': action == 'digest' ? '1' : '0',
    if (operation == 'highlight') ...{
      'highlight_color': action == 'highlight' ? '1' : '0',
      'highlight_style[1]': action == 'highlight' ? '1' : '0',
    },
    if (action == 'move') ...{'moveto': '$destination', 'threadtypeid': type},
    if (action == 'type') 'typeid': type,
  };
}

Future<({int fid, String hash})> loadModerationScope(
  ForumInteractionClient api, {
  required int tid,
  required int uid,
  int? expectedForum,
}) async {
  final current = await api.request('viewthread', {'tid': tid});
  current.requireData('thread');
  final variables = current.variables;
  final fid = discuzInt(variables['fid']);
  final hash = discuzString(variables['formhash']);
  if (discuzInt(variables['member_uid']) != uid ||
      (discuzPermission(variables['ismoderator']) != true &&
          discuzInt(variables['ismoderator']) <= 0) ||
      hash.isEmpty ||
      fid <= 0 ||
      (expectedForum != null &&
          (expectedForum != fid ||
              discuzInt(discuzMap(variables['thread'])['tid']) != tid))) {
    throw const ForumApiException('no_privilege', '');
  }
  return (fid: fid, hash: hash);
}

class ModerateThreadPage extends StatefulWidget {
  final Discuz discuz;
  final User user;
  final int tid;
  final int? boardId;
  final List<int> batchIds;
  final Map<String, String> boardTypes;
  final bool boardTypeRequired;
  final Future<ForumInteractionClient> Function()? createClient;

  const ModerateThreadPage({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    this.createClient,
  }) : boardId = null,
       batchIds = const [],
       boardTypes = const {},
       boardTypeRequired = false;

  const ModerateThreadPage.batch({
    super.key,
    required this.discuz,
    required this.user,
    required int boardId,
    required this.batchIds,
    required this.boardTypes,
    required this.boardTypeRequired,
    this.createClient,
  }) : boardId = boardId,
       tid = 0;

  @override
  State<ModerateThreadPage> createState() => _ModerateThreadPageState();
}

class _ModerateThreadPageState extends State<ModerateThreadPage> {
  bool get batch => widget.boardId != null;
  late String action = batch ? 'close' : 'stick';
  String type = '0';
  int? destination;
  bool busy = false;
  late bool typeRequired = widget.boardTypeRequired;
  DiscuzError? error;
  List<Map<String, dynamic>> forums = [];
  late Map<String, dynamic> types = widget.boardTypes;
  final reason = TextEditingController();

  bool get sameAccount {
    final account = context.read<DiscuzAndUserNotifier>();
    return account.user == widget.user &&
        account.user?.auth == widget.user.auth &&
        widget.discuz.isSameSite(account.discuz);
  }

  Future<ForumInteractionClient> client() async => widget.createClient != null
      ? widget.createClient!()
      : ForumInteractionClient(
          await NetworkUtils.getDioWithPersistCookieJar(widget.user),
          widget.discuz.baseURL,
        );

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> loadForums() async {
    setState(() {
      busy = true;
      error = null;
    });
    ForumInteractionClient? api;
    try {
      api = await client();
      final result = await loadForumNavigation(api);
      if (mounted && sameAccount) setState(() => forums = result);
    } catch (e) {
      if (mounted && sameAccount) {
        setState(() => error = forumRequestError(S.of(context), e));
      }
    } finally {
      if (widget.createClient == null) api?.dio.close();
      if (mounted) setState(() => busy = false);
    }
  }

  void _selectDestination(int fid) {
    final row = forums.where((row) => discuzInt(row['fid']) == fid).firstOrNull;
    final threadTypes = discuzMap(row?['threadtypes']);
    setState(() {
      destination = fid;
      types = discuzMap(threadTypes['types']);
      typeRequired = discuzPermission(threadTypes['required']) == true;
      type = typeRequired
          ? types.keys.where((key) => key != '0').firstOrNull ?? '0'
          : '0';
      error = null;
    });
  }

  Future<void> submit(String label) async {
    if (busy || !sameAccount) return;
    final s = S.of(context);
    final ids = (batch ? widget.batchIds : [widget.tid]).toSet();
    Map<String, dynamic> fields;
    try {
      if ((action == 'type' || action == 'move') &&
          typeRequired &&
          (type == '0' || !types.containsKey(type))) {
        throw const FormatException('Missing thread type');
      }
      fields = moderationFields(
        action,
        reason.text,
        destination: destination,
        type: type,
      );
    } catch (_) {
      setState(
        () => error = DiscuzError('moderation_required', s.moderationRequired),
      );
      return;
    }
    if (ids.isEmpty || ids.any((id) => id <= 0)) return;
    setState(() {
      busy = true;
      error = null;
    });
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    bool current() =>
        mounted && sameAccount && identical(session, account.sessionIdentity);
    bool submitted = false;
    ForumInteractionClient? api;
    try {
      var confirmed = false;
      await showPlatformAlert(
        context: context,
        title: label,
        message: batch
            ? '${s.modSelected(ids.length)}\n${reason.text.trim()}'
            : reason.text.trim(),
        actions: [
          PlatformAlertAction(label: s.cancel, isCancelAction: true),
          PlatformAlertAction(
            label: s.forumConfirm,
            onPressed: () => confirmed = true,
          ),
        ],
      );
      if (!confirmed || !current()) return;
      final activeApi = api = await client();
      late ({int fid, String hash}) target;
      for (final tid in ids) {
        if (!current()) return;
        target = await loadModerationScope(
          activeApi,
          tid: tid,
          uid: widget.user.uid,
          expectedForum: widget.boardId,
        );
      }
      if (!current()) return;
      submitted = true;
      final result = await activeApi.request(
        'topicadmin',
        {
          'action': 'moderate',
          if (!batch) 'tid': widget.tid,
          'fid': target.fid,
        },
        body: {
          ...fields,
          if (batch) 'moderate[]': ids.toList(),
          'formhash': target.hash,
        },
      );
      result.requireSuccess({'admin_succeed'});
      if (current()) Navigator.pop(context, true);
    } catch (e) {
      if (current()) {
        setState(
          () =>
              error = forumRequestError(S.of(context), e, submitted: submitted),
        );
      }
    } finally {
      if (widget.createClient == null) api?.dio.close();
      if (mounted) setState(() => busy = false);
    }
  }

  Future<T?> _choose<T>(String label, Map<T, String> options, T? value) =>
      showPostSettingsSheet<T>(
        context,
        (sheet) => PostSettingsSheet(
          title: label,
          children: [
            for (final entry in options.entries)
              PlatformListTile(
                title: Text(entry.value),
                trailing: entry.key == value
                    ? Icon(PlatformIcons(sheet).checkMark)
                    : null,
                onTap: () => Navigator.pop(sheet, entry.key),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final actions = batch
        ? {
            'close': s.modClose,
            'unstick': s.modUnstick,
            if (widget.boardTypes.isNotEmpty) 'type': s.modChangeType,
          }
        : {
            'stick': s.modStick,
            'unstick': s.modUnstick,
            'digest': s.modDigest,
            'undigest': s.modUndigest,
            'close': s.modClose,
            'open': s.modOpen,
            'move': s.modMove,
            'highlight': s.modHighlight,
            'unhighlight': s.modUnhighlight,
          };
    final typeOptions = {
      if (!typeRequired) '0': s.directoryNoType,
      for (final entry in types.entries)
        if (entry.key != '0') entry.key: discuzString(entry.value),
    };
    final boardOptions = {
      for (final row in forums)
        discuzInt(row['fid']): discuzString(row['name']),
    };
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(batch ? s.batchModeration : s.moderateThread),
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: !sameAccount
            ? Center(child: Text(s.forumAccountChanged))
            : ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  if (batch)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(s.modSelected(widget.batchIds.length)),
                    ),
                  PlatformCard(
                    child: Column(
                      children: [
                        PlatformListTile(
                          title: Text(s.modAction),
                          subtitle: Text(actions[action]!),
                          trailing: Icon(PlatformIcons(context).forward),
                          onTap: busy
                              ? null
                              : () async {
                                  final selected = await _choose(
                                    s.modAction,
                                    actions,
                                    action,
                                  );
                                  if (!mounted ||
                                      selected == null ||
                                      !sameAccount)
                                    return;
                                  setState(() {
                                    action = selected;
                                    if (selected == 'type' &&
                                        typeRequired &&
                                        type == '0') {
                                      type =
                                          typeOptions.keys.firstOrNull ?? '0';
                                    }
                                  });
                                  if (action == 'move' && forums.isEmpty)
                                    await loadForums();
                                },
                        ),
                        if (action == 'move')
                          PlatformListTile(
                            title: Text(s.moveDestination),
                            subtitle: destination == null
                                ? null
                                : Text(boardOptions[destination] ?? ''),
                            trailing: Icon(PlatformIcons(context).forward),
                            onTap: busy
                                ? null
                                : () async {
                                    if (forums.isEmpty) await loadForums();
                                    if (!mounted ||
                                        !sameAccount ||
                                        forums.isEmpty)
                                      return;
                                    final options = {
                                      for (final row in forums)
                                        discuzInt(row['fid']): discuzString(
                                          row['name'],
                                        ),
                                    };
                                    final selected = await _choose(
                                      s.moveDestination,
                                      options,
                                      destination,
                                    );
                                    if (mounted &&
                                        sameAccount &&
                                        selected != null)
                                      _selectDestination(selected);
                                  },
                          ),
                        if (action == 'type' ||
                            (action == 'move' && types.isNotEmpty))
                          PlatformListTile(
                            title: Text(s.forumFilterTypeIdTitle),
                            subtitle: Text(typeOptions[type] ?? ''),
                            trailing: Icon(PlatformIcons(context).forward),
                            onTap: busy
                                ? null
                                : () async {
                                    final selected = await _choose(
                                      s.forumFilterTypeIdTitle,
                                      typeOptions,
                                      type,
                                    );
                                    if (mounted &&
                                        sameAccount &&
                                        selected != null) {
                                      setState(() => type = selected);
                                    }
                                  },
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PlatformTextField(
                      controller: reason,
                      hintText: s.moderationReason,
                      maxLines: 3,
                    ),
                  ),
                  if (error case final failure?)
                    ErrorCard(failure, null, largeSize: false),
                  PlatformElevatedButton(
                    onPressed: busy ? null : () => submit(actions[action]!),
                    child: Text(busy ? s.forumWorking : s.forumConfirm),
                  ),
                ],
              ),
      ),
    );
  }
}
