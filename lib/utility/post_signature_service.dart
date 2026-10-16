import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../entity/post_signature.dart';
import '../generated/l10n.dart';
import 'PostTextFieldUtils.dart';
import 'UserPreferencesUtils.dart';

class PostSignatureService {
  static Future<String> render({
    required PostSignature signature,
    required S strings,
    required Future<String> Function() loadDeviceName,
    required Future<String> Function() loadVersion,
  }) async {
    final device = signature.includesDevice ? await loadDeviceName() : '';
    final version = signature.includesApp ? await loadVersion() : '';
    return switch (signature.style) {
      PostSignatureStyle.none => '',
      PostSignatureStyle.custom => signature.customText,
      PostSignatureStyle.device =>
        device.isEmpty ? '' : strings.fromDeviceSignature(device),
      PostSignatureStyle.app => strings.fromAppOnlySignature(version),
      PostSignatureStyle.appAndDevice =>
        device.isEmpty
            ? strings.fromAppOnlySignature(version)
            : strings.fromAppSignature(device, version),
    };
  }

  static Future<String> append(BuildContext context, String message) async {
    final strings = S.of(context);
    final signature = await UserPreferencesUtils.getSignaturePreference();
    if (!context.mounted) return message;
    final suffix = await render(
      signature: signature,
      strings: strings,
      loadDeviceName: () => PostTextFieldUtils.getDeviceName(context: context),
      loadVersion: () async => (await PackageInfo.fromPlatform()).version,
    );
    return suffix.trim().isEmpty ? message : '$message\n\n$suffix';
  }
}
