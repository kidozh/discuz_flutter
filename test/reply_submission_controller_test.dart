import 'dart:async';

import 'package:discuz_flutter/utility/reply_submission_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController editor;
  late List<String> attachments;
  late ReplySubmissionController submission;
  setUp(() {
    editor = TextEditingController(text: 'Draft [attachimg]42[/attachimg]');
    attachments = ['42'];
    submission = ReplySubmissionController(editor, attachments);
  });
  tearDown(() {
    submission.dispose();
    editor.dispose();
  });

  testWidgets('snapshots the request and preserves edits and new attachments',
      (tester) async {
    final response = Completer<bool>();
    late ReplyDraftSnapshot sent;
    final pending = submission.submit(
        request: (draft) {
          sent = draft;
          return response.future;
        },
        succeeded: (ok) => ok);
    expect(submission.status, SendReplyStatus.loading);
    editor.text += '\nContinued [attachimg]99[/attachimg]';
    attachments.add('99');
    response.complete(true);
    await pending;
    expect(sent.text, 'Draft [attachimg]42[/attachimg]');
    expect(sent.attachmentIds, ['42']);
    expect(editor.text, contains('Continued'));
    expect(attachments, ['42', '99']);
    await tester.pump(const Duration(seconds: 2));
    expect(editor.text, contains('Continued'));
  });

  testWidgets('success clears only the sent draft, not typing during feedback',
      (tester) async {
    await submission.submit(request: (_) async => true, succeeded: (ok) => ok);
    expect(editor.text, isEmpty);
    expect(attachments, isEmpty);
    expect(submission.status, SendReplyStatus.success);
    editor.text = 'Next message';
    attachments.add('99');
    await tester.pump(const Duration(seconds: 1));
    expect(submission.status, SendReplyStatus.idle);
    expect(editor.text, 'Next message');
    expect(attachments, ['99']);
  });

  testWidgets('duplicate sends and stale retry timers cannot reset a request',
      (tester) async {
    var requests = 0;
    await submission.submit(request: (_) async => false, succeeded: (ok) => ok);
    expect(submission.status, SendReplyStatus.fail);
    final response = Completer<bool>();
    final pending = submission.submit(
        request: (_) {
          requests++;
          return response.future;
        },
        succeeded: (ok) => ok);
    await submission.submit(
        request: (_) async {
          requests++;
          return true;
        },
        succeeded: (ok) => ok);
    await tester.pump(const Duration(seconds: 2));
    expect(requests, 1);
    expect(submission.status, SendReplyStatus.loading);
    response.complete(true);
    await pending;
    await submission.submit(
        request: (_) async {
          requests++;
          return true;
        },
        succeeded: (ok) => ok);
    expect(requests, 1);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('setup or network failures leave the complete draft retryable',
      (tester) async {
    await expectLater(
        submission.submit<bool>(
            request: (_) async => throw StateError('offline'),
            succeeded: (ok) => ok),
        throwsStateError);
    expect(submission.status, SendReplyStatus.fail);
    expect(editor.text, contains('Draft'));
    expect(attachments, ['42']);
    await tester.pump(const Duration(seconds: 1));
    expect(submission.status, SendReplyStatus.idle);
  });

  testWidgets('replacing a draft with identical text still counts as an edit',
      (tester) async {
    final original = editor.text;
    final response = Completer<bool>();
    final pending = submission.submit(
        request: (_) => response.future, succeeded: (ok) => ok);
    editor.clear();
    editor.text = original;
    response.complete(true);
    await pending;
    expect(editor.text, original);
    expect(attachments, ['42']);
    await tester.pump(const Duration(seconds: 1));
  });

  for (final fails in [false, true]) {
    testWidgets('disposed submission ignores a late response (failure=$fails)',
        (tester) async {
      final localEditor = TextEditingController(text: 'Draft');
      final local = ReplySubmissionController(localEditor, []);
      var notifications = 0;
      local.addListener(() => notifications++);
      final response = Completer<bool>();
      final pending =
          local.submit(request: (_) => response.future, succeeded: (ok) => ok);
      local.dispose();
      localEditor.dispose();
      if (fails) {
        response.completeError(StateError('offline'));
      } else {
        response.complete(true);
      }
      expect(await pending, isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(notifications, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
