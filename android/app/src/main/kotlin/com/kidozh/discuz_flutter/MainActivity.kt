package com.kidozh.discuz_flutter

import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterFragmentActivity() {
    private var onDeviceAi: AndroidOnDeviceAiChannel? = null
    private var translation: AndroidTranslationChannel? = null
    private var backgroundNewPosts: BackgroundNewPostsChannel? = null
    private var webViewCookies: WebViewCookiesChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 15 and later enforce edge-to-edge for this app's target SDK.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            enableEdgeToEdge()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        onDeviceAi = AndroidOnDeviceAiChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        translation = AndroidTranslationChannel(flutterEngine.dartExecutor.binaryMessenger)
        backgroundNewPosts = BackgroundNewPostsChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        webViewCookies = WebViewCookiesChannel(flutterEngine.dartExecutor.binaryMessenger)
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
        webViewCookies?.close()
        webViewCookies = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
