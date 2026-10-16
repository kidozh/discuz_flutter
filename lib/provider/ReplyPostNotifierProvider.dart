import 'package:discuz_flutter/entity/Post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplyPostNotifierProvider with ChangeNotifier {
  Post? _post;

  Post? get post => _post;

  setPost(Post? post) {
    _post = post;
    notifyListeners();
  }

  ReplyPostNotifierProvider();
}

/// A thread owns its reply target for its entire mounted lifetime, including
/// when another thread is pushed above it or its pane changes size.
class ThreadReplyScope extends StatelessWidget {
  final Object threadIdentity;
  final Widget child;

  const ThreadReplyScope({
    super.key,
    required this.threadIdentity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<ReplyPostNotifierProvider>(
        key: ValueKey(threadIdentity),
        create: (_) => ReplyPostNotifierProvider(),
        child: child,
      );
}
