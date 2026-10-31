import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/ToastUtils.dart';
import 'package:discuz_flutter/widget/post_copy_menu_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final style in AppVisualStyle.values.where(
    (style) => style != AppVisualStyle.system,
  )) {
    for (final empty in [false, true]) {
      testWidgets('post menu copies readable text: $style empty=$empty', (
        tester,
      ) async {
        var copied = 'existing clipboard';
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(() {
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          );
        });
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              locale: const Locale('zh', 'CN'),
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: ToastUtils.easyLoadingBuilder(),
              home: Scaffold(
                body: Builder(
                  builder: (context) => PlatformPopupMenu(
                    icon: const Icon(Icons.more_horiz),
                    options: [
                      postCopyMenuOption(
                        context,
                        html: empty
                            ? '<p><img src="image.png"></p>'
                            : '<p>其乐 <b>正文</b> &amp; 🎮</p>'
                                  '<blockquote>引用文字</blockquote>'
                                  '<p>下一行<br>末行</p>'
                                  '<script>not post text</script>'
                                  '<span hidden>not visible</span>',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(PlatformPopupMenu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('复制正文'));
        await tester.pumpAndSettle();
        expect(
          copied,
          empty ? 'existing clipboard' : '其乐 正文 & 🎮\n引用文字\n下一行\n末行',
        );
        expect(find.text(empty ? '这条帖子没有可复制的文字。' : '正文已复制'), findsOneWidget);
        await EasyLoading.dismiss(animation: false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
