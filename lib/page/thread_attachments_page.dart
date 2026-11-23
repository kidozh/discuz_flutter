import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/MobileApiClient.dart';
import '../entity/Discuz.dart';
import '../entity/DiscuzError.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/EasyRefreshUtils.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/post_locator.dart';
import '../utility/thread_attachments.dart';
import '../widget/AttachmentWidget.dart';
import '../widget/ErrorCard.dart';

class ThreadAttachmentsPage extends StatefulWidget {
  final Discuz discuz;
  final User? user;
  final int tid;
  final VoidCallback onPurchased;

  const ThreadAttachmentsPage({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    required this.onPurchased,
  });

  @override
  State<ThreadAttachmentsPage> createState() => _ThreadAttachmentsPageState();
}

class _ThreadAttachmentsPageState extends State<ThreadAttachmentsPage> {
  final _controller = EasyRefreshController();
  final _attachments = <String, (ThreadAttachment, int)>{};
  late final Object _session;
  int _page = 1;
  bool _loading = false;
  bool _more = true;
  bool _failedRefresh = false;
  int? _failedReloadPage, _pendingPurchasePage;
  DiscuzError? _error;

  @override
  void initState() {
    super.initState();
    _session = context.read<DiscuzAndUserNotifier>().sessionIdentity;
    unawaited(_load(refresh: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _load({bool refresh = false, int? reloadPage}) async {
    if (_loading) return IndicatorResult.fail;
    if (!refresh && reloadPage == null && !_more) return IndicatorResult.noMore;
    final account = context.read<DiscuzAndUserNotifier>();
    bool isCurrent() => mounted && identical(account.sessionIdentity, _session);
    if (!isCurrent()) return IndicatorResult.fail;
    final requestedPage = reloadPage ?? (refresh ? 1 : _page);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(
        widget.user,
        guestForum: widget.discuz.baseURL,
      );
      try {
        final result = await MobileApiClient(
          dio,
          baseUrl: widget.discuz.baseURL,
        ).viewThreadPage(widget.tid, requestedPage, 15, {'ordertype': '0'});
        if (!isCurrent()) return IndicatorResult.fail;
        final variables = result.threadVariables;
        final error = EasyRefreshUtils.responseError(
          context,
          result,
          widget.user,
          variables.member_uid,
        );
        if (error != null) {
          // The forum may revoke access while the overview is already open.
          setState(_attachments.clear);
          throw error;
        }
        final ppp = int.tryParse(variables.ppp) ?? 0;
        if (variables.threadInfo.tid != widget.tid ||
            variables.member_uid != (widget.user?.uid ?? 0) ||
            ppp <= 0) {
          throw const FormatException('Invalid thread attachment page');
        }
        final posts = variables.postList.where(
          (post) => post.pid > 0 && post.tid == widget.tid,
        );
        setState(() {
          if (refresh) _attachments.clear();
          for (final post in posts) {
            for (final attachment in ThreadAttachment.fromPost(
              widget.discuz,
              post,
            )) {
              final originalPage = _attachments[attachment.key]?.$2;
              _attachments[attachment.key] = (
                attachment,
                originalPage ?? requestedPage,
              );
            }
          }
          if (reloadPage == null) {
            _more =
                posts.isNotEmpty &&
                hasMoreThreadPages(
                  page: requestedPage,
                  postsPerPage: ppp,
                  replies: variables.threadInfo.replies,
                );
            _page = requestedPage + 1;
          }
        });
        if (refresh) _controller.resetFooter();
        return refresh || _more
            ? IndicatorResult.success
            : IndicatorResult.noMore;
      } finally {
        dio.close();
      }
    } catch (failure) {
      if (isCurrent()) {
        setState(() {
          _error = failure is DiscuzError
              ? failure
              : EasyRefreshUtils.requestError(context, failure);
          _failedRefresh = refresh;
          _failedReloadPage = reloadPage;
        });
      }
      return IndicatorResult.fail;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (_pendingPurchasePage case final page?) {
          _pendingPurchasePage = null;
          unawaited(_load(reloadPage: page));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final account = context.watch<DiscuzAndUserNotifier>();
    final active = identical(account.sessionIdentity, _session);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(strings.threadAttachments),
        liquidGlassTitle: strings.threadAttachments,
      ),
      iosContentPadding: true,
      body: PlatformLiquidGlassPageBackdrop(
        child: !active
            ? const SizedBox.shrink()
            : EasyRefresh(
                controller: _controller,
                header: EasyRefreshUtils.i18nClassicHeader(context),
                footer: EasyRefreshUtils.i18nClassicFooter(context),
                onRefresh: () => _load(refresh: true),
                onLoad: _load,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final (entry, page) in _attachments.values)
                      _buildAttachment(context, entry, page),
                    if (_error case final failure?)
                      ErrorCard(
                        failure,
                        () => _load(
                          refresh: _failedRefresh,
                          reloadPage: _failedReloadPage,
                        ),
                        largeSize: false,
                      )
                    else if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                          child: PlatformCircularProgressIndicator(),
                        ),
                      )
                    else if (_more)
                      Center(
                        child: PlatformTextButton(
                          onPressed: () => _load(),
                          semanticLabel: strings.threadLoadMoreAttachments,
                          child: Text(strings.threadLoadMoreAttachments),
                        ),
                      )
                    else if (_attachments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          strings.threadNoAttachments,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAttachment(
    BuildContext context,
    ThreadAttachment entry,
    int page,
  ) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final actionStyle = theme.brightness == Brightness.dark
        ? TextStyle(color: theme.colorScheme.onSurface)
        : null;
    final floor = entry.post.position > 0
        ? entry.post.position
        : entry.post.number;
    return PlatformCard(
      key: ValueKey(entry.key),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    floor > 0
                        ? '#$floor · ${entry.post.author}'
                        : entry.post.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                PlatformTextButton(
                  onPressed: () => Navigator.of(context).pop(entry.post.pid),
                  semanticLabel: strings.threadJumpToAttachmentPost,
                  child: Text(
                    strings.threadJumpToAttachmentPost,
                    style: actionStyle,
                  ),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: AttachmentWidget(
                widget.discuz,
                entry.attachment,
                threadId: widget.tid,
                postId: entry.post.pid,
                isListedImage: entry.isListedImage,
                inlineThumbnail: entry.inlineThumbnail,
                onContentChanged: () {
                  widget.onPurchased();
                  if (_loading) {
                    _pendingPurchasePage = page;
                  } else {
                    unawaited(_load(reloadPage: page));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
