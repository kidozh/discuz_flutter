import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/utility/TwoPaneScaffold.dart';
import 'package:discuz_flutter/utility/TwoPaneUtils.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget replyTarget(String label) => Consumer<ReplyPostNotifierProvider>(
  builder: (_, target, _) => Text('$label:${target.post?.pid ?? 0}'),
);

void main() {
  testWidgets('opening a nested thread preserves the previous reply target', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    late ReplyPostNotifierProvider original;
    late ReplyPostNotifierProvider nested;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: ThreadReplyScope(
          threadIdentity: ('https://example.com', 1, 10),
          child: Builder(
            builder: (context) {
              original = context.read<ReplyPostNotifierProvider>();
              return Scaffold(body: replyTarget('original'));
            },
          ),
        ),
      ),
    );
    original.setPost(Post()..pid = 42);
    await tester.pump();

    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadReplyScope(
          threadIdentity: ('https://example.com', 1, 11),
          child: Builder(
            builder: (context) {
              nested = context.read<ReplyPostNotifierProvider>();
              return Scaffold(body: replyTarget('nested'));
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(nested, isNot(same(original)));
    expect(find.text('nested:0'), findsOneWidget);
    nested.setPost(Post()..pid = 99);
    await tester.pump();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('original:42'), findsOneWidget);
    expect(original.post?.pid, 42);
  });

  testWidgets('folding retains reply target and a new thread starts empty', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 700);
    addTearDown(tester.view.reset);
    var tid = 10;
    late StateSetter rebuild;
    late ReplyPostNotifierProvider target;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (_, setState) {
            rebuild = setState;
            return TwoPaneScaffold(
              type: TwoPaneType.foldable,
              child: TwoPane(
                panePriority: TwoPanePriority.end,
                startPane: const Text('list'),
                endPane: ThreadReplyScope(
                  threadIdentity: ('https://example.com', 1, tid),
                  child: Builder(
                    builder: (context) {
                      target = context.read<ReplyPostNotifierProvider>();
                      return replyTarget('detail');
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    target.setPost(Post()..pid = 42);
    await tester.pump();
    final original = target;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(900, 700);
    await tester.pumpAndSettle();
    expect(target, same(original));
    expect(find.text('detail:42'), findsOneWidget);
    rebuild(() => tid = 11);
    await tester.pumpAndSettle();
    expect(target, isNot(same(original)));
    expect(find.text('detail:0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
