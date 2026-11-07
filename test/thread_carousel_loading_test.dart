import 'dart:async';
import 'dart:ui' as ui;

import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/ThreadSlideShowCarouselWidget.dart';
import 'package:discuz_flutter/widget/thread_carousel_card.dart';
import 'package:discuz_flutter/widget/thread_carousel_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class DeferredImage extends ImageProvider<DeferredImage> {
  final frame = Completer<ImageInfo>();

  DeferredImage() {
    // A test can complete a request before the corresponding page is built.
    frame.future.ignore();
  }

  @override
  Future<DeferredImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    DeferredImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(frame.future);
}

Widget host(
  Future<List<KeylolCarouselItem>> items,
  List<DeferredImage> images,
  AppVisualStyle style,
  double width,
) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserPreferenceNotifierProvider()),
    ChangeNotifierProvider(
      create: (_) => DiscuzAndUserNotifier()
        ..initDiscuz(
          Discuz(
            'https://keylol.com',
            'X3.4',
            'utf-8',
            4,
            '',
            '',
            false,
            '',
            '',
            'Keylol',
            '0',
            '',
            '',
          ),
        ),
    ),
  ],
  child: PlatformProvider(
    style: style,
    builder: (_) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThreadSlideShowCarouselWidget(
                  loadItems: () => items,
                  imageProviderBuilder: (source) => images[int.parse(source)],
                ),
                const Text('Feed below', key: Key('feed-marker')),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);

List<KeylolCarouselItem> promotions() => [
  for (var index = 0; index < 6; index++)
    KeylolCarouselItem(
      '$index',
      'Promotion $index',
      'Forum',
      'Category',
      'Author',
      index + 1,
      'https://keylol.com/thread-${index + 1}-1-1.html',
    ),
];

Future<ui.Image> artwork(WidgetTester tester) async =>
    (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.blue, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(40, 20);
      picture.dispose();
      return image;
    }))!;

void main() {
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    for (final width in [390.0, 900.0]) {
      testWidgets(
        'slow loading keeps the feed and swiped page stable: $style width=$width',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1200, 900);
          addTearDown(tester.view.reset);
          final request = Completer<List<KeylolCarouselItem>>();
          final images = List.generate(6, (_) => DeferredImage());
          final image = await artwork(tester);
          addTearDown(image.dispose);
          await tester.pumpWidget(host(request.future, images, style, width));
          await tester.pumpAndSettle();
          final marker = tester
              .getTopLeft(find.byKey(const Key('feed-marker')))
              .dy;
          expect(find.byType(PageView), findsNothing);
          expect(find.byType(PlatformCircularProgressIndicator), findsNothing);
          expect(tester.binding.hasScheduledFrame, isFalse);
          request.complete(promotions());
          await tester.pumpAndSettle();
          expect(find.byType(ThreadCarouselCard), findsWidgets);
          expect(
            tester.getTopLeft(find.byKey(const Key('feed-marker'))).dy,
            marker,
          );
          final controller = tester
              .widget<PageView>(find.byType(PageView))
              .controller!;
          final first = controller.page!;
          await tester.pump(const Duration(seconds: 10));
          expect(controller.page, first);
          await tester.drag(find.byType(PageView), const Offset(-300, 0));
          await tester.pumpAndSettle();
          final swiped = controller.page!;
          expect(swiped, greaterThan(first));
          for (final provider in images) {
            provider.frame.complete(ImageInfo(image: image.clone()));
          }
          await tester.pumpAndSettle();
          expect(
            tester.widget<PageView>(find.byType(PageView)).controller,
            same(controller),
          );
          expect(controller.page, swiped);
          expect(
            tester.getTopLeft(find.byKey(const Key('feed-marker'))).dy,
            marker,
          );
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          expect(controller.page, swiped + 1);
          expect(
            tester.getTopLeft(find.byKey(const Key('feed-marker'))).dy,
            marker,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'failed artwork keeps usable promotions without a loading animation',
    (tester) async {
      final images = List.generate(6, (_) => DeferredImage());
      await tester.pumpWidget(
        host(Future.value(promotions()), images, AppVisualStyle.material, 390),
      );
      await tester.pumpAndSettle();
      for (final image in images) {
        image.frame.completeError(StateError('artwork unavailable'));
      }
      await tester.pumpAndSettle();
      expect(find.byType(ThreadCarouselCard), findsWidgets);
      expect(find.text('Promotion 0'), findsOneWidget);
      expect(find.byType(PlatformCircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('request completion after disposal is ignored', (tester) async {
    final request = Completer<List<KeylolCarouselItem>>();
    await tester.pumpWidget(
      host(request.future, [], AppVisualStyle.material, 390),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    request.complete(promotions());
    await tester.pumpAndSettle();
    expect(find.byType(ThreadCarouselLayout), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
