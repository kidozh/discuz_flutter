import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/BilibiliWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wide preview is compact and narrow panes retain phone details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final width = ValueNotifier<double>(1100);
    addTearDown(width.dispose);
    final key = GlobalKey<BilibiliVideoState>();
    await tester.pumpWidget(
      PlatformProvider(
        style: AppVisualStyle.material,
        builder: (_) => MaterialApp(
          localizationsDelegates: const [S.delegate],
          home: Scaffold(
            body: ValueListenableBuilder<double>(
              valueListenable: width,
              builder: (_, value, __) => SizedBox(
                width: value,
                child: BilibiliWidget(
                  'https://www.bilibili.com/video/',
                  key: key,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    key.currentState!.setState(() {
      final data = key.currentState!.videoResult.data.viewData;
      data.pic = 'https://example.invalid/cover.jpg';
      data.title = 'A video title';
      data.desc = 'An existing video description for the wide preview.';
      data.owner.name = 'Creator';
      data.pubdate = 1700000000;
      data.duration = 125;
      data.videos = 3;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Duration 02:05'), findsOneWidget);
    expect(find.text('3 parts'), findsOneWidget);
    expect(find.textContaining('Published '), findsOneWidget);
    final image = find.byType(CachedNetworkImage);
    expect(tester.getSize(image).width, lessThanOrEqualTo(280));
    expect(
      find.text('An existing video description for the wide preview.'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('A video title')).dx,
      greaterThan(tester.getTopRight(image).dx),
    );

    width.value = 380;
    await tester.pump();
    expect(find.text('A video title'), findsOneWidget);
    expect(
      find.text('An existing video description for the wide preview.'),
      findsNothing,
    );
    expect(find.text('Duration 02:05'), findsNothing);
    expect(find.text('3 parts'), findsNothing);
    expect(find.text('02:05'), findsOneWidget);
    expect(tester.takeException(), isNull);

    width.value = 1100;
    key.currentState!.setState(() {
      final data = key.currentState!.videoResult.data.viewData;
      data.pubdate = 0;
      data.duration = 0;
      data.videos = 1;
    });
    await tester.pump();
    expect(find.textContaining('Published '), findsNothing);
    expect(find.textContaining('Duration '), findsNothing);
    expect(find.text('1 parts'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
