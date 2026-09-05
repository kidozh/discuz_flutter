import 'dart:convert';

import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/utility/DiscuzCheckResponseUtils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const response = <String, dynamic>{
    'discuzversion': 'X3.2',
    'truediscuzversion': 'X3.5',
    'charset': 'utf-8',
    'version': 4,
    'pluginversion': '1.4.8',
    'regname': 'register',
    'qqconnect': 0,
    'wsqqqconnect': '0',
    'wsqhideregister': '0',
    'sitename': '远景论坛',
    'mysiteid': 1326486,
    'ucenterurl': 'https://uc.example.com',
    'defaultfid': null,
    'testcookie': null,
  };

  test('decodes and normalizes a raw Discuz check response', () {
    final decoded = DiscuzCheckResponseUtils.tryDecode(jsonEncode(response));

    expect(decoded, isNotNull);
    expect(decoded!['version'], '4');
    expect(decoded['qqconnect'], '0');
    expect(decoded['mysiteid'], '1326486');
    expect(decoded['defaultfid'], '0');
    expect(CheckResult.fromJson(decoded).siteName, '远景论坛');
  });

  test('decodes JSON displayed inside a browser pre element', () {
    final escapedJson = const HtmlEscape().convert(jsonEncode(response));
    final html = '<html><body><pre>$escapedJson</pre></body></html>';

    final decoded = DiscuzCheckResponseUtils.tryDecode(html);

    expect(decoded?['discuzversion'], 'X3.2');
    expect(decoded?['sitename'], '远景论坛');
  });

  test('decodes a JSON-encoded JavaScript string result', () {
    final javascriptResult = jsonEncode(jsonEncode(response));

    final decoded = DiscuzCheckResponseUtils.tryDecode(javascriptResult);

    expect(decoded?['truediscuzversion'], 'X3.5');
  });

  test('does not mistake security challenge JSON for a Discuz response', () {
    const challenge = '''
      <html><body><script>
        fetch('/__access_review').then(() => ({"ok": true}));
      </script></body></html>
    ''';

    expect(DiscuzCheckResponseUtils.tryDecode(challenge), isNull);
  });
}
