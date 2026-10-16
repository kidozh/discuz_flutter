import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PostTextFieldUtils.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_utsname_ext/extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceReader extends DeviceInfoPlugin {
  final Future<BaseDeviceInfo> result;
  DeviceReader(BaseDeviceInfo info) : result = Future.value(info);
  DeviceReader.pending(this.result);
  @override
  Future<BaseDeviceInfo> get deviceInfo => result;
}

final iphone = IosDeviceInfo.setMockInitialValues(
  name: 'Private name',
  systemName: 'iOS',
  systemVersion: '27.1',
  model: 'iPhone',
  modelName: 'iPhone',
  localizedModel: 'iPhone',
  freeDiskSize: 0,
  totalDiskSize: 0,
  isPhysicalDevice: true,
  isiOSAppOnMac: false,
  isiOSAppOnVision: false,
  physicalRamSize: 0,
  availableRamSize: 0,
  utsname: IosUtsname.setMockInitialValues(
    sysname: 'Darwin',
    nodename: '',
    release: '',
    version: '',
    machine: 'iPhone14,2',
  ),
);
final linux = LinuxDeviceInfo(
  name: 'Ubuntu',
  id: 'ubuntu',
  prettyName: 'Ubuntu',
  machineId: null,
);

void main() {
  testWidgets(
    'iPhone metadata does not require localization at the application root',
    (tester) async {
      BuildContext? root;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            root = context;
            return const SizedBox();
          },
        ),
      );
      expect(S.maybeOf(root!), isNull);
      expect(
        await PostTextFieldUtils.getDeviceName(
          context: root,
          deviceInfo: DeviceReader(iphone),
        ),
        iphone.utsname.machine.iOSProductName,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('background metadata is available without any context', (
    tester,
  ) async {
    expect(
      await PostTextFieldUtils.getDeviceName(deviceInfo: DeviceReader(iphone)),
      iphone.utsname.machine.iOSProductName,
    );
    expect(
      await PostTextFieldUtils.getDeviceName(deviceInfo: DeviceReader(linux)),
      'Ubuntu',
    );
  });

  testWidgets(
    'missing or disposed desktop localization falls back to the raw name',
    (tester) async {
      BuildContext? context;
      await tester.pumpWidget(
        Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      );
      expect(
        await PostTextFieldUtils.getDeviceName(
          context: context,
          deviceInfo: DeviceReader(linux),
        ),
        'Ubuntu',
      );
      await tester.pumpWidget(const SizedBox());
      expect(context!.mounted, isFalse);
      expect(
        await PostTextFieldUtils.getDeviceName(
          context: context,
          deviceInfo: DeviceReader(linux),
        ),
        'Ubuntu',
      );
    },
  );

  testWidgets(
    'UI device labels retain the selected locale across an asynchronous query',
    (tester) async {
      BuildContext? context;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: const [
            S.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final expected = S.of(context!).linuxDeviceName('Ubuntu');
      final query = Completer<BaseDeviceInfo>();
      final name = PostTextFieldUtils.getDeviceName(
        context: context,
        deviceInfo: DeviceReader.pending(query.future),
      );
      await tester.pumpWidget(const SizedBox());
      query.complete(linux);
      expect(await name, expected);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unavailable native metadata or push services do not escape initialization',
    (tester) async {
      const channel = MethodChannel('dev.fluttercommunity.plus/device_info');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'unavailable'),
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      PackageInfo.setMockInitialValues(
        appName: 'DisFly',
        packageName: 'test',
        version: '2.0.8',
        buildNumber: '164',
        buildSignature: '',
      );
      // A Flutter test has no native device-info/Firebase app registration. This
      // must resolve to no token instead of an unhandled startup exception.
      expect(await PushServiceUtils.getPushToken(), isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
