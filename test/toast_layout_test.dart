import "package:flutter/cupertino.dart";
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toast glass encloses content throughout accessible animations', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final platformKey = GlobalKey<PlatformProviderState>();
    await tester.pumpWidget(
      PlatformProvider(
        key: platformKey,
        style: AppVisualStyle.cupertino,
        builder: (context) => PlatformTheme(
          materialLightTheme: ThemeData.light(),
          materialDarkTheme: ThemeData.dark(),
          cupertinoLightTheme: const CupertinoThemeData(),
          cupertinoDarkTheme: const CupertinoThemeData(),
          builder: (context) => PlatformApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: ToastUtils.easyLoadingBuilder(),
            home: PlatformScaffold(body: const Text('Home')),
          ),
        ),
      ),
    );
    for (final message in ['成功', '这是一条较长的提示，用于检查背景是否完整包住内容']) {
      EasyLoading.showSuccess(message, duration: const Duration(seconds: 5));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      expect(find.text(message), findsOneWidget);
      platformKey.currentState!.changeStyle(AppVisualStyle.material);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      platformKey.currentState!.changeStyle(AppVisualStyle.cupertino);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      EasyLoading.dismiss();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ToastUtils.toastGlassPanel(
            const Padding(padding: EdgeInsets.all(20), child: Text('玻璃提示')),
          ),
        ),
      ),
    );
    {
      final glass = find.byType(PlatformLiquidGlassCard);
      expect(glass, findsOneWidget);
      final background = tester.getRect(glass);
      final text = tester.getRect(find.text('玻璃提示'));
      expect(background.contains(text.topLeft), isTrue);
      expect(background.contains(text.bottomRight), isTrue);
      EasyLoading.dismiss();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });
}
