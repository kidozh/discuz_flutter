import 'dart:convert';

import 'package:discuz_flutter/entity/post_signature.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/SelectSignatureStylePage.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/post_signature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'fresh and legacy app signatures never publish device details',
    () async {
      for (final legacy in [null, 'USE_APP_SIGNATURE']) {
        SharedPreferences.setMockInitialValues({
          UserPreferencesUtils.signaturePreferenceKey: ?legacy,
        });
        final value = await UserPreferencesUtils.getSignaturePreference();
        expect(value.style, PostSignatureStyle.app);
        expect(value.includesDevice, isFalse);
        expect(
          (await SharedPreferences.getInstance()).getString(
            UserPreferencesUtils.postSignaturePreferenceKey,
          ),
          isNotNull,
        );
      }
    },
  );

  test(
    'legacy opt-out, device-only and custom settings migrate once',
    () async {
      for (final (text, style) in [
        ('', PostSignatureStyle.none),
        ('USE_DEVICE_SIGNATURE', PostSignatureStyle.device),
        ('My signature', PostSignatureStyle.custom),
        (' USE_APP_SIGNATURE ', PostSignatureStyle.custom),
      ]) {
        SharedPreferences.setMockInitialValues({
          UserPreferencesUtils.signaturePreferenceKey: text,
        });
        final value = await UserPreferencesUtils.getSignaturePreference();
        expect(value.style, style);
        if (style == PostSignatureStyle.custom) expect(value.customText, text);
        await (await SharedPreferences.getInstance()).setString(
          UserPreferencesUtils.signaturePreferenceKey,
          'USE_DEVICE_SIGNATURE',
        );
        expect(
          (await UserPreferencesUtils.getSignaturePreference()).style,
          style,
        );
      }
    },
  );

  test(
    'custom text including old preset tokens is preserved verbatim',
    () async {
      for (final text in [
        '',
        ' ',
        'USE_APP_SIGNATURE',
        'USE_DEVICE_SIGNATURE',
        'Line 1\n[url=https://example.com]Line 2[/url]',
      ]) {
        await UserPreferencesUtils.putSignaturePreference(
          PostSignature(style: PostSignatureStyle.custom, customText: text),
        );
        final restored = await UserPreferencesUtils.getSignaturePreference();
        expect(restored.style, PostSignatureStyle.custom);
        expect(restored.customText, text);
        expect(restored.includesApp, isFalse);
        expect(restored.includesDevice, isFalse);
      }
    },
  );

  test(
    'malformed or unknown signature styles safely disable publication',
    () async {
      for (final raw in [
        false,
        '{broken',
        '[]',
        jsonEncode({'style': 'unknown'}),
        jsonEncode({'style': 3, 'customText': true}),
      ]) {
        SharedPreferences.setMockInitialValues({
          UserPreferencesUtils.postSignaturePreferenceKey: raw,
          UserPreferencesUtils.signaturePreferenceKey: 'USE_DEVICE_SIGNATURE',
        });
        expect(
          (await UserPreferencesUtils.getSignaturePreference()).style,
          PostSignatureStyle.none,
        );
      }
    },
  );

  for (final locale in [const Locale('en'), const Locale('zh', 'CN')]) {
    test('each signature mode loads only needed data in $locale', () async {
      final strings = await S.load(locale);
      for (final style in PostSignatureStyle.values) {
        var deviceReads = 0;
        var versionReads = 0;
        final signature = PostSignature(
          style: style,
          customText: 'USE_APP_SIGNATURE',
        );
        final text = await PostSignatureService.render(
          signature: signature,
          strings: strings,
          loadDeviceName: () async {
            deviceReads++;
            return 'PrivateDevice';
          },
          loadVersion: () async {
            versionReads++;
            return '2.0.7';
          },
        );
        expect(deviceReads, signature.includesDevice ? 1 : 0);
        expect(versionReads, signature.includesApp ? 1 : 0);
        expect(text.contains('PrivateDevice'), signature.includesDevice);
        if (style == PostSignatureStyle.custom) {
          expect(text, 'USE_APP_SIGNATURE');
        }
        if (signature.includesApp) {
          expect(text, contains('discuzhub.kidozh.com'));
          expect(text, contains('2.0.7'));
        }
      }
      final fallback = await PostSignatureService.render(
        signature: const PostSignature(style: PostSignatureStyle.appAndDevice),
        strings: strings,
        loadDeviceName: () async => '',
        loadVersion: () async => '2.0.7',
      );
      expect(fallback, strings.fromAppOnlySignature('2.0.7'));
    });
  }

  testWidgets(
    'editing empty custom text never selects a preset; switching retains it',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'DisFly',
        packageName: 'test',
        version: '2.0.7',
        buildNumber: '163',
        buildSignature: '',
      );
      final provider = UserPreferenceNotifierProvider();
      addTearDown(provider.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: PlatformProvider(
            style: AppVisualStyle.material,
            builder: (_) => MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: const SelectSignatureStylePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('USE_APP_SIGNATURE'), findsNothing);
      await tester.tap(find.text(S.current.customSignature));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'USE_APP_SIGNATURE');
      await tester.pumpAndSettle();
      expect(provider.signature.style, PostSignatureStyle.custom);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(provider.signature.style, PostSignatureStyle.custom);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'My custom text');
      await tester.tap(find.text(S.current.signatureWithDisFly));
      await tester.pumpAndSettle();
      expect(provider.signature.style, PostSignatureStyle.app);
      await tester.tap(find.text(S.current.customSignature));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'My custom text',
      );
      expect(
        (await UserPreferencesUtils.getSignaturePreference()).customText,
        'My custom text',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
