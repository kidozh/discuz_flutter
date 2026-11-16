import 'package:flutter/material.dart';

import '../JsonResult/CheckPostResult.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';
import '../utility/forum_error.dart';
import '../utility/forum_voice.dart';
import 'ErrorCard.dart';

/// Keeps the editor out of reach until the server confirms this operation.
/// Changing account/forum must provide a new key to discard the old grant.
class PostPermissionGate extends StatefulWidget {
  final Future<CheckPostResult> Function() load;
  final bool reply;
  final Widget child;
  final bool fullPage;
  final ({String site, int uid, int fid})? voiceScope;
  const PostPermissionGate({
    super.key,
    required this.load,
    required this.reply,
    required this.child,
    this.fullPage = false,
    this.voiceScope,
  });
  static ForumVoiceOptions? voiceOptionsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_VoiceOptions>()?.options;

  @override
  State<PostPermissionGate> createState() => _PostPermissionGateState();
}

class _PostPermissionGateState extends State<PostPermissionGate> {
  bool _loading = true;
  bool? _allowed;
  DiscuzError? _serverError;
  ForumVoiceOptions? _voice;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _serverError = null;
    });
    try {
      final result = await widget.load();
      if (!mounted) return;
      final error = forumResponseError(S.of(context), result);
      final scope = widget.voiceScope;
      final allow = result.variables.allowPerm;
      final options =
          error == null &&
              canRecordForumVoice &&
              scope != null &&
              result.variables.member_uid == scope.uid
          ? await rememberForumVoice(
              '${scope.site}|${scope.uid}|${scope.fid}',
              allow,
            )
          : null;
      if (!mounted) return;
      setState(() {
        _serverError = error;
        _voice = options;
        _allowed = error == null
            ? (widget.reply ? allow.allowReply : allow.allowPost)
            : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _allowed = null;
        _serverError = forumRequestError(S.of(context), error);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _allowed == true) {
      return _VoiceOptions(_voice, child: widget.child);
    }
    if (!_loading && widget.reply && _allowed == false) {
      return const SizedBox.shrink();
    }
    final s = S.of(context);
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            PlatformCircularProgressIndicator()
          else if (_serverError case final error?)
            ErrorCard(error, _load, largeSize: false)
          else ...[
            Text(
              _allowed == false
                  ? widget.reply
                        ? s.replyPermissionDenied
                        : s.postPermissionDenied
                  : s.postPermissionUnknown,
              textAlign: TextAlign.center,
            ),
            PlatformTextButton(onPressed: _load, child: Text(s.refresh)),
          ],
        ],
      ),
    );
    return widget.fullPage
        ? PlatformScaffold(
            appBar: PlatformAppBar(title: Text(s.pushThreadTitle)),
            body: Center(child: content),
          )
        : content;
  }
}

class _VoiceOptions extends InheritedWidget {
  const _VoiceOptions(this.options, {required super.child});

  final ForumVoiceOptions? options;

  @override
  bool updateShouldNotify(_VoiceOptions oldWidget) =>
      options != oldWidget.options;
}
