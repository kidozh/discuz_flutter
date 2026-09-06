import 'package:discuz_flutter/utility/PlatformGlass.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart'
    show isInsidePlatformLiquidGlassContainer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget surface(
        {Widget child = const SizedBox(height: 80),
        PlatformGlassEffect effect = PlatformGlassEffect.automatic}) =>
    ClipRect(child: PlatformGlassBackdrop(effect: effect, child: child));

void main() {
  testWidgets('public glass query uses the shared scope', (tester) async {
    bool? outside;
    bool? inside;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      outside = isInsidePlatformLiquidGlassContainer(context);
      return PlatformGlassScope(child: Builder(builder: (context) {
        inside = isInsidePlatformLiquidGlassContainer(context);
        return const SizedBox();
      }));
    })));
    expect(outside, isFalse);
    expect(inside, isTrue);
  });

  testWidgets('standalone glass keeps real backdrop blur', (tester) async {
    await tester.pumpWidget(MaterialApp(home: surface()));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('nested glass never adds a second blur, even when requested',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: surface(
      child: surface(effect: PlatformGlassEffect.backdropBlur),
    )));
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(PlatformGlassScope), findsNWidgets(2));
  });

  testWidgets('scrolling surfaces retain children without backdrop filters',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ListView(
      children: List.generate(5, (_) => surface()),
    )));
    expect(find.byType(PlatformGlassBackdrop), findsNWidgets(5));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('standalone scrolling blur can be explicitly enabled',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ListView(
      children: [surface(effect: PlatformGlassEffect.backdropBlur)],
    )));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('tint-only parent also prevents descendant backdrop sampling',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: surface(
      effect: PlatformGlassEffect.tintOnly,
      child: surface(effect: PlatformGlassEffect.backdropBlur),
    )));
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('shared native surface scope suppresses Flutter child blur',
      (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: PlatformGlassScope(child: surface())));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
