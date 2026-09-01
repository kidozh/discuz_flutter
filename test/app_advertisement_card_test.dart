import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/AppBannerAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('advertisement card presents attribution and creative together',
      (tester) async {
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.android,
        builder: (context) => MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          home: const Scaffold(
            body: AppAdvertisementCard(
              title: '广告',
              subtitle: '由 Google 提供的广告',
              child: SizedBox(
                key: ValueKey('fake-ad-creative'),
                width: 320,
                height: 50,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-ad-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-ad-header')), findsOneWidget);
    expect(find.byKey(const ValueKey('fake-ad-creative')), findsOneWidget);
    expect(find.text('广告'), findsOneWidget);
    expect(find.text('由 Google 提供的广告'), findsOneWidget);
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('advertisement card stays bounded on a wide layout',
      (tester) async {
    await tester.pumpWidget(
      PlatformProvider(
        initialPlatform: TargetPlatform.android,
        builder: (context) => const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: AppAdvertisementCard(
                title: 'AD',
                subtitle: 'Advertisement provided by Google',
                maximumWidth: 696,
                child: SizedBox(height: 50),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('app-ad-card'))).width,
      712,
    );
  });
}
