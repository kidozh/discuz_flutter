import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
  final output = 'build/issue12_thermal/$stamp';
  await Directory(output).create(recursive: true);
  await integrationDriver(
    timeout: const Duration(minutes: 10),
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      await writeResponseData(data ?? {},
          testOutputFilename: 'report', destinationDirectory: output);
      // Path only; do not print the complete report or unrelated app logs.
      stdout.writeln('ISSUE12_THERMAL_REPORT $output/report.json');
    },
  );
}
