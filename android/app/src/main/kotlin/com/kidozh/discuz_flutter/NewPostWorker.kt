package com.kidozh.discuz_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.text.Html
import androidx.annotation.Keep
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.nio.charset.Charset
import java.util.concurrent.CancellationException
import java.util.concurrent.TimeUnit

@Keep
class NewPostWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    @Volatile private var connection: HttpURLConnection? = null
    private var deadline = 0L

    override fun doWork(): Result {
        val store = NewPostStore.get(applicationContext)
        if (!store.enabled() || !notificationsAllowed(applicationContext)) return Result.success()
        deadline = SystemClock.elapsedRealtime() + 90_000
        for (site in store.sites().filter { it.enabled }) {
            if (isStopped || SystemClock.elapsedRealtime() >= deadline) break
            try {
                var fids = site.fids
                if (fids.isEmpty() || System.currentTimeMillis() - site.catalogAt > TimeUnit.DAYS.toMillis(1)) {
                    fids = rows(request(site, "forumindex"), "forumlist")
                        .map { it.optString("fid") }.filter { (it.toLongOrNull() ?: 0) > 0 }.distinct().joinToString(",")
                    store.saveCatalog(site.url, fids)
                }
                val posts = mutableListOf<MonitoredPost>()
                if (fids.isNotEmpty()) {
                    // Bound network work and notification volume per idle run.
                    for (page in 0 until if (site.seeded) 5 else 1) {
                        val next = rows(request(site, "newthreads", mapOf(
                            "fids" to fids, "limit" to "20", "start" to (page * 20).toString(),
                        )), "data").take(20).mapNotNull { row ->
                            val tid = row.optString("tid").toLongOrNull() ?: 0
                            val title = Html.fromHtml(row.optString("subject"), Html.FROM_HTML_MODE_LEGACY).toString().trim()
                            if (tid > 0 && title.isNotEmpty()) MonitoredPost(tid, title) else null
                        }
                        posts.addAll(next)
                        if (next.size < 20 || next.any { it.tid <= site.baselineTid } ||
                            store.known(site.url, next.map { it.tid }).isNotEmpty()) break
                    }
                }
                checkActive()
                store.record(site.url, posts, { !isStopped && notificationsAllowed(applicationContext) }, ::notifyPosts)
            } catch (_: CancellationException) {
                break
            } catch (_: Exception) {
                if (!isStopped) store.failed(site.url)
            }
        }
        // Network failures wait for the next idle period rather than a tight retry.
        return Result.success()
    }

    override fun onStopped() {
        connection?.disconnect()
        super.onStopped()
    }

    private fun checkActive() {
        if (isStopped || SystemClock.elapsedRealtime() >= deadline) throw CancellationException()
    }

    private fun request(site: MonitoredSite, module: String, params: Map<String, String> = emptyMap()): JSONObject {
        checkActive()
        val query = (mapOf("version" to "4", "module" to module) + params).entries.joinToString("&") {
            "${URLEncoder.encode(it.key, "UTF-8")}=${URLEncoder.encode(it.value, "UTF-8")}"
        }
        val conn = URL("${site.url}/api/mobile/index.php?$query").openConnection() as HttpURLConnection
        connection = conn
        try {
            conn.connectTimeout = 10_000
            conn.readTimeout = 10_000
            conn.useCaches = false
            conn.setRequestProperty("Accept", "application/json")
            conn.setRequestProperty("User-Agent", "DisFly/2 Android NewPostMonitor")
            if (conn.responseCode !in 200..299) throw IllegalStateException("HTTP failure")
            val bytes = ByteArrayOutputStream()
            conn.inputStream.use { stream ->
                val buffer = ByteArray(8192)
                while (true) {
                    checkActive()
                    val count = stream.read(buffer)
                    if (count < 0) break
                    if (bytes.size() + count > 2 * 1024 * 1024) throw IllegalStateException("Response too large")
                    bytes.write(buffer, 0, count)
                }
            }
            val encoding = Regex("charset=([^; ]+)", RegexOption.IGNORE_CASE).find(conn.contentType ?: "")?.groupValues?.get(1)
            val charset = runCatching { Charset.forName(encoding ?: site.charset) }.getOrDefault(Charsets.UTF_8)
            var source = bytes.toString(charset.name()).trim().removePrefix("\uFEFF").trim()
            val envelope = Regex("^(?:<\\?xml[^>]*>\\s*)?<root>\\s*<!\\[CDATA\\[([\\s\\S]*?)\\]\\]>\\s*</root>$").matchEntire(source)
            if (envelope != null) source = envelope.groupValues[1].trim()
            val response = JSONObject(source)
            if (response.optJSONObject("Message")?.optString("messageval").orEmpty().isNotEmpty() ||
                response.optString("error").isNotEmpty()) throw IllegalStateException("Forum rejected request")
            return response.getJSONObject("Variables")
        } finally {
            conn.disconnect()
            connection = null
        }
    }

    private fun rows(variables: JSONObject, field: String): List<JSONObject> = when (val data = variables.get(field)) {
        is JSONArray -> (0 until data.length()).mapNotNull { data.optJSONObject(it) }
        is JSONObject -> data.keys().asSequence().mapNotNull { data.optJSONObject(it) }.toList()
        else -> throw IllegalStateException("Invalid feed")
    }

    private fun notifyPosts(site: MonitoredSite, posts: List<MonitoredPost>) {
        checkActive()
        val latest = posts.maxBy { it.tid }
        val payload = JSONObject().put("site_url", site.url).put("tid", latest.tid).toString()
        val intent = Intent(applicationContext, MainActivity::class.java)
            .setAction("${applicationContext.packageName}.NEW_POSTS")
            .setData(android.net.Uri.parse("disfly://new-posts/${android.net.Uri.encode(site.url)}/${latest.tid}"))
            .putExtra(INTENT_PAYLOAD, payload)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pending = PendingIntent.getActivity(applicationContext, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val body = posts.distinctBy { it.tid }.take(3).joinToString("\n") {
            it.subject.substring(0, it.subject.offsetByCodePoints(0, minOf(160, it.subject.codePointCount(0, it.subject.length))))
        }
        val notification = NotificationCompat.Builder(applicationContext, CHANNEL)
            .setSmallIcon(R.drawable.ic_new_post_notification)
            .setContentTitle(site.name)
            .setSubText(applicationContext.resources.getQuantityString(R.plurals.background_new_posts_count, posts.size, posts.size))
            .setContentText(latest.subject)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pending).setAutoCancel(true)
            .setCategory(NotificationCompat.CATEGORY_SOCIAL)
            .build()
        NotificationManagerCompat.from(applicationContext).notify("new_posts:${site.url}", 0, notification)
    }

    companion object {
        const val WORK_NAME = "discuz.background_new_posts.v1"
        const val CHANNEL = "discuz_new_posts_v1"
        const val INTENT_PAYLOAD = "discuz_background_new_post"

        fun notificationsAllowed(context: Context): Boolean {
            val manager = context.getSystemService(NotificationManager::class.java)
            return NotificationManagerCompat.from(context).areNotificationsEnabled() &&
                manager.getNotificationChannel(CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE
        }

        fun schedule(context: Context) {
            val store = NewPostStore.get(context)
            val work = WorkManager.getInstance(context)
            if (!store.enabled() || store.sites().none { it.enabled }) {
                work.cancelUniqueWork(WORK_NAME)
                return
            }
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL, context.getString(R.string.background_new_posts_channel), NotificationManager.IMPORTANCE_DEFAULT))
            work.enqueueUniquePeriodicWork(WORK_NAME, ExistingPeriodicWorkPolicy.KEEP, workRequest())
        }

        internal fun workRequest() = PeriodicWorkRequestBuilder<NewPostWorker>(1, TimeUnit.HOURS)
                .setConstraints(Constraints.Builder()
                    .setRequiresDeviceIdle(true)
                    .setRequiresBatteryNotLow(true)
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build())
                .build()
    }
}
