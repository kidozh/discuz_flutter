import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/ActivityRegistration.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../client/ForumInteractionClient.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import 'InternalWebviewBrowserPage.dart';

class ActivityRegistrationPage extends StatefulWidget {
  final Discuz discuz;
  final User user;
  final int tid;
  final Future<ForumInteractionClient> Function()? createClient;
  const ActivityRegistrationPage({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    this.createClient,
  });
  @override
  State<ActivityRegistrationPage> createState() =>
      _ActivityRegistrationPageState();
}

class _ActivityRegistrationPageState extends State<ActivityRegistrationPage> {
  ActivityRegistration? spec;
  bool busy = false, contribute = false;
  String? error;
  final values = <String, String>{};
  final message = TextEditingController(),
      amount = TextEditingController(text: '0');
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
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    message.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<ForumReply> fetch(ForumInteractionClient api) async {
    final result = await api.request('viewthread', {'tid': widget.tid});
    result.requireData('special_activity');
    if (discuzInt(result.variables['member_uid']) != widget.user.uid ||
        discuzString(result.variables['formhash']).isEmpty)
      throw const ForumApiException('not_loggedin', '');
    return result;
  }

  Future<void> load() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await fetch(await client());
      if (!mounted || !sameAccount) return;
      setState(() {
        spec = ActivityRegistration.fromJson(
          result.variables['special_activity'],
        );
        values.clear();
        final stored = {
          ...discuzMap(spec!.raw['userfield']),
          ...discuzMap(spec!.raw['extfield']),
        };
        for (final field in spec!.fields) {
          values[field.id] = discuzString(stored[field.id]);
        }
      });
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException && e.message.isNotEmpty
              ? e.message
              : S.of(context).forumLoadFailed,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() async {
    if (busy || spec == null || !sameAccount) return;
    final original = spec!;
    Map<String, dynamic> fields;
    try {
      fields = original.form(
        values,
        message.text,
        contribute ? amount.text : null,
      );
    } catch (_) {
      setState(() => error = S.of(context).activityRequired);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    bool submitted = false;
    try {
      final s = S.of(context);
      bool confirmed = false;
      await showPlatformAlert(
        context: context,
        title: original.button == 'cancel' ? s.cancelActivity : s.joinActivity,
        message: original.button == 'cancel'
            ? s.cancelActivityHint
            : '${s.activityPaymentHint}\n${s.activityCost}: ${original.cost}\n${s.activityCredits}: ${original.creditCost.isEmpty ? '0' : original.creditCost}',
        actions: [
          PlatformAlertAction(label: s.cancel, isCancelAction: true),
          PlatformAlertAction(
            label: s.forumConfirm,
            onPressed: () {
              confirmed = true;
            },
          ),
        ],
      );
      if (!mounted || !confirmed || !sameAccount) return;
      final api = await client();
      final fresh = await fetch(api);
      final current = ActivityRegistration.fromJson(
        fresh.variables['special_activity'],
      );
      if (current.terms != original.terms)
        throw ForumApiException('activity_changed', s.activityChanged);
      if (!mounted || !sameAccount) return;
      submitted = true;
      final result = await api.request(
        'forummisc',
        {'action': 'activityapplies', 'tid': widget.tid},
        body: {...fields, 'formhash': fresh.variables['formhash']},
      );
      result.requireSuccess({
        original.button == 'cancel'
            ? 'activity_cancel_success'
            : 'activity_completion',
      });
      if (mounted && sameAccount) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException && e.message.isNotEmpty
              ? e.message
              : submitted
              ? S.of(context).forumSubmissionUnknown
              : S.of(context).forumLoadFailed,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(ActivityJoinField field) {
    final value = values[field.id] ?? '';
    if (field.type == 'select' || field.type == 'radio')
      return DropdownButton<String>(
        value: field.choices.contains(value) ? value : null,
        hint: Text(field.title),
        isExpanded: true,
        items: field.choices
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: busy
            ? null
            : (v) => setState(() => values[field.id] = v ?? ''),
      );
    if (field.type == 'checkbox')
      return Column(
        children: field.choices
            .map(
              (s) => CheckboxListTile(
                title: Text(s),
                value: value.split(',').contains(s),
                onChanged: busy
                    ? null
                    : (selected) {
                        final items = value
                            .split(',')
                            .where((s) => s.isNotEmpty)
                            .toSet();
                        selected == true ? items.add(s) : items.remove(s);
                        setState(() => values[field.id] = items.join(','));
                      },
              ),
            )
            .toList(),
      );
    return TextFormField(
      key: ValueKey('${spec.hashCode}:${field.id}'),
      initialValue: value,
      enabled: !busy,
      maxLines: field.type == 'textarea' ? 3 : 1,
      decoration: InputDecoration(labelText: field.title),
      onChanged: (v) => values[field.id] = v,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context), current = spec;
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.activityRegistration)),
      body: Material(
        type: MaterialType.transparency,
        child: !sameAccount
            ? Center(child: Text(s.forumAccountChanged))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null) Text(error!),
                    if (current != null) ...[
                      Text('${s.activityCost}: ${current.cost}'),
                      if (current.creditCost.isNotEmpty)
                        Text('${s.activityCredits}: ${current.creditCost}'),
                      if ((current.supported || current.button == 'cancel') &&
                          !current.closed &&
                          {'join', 'cancel'}.contains(current.button)) ...[
                        if (current.button == 'join') ...[
                          for (final f in current.fields) ...[
                            Text('${f.title} *'),
                            field(f),
                            const SizedBox(height: 8),
                          ],
                          SwitchListTile(
                            title: Text(s.activityContribute),
                            subtitle: Text(s.activitySelfPay),
                            value: contribute,
                            onChanged: busy
                                ? null
                                : (v) => setState(() => contribute = v),
                          ),
                          if (contribute)
                            PlatformTextField(
                              controller: amount,
                              keyboardType: TextInputType.number,
                            ),
                        ],
                        PlatformTextField(
                          controller: message,
                          hintText: s.activityMessage,
                          maxLines: 3,
                        ),
                        PlatformTextButton(
                          onPressed: busy ? null : submit,
                          child: Text(
                            busy
                                ? s.forumWorking
                                : current.button == 'cancel'
                                ? s.cancelActivity
                                : s.joinActivity,
                          ),
                        ),
                      ] else
                        Text(s.activityWebsiteRequired),
                      PlatformTextButton(
                        onPressed: () => Navigator.push(
                          context,
                          platformPageRoute(
                            context: context,
                            builder: (_) => InternalWebviewBrowserPage(
                              widget.discuz,
                              widget.user,
                              '${widget.discuz.baseURL}/forum.php?mod=viewthread&tid=${widget.tid}',
                            ),
                          ),
                        ),
                        child: Text(s.specialOpenWebsite),
                      ),
                    ],
                    PlatformTextButton(
                      onPressed: busy ? null : load,
                      child: Text(busy ? s.forumWorking : s.forumRefresh),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
