package com.kidozh.discuz_flutter

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterFragmentActivity() {
    private var onDeviceAi: AndroidOnDeviceAiChannel? = null
    private var translation: AndroidTranslationChannel? = null
    private var backgroundNewPosts: BackgroundNewPostsChannel? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        onDeviceAi = AndroidOnDeviceAiChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        translation = AndroidTranslationChannel(flutterEngine.dartExecutor.binaryMessenger)
        backgroundNewPosts = BackgroundNewPostsChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "NativeAd",
            AppNativeAdFactory(this),
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        backgroundNewPosts?.onNewIntent(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "NativeAd")
        onDeviceAi?.dispose()
        onDeviceAi = null
        translation?.close()
        translation = null
        backgroundNewPosts?.close()
        backgroundNewPosts = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
