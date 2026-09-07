import 'package:discuz_flutter/dao/DiscuzAuthenticationDao.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/password_store_recovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDao implements DiscuzAuthenticationDao {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final confirm in [false, true]) {
    testWidgets('new password store requires explicit consent: $confirm',
        (tester) async {
      var creates = 0;
      final dao = FakeDao();
      DiscuzAuthenticationDao? result;
      await tester.pumpWidget(PlatformProvider(
        style: AppVisualStyle.material,
        builder: (_) => MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                        onPressed: () async {
                          result = await openPasswordStoreWithRecovery(context,
                              openStore: () async =>
                                  throw StateError('unreadable'),
                              createStore: () async {
                                creates++;
                                return dao;
                              });
                        },
                        child: const Text('Open'),
                      ))),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(creates, 0);
      expect(find.text('Saved passwords could not be read'), findsOneWidget);
      await tester.tap(find.text(confirm ? 'Create new store' : 'Cancel'));
      await tester.pumpAndSettle();
      expect(creates, confirm ? 1 : 0);
      expect(result, confirm ? same(dao) : isNull);
      expect(tester.takeException(), isNull);
    });
  }
}
