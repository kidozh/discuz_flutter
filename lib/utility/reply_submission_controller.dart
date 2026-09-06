import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum SendReplyStatus { idle, loading, success, fail }

class ReplyDraftSnapshot {
  final String text;
  final List<String> attachmentIds;

  ReplyDraftSnapshot(this.text, List<String> attachmentIds)
      : attachmentIds = List.unmodifiable(attachmentIds);
}

/// Owns submission state, not the editor. Late replies and feedback timers must
/// never touch a disposed page or erase a draft edited after the send tap.
class ReplySubmissionController extends ChangeNotifier {
  final TextEditingController editor;
  final List<String> attachmentIds;
  SendReplyStatus _status = SendReplyStatus.idle;
  Timer? _feedbackTimer;
  bool _disposed = false;
  int _revision = 0;
  String _lastText;

  ReplySubmissionController(this.editor, this.attachmentIds)
      : _lastText = editor.text {
    editor.addListener(_onEdited);
  }

  SendReplyStatus get status => _status;

  void _onEdited() {
    if (editor.text != _lastText) {
      _lastText = editor.text;
      _revision++;
    }
  }

  void _setStatus(SendReplyStatus value) {
    _status = value;
    notifyListeners();
  }

  void _finish(SendReplyStatus value) {
    _setStatus(value);
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      if (!_disposed) _setStatus(SendReplyStatus.idle);
    });
  }

  Future<T?> submit<T>({
    required Future<T> Function(ReplyDraftSnapshot draft) request,
    required bool Function(T response) succeeded,
  }) async {
    if (_disposed ||
        status == SendReplyStatus.loading ||
        status == SendReplyStatus.success ||
        editor.text.isEmpty) {
      return null;
    }
    final draft = ReplyDraftSnapshot(editor.text, attachmentIds);
    final revision = _revision;
    _feedbackTimer?.cancel();
    _setStatus(SendReplyStatus.loading);
    try {
      final response = await request(draft);
      if (_disposed) return null;
      if (succeeded(response)) {
        if (_revision == revision &&
            editor.text == draft.text &&
            listEquals(attachmentIds, draft.attachmentIds)) {
          // Clear immediately, never from the delayed success indicator.
          attachmentIds.clear();
          editor.clear();
        }
        _finish(SendReplyStatus.success);
      } else {
        _finish(SendReplyStatus.fail);
      }
      return response;
    } catch (_) {
      if (_disposed) return null;
      _finish(SendReplyStatus.fail);
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _feedbackTimer?.cancel();
    editor.removeListener(_onEdited);
    super.dispose();
  }
}
