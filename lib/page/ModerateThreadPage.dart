import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';

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
  };
  final operation = operations[action];
  if (operation == null ||
      reason.trim().isEmpty ||
      (action == 'move' && (destination == null || destination <= 0)))
    throw const FormatException('Invalid moderation');
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
  };
}

class ModerateThreadPage extends StatefulWidget {
  final Discuz discuz;
  final User user;
  final int tid;
  final Future<ForumInteractionClient> Function()? createClient;
  const ModerateThreadPage({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    this.createClient,
  });
  @override
  State<ModerateThreadPage> createState() => _ModerateThreadPageState();
}

class _ModerateThreadPageState extends State<ModerateThreadPage> {
  String action = 'stick', type = '0';
  int? destination;
  bool busy = false, typeRequired = false;
  String? error;
  List<Map<String, dynamic>> forums = [];
  Map<String, dynamic> types = {};
  final reason = TextEditingController();
  bool get sameAccount {
    final account = context.read<DiscuzAndUserNotifier>();
    return account.user == widget.user &&
        account.user?.auth == widget.user.auth &&
        account.discuz?.baseURL == widget.discuz.baseURL;
  }

  Future<ForumInteractionClient> client() async => widget.createClient != null
      ? await widget.createClient!()
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
    try {
      final response = await (await client()).request('forumindex', {});
      response.requireData('forumlist');
      if (mounted && sameAccount)
        setState(
          () => forums = forumRows(
            response.variables['forumlist'],
          ).map(discuzMap).where((f) => discuzInt(f['fid']) > 0).toList(),
        );
    } catch (_) {
      if (mounted) setState(() => error = S.of(context).forumLoadFailed);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> selectDestination(int? fid) async {
    setState(() {
      destination = null;
      types = {};
      type = '0';
      busy = true;
      error = null;
    });
    try {
      final response = await (await client()).request('forumdisplay', {
        'fid': fid,
      });
      response.requireData('forum');
      final threadTypes = discuzMap(response.variables['threadtypes']);
      if (mounted && sameAccount)
        setState(() {
          destination = fid;
          types = discuzMap(threadTypes['types']);
          typeRequired = discuzPermission(threadTypes['required']) == true;
          if (typeRequired && types.isNotEmpty) type = types.keys.first;
        });
    } catch (_) {
      if (mounted) setState(() => error = S.of(context).forumLoadFailed);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit(String label) async {
    if (busy || !sameAccount) return;
    Map<String, dynamic> fields;
    try {
      fields = moderationFields(
        action,
        reason.text,
        destination: destination,
        type: type,
      );
    } catch (_) {
      setState(() => error = S.of(context).moderationRequired);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    bool submitted = false;
    try {
      bool confirmed = false;
      await showPlatformAlert(
        context: context,
        title: label,
        message: reason.text,
        actions: [
          PlatformAlertAction(
            label: S.of(context).cancel,
            isCancelAction: true,
          ),
          PlatformAlertAction(
            label: S.of(context).forumConfirm,
            onPressed: () {
              confirmed = true;
            },
          ),
        ],
      );
      if (!mounted || !confirmed || !sameAccount) return;
      final api = await client();
      final current = await api.request('viewthread', {'tid': widget.tid});
      current.requireData('thread');
      if (discuzInt(current.variables['member_uid']) != widget.user.uid ||
          !(discuzPermission(current.variables['ismoderator']) == true ||
              discuzInt(current.variables['ismoderator']) > 0) ||
          discuzString(current.variables['formhash']).isEmpty)
        throw const ForumApiException('no_privilege', '');
      if (!mounted || !sameAccount) return;
      submitted = true;
      final result = await api.request(
        'topicadmin',
        {
          'action': 'moderate',
          'tid': widget.tid,
          'fid': discuzInt(current.variables['fid']),
        },
        body: {...fields, 'formhash': current.variables['formhash']},
      );
      result.requireSuccess({'admin_succeed'});
      if (mounted && sameAccount) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException
              ? (e.message.isEmpty ? e.code : e.message)
              : submitted
              ? S.of(context).forumSubmissionUnknown
              : S.of(context).forumLoadFailed,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    final actions = {
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
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.moderateThread)),
      body: Material(
        type: MaterialType.transparency,
        child: !sameAccount
            ? Center(child: Text(s.forumAccountChanged))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButton<String>(
                      value: action,
                      isExpanded: true,
                      items: actions.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: busy
                          ? null
                          : (value) {
                              setState(() => action = value!);
                              if (value == 'move' && forums.isEmpty)
                                loadForums();
                            },
                    ),
                    if (action == 'move') ...[
                      Text(s.moveDestination),
                      DropdownButton<int>(
                        value: destination,
                        isExpanded: true,
                        items: forums
                            .map(
                              (f) => DropdownMenuItem(
                                value: discuzInt(f['fid']),
                                child: Text(discuzString(f['name'])),
                              ),
                            )
                            .toList(),
                        onChanged: busy ? null : selectDestination,
                      ),
                      if (forums.isEmpty)
                        PlatformTextButton(
                          onPressed: busy ? null : loadForums,
                          child: Text(s.retry),
                        ),
                      if (types.isNotEmpty)
                        DropdownButton<String>(
                          value: type,
                          isExpanded: true,
                          items: [
                            if (!typeRequired)
                              DropdownMenuItem(
                                value: '0',
                                child: Text(s.directoryNoType),
                              ),
                            ...types.entries
                                .where((e) => e.key != '0')
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(discuzString(e.value)),
                                  ),
                                ),
                          ],
                          onChanged: busy
                              ? null
                              : (v) => setState(() => type = v!),
                        ),
                    ],
                    PlatformTextField(
                      controller: reason,
                      hintText: s.moderationReason,
                      maxLines: 3,
                    ),
                    if (error != null) Text(error!),
                    PlatformTextButton(
                      onPressed: busy ? null : () => submit(actions[action]!),
                      child: Text(busy ? s.forumWorking : s.forumConfirm),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
