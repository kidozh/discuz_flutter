import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzNotification.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/DiscuzNotificationWidget.dart';
import 'package:discuz_flutter/widget/ThreadReplyTargetBanner.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:discuz_flutter/widget/thread_reply_composer.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  AppVisualStyle style = AppVisualStyle.cupertino,
  double textScale = 1,
}) =>
    PlatformProvider(
      style: style,
      builder: (_) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: CupertinoTheme(
          data: CupertinoThemeData(
              brightness: brightness,
              // Exercise realistic line heights without relying on fonts absent in CI.
              textTheme: const CupertinoTextThemeData(
                  textStyle: TextStyle(fontSize: 17, height: 1.4))),
          child:
              PlatformScaffold(body: CupertinoComposerViewport(child: child)),
        ),
      ),
    );

void main() {
  testWidgets('keyboard/accessory transitions never stack both panels',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(844, 390);
    tester.view.viewInsets = const FakeViewPadding(bottom: 216);
    addTearDown(tester.view.reset);
    final controller =
        TextEditingController(text: 'One\nTwo\nThree\nFour\nFive');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(Column(children: [
      const Expanded(child: SizedBox()),
      CupertinoThreadReplyComposer(
          discuz: site,
          controller: controller,
          focusNode: focus,
          replyTarget: ThreadReplyTargetBanner(
              author: 'Author',
              messageHtml: 'Quote',
              picturePlaceholder: '[Image]',
              embeddedInComposer: true,
              onDismiss: () {}),
          panelVisible: true,
          sendStatus: SendReplyStatus.idle,
          onTogglePanel: () {},
          onSend: () {}),
      const CupertinoKeyboardAccessory(
          enabled: true,
          child: SizedBox(key: ValueKey('accessory'), height: 110)),
    ])));
    final panel = find.byKey(const ValueKey('accessory'));
    for (final inset in [216.0, 100.0, 0.0, 100.0, 216.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pumpAndSettle();
      expect(panel, inset == 0 ? findsOneWidget : findsNothing);
      expect(controller.text, 'One\nTwo\nThree\nFour\nFive');
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final brightness in Brightness.values) {
    testWidgets('selected filters have contrasting text/icons ($brightness)',
        (tester) async {
      var selected = false;
      await tester.pumpWidget(host(
          StatefulBuilder(
              builder: (context, setState) => Center(
                    child: PlatformChoiceChip(
                        label: const Text('Latest'),
                        avatar: const Icon(CupertinoIcons.clock),
                        selected: selected,
                        onSelected: (value) =>
                            setState(() => selected = value)),
                  )),
          brightness: brightness));
      for (var i = 0; i < 2; i++) {
        final button =
            tester.widget<CupertinoButton>(find.byType(CupertinoButton));
        final context = tester.element(find.text('Latest'));
        final foreground = DefaultTextStyle.of(context).style.color!;
        expect(foreground.toARGB32(), isNot(button.color!.toARGB32()));
        expect(
            IconTheme.of(tester.element(find.byIcon(CupertinoIcons.clock)))
                .color!
                .toARGB32(),
            foreground.toARGB32());
        await tester.tap(find.text('Latest'));
        await tester.pumpAndSettle();
      }
      expect(selected, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final style in [AppVisualStyle.cupertino, AppVisualStyle.material]) {
    testWidgets(
        'notification rows retain content and style-specific separators ($style)',
        (tester) async {
      final notification = DiscuzNotification()
        ..type = 'post'
        ..note = '<p>New reply</p>'
        ..isNew = '1';
      await tester.pumpWidget(host(
          MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (_) => TypeSettingNotifierProvider()),
            ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
          ], child: DiscuzNotificationWidget(site, notification)),
          style: style));
      await tester.pumpAndSettle();
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('New reply', findRichText: true), findsOneWidget);
      expect(tester.widget<PlatformCard>(find.byType(PlatformCard)).color,
          isNotNull);
      expect(find.byType(CupertinoListSeparator),
          style == AppVisualStyle.cupertino ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final landscape in [false, true]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final privateMessage in [false, true]) {
        testWidgets(
            'bounded editor scrolls without losing content: landscape=$landscape scale=$scale private=$privateMessage',
            (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize =
              landscape ? const Size(844, 390) : const Size(320, 568);
          tester.view.viewInsets =
              FakeViewPadding(bottom: landscape ? 216 : 300);
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          var sent = 0;
          var dismissed = false;
          final composer = privateMessage
              ? CupertinoPrivateMessageComposer(
                  controller: controller,
                  focusNode: focus,
                  panelVisible: false,
                  sending: false,
                  canSend: true,
                  onTogglePanel: () {},
                  onSend: () => sent++)
              : CupertinoThreadReplyComposer(
                  discuz: site,
                  controller: controller,
                  focusNode: focus,
                  replyTarget: ThreadReplyTargetBanner(
                      author: 'Author',
                      messageHtml: '<p>Quoted text</p>',
                      picturePlaceholder: '[Image]',
                      embeddedInComposer: true,
                      onDismiss: () => dismissed = true),
                  panelVisible: false,
                  sendStatus: SendReplyStatus.idle,
                  onTogglePanel: () {},
                  onSend: () => sent++);
          await tester.pumpWidget(host(
              Column(children: [
                const Expanded(child: SizedBox()),
                composer,
              ]),
              textScale: scale));
          final editor = privateMessage
              ? find.byType(CupertinoTextField)
              : find.byType(ExtendedTextField);
          final draft = List.generate(30, (i) => 'Line $i').join('\n');
          await tester.tap(editor);
          tester.testTextInput.enterText(draft);
          await tester.pumpAndSettle();
          expect(controller.text, draft);
          final scrollable = tester.state<ScrollableState>(find
              .descendant(of: editor, matching: find.byType(Scrollable))
              .first);
          expect(scrollable.position.maxScrollExtent, greaterThan(0));
          expect(scrollable.position.pixels, greaterThan(0));
          final send = find.byKey(const ValueKey('cupertino-composer-send'));
          expect(tester.getSize(send), const Size(44, 44));
          expect(
              tester.getBottomRight(send).dy,
              lessThanOrEqualTo(tester.view.physicalSize.height -
                  tester.view.viewInsets.bottom));
          await tester.tap(send);
          expect(sent, 1);
          if (!privateMessage) {
            await tester.tap(find.byIcon(CupertinoIcons.clear_circled_solid));
            expect(dismissed, isTrue);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  testWidgets(
      'private composer preserves IME and disables send while busy or not ready',
      (tester) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    var sent = 0;
    Widget composer(
            {bool sending = false, bool canSend = true, bool panel = false}) =>
        host(CupertinoPrivateMessageComposer(
            controller: controller,
            focusNode: focus,
            panelVisible: panel,
            sending: sending,
            canSend: canSend,
            onTogglePanel: () {},
            onSend: () => sent++));
    await tester.pumpWidget(composer());
    await tester.tap(find.byType(CupertinoTextField));
    tester.testTextInput.updateEditingValue(const TextEditingValue(
        text: '拼音 :smile:',
        selection: TextSelection.collapsed(offset: 2),
        composing: TextRange(start: 0, end: 2)));
    await tester.pump();
    final draft = controller.value;
    await tester.pumpWidget(composer(sending: true));
    final send = find.byKey(const ValueKey('cupertino-composer-send'));
    expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    await tester.pumpWidget(composer(canSend: false));
    expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
    await tester.pumpWidget(composer(panel: true));
    expect(find.byIcon(CupertinoIcons.keyboard), findsOneWidget);
    expect(controller.value, draft);
    expect(find.byType(InputDecorator), findsNothing);
    await tester.tap(send);
    expect(sent, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
