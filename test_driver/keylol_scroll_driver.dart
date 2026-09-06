import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  const output = 'build/issue12_integration';
  await Directory(output).create(recursive: true);
  await integrationDriver(
    writeResponseOnFailure: true,
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(name)) return false;
      await File('$output/$name.png').writeAsBytes(bytes);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) async {
      final report = Map<String, dynamic>.from(data ?? {});
      final screenshots = report.remove('screenshots') as List<dynamic>?;
      report['screenshot_files'] = [
        for (final shot in screenshots ?? []) '${shot['screenshotName']}.png',
      ];
      await writeResponseData(report,
          testOutputFilename: 'report', destinationDirectory: output);
    },
  );
}
