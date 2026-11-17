import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/forum_guide.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/ErrorCard.dart';
import 'ForumListsPage.dart';
import 'InternalWebviewBrowserPage.dart';

class ForumGuidePage extends StatefulWidget {
  const ForumGuidePage(this.discuz, {this.createClient, super.key});
  final Discuz discuz;
  final Future<ForumInteractionClient> Function()? createClient;
  @override
  State<ForumGuidePage> createState() => _ForumGuidePageState();
}

class _ForumGuidePageState extends State<ForumGuidePage> {
  Set<String>? supported;
  DiscuzError? error;
  Object? _session;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final account = context.read<DiscuzAndUserNotifier>();
    final session = account.sessionIdentity;
    final ticket = ++_generation;
    _session = session;
    bool isCurrent() =>
        mounted &&
        ticket == _generation &&
        identical(session, account.sessionIdentity);
    setState(() {
      error = null;
      supported = null;
    });
    try {
      final client = widget.createClient != null
          ? await widget.createClient!()
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(
                account.userFor(widget.discuz),
              ),
              widget.discuz.baseURL,
            );
      try {
        final tabs = await client.guideSections();
        if (isCurrent()) setState(() => supported = tabs);
      } finally {
        if (widget.createClient == null) client.dio.close();
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
    final available = supported;
    final account = context.watch<DiscuzAndUserNotifier>();
    final sections = ForumGuideSection.values.where(
      (section) => available?.contains(section.identifier) == true,
    );
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(title: Text(strings.forumGuide)),
      body: switch (error) {
        _ when !identical(_session, account.sessionIdentity) => Center(
          child: PlatformTextButton(
            onPressed: load,
            child: Text(strings.refresh),
          ),
        ),
        final failure? => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorCard(failure, load, largeSize: false),
            PlatformTextButton(
              child: Text(strings.navigateToWebPage),
              onPressed: () => Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  builder: (_) => InternalWebviewBrowserPage(
                    widget.discuz,
                    account.userFor(widget.discuz),
                    '${widget.discuz.getBaseURLWithAfterfix()}forum.php?mod=guide',
                  ),
                ),
              ),
            ),
          ],
        ),
        _ when available == null => const Center(
          child: PlatformCircularProgressIndicator(),
        ),
        _ when sections.isEmpty => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.forumApiUnavailable),
              PlatformTextButton(onPressed: load, child: Text(strings.refresh)),
              PlatformTextButton(
                child: Text(strings.navigateToWebPage),
                onPressed: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => InternalWebviewBrowserPage(
                      widget.discuz,
                      account.userFor(widget.discuz),
                      '${widget.discuz.getBaseURLWithAfterfix()}forum.php?mod=guide',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _ => ListView(
          children: [
            for (final section in sections)
              PlatformListTile(
                title: Text(section.title(strings)),
                trailing: Icon(
                  PlatformIcons(
                    context,
                  ).pick(Icons.chevron_right, CupertinoIcons.chevron_forward),
                ),
                onTap: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => ForumListsPage(
                      discuz: widget.discuz,
                      user: account.userFor(widget.discuz),
                      guide: section,
                      createClient: widget.createClient,
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
