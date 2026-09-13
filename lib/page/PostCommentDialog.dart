import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import 'InternalWebviewBrowserPage.dart';

class PostCommentDialog extends StatefulWidget {
  final Discuz discuz;
  final User user;
  final int tid, pid;
  const PostCommentDialog({
    super.key,
    required this.discuz,
    required this.user,
    required this.tid,
    required this.pid,
  });
  @override
  State<PostCommentDialog> createState() => _PostCommentDialogState();
}

class _PostCommentDialogState extends State<PostCommentDialog> {
  final text = TextEditingController();
  bool busy = false;
  String? error;
  bool sameAccount() {
    if (!mounted) return false;
    final account = context.read<DiscuzAndUserNotifier>();
    return account.discuz?.baseURL == widget.discuz.baseURL &&
        account.user?.uid == widget.user.uid &&
        account.user?.auth == widget.user.auth;
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    final strings = S.of(context);
    if (text.text.trim().isEmpty || text.text.trim().runes.length > 200) {
      setState(() => error = strings.postCommentHint);
      return;
    }
    if (!sameAccount()) {
      setState(() => error = strings.forumSignInRequired);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final api = ForumInteractionClient(
        await NetworkUtils.getDioWithPersistCookieJar(widget.user),
        widget.discuz.baseURL,
      );
      await api.addPostComment(
        tid: widget.tid,
        pid: widget.pid,
        uid: widget.user.uid,
        message: text.text,
        sameAccount: sameAccount,
      );
      if (mounted && sameAccount()) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException
              ? (e.message.isEmpty ? strings.postCommentUnavailable : e.message)
              : strings.forumSubmissionUnknown,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: !busy,
      child: PlatformAlertDialog(
        glassBackgroundColor: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.72),
        title: Text(s.postAddComment),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              PlatformTextField(
                controller: text,
                minLines: 2,
                maxLines: 4,
                enabled: !busy,
                autofocus: true,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!),
                ),
            ],
          ),
        ),
        actions: [
          if (error != null)
            PlatformDialogAction(
              onPressed: busy
                  ? null
                  : () => Navigator.push(
                      context,
                      platformPageRoute(
                        context: context,
                        builder: (_) => InternalWebviewBrowserPage(
                          widget.discuz,
                          widget.user,
                          '${widget.discuz.baseURL.replaceAll(RegExp(r"/+$"), "")}/forum.php?mod=misc&action=comment&tid=${widget.tid}&pid=${widget.pid}',
                        ),
                      ),
                    ),
              child: Text(s.specialOpenWebsite),
            ),
          PlatformDialogAction(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          PlatformDialogAction(
            onPressed: busy ? null : submit,
            child: Text(busy ? s.forumWorking : s.send),
          ),
        ],
      ),
    );
  }
}
