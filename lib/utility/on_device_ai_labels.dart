import 'dart:io';

import 'package:discuz_flutter/generated/l10n.dart';

/// Name the actual OS provider, independently of the chosen visual style.
class OnDeviceAiLabels {
  static String name(S strings) {
    if (Platform.isAndroid) return strings.onDeviceAiNameAndroid;
    if (Platform.isIOS || Platform.isMacOS) return strings.onDeviceAiNameApple;
    return strings.appleIntelligence;
  }

  static String enable(S strings) {
    if (Platform.isAndroid) return strings.onDeviceAiEnableAndroid;
    if (Platform.isIOS || Platform.isMacOS) return strings.onDeviceAiEnableApple;
    return strings.appleIntelligenceEnabled;
  }
}
