import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {

  static String get bannerAdUnitTestId {
    return 'ca-app-pub-4589701606972085/2191589113';

    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get nativeAdUnitTestId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    return 'ca-app-pub-3940256099942544/2247696110';
  }

  static NativeAd get forumThreadNativeAd{
    return NativeAd(adUnitId: nativeAdUnitTestId,
        factoryId: "NativeAd",
        listener: NativeAdListener(),
        request: AdRequest());
  }
}