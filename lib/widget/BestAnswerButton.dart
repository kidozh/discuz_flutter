import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../client/ForumInteractionClient.dart';
import '../JsonResult/ViewThreadResult.dart';
import '../entity/Discuz.dart';
import '../entity/Post.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

bool canSelectBestAnswer(DetailedThreadInfo thread, Post post, int? uid) =>
    uid != null &&
    uid > 0 &&
    thread.special == 3 &&
    thread.price > 0 &&
    thread.authorId == uid &&
    post.tid == thread.tid &&
    post.pid > 0 &&
    !post.first &&
    post.authorId > 0 &&
    post.authorId != uid;

class BestAnswerButton extends StatefulWidget {
  final Discuz discuz;
  final ThreadVariables variables;
  final Post post;
  final VoidCallback onChanged;
  final Future<ForumInteractionClient> Function(User)? createClient;
  const BestAnswerButton({
    super.key,
    required this.discuz,
    required this.variables,
    required this.post,
    required this.onChanged,
    this.createClient,
  });
  @override
  State<BestAnswerButton> createState() => _BestAnswerButtonState();
}

class _BestAnswerButtonState extends State<BestAnswerButton> {
  static final Set<String> _inFlight = {};
  bool busy = false, completed = false;
  bool sameAccount(User user) {
    final state = context.read<DiscuzAndUserNotifier>();
    return state.discuz?.baseURL == widget.discuz.baseURL &&
        state.user == user &&
        state.user?.auth == user.auth;
  }

  Future<void> select() async {
    if (busy || completed) return;
    final user = context.read<DiscuzAndUserNotifier>().user;
    if (user == null ||
        !sameAccount(user) ||
        !canSelectBestAnswer(
          widget.variables.threadInfo,
          widget.post,
          user.uid,
        ))
      return;
    final operation = '${widget.discuz.baseURL}:${user.uid}:${widget.post.tid}';
    if (!_inFlight.add(operation)) return;
    setState(() => busy = true);
    bool submitted = false;
    try {
      final client = widget.createClient != null
          ? await widget.createClient!(user)
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(user),
              widget.discuz.baseURL,
            );
      if (!mounted || !sameAccount(user)) return;
      bool confirmed = false;
      await showPlatformAlert(
        context: context,
        title: S.of(context).selectBestAnswer,
        message: S.of(context).confirmBestAnswer(widget.post.author),
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
      if (!mounted || !confirmed || !sameAccount(user)) return;
      // Re-read the selected reply and current bounty immediately before writing.
      final fresh = await client.request('viewthread', {
        'tid': widget.post.tid,
        'viewpid': widget.post.pid,
      });
      fresh.requireData('thread');
      final variables = ThreadVariables.fromJson(fresh.variables);
      final replies = variables.postList.where((p) => p.pid == widget.post.pid);
      if (replies.length != 1 ||
          replies.single.authorId != widget.post.authorId ||
          !canSelectBestAnswer(
            variables.threadInfo,
            replies.single,
            user.uid,
          ) ||
          variables.member_uid != user.uid ||
          variables.formHash.isEmpty ||
          variables.threadInfo.price != widget.variables.threadInfo.price) {
        throw ForumApiException(
          'answer_changed',
          mounted ? S.of(context).bestAnswerChanged : '',
        );
      }
      if (!mounted || !sameAccount(user)) return;
      submitted = true;
      await client.bestAnswer(
        widget.post.tid,
        widget.post.pid,
        variables.formHash,
      );
      if (!mounted || !sameAccount(user)) return;
      setState(() => completed = true);
      widget.onChanged();
    } catch (error) {
      if (!mounted || !sameAccount(user)) return;
      await showPlatformAlert(
        context: context,
        title: S.of(context).forumActionFailed,
        message: error is ForumApiException && error.message.isNotEmpty
            ? error.message
            : submitted
            ? S.of(context).forumSubmissionUnknown
            : S.of(context).bestAnswerChanged,
        actions: [PlatformAlertAction(label: S.of(context).forumConfirm)],
      );
    } finally {
      _inFlight.remove(operation);
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<DiscuzAndUserNotifier>();
    if (account.discuz?.baseURL != widget.discuz.baseURL ||
        !canSelectBestAnswer(
          widget.variables.threadInfo,
          widget.post,
          account.user?.uid,
        ))
      return const SizedBox.shrink();
    return PlatformTextButton(
      onPressed: busy || completed ? null : select,
      child: Text(
        completed
            ? S.of(context).bestAnswerSelected
            : busy
            ? S.of(context).forumWorking
            : S.of(context).selectBestAnswer,
      ),
    );
  }
}
