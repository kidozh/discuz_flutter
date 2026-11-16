import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/discuz_json.dart';
import '../utility/forum_error.dart';
import '../utility/forum_navigation.dart';
import '../widget/ErrorCard.dart';
import 'PostThreadPage.dart';

class ForumBoardPickerPage extends StatefulWidget {
  const ForumBoardPickerPage(this.discuz, {super.key});
  final Discuz discuz;

  @override
  State<ForumBoardPickerPage> createState() => _ForumBoardPickerState();
}

class _ForumBoardPickerState extends State<ForumBoardPickerPage> {
  List<Map<String, dynamic>>? boards;
  DiscuzError? error;
  Object? _session;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    _session = session;
    final user = account.userFor(widget.discuz);
    if (user == null) return;
    bool isCurrent() => mounted && identical(session, account.sessionIdentity);
    setState(() => error = null);
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      try {
        final result = await loadForumNavigation(
          ForumInteractionClient(dio, widget.discuz.baseURL),
        );
        if (isCurrent()) setState(() => boards = result);
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (isCurrent()) {
        setState(() => error = forumRequestError(S.of(context), failure));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final items = boards;
    final account = context.watch<DiscuzAndUserNotifier>();
    final user = account.userFor(widget.discuz);
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(strings.choosePostingForum)),
      body: switch (error) {
        _ when user == null => Center(child: Text(strings.forumSignInRequired)),
        _ when !identical(_session, account.sessionIdentity) => Center(
          child: PlatformTextButton(
            onPressed: load,
            child: Text(strings.refresh),
          ),
        ),
        final failure? => ErrorCard(failure, load, largeSize: false),
        _ when items == null => const Center(
          child: PlatformCircularProgressIndicator(),
        ),
        _ when items.isEmpty => Center(child: Text(strings.forumEmpty)),
        _ => ListView(
          children: [
            for (final board in items)
              PlatformListTile(
                title: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.0 * discuzInt(board['depth']).clamp(0, 5),
                  ),
                  child: Text(discuzString(board['name'])),
                ),
                onTap: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => PostThreadPage(
                      widget.discuz,
                      discuzInt(board['fid']),
                      0,
                      navigationTypes: discuzMap(board['threadtypes']),
                    ),
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }
}
