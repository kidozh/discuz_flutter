import 'dart:io';

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/post_editor_controller.dart';
import 'package:discuz_flutter/widget/PostTextField.dart';
import 'package:discuz_flutter/widget/post_image_preview.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

final _site = Discuz(
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
const _attachment = '[attachimg]42[/attachimg]';
const _hosted = '[img]https://example.com/photo.jpg[/img]';

Widget _host(
  TextEditingController controller,
  FocusNode focus, {
  AppVisualStyle style = AppVisualStyle.material,
  Brightness brightness = Brightness.light,
  bool expanded = false,
  double textScale = 1,
}) => PlatformProvider(
  style: style,
  builder: (_) => MaterialApp(
    locale: const Locale('zh', 'CN'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: Center(
        child: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            platformBrightness: brightness,
          ),
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: brightness),
            child: SizedBox(
              width: 280,
              height: expanded ? 300 : null,
              child: PostTextField(
                _site,
                controller,
                focusNode: focus,
                expanded: expanded ? true : null,
                embeddedInComposer: !expanded,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  const formatter = PostEditorInputFormatter();
  for (final token in [
    _attachment,
    _hosted,
    '[IMG=200,100]https://example.com/p.jpg[/IMG]',
    '[smiley]{"code":":)","image":"smile.gif"}[/smiley]',
  ]) {
    test('keyboard edits treat $token as one object', () {
      final text = '前${token}后';
      final start = 1;
      final end = 1 + token.length;
      for (final range in [
        TextRange(start: start, end: start + 1), // forward delete
        TextRange(start: end - 1, end: end), // backspace
        TextRange(start: start + 2, end: end - 2), // partial selection
        TextRange(start: start, end: end), // replace full selection
      ]) {
        for (final inserted in ['', '新文字']) {
          final result = formatter.formatEditUpdate(
            TextEditingValue(
              text: text,
              selection: TextSelection(
                baseOffset: range.start,
                extentOffset: range.end,
              ),
            ),
            TextEditingValue(
              text: text.replaceRange(range.start, range.end, inserted),
              selection: TextSelection.collapsed(
                offset: range.start + inserted.length,
              ),
            ),
          );
          expect(result.text, '前${inserted}后');
          expect(result.selection.extentOffset, 1 + inserted.length);
        }
      }
    });
  }

  test('range spanning two images preserves surrounding text and paste', () {
    const text = '头$_attachment 中 $_hosted尾';
    final start = text.indexOf('42');
    final end = text.indexOf('photo') + 3;
    final result = formatter.formatEditUpdate(
      TextEditingValue(text: text),
      TextEditingValue(
        text: text.replaceRange(start, end, '替换😀'),
        selection: TextSelection.collapsed(offset: start + 4),
      ),
    );
    expect(result.text, '头替换😀尾');
    expect(result.selection.extentOffset, '头替换😀'.length);
  });

  test('Chinese composition beside an image is unchanged', () {
    const old = TextEditingValue(text: '$_attachment\n');
    const next = TextEditingValue(
      text: '$_attachment\nzhong',
      selection: TextSelection.collapsed(offset: _attachment.length + 6),
      composing: TextRange(
        start: _attachment.length + 1,
        end: _attachment.length + 6,
      ),
    );
    expect(formatter.formatEditUpdate(old, next), next);
  });

  test('undo restores complete images that share markup prefixes', () {
    const restored = '[attachimg]99[/attachimg]';
    final result = formatter.formatEditUpdate(
      const TextEditingValue(
        text: _attachment,
        selection: TextSelection.collapsed(offset: _attachment.length),
      ),
      const TextEditingValue(
        text: restored,
        selection: TextSelection.collapsed(offset: restored.length),
      ),
    );
    expect(result.text, restored);
  });

  test(
    'a stale keyboard deletion inside a URL still removes the whole image',
    () {
      const text = '$_hosted尾';
      final offset = text.indexOf('photo');
      final result = formatter.formatEditUpdate(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: offset),
        ),
        TextEditingValue(
          text: text.replaceRange(offset, offset + 1, ''),
          selection: TextSelection.collapsed(offset: offset),
        ),
      );
      expect(result.text, '尾');
    },
  );

  test(
    'insertion uses cursor and reverse selection with clean image paragraphs',
    () {
      final controller = PostEditorController(text: '前文后文');
      addTearDown(controller.dispose);
      controller.selection = const TextSelection.collapsed(offset: 2);
      controller.insertAttachment('42', '/private/photo.jpg');
      expect(controller.text, '前文\n$_attachment\n后文');
      expect(controller.selection.extentOffset, '前文\n$_attachment\n'.length);
      expect(controller.imagePathFor(_attachment), '/private/photo.jpg');
      expect(controller.text, isNot(contains('/private/')));
      controller.selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length - 2,
      );
      controller.insertHostedImage(
        'https://example.com/photo.jpg',
        '/private/hosted.jpg',
      );
      expect(controller.text, '前文\n$_attachment\n$_hosted\n');
      expect(PostTextFieldUtils.getAttachmentAidList(controller.text), ['42']);
      controller.insertText('继续');
      expect(controller.text.endsWith('$_hosted\n继续'), isTrue);
    },
  );

  test('removing an image only removes its own line and submission attachment', () {
    final controller = PostEditorController(text: '前文\n$_attachment\n后文');
    addTearDown(controller.dispose);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    removePostEditorImage(
      controller,
      PostEditorToken.inText(controller.text).single,
    );
    expect(controller.text, '前文\n后文');
    expect(controller.selection.extentOffset, controller.text.length);
    expect(PostTextFieldUtils.getAttachmentAidList(controller.text), isEmpty);
    // A button left over from an earlier frame must not delete unrelated text.
    removePostEditorImage(controller, PostEditorToken(3, _attachment));
    expect(controller.text, '前文\n后文');
  });

  testWidgets(
    'backspace, forward delete, selection replacement and undo never expose markup',
    (tester) async {
      final controller = PostEditorController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(_host(controller, focus, expanded: true));
      focus.requestFocus();
      await tester.pumpAndSettle();
      for (final token in [_attachment, _hosted]) {
        for (final forward in [false, true]) {
          controller.value = TextEditingValue(
            text: '前${token}后',
            selection: TextSelection.collapsed(
              offset: forward ? 1 : 1 + token.length,
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(
            forward ? LogicalKeyboardKey.delete : LogicalKeyboardKey.backspace,
          );
          await tester.pumpAndSettle();
          expect(controller.text, '前后');
          expect(find.byType(PostImagePreview), findsNothing);
        }
        controller.value = TextEditingValue(
          text: '前${token}后',
          selection: TextSelection(
            baseOffset: 1,
            extentOffset: 1 + token.length,
          ),
        );
        await tester.pumpAndSettle();
        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: '前好后',
            selection: TextSelection.collapsed(offset: 2),
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.text, '前好后');
        // Undo restores the complete token, rather than partially deleted markup.
        await tester.pump(const Duration(milliseconds: 600));
        tester
            .state<UndoHistoryState<TextEditingValue>>(
              find.byType(UndoHistory<TextEditingValue>),
            )
            .undo();
        await tester.pumpAndSettle();
        expect(controller.text, '前${token}后');
        expect(find.byType(PostImagePreview), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final style in AppVisualStyle.values) {
    for (final brightness in Brightness.values) {
      for (final expanded in [false, true]) {
        testWidgets('image cards fit $style $brightness expanded=$expanded', (
          tester,
        ) async {
          final controller = PostEditorController(
            text: '文字\n$_attachment\n[attachimg]99[/attachimg]\n继续',
          );
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          await tester.pumpWidget(
            _host(
              controller,
              focus,
              style: style,
              brightness: brightness,
              expanded: expanded,
              textScale: expanded ? 2 : 1,
            ),
          );
          await tester.pumpAndSettle();
          final previews = tester.widgetList<PostImagePreview>(
            find.byType(PostImagePreview),
          );
          expect(previews.map((e) => e.number), [1, 2]);
          final editable = tester.state<ExtendedEditableTextState>(
            find.byType(ExtendedEditableText),
          );
          expect(
            editable.renderEditable.text!.toPlainText(),
            isNot(contains('[attachimg]')),
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }

  testWidgets(
    'image after Chinese composition keeps numbering and removes the right occurrence',
    (tester) async {
      final controller = PostEditorController(
        text: '$_attachment中$_attachment',
      );
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(_host(controller, focus, expanded: true));
      focus.requestFocus();
      await tester.pumpAndSettle();
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: controller.text,
          selection: const TextSelection.collapsed(
            offset: _attachment.length + 1,
          ),
          composing: const TextRange(
            start: _attachment.length,
            end: _attachment.length + 1,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<PostImagePreview>(find.byType(PostImagePreview))
            .map((e) => e.number),
        [1, 2],
      );
      await tester.tap(find.byTooltip(S.current.removeComposerImage(2)));
      await tester.pumpAndSettle();
      expect(controller.text, '${_attachment}中');
      expect(PostTextFieldUtils.getAttachmentAidList(controller.text), ['42']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets(
      'compact $style image remove button stays visible at the insertion cursor',
      (tester) async {
        final controller = PostEditorController()..insertAttachment('42', '');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(_host(controller, focus, style: style));
        focus.requestFocus();
        await tester.pumpAndSettle();
        final button = find.byTooltip(S.current.removeComposerImage(1));
        final field = tester.getRect(find.byType(ExtendedEditableText));
        final rect = tester.getRect(button);
        expect(rect.top, greaterThanOrEqualTo(field.top));
        expect(rect.bottom, lessThanOrEqualTo(field.bottom));
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(controller.text, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('IME never renders image source as composing text', (
    tester,
  ) async {
    final controller = PostEditorController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(_host(controller, focus, expanded: true));
    focus.requestFocus();
    await tester.pumpAndSettle();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: _attachment,
        selection: TextSelection.collapsed(offset: _attachment.length),
        composing: TextRange(start: 0, end: _attachment.length),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.value.composing, TextRange.empty);
    final editable = tester.state<ExtendedEditableTextState>(
      find.byType(ExtendedEditableText),
    );
    expect(
      editable.renderEditable.text!.toPlainText(),
      isNot(contains('[attachimg]')),
    );
    expect(find.byType(PostImagePreview), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'switching draft controllers updates image sources and selection ownership',
    (tester) async {
      final first = PostEditorController()
        ..insertAttachment('42', '/first.jpg');
      final second = PostEditorController()
        ..insertAttachment('99', '/second.jpg');
      final focus = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(_host(first, focus, expanded: true));
      final state = tester.state(find.byType(PostTextField));
      await tester.pumpWidget(_host(second, focus, expanded: true));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(PostTextField)), same(state));
      expect(
        tester
            .widget<PostImagePreview>(find.byType(PostImagePreview))
            .localPath,
        '/second.jpg',
      );
      first.clear();
      await tester.pump();
      expect(second.text, '[attachimg]99[/attachimg]\n');
      expect(find.byType(PostImagePreview), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a new local upload renders a clear thumbnail without attachment history',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'discuz-image-preview-',
      );
      final image = File('${directory.path}/test.png');
      File('assets/images/netease_cloud_music.png').copySync(image.path);
      addTearDown(() => directory.deleteSync(recursive: true));
      final controller = PostEditorController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(_host(controller, focus, expanded: true));
      await tester.runAsync(() async {
        await precacheImage(
          ResizeImage.resizeIfNeeded(384, null, FileImage(image)),
          tester.element(find.byType(PostTextField)),
        );
      });
      controller.insertAttachment('42', image.path);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PostImagePreview>(find.byType(PostImagePreview))
            .localPath,
        image.path,
      );
      expect(
        find.descendant(
          of: find.byType(PostImagePreview),
          matching: find.byType(ImageFiltered),
        ),
        findsNothing,
      );
      expect(
        tester
            .widget<RawImage>(
              find.descendant(
                of: find.byType(PostImagePreview),
                matching: find.byType(RawImage),
              ),
            )
            .image,
        isNotNull,
      );
      await tester.tap(find.byTooltip(S.current.removeComposerImage(1)));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      expect(find.byType(PostImagePreview), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
