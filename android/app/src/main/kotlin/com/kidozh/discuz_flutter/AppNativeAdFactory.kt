package com.kidozh.discuz_flutter

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin


class AppNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd, customOptions: Map<String?, Any?>?
    ): NativeAdView {
        val adView: NativeAdView = LayoutInflater.from(context).inflate(R.layout.app_native_ad, null) as NativeAdView
        with(adView){
            val headlineView: TextView = adView.findViewById(R.id.ad_headline)
            val bodyView: TextView = adView.findViewById(R.id.ad_body)
            headlineView.text = nativeAd.headline
            bodyView.text = nativeAd.body
            adView.setBackgroundColor(Color.YELLOW)
            adView.setNativeAd(nativeAd)
            adView.bodyView = bodyView
            adView.headlineView = headlineView
        }

        return adView
    }
}