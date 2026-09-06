import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _site = Discuz('https://example.com', 'X3.5', 'utf-8', 4, '', '', false,
    '0', '0', 'Example', '1', '', '0');

Widget _host(TargetPlatform target, Widget Function(BuildContext) builder) =>
    MaterialApp(
        localizationsDelegates: const [S.delegate],
        home: PlatformProvider(
            initialPlatform: target,
            builder: (context) =>
                Scaffold(body: Center(child: builder(context)))));

CachedNetworkImage _image(InkWell avatar) =>
    (avatar.child as PlatformLiquidGlassAvatar).child as CachedNetworkImage;

void main() {
  testWidgets('Cupertino pending avatar is static, sized and accessible',
      (tester) async {
    await tester.pumpWidget(_host(TargetPlatform.iOS, (context) {
      final avatar =
          UserAvatar(_site, 123, 'Alice', size: 40).build(context) as InkWell;
      return _image(avatar).progressIndicatorBuilder!(
          context, '', const DownloadProgress('', null, 0));
    }));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('A'), findsOneWidget);
    expect(tester.getSize(find.byType(SizedBox).last), const Size(40, 40));
    final labels = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((widget) => widget.properties.label ?? '');
    expect(
        labels.any((label) =>
            label.contains('Alice') && label.contains(S.current.loading)),
        isTrue);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Material keeps its determinate download progress',
      (tester) async {
    await tester.pumpWidget(_host(TargetPlatform.android, (context) {
      final avatar =
          UserAvatar(_site, 123, 'Alice', size: 40).build(context) as InkWell;
      return _image(avatar).progressIndicatorBuilder!(
          context, '', const DownloadProgress('', 100, 50));
    }));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<CircularProgressIndicator>(
                find.byType(CircularProgressIndicator))
            .value,
        .5);
  });

  testWidgets(
      'original image provider, error fallback and tap availability are preserved',
      (tester) async {
    const original = NetworkImage('https://example.com/original.png');
    await tester.pumpWidget(_host(TargetPlatform.iOS, (context) {
      final enabled =
          UserAvatar(_site, 123, 'Alice', size: 40).build(context) as InkWell;
      final disabled = UserAvatar(_site, 123, 'Alice', disableTap: true)
          .build(context) as InkWell;
      expect(enabled.onTap, isNotNull);
      expect(disabled.onTap, isNull);
      final image = _image(enabled);
      final rendered = image.imageBuilder!(context, original) as DecoratedBox;
      expect(
          (rendered.decoration as BoxDecoration).image!.image, same(original));
      return image.errorWidget!(context, '', StateError('test failure'));
    }));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
