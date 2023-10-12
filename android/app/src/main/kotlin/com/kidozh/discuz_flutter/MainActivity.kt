package com.kidozh.discuz_flutter

//import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;
import android.content.Context
import androidx.activity.OnBackPressedCallback;




//
// class MainActivity: FlutterActivity() {
class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        // register the ad factory

        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "NativeAd",
            AppNativeAdFactory(this)
        )

    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "NativeAd")
    }

}
