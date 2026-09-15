package com.kidozh.discuz_flutter

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterFragmentActivity() {
    private var onDeviceAi: AndroidOnDeviceAiChannel? = null
    private var translation: AndroidTranslationChannel? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        onDeviceAi = AndroidOnDeviceAiChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        translation = AndroidTranslationChannel(flutterEngine.dartExecutor.binaryMessenger)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "NativeAd",
            AppNativeAdFactory(this),
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "NativeAd")
        onDeviceAi?.dispose()
        onDeviceAi = null
        translation?.close()
        translation = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
