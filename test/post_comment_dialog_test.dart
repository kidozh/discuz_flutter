import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/PostCommentDialog.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';

void main() {
  for (final style in [AppVisualStyle.material, AppVisualStyle.cupertino]) {
    testWidgets('compact comment dialog opens and cancels: $style', (
      tester,
    ) async {
      final discuz = Discuz(
        'https://forum.test',
        'X3.5',
        'utf-8',
        4,
        '',
        '',
        false,
        '',
        '',
        'Forum',
        '',
        '',
        '',
      );
      final user = User('auth', 'salt', 'test', '', 1, 1, 10, discuz);
      await tester.pumpWidget(
        PlatformProvider(
          style: style,
          builder: (_) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Open'),
                  onPressed: () => showPlatformDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => PostCommentDialog(
                      discuz: discuz,
                      user: user,
                      tid: 10,
                      pid: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(PostCommentDialog), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(S.current.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(PostCommentDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
