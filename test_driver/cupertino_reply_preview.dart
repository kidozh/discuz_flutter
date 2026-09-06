// Local visual check: flutter test test_driver/cupertino_reply_preview.dart
// Renders production widgets, with locally available macOS fonts, into build/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/ThreadReplyTargetBanner.dart';
import 'package:discuz_flutter/widget/thread_reply_composer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'CupertinoSystemText': '/System/Library/Fonts/SFNS.ttf',
      'PreviewCJK': '/System/Library/Fonts/STHeiti Light.ttc',
    }.entries) {
      final file = File(entry.value);
      if (await file.exists()) {
        await (FontLoader(entry.key)
              ..addFont(file
                  .readAsBytes()
                  .then((bytes) => ByteData.sublistView(bytes))))
            .load();
      }
    }
    await (FontLoader('packages/cupertino_icons/CupertinoIcons')
          ..addFont(rootBundle
              .load('packages/cupertino_icons/assets/CupertinoIcons.ttf')))
        .load();
  });

  testWidgets('render actual Cupertino reply widgets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '',
        false, '0', '0', 'Example', '1', '', '0');
    final controllers = [
      TextEditingController(),
      TextEditingController(text: '收到，我来试一下这个方案。'),
      TextEditingController(text: '补充两点：\n表情和图片也可以继续使用。'),
      TextEditingController(text: '深色模式下的回复'),
    ];
    final focuses = List.generate(4, (_) => FocusNode());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
      for (final focus in focuses) {
        focus.dispose();
      }
    });
    final boundary = GlobalKey();
    Widget example(int index, String label,
        {bool dark = false, bool quote = false}) {
      final brightness = dark ? Brightness.dark : Brightness.light;
      return Theme(
        data: ThemeData(brightness: brightness, fontFamily: 'PreviewCJK'),
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: brightness,
            textTheme: const CupertinoTextThemeData(
                textStyle: TextStyle(
                    fontFamily: 'CupertinoSystemText',
                    fontFamilyFallback: ['PreviewCJK'],
                    fontSize: 17,
                    textBaseline: TextBaseline.alphabetic)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'PreviewCJK',
                        fontSize: 12,
                        color: dark ? Colors.white70 : Colors.black54))),
            CupertinoThreadReplyComposer(
                discuz: site,
                controller: controllers[index],
                focusNode: focuses[index],
                panelVisible: false,
                sendStatus: SendReplyStatus.idle,
                onTogglePanel: () {},
                onSend: () {},
                replyTarget: quote
                    ? ThreadReplyTargetBanner(
                        author: '小林',
                        messageHtml: '希望回复框像 iMessage 一样简洁。',
                        picturePlaceholder: '[图片]',
                        embeddedInComposer: true,
                        onDismiss: () {})
                    : const SizedBox.shrink()),
          ]),
        ),
      );
    }

    await tester.pumpWidget(PlatformProvider(
      style: AppVisualStyle.cupertino,
      builder: (_) => MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
            body: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: boundary,
            child: ColoredBox(
              color: Colors.white,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                example(0, '空白 · 左侧添加，右侧输入'),
                example(1, '输入 · 框内蓝色发送按钮'),
                example(2, '引用 · 可取消，支持多行', quote: true),
                const SizedBox(height: 16),
                ColoredBox(
                    color: Colors.black, child: example(3, '深色模式', dark: true)),
              ]),
            ),
          ),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('build/cupertino-reply-preview.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
