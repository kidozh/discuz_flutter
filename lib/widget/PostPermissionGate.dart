import 'package:flutter/material.dart';
import '../JsonResult/CheckPostResult.dart';
import '../generated/l10n.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Keeps the editor out of reach until the server confirms this operation.
/// Changing account/forum must provide a new key to discard the old grant.
class PostPermissionGate extends StatefulWidget {
  final Future<CheckPostResult> Function() load;
  final bool reply;
  final Widget child;
  final bool fullPage;
  const PostPermissionGate({
    super.key,
    required this.load,
    required this.reply,
    required this.child,
    this.fullPage = false,
  });
  @override
  State<PostPermissionGate> createState() => _PostPermissionGateState();
}

class _PostPermissionGateState extends State<PostPermissionGate> {
  bool _loading = true;
  bool? _allowed;
  String? _serverError;
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
      setState(() {
        _serverError = result.getErrorString();
        _allowed = _serverError == null
            ? (widget.reply
                  ? result.variables.allowPerm.allowReply
                  : result.variables.allowPerm.allowPost)
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _allowed = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _allowed == true) return widget.child;
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
          else ...[
            Text(
              _serverError ??
                  (_allowed == false
                      ? widget.reply
                            ? s.replyPermissionDenied
                            : s.postPermissionDenied
                      : s.postPermissionUnknown),
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
