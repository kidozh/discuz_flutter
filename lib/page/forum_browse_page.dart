import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/ForumInteractionClient.dart';
import '../client/discuz_web_client.dart';
import '../client/forum_browse.dart';
import '../entity/Discuz.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../widget/DiscuzHtmlWidget.dart';
import '../widget/ErrorCard.dart';
import 'InternalWebviewBrowserPage.dart';

typedef _ForumBrowseItems = ({
  List<ForumAnnouncement> announcements,
  List<ForumThreadTag> tags,
});

class ForumBrowsePage extends StatefulWidget {
  const ForumBrowsePage(this.forum, {this.tid, super.key});

  final Discuz forum;
  final int? tid;

  @override
  State<ForumBrowsePage> createState() => _ForumBrowsePageState();
}

class _ForumBrowsePageState extends State<ForumBrowsePage> {
  late final account = context.read<DiscuzAndUserNotifier>();
  late final session = account.sessionIdentity;
  late Future<_ForumBrowseItems> _items;
  final expanded = <int>{};

  @override
  void initState() {
    super.initState();
    _items = _load();
  }

  Future<_ForumBrowseItems> _load() async {
    // Capture the account used to load these pages even if the screen is idle.
    final currentSession = session;
    final forum = widget.forum;
    final user = account.userFor(forum);
    final dio = await NetworkUtils.getDioWithPersistCookieJar(
      user,
      guestForum: forum.baseURL,
    );
    try {
      if (!identical(currentSession, account.sessionIdentity)) {
        throw const ForumApiException('account_changed', '');
      }
      final client = ForumBrowseClient(
        DiscuzWebClient(ForumInteractionClient(dio, forum.baseURL)),
      );
      final tid = widget.tid;
      return tid == null
          ? (announcements: await client.announcements(), tags: <ForumThreadTag>[])
          : (announcements: <ForumAnnouncement>[], tags: await client.tags(tid));
    } finally {
      dio.close();
    }
  }

  Future<IndicatorResult> _refresh() async {
    setState(() => _items = _load());
    try {
      await _items;
      return IndicatorResult.success;
    } catch (_) {
      return IndicatorResult.fail;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(
          widget.tid == null ? s.forumAnnouncements : s.forumThreadTags,
        ),
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: !identical(session, account.sessionIdentity)
            ? Center(child: Text(s.forumAccountChanged))
            : FutureBuilder<_ForumBrowseItems>(
                future: _items,
                builder: (context, result) {
                  final items = result.data;
                  return EasyRefresh(
                    header: EasyRefreshUtils.i18nClassicHeader(context),
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        if (result.hasError)
                          ErrorCard(
                            forumRequestError(s, result.error!),
                            _refresh,
                            largeSize: false,
                          )
                        else if (items == null)
                          const Center(
                            child: PlatformCircularProgressIndicator(),
                          )
                        else if (items.tags.isEmpty &&
                            items.announcements.isEmpty)
                          Center(child: Text(s.forumEmpty))
                        else ...[
                          for (final tag in items.tags)
                            PlatformListTile(
                              title: Text(tag.name),
                              trailing: Icon(PlatformIcons(context).forward),
                              onTap: () => pushDetailPage(
                                context,
                                platformPageRoute(
                                  context: context,
                                  builder: (_) => InternalWebviewBrowserPage(
                                    widget.forum,
                                    account.userFor(widget.forum),
                                    tag.uri.toString(),
                                  ),
                                ),
                              ),
                            ),
                          for (final item in items.announcements)
                            PlatformCard(
                              child: Column(
                                children: [
                                  PlatformListTile(
                                    title: Text(item.title),
                                    subtitle: item.date.isEmpty
                                        ? null
                                        : Text(item.date),
                                    trailing: Icon(
                                      expanded.contains(item.id)
                                          ? PlatformIcons(context).upArrow
                                          : PlatformIcons(context).downArrow,
                                    ),
                                    onTap: () => setState(() {
                                      if (!expanded.remove(item.id)) {
                                        expanded.add(item.id);
                                      }
                                    }),
                                  ),
                                  if (expanded.contains(item.id))
                                    DiscuzHtmlWidget(
                                      widget.forum,
                                      item.body,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
