import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:provider/provider.dart';

import '../JsonResult/ViewThreadResult.dart';
import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/poll_voters.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import '../widget/post_settings_sheet.dart';
import 'UserProfilePage.dart';

Future<PollVoterBatch> readPollVoters(
  Discuz forum,
  User? user,
  int tid,
  int option,
  int page,
) async {
  final dio = await NetworkUtils.getDioWithPersistCookieJar(
    user,
    guestForum: forum.baseURL,
  );
  try {
    return await PollVotersClient(
      DiscuzWebClient(ForumInteractionClient(dio, forum.baseURL)),
    ).load(tid, option, page);
  } finally {
    dio.close();
  }
}

class PollVotersPage extends StatefulWidget {
  const PollVotersPage({
    super.key,
    required this.forum,
    required this.user,
    required this.tid,
    required this.options,
    required this.initial,
    required this.session,
  });

  final Discuz forum;
  final User? user;
  final int tid;
  final List<PollOption> options;
  final PollVoterBatch initial;
  final Object session;

  @override
  State<PollVotersPage> createState() => _PollVotersPageState();
}

class _PollVotersPageState extends State<PollVotersPage> {
  final controller = EasyRefreshController();
  late final account = context.read<DiscuzAndUserNotifier>();
  late var option = widget.options.first;
  late var voters = widget.initial.voters;
  late var next = widget.initial.next;
  DiscuzError? error;
  int request = 0;
  bool busy = false;

  bool get current =>
      mounted && identical(account.sessionIdentity, widget.session);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> load({bool more = false}) async {
    if (!current || (busy && more)) return IndicatorResult.fail;
    final page = more ? next : 1;
    if (page == null) return IndicatorResult.noMore;
    final ticket = ++request;
    final id = option.id;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final batch = await readPollVoters(
        widget.forum,
        widget.user,
        widget.tid,
        id,
        page,
      );
      if (!current || ticket != request) return IndicatorResult.fail;
      setState(() {
        voters = {
          if (more)
            for (final voter in voters) voter.uid: voter,
          for (final voter in batch.voters) voter.uid: voter,
        }.values.toList();
        next = batch.next;
      });
      if (!more) controller.resetFooter();
      return batch.next == null && more
          ? IndicatorResult.noMore
          : IndicatorResult.success;
    } catch (failure) {
      if (current && ticket == request) {
        setState(() => error = forumRequestError(S.of(context), failure));
      }
      return IndicatorResult.fail;
    } finally {
      if (mounted && ticket == request) setState(() => busy = false);
    }
  }

  String label(PollOption item) => parseFragment(item.name).text ?? item.name;

  Future<void> choose() async {
    final item = await showPostSettingsSheet<PollOption>(
      context,
      (sheet) => PostSettingsSheet(
        title: S.of(sheet).pollTitle,
        children: [
          for (final item in widget.options)
            PlatformListTile(
              title: Text(label(item)),
              trailing: item.id == option.id
                  ? Icon(PlatformIcons(sheet).checkMark)
                  : null,
              onTap: () => Navigator.pop(sheet, item),
            ),
        ],
      ),
    );
    if (!current || item == null || item.id == option.id) return;
    setState(() {
      option = item;
      voters = [];
      next = null;
    });
    await load();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(s.pollVoterList)),
      body: PlatformLiquidGlassPageBackdrop(
        child: !current
            ? Center(child: Text(s.forumAccountChanged))
            : Column(
                children: [
                  PlatformListTile(
                    title: Text(label(option)),
                    trailing: Icon(PlatformIcons(context).downArrow),
                    onTap: choose,
                  ),
                  Expanded(
                    child: EasyRefresh(
                      controller: controller,
                      header: EasyRefreshUtils.i18nClassicHeader(context),
                      footer: EasyRefreshUtils.i18nClassicFooter(context),
                      onRefresh: load,
                      onLoad: () => load(more: true),
                      child: ListView(
                        children: [
                          if (error case final failure?)
                            ErrorCard(failure, load, largeSize: false),
                          if (voters.isEmpty && error == null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: busy
                                    ? const PlatformCircularProgressIndicator()
                                    : Text(s.forumEmpty),
                              ),
                            ),
                          for (final voter in voters)
                            PlatformListTile(
                              title: Text(voter.name),
                              trailing: Icon(PlatformIcons(context).forward),
                              onTap: () => pushDetailPage(
                                context,
                                platformPageRoute(
                                  context: context,
                                  builder: (_) => UserProfilePage(
                                    widget.forum,
                                    widget.user,
                                    voter.uid,
                                    username: voter.name,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
