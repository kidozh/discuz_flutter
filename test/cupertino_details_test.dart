import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:discuz_flutter/widget/PrivateMessagePortalWidget.dart';
import 'package:discuz_flutter/widget/cupertino_separated_item.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final _site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

Widget _host(
  Widget child, {
  AppVisualStyle style = AppVisualStyle.cupertino,
  Brightness brightness = Brightness.light,
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
        home: Scaffold(body: child),
      ),
    );

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Cupertino separators use a physical hairline in $brightness',
        (tester) async {
      await tester.pumpWidget(_host(
        MediaQuery(
            data: const MediaQueryData(devicePixelRatio: 3),
            child: const CupertinoSeparatedItem(child: SizedBox(height: 40))),
        brightness: brightness,
      ));
      await tester.pumpAndSettle();
      final line = find.descendant(
          of: find.byType(CupertinoListSeparator),
          matching: find.byType(ColoredBox));
      expect(tester.getSize(line).height, closeTo(1 / 3, .00001));
      expect(tester.widget<ColoredBox>(line).color,
          CupertinoColors.separator.resolveFrom(tester.element(line)));
      expect(find.byType(BackdropFilter), findsNothing);
    });
  }

  testWidgets('Material items have no extra separator or layout wrapper',
      (tester) async {
    const item = SizedBox(key: ValueKey('item'), height: 40);
    await tester.pumpWidget(_host(const CupertinoSeparatedItem(child: item),
        style: AppVisualStyle.material));
    expect(find.byType(CupertinoListSeparator), findsNothing);
    expect(find.byType(Column), findsNothing);
    expect(find.byKey(const ValueKey('item')), findsOneWidget);
  });

  testWidgets('private-message rows retain content and gain one separator',
      (tester) async {
    final message = PrivateMessagePortal()
      ..toUserName = 'Alice'
      ..message = 'Private message preview'
      ..dateTimeString = 'Today'
      ..isNew = true;
    await tester.pumpWidget(_host(PrivateMessagePortalWidget(_site, message)));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Private message preview'), findsOneWidget);
    expect(find.byType(CupertinoListSeparator), findsOneWidget);
    expect(tester.widget<PlatformListTile>(find.byType(PlatformListTile)).onTap,
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sliver separators preserve lazy long-post layout',
      (tester) async {
    var built = 0;
    await tester.pumpWidget(_host(CustomScrollView(slivers: [
      CupertinoSeparatedItem(
          sliver: true,
          child: SliverList.builder(
            itemCount: 200,
            itemBuilder: (_, index) {
              built++;
              return SizedBox(height: 80, child: Text('post section $index'));
            },
          )),
    ])));
    await tester.pumpAndSettle();
    expect(find.byType(SliverList), findsOneWidget);
    expect(find.byType(ShrinkWrappingViewport), findsNothing);
    expect(built, lessThan(25));
    expect(tester.takeException(), isNull);
  });

  for (final expanded in [false, true]) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'Cupertino reply field preserves editing ($expanded, $brightness)',
          (tester) async {
        final controller = TextEditingController();
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        final field = PostTextField(_site, controller,
            focusNode: focus,
            expanded: expanded ? true : null,
            embeddedInComposer: !expanded);
        await tester.pumpWidget(_host(
          SizedBox(width: 320, height: expanded ? 260 : null, child: field),
          brightness: brightness,
        ));
        await tester.pumpAndSettle();
        final widget =
            tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
        expect(widget.decoration, isNull);
        expect(find.byType(InputDecorator), findsNothing);
        expect(find.text(S.current.sendReplyHint), findsOneWidget);
        expect(widget.selectionControls,
            same(cupertinoTextSelectionHandleControls));
        expect(widget.keyboardAppearance, brightness);
        expect(widget.expands, expanded);
        expect(
            widget.specialTextSpanBuilder, isA<PostSpecialTextSpanBuilder>());
        final surface = tester.widget<Container>(
            find.byKey(const ValueKey('cupertino-post-input')));
        if (expanded) {
          final decoration = surface.decoration! as BoxDecoration;
          expect(
              decoration.color,
              CupertinoColors.systemBackground
                  .resolveFrom(tester.element(find.byWidget(surface))));
        } else {
          // Embedded editing belongs to the composer's single message bubble.
          expect(surface.decoration, isNull);
        }
        await tester.tap(find.byType(ExtendedTextField));
        await tester.pump();
        expect(focus.hasFocus, isTrue);
        const draft = '回复内容😀\n[attachimg]42[/attachimg]';
        tester.testTextInput.updateEditingValue(const TextEditingValue(
            text: draft,
            selection: TextSelection.collapsed(offset: draft.length)));
        await tester.pump();
        expect(controller.text, draft);
        expect(find.text(S.current.sendReplyHint), findsNothing);
        expect(
            PostTextFieldUtils.getAttachmentAidList(controller.text), ['42']);
        final editable = tester.state<ExtendedEditableTextState>(
            find.byType(ExtendedEditableText));
        final menu = widget.extendedContextMenuBuilder!(
            tester.element(find.byType(ExtendedTextField)), editable);
        expect(menu, isA<CupertinoAdaptiveTextSelectionToolbar>());
        controller.clear();
        await tester.pump();
        expect(find.text(S.current.sendReplyHint), findsOneWidget);
        focus.unfocus();
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('changing reply appearance retains draft and selection',
      (tester) async {
    final controller =
        TextEditingController(text: '已有草稿 [attachimg]12[/attachimg]')
          ..selection = const TextSelection(baseOffset: 0, extentOffset: 4);
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    final field = PostTextField(_site, controller, focusNode: focus);
    await tester.pumpWidget(_host(field, style: AppVisualStyle.material));
    await tester.pumpAndSettle();
    expect(find.byType(InputDecorator), findsOneWidget);
    final before = controller.value;
    await tester.pumpWidget(_host(field));
    await tester.pumpAndSettle();
    expect(controller.value, before);
    expect(find.byType(InputDecorator), findsNothing);
    await tester.pumpWidget(_host(field, style: AppVisualStyle.material));
    await tester.pumpAndSettle();
    expect(controller.value, before);
    expect(find.byType(InputDecorator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('smiley and attachment serialization still uses the original text', () {
    const text = '[smiley]{"code":":)","image":"smile.gif"}[/smiley]'
        '[attachimg]42[/attachimg]';
    final spans = PostSpecialTextSpanBuilder(_site)
        .build(text, textStyle: const TextStyle(fontSize: 17));
    expect(spans.children!.first, isA<ImageSpan>());
    expect((spans.children!.first as ImageSpan).actualText,
        '[smiley]{"code":":)","image":"smile.gif"}[/smiley]');
    expect(
        PostTextFieldUtils.getPostMessage(text), ':)[attachimg]42[/attachimg]');
    expect(PostTextFieldUtils.getAttachmentAidList(text), ['42']);
  });
}
