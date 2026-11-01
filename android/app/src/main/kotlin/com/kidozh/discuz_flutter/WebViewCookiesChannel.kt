package com.kidozh.discuz_flutter

import android.net.Uri
import android.webkit.CookieManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Shares Android WebView's real cookie store, including HttpOnly cookies. */
class WebViewCookiesChannel(messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "com.kidozh.discuz_flutter/webview_cookies")

    init {
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        val manager = CookieManager.getInstance()
        if (call.method == "clearCookies") {
            manager.removeAllCookies {
                manager.flush()
                result.success(null)
            }
            return
        }
        if (call.method != "getCookies" && call.method != "setCookies") {
            result.notImplemented()
            return
        }
        val rawURL = call.argument<String>("url")
        val url = rawURL?.let(Uri::parse)
        if (rawURL == null || url == null || url.host.isNullOrEmpty() || url.scheme !in listOf("http", "https")) {
            result.error("invalid_url", "An HTTP(S) URL is required", null)
            return
        }
        if (call.method == "getCookies") {
            result.success(parseWebViewCookieHeader(manager.getCookie(rawURL)))
        } else {
            val headers = call.argument<List<String>>("cookies")
            if (headers == null) {
                result.error("invalid_cookies", "Cookie headers are required", null)
                return
            }
            if (headers.isEmpty()) {
                result.success(null)
                return
            }
            var pending = headers.size
            for (header in headers) {
                manager.setCookie(rawURL, header) {
                    pending -= 1
                    if (pending == 0) {
                        manager.flush()
                        result.success(null)
                    }
                }
            }
        }
    }

    fun close() {
        channel.setMethodCallHandler(null)
    }
}

// CookieManager exposes a Cookie header, not Set-Cookie attributes. Keep the
// entire value after the first '='; encoded Discuz auth values can end in '=='.
internal fun parseWebViewCookieHeader(header: String?): List<Map<String, String>> =
    header.orEmpty().split(';').mapNotNull { entry ->
        val pair = entry.trim()
        val separator = pair.indexOf('=')
        if (separator <= 0) null
        else mapOf("name" to pair.substring(0, separator), "value" to pair.substring(separator + 1))
    }
