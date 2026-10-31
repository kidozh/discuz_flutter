package com.kidozh.discuz_flutter

import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.concurrent.Executors

internal class BackgroundNewPostsChannel(
    private val activity: MainActivity,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, "com.kidozh.discuz_flutter/background_new_posts")
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var listening = false

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method == "takeNotification") {
                listening = true
                result.success(takeNotification())
                return@setMethodCallHandler
            }
            executor.execute {
                try {
                    val store = NewPostStore.get(activity)
                    when (call.method) {
                        "syncSites" -> {
                            val args = call.arguments as? List<*> ?: throw IllegalArgumentException()
                            val sites = args.map { item ->
                                val row = item as? Map<*, *> ?: throw IllegalArgumentException()
                                mapOf("url" to validUrl(row["url"]),
                                    "name" to (row["name"] as? String).orEmpty().take(200),
                                    "charset" to ((row["charset"] as? String) ?: "utf-8"))
                            }
                            store.syncSites(sites)
                        }
                        "setEnabled" -> {
                            val value = call.arguments as? Boolean ?: throw IllegalArgumentException()
                            if (value && !NewPostWorker.notificationsAllowed(activity)) {
                                throw SecurityException("Notifications are disabled")
                            }
                            store.setEnabled(value)
                        }
                        "setSiteEnabled" -> {
                            val args = call.arguments as? Map<*, *> ?: throw IllegalArgumentException()
                            store.setSiteEnabled(validUrl(args["url"]), args["enabled"] as? Boolean ?: false)
                        }
                        "removeSite" -> store.removeSite(validUrl(call.arguments))
                        "getState" -> Unit
                        else -> {
                            main.post { result.notImplemented() }
                            return@execute
                        }
                    }
                    NewPostWorker.schedule(activity.applicationContext)
                    val state = mapOf(
                        "enabled" to store.enabled(),
                        "notificationsAllowed" to NewPostWorker.notificationsAllowed(activity),
                        "sites" to store.sites().map { it.toMap() },
                    )
                    main.post { result.success(state) }
                } catch (e: Exception) {
                    main.post { result.error(
                        if (e is SecurityException) "notifications_disabled" else "monitor_error",
                        "Unable to update background new-post monitoring", null) }
                }
            }
        }
    }

    fun onNewIntent(intent: Intent) {
        if (!listening || !intent.hasExtra(NewPostWorker.INTENT_PAYLOAD)) return
        takeNotification()?.let { channel.invokeMethod("openPost", it) }
    }

    private fun takeNotification(): Map<String, Any>? {
        val intent = activity.intent ?: return null
        val raw = intent.getStringExtra(NewPostWorker.INTENT_PAYLOAD) ?: return null
        intent.removeExtra(NewPostWorker.INTENT_PAYLOAD)
        return runCatching {
            val data = JSONObject(raw)
            val url = validUrl(data.getString("site_url"))
            val tid = data.getLong("tid")
            require(tid > 0)
            mapOf("site_url" to url, "tid" to tid)
        }.getOrNull()
    }

    fun close() {
        listening = false
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    private fun validUrl(value: Any?): String {
        val uri = Uri.parse(value as? String ?: throw IllegalArgumentException())
        require(uri.scheme in setOf("https", "http") && !uri.host.isNullOrBlank() && uri.userInfo == null)
        return uri.buildUpon().clearQuery().fragment(null).build().toString().trimEnd('/')
    }
}
