import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/DiscuzQuoteBlock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders standalone and Discuz wrapped quotes as native cards',
      (tester) async {
    final discuz = Discuz(
      'https://example.com',
      'X3.5',
      'utf-8',
      4,
      '1.4.8',
      'register',
      false,
      '0',
      '0',
      'Example',
      '1',
      'https://example.com/uc_server',
      '0',
      trueDiscuzVersion: 'X3.5',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TypeSettingNotifierProvider()),
          ChangeNotifierProvider(create: (_) => ThemeNotifierProvider()),
        ],
        child: MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: DiscuzHtmlWidget(
              discuz,
              '<blockquote><p>Standalone quote</p></blockquote>'
              '<div class="quote"><blockquote>'
              '<a href="https://example.com/source">Discuz quote</a>'
              '</blockquote></div>',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DiscuzQuoteBlock), findsNWidgets(2));
    expect(find.byKey(const ValueKey('discuz-quote-block')), findsNWidgets(2));
    expect(find.byKey(const ValueKey('discuz-quote-accent')), findsNWidgets(2));
    expect(find.text('Standalone quote', findRichText: true), findsOneWidget);
    expect(find.text('Discuz quote', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
