import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final site = Discuz(
  'https://example.com',
  'X3.5',
  'utf-8',
  4,
  '',
  '',
  false,
  '0',
  '0',
  'Example',
  '1',
  '',
  '0',
);

Widget host(AppVisualStyle style, {double scale = 1}) => ChangeNotifierProvider(
  create: (_) => DiscuzAndUserNotifier(),
  child: PlatformProvider(
    style: style,
    builder: (_) => PlatformApp(
      localizationsDelegates: const [
        S.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: LoginPage(site, 'kept-account'),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/local_auth'),
          (_) async => false,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/local_auth'),
          null,
        );
  });

  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'short login page scrolls to every action: $style scale=$scale',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(420, 340);
          addTearDown(tester.view.reset);
          await tester.pumpWidget(host(style, scale: scale));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          final password = tester.widget<PlatformTextFormField>(
            find.byType(PlatformTextFormField).last,
          );
          password.controller!.text = 'draft-password';

          final browser = find.text(S.current.signInViaBrowser);
          await tester.ensureVisible(browser);
          await tester.pump();
          expect(browser.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);

          tester.view.viewInsets = const FakeViewPadding(bottom: 140);
          await tester.pump();
          await tester.ensureVisible(browser);
          await tester.pump();
          expect(browser.hitTestable(), findsOneWidget);
          expect(tester.getBottomRight(browser).dy, lessThanOrEqualTo(200));
          expect(tester.takeException(), isNull);
          final account = tester.widget<PlatformTextFormField>(
            find.byType(PlatformTextFormField).first,
          );
          expect(account.controller!.text, 'kept-account');

          tester.view.physicalSize = const Size(390, 720);
          tester.view.viewInsets = const FakeViewPadding();
          await tester.pump();
          expect(account.controller!.text, 'kept-account');
          expect(tester.takeException(), isNull);
          expect(password.controller!.text, 'draft-password');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
