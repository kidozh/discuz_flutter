import 'dart:async';
import 'package:flutter/services.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/OnDeviceAiService.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.kidozh.discuz_flutter/on_device_ai');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  testWidgets('Android availability times out when the native service stalls',
      (tester) async {
    messenger.setMockMethodCallHandler(
        channel, (_) => Completer<Object?>().future);
    final pending = OnDeviceAiService.checkAndroidAvailability();
    await tester.pump(const Duration(seconds: 16));
    final result = await pending;
    expect(result.status, OnDeviceAiAvailabilityStatus.error);
    expect(result.reasonCode, 'check_timeout');
  });

  test('Android availability handles an unregistered plugin', () async {
    final result = await OnDeviceAiService.checkAndroidAvailability();
    expect(result.status, OnDeviceAiAvailabilityStatus.error);
    expect(result.reasonCode, 'check_failed');
  });

  test('Android availability preserves a successful service response',
      () async {
    messenger.setMockMethodCallHandler(
        channel, (_) async => {'status': 'available', 'platform': 'android'});
    expect((await OnDeviceAiService.checkAndroidAvailability()).isAvailable,
        isTrue);
  });

  group('OnDeviceAiAvailability', () {
    const cases = <String, OnDeviceAiAvailabilityStatus>{
      'available': OnDeviceAiAvailabilityStatus.available,
      'downloadable': OnDeviceAiAvailabilityStatus.downloadable,
      'downloading': OnDeviceAiAvailabilityStatus.downloading,
      'needsAICoreUpdate': OnDeviceAiAvailabilityStatus.needsAICoreUpdate,
      'needsSystemUpdate': OnDeviceAiAvailabilityStatus.needsSystemUpdate,
      'notEnoughStorage': OnDeviceAiAvailabilityStatus.notEnoughStorage,
      'temporarilyUnavailable':
          OnDeviceAiAvailabilityStatus.temporarilyUnavailable,
      'unsupportedPlatform': OnDeviceAiAvailabilityStatus.unsupportedPlatform,
      'error': OnDeviceAiAvailabilityStatus.error,
      'unavailable': OnDeviceAiAvailabilityStatus.unavailable,
    };

    for (final entry in cases.entries) {
      test('parses ${entry.key}', () {
        final availability = OnDeviceAiAvailability.fromMap({
          'status': entry.key,
          'reasonCode': 'test_reason',
          'nativeCode': -101,
          'osVersion': '16',
          'platform': 'android',
        });

        expect(availability.status, entry.value);
        expect(availability.reasonCode, 'test_reason');
        expect(availability.nativeCode, -101);
        expect(availability.platform, 'android');
      });
    }

    test('only available status enables inference', () {
      final available = OnDeviceAiAvailability.fromMap({
        'status': 'available',
      });
      final downloadable = OnDeviceAiAvailability.fromMap({
        'status': 'downloadable',
      });

      expect(available.isAvailable, isTrue);
      expect(downloadable.isAvailable, isFalse);
      expect(downloadable.canDownload, isTrue);
    });
  });

  test('download event preserves byte progress and native errors', () {
    final event = OnDeviceAiDownloadEvent.fromMap({
      'state': 'progress',
      'downloadedBytes': 1024,
      'totalBytes': 4096,
      'reasonCode': 'not_enough_disk_space',
      'nativeCode': 501,
    });

    expect(event.state, OnDeviceAiDownloadState.progress);
    expect(event.downloadedBytes, 1024);
    expect(event.totalBytes, 4096);
    expect(event.nativeCode, 501);
  });

  test('preference provider retains setup status without enabling AI', () {
    final provider = UserPreferenceNotifierProvider();
    provider.setAppleIntelligenceEnabled(true);
    provider.setOnDeviceAiAvailability(
      const OnDeviceAiAvailability(
        status: OnDeviceAiAvailabilityStatus.downloadable,
      ),
    );

    expect(provider.appleIntelligenceAvailabilityChecked, isTrue);
    expect(provider.appleIntelligenceAvailable, isFalse);
    expect(provider.appleIntelligenceEnabled, isFalse);
    expect(
      provider.onDeviceAiStatus,
      OnDeviceAiAvailabilityStatus.downloadable,
    );
  });
}
