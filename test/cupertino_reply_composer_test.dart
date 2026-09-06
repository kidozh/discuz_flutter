import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/widget/ThreadReplyTargetBanner.dart';
import 'package:discuz_flutter/widget/thread_reply_composer.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final _site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

Widget _host(Widget child,
        {Brightness brightness = Brightness.light,
        double width = 390,
        double textScale = 1,
        double bottomInset = 0,
        double keyboardInset = 0}) =>
    PlatformProvider(
      style: AppVisualStyle.cupertino,
      builder: (_) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
            body: Center(
                child: SizedBox(
          width: width,
          child: MediaQuery(
              data: MediaQueryData(
                  size: Size(width, 844),
                  devicePixelRatio: 3,
                  textScaler: TextScaler.linear(textScale),
                  padding: EdgeInsets.only(bottom: bottomInset),
                  viewInsets: EdgeInsets.only(bottom: keyboardInset)),
              child: child),
        ))),
      ),
    );

void main() {
  late TextEditingController controller;
  late FocusNode focus;
  var sent = 0;
  var toggled = 0;
  setUp(() {
    controller = TextEditingController();
    focus = FocusNode();
    sent = toggled = 0;
  });
  tearDown(() {
    controller.dispose();
    focus.dispose();
  });

  Widget composer(
          {SendReplyStatus status = SendReplyStatus.idle,
          bool panelVisible = false,
          Widget target = const SizedBox.shrink()}) =>
      CupertinoThreadReplyComposer(
          discuz: _site,
          controller: controller,
          focusNode: focus,
          replyTarget: target,
          panelVisible: panelVisible,
          sendStatus: status,
          onTogglePanel: () => toggled++,
          onSend: () => sent++);
  final add = find.byKey(const ValueKey('cupertino-composer-add'));
  final send = find.byKey(const ValueKey('cupertino-composer-send'));
  final bubble = find.byKey(const ValueKey('cupertino-composer-bubble'));

  for (final brightness in Brightness.values) {
    testWidgets(
        'message composer has one bubble and an inset send button ($brightness)',
        (tester) async {
      await tester.pumpWidget(_host(composer(), brightness: brightness));
      await tester.pumpAndSettle();
      expect(find.byType(PlatformLiquidGlassCard), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(InputDecorator), findsNothing);
      expect(
          tester
              .widget<Container>(
                  find.byKey(const ValueKey('cupertino-post-input')))
              .decoration,
          isNull);
      final box = tester.getRect(bubble);
      expect(box.contains(tester.getCenter(send)), isTrue);
      expect(box.contains(tester.getCenter(add)), isFalse);
      expect(tester.getSize(send), const Size(44, 44));
      expect(tester.getSize(add), const Size(44, 44));
      expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
      await tester.tap(find.byType(ExtendedTextField));
      tester.testTextInput.enterText('这是一条回复😀');
      await tester.pumpAndSettle();
      final circle = tester.widget<Container>(
          find.byKey(const ValueKey('cupertino-composer-send-circle')));
      expect((circle.decoration! as BoxDecoration).color,
          CupertinoColors.systemBlue.resolveFrom(tester.element(send)));
      expect(find.byIcon(CupertinoIcons.arrow_up), findsOneWidget);
      await tester.tap(send);
      expect(sent, 1);
      expect(controller.text, '这是一条回复😀');
      await tester.tap(add);
      expect(toggled, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'sending, success and retry preserve the draft and prevent duplicate sends',
      (tester) async {
    controller.text = '草稿 [attachimg]42[/attachimg]';
    await tester.pumpWidget(_host(composer(status: SendReplyStatus.loading)));
    await tester.pump();
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
    await tester.tap(send);
    expect(sent, 0);
    await tester.pumpWidget(_host(composer(status: SendReplyStatus.success)));
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
    await tester.pumpWidget(_host(composer(status: SendReplyStatus.fail)));
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.arrow_clockwise), findsOneWidget);
    await tester.tap(send);
    expect(sent, 1);
    expect(PostTextFieldUtils.getAttachmentAidList(controller.text), ['42']);
    controller.clear();
    await tester.pumpAndSettle();
    expect(tester.widget<CupertinoButton>(send).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'quote preview dismisses independently and survives a narrow large-text layout',
      (tester) async {
    var dismissed = false;
    final target = ThreadReplyTargetBanner(
        author: '用户名很长的论坛用户',
        messageHtml: '<p>一段很长的引用内容<img src="a"></p>',
        picturePlaceholder: '[图片]',
        embeddedInComposer: true,
        onDismiss: () => dismissed = true);
    controller.text = List.filled(20, '长回复内容😀').join('\n');
    await tester
        .pumpWidget(_host(composer(target: target), width: 320, textScale: 2));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ExtendedTextField>(find.byType(ExtendedTextField))
            .maxLines,
        5);
    expect(find.byType(PlatformLiquidGlassCard), findsNothing);
    expect(tester.getBottomRight(send).dy,
        closeTo(tester.getBottomRight(bubble).dy, 1));
    final dismiss = find.descendant(
        of: find.byType(ThreadReplyTargetBanner),
        matching: find.byType(CupertinoButton));
    await tester.tap(dismiss);
    expect(dismissed, isTrue);
    expect(controller.text, contains('长回复内容'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'keyboard and accessory modes preserve IME selection without extra bottom gaps',
      (tester) async {
    await tester.pumpWidget(_host(composer(), bottomInset: 34));
    await tester.pumpAndSettle();
    final normalHeight =
        tester.getSize(find.byType(CupertinoThreadReplyComposer)).height;
    await tester.tap(find.byType(ExtendedTextField));
    tester.testTextInput.updateEditingValue(const TextEditingValue(
        text: '回复拼音',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 2, end: 4)));
    await tester.pump();
    final editing = controller.value;
    await tester
        .pumpWidget(_host(composer(panelVisible: true), bottomInset: 34));
    await tester.pumpAndSettle();
    expect(controller.value, editing);
    expect(find.byIcon(CupertinoIcons.keyboard), findsOneWidget);
    expect(tester.getSize(find.byType(CupertinoThreadReplyComposer)).height,
        closeTo(normalHeight - 34, 1));
    await tester.tap(add);
    expect(toggled, 1);
    await tester.pumpWidget(_host(composer(), keyboardInset: 300));
    await tester.pumpAndSettle();
    expect(controller.value, editing);
    expect(tester.getSize(find.byType(CupertinoThreadReplyComposer)).height,
        closeTo(normalHeight - 34, 1));
    expect(tester.takeException(), isNull);
  });
}
