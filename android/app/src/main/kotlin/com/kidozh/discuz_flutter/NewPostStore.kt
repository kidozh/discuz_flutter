package com.kidozh.discuz_flutter

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

internal data class MonitoredSite(
    val url: String,
    val name: String,
    val charset: String,
    val enabled: Boolean,
    val seeded: Boolean,
    val baselineTid: Long,
    val lastCheck: Long,
    val lastAttempt: Long,
    val failed: Boolean,
    val fids: String,
    val catalogAt: Long,
) {
    fun toMap(): Map<String, Any> = mapOf(
        "url" to url, "name" to name, "enabled" to enabled,
        "seeded" to seeded, "lastCheck" to lastCheck, "failed" to failed,
    )
}

/** Independent of the foreground Hive boxes; SQLite serializes worker/UI writes. */
internal class NewPostStore(context: Context) :
    SQLiteOpenHelper(context.applicationContext, "background_new_posts.db", null, 1) {
    init { setWriteAheadLoggingEnabled(true) }

    override fun onConfigure(db: SQLiteDatabase) { db.setForeignKeyConstraintsEnabled(true) }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("CREATE TABLE settings (id INTEGER PRIMARY KEY CHECK(id=1), enabled INTEGER NOT NULL DEFAULT 0)")
        db.execSQL("INSERT INTO settings(id) VALUES(1)")
        db.execSQL("""CREATE TABLE sites (
            url TEXT PRIMARY KEY, name TEXT NOT NULL, charset TEXT NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 0, seeded INTEGER NOT NULL DEFAULT 0,
            baseline_tid INTEGER NOT NULL DEFAULT 0, last_check INTEGER NOT NULL DEFAULT 0,
            last_attempt INTEGER NOT NULL DEFAULT 0, failed INTEGER NOT NULL DEFAULT 0,
            fids TEXT NOT NULL DEFAULT '', catalog_at INTEGER NOT NULL DEFAULT 0)""")
        db.execSQL("""CREATE TABLE seen (
            site TEXT NOT NULL REFERENCES sites(url) ON DELETE CASCADE,
            tid INTEGER NOT NULL, PRIMARY KEY(site,tid))""")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit

    fun enabled(): Boolean = readableDatabase.rawQuery("SELECT enabled FROM settings WHERE id=1", null).use {
        it.moveToFirst() && it.getInt(0) == 1
    }

    fun sites(): List<MonitoredSite> = readableDatabase.rawQuery("SELECT * FROM sites ORDER BY last_attempt,url", null).use { c ->
        buildList {
            while (c.moveToNext()) {
                fun s(name: String) = c.getString(c.getColumnIndexOrThrow(name))
                fun n(name: String) = c.getLong(c.getColumnIndexOrThrow(name))
                add(MonitoredSite(s("url"), s("name"), s("charset"), n("enabled") == 1L,
                    n("seeded") == 1L, n("baseline_tid"), n("last_check"), n("last_attempt"),
                    n("failed") == 1L, s("fids"), n("catalog_at")))
            }
        }
    }

    fun syncSites(catalog: List<Map<String, String>>) = transaction { db ->
        val urls = catalog.map { it.getValue("url") }.toSet()
        for (site in sites()) if (site.url !in urls) db.delete("sites", "url=?", arrayOf(site.url))
        for (site in catalog) {
            val values = ContentValues().apply {
                put("url", site.getValue("url")); put("name", site.getValue("name"))
                put("charset", site.getValue("charset"))
            }
            // REPLACE would delete the prior baseline and its deduplication rows.
            db.insertWithOnConflict("sites", null, values, SQLiteDatabase.CONFLICT_IGNORE)
            db.update("sites", values, "url=?", arrayOf(site.getValue("url")))
        }
    }

    fun setEnabled(value: Boolean) = transaction { db ->
        if (value && !enabled()) db.execSQL("UPDATE sites SET seeded=0")
        db.execSQL("UPDATE settings SET enabled=? WHERE id=1", arrayOf(if (value) 1 else 0))
    }

    fun setSiteEnabled(url: String, value: Boolean) = transaction { db ->
        val site = sites().firstOrNull { it.url == url } ?: throw IllegalArgumentException("Unknown site")
        if (site.enabled != value) {
            db.execSQL("UPDATE sites SET enabled=?,seeded=0 WHERE url=?", arrayOf<Any>(if (value) 1 else 0, url))
        }
    }

    fun removeSite(url: String) { writableDatabase.delete("sites", "url=?", arrayOf(url)) }

    fun saveCatalog(url: String, fids: String) {
        writableDatabase.update("sites", ContentValues().apply {
            put("fids", fids); put("catalog_at", System.currentTimeMillis())
        }, "url=?", arrayOf(url))
    }

    fun failed(url: String) {
        writableDatabase.update("sites", ContentValues().apply {
            put("failed", 1); put("last_attempt", System.currentTimeMillis())
        }, "url=?", arrayOf(url))
    }

    fun known(url: String, tids: List<Long>): Set<Long> {
        if (tids.isEmpty()) return emptySet()
        val placeholders = tids.joinToString(",") { "?" }
        return readableDatabase.rawQuery("SELECT tid FROM seen WHERE site=? AND tid IN ($placeholders)",
            (listOf(url) + tids.map { it.toString() }).toTypedArray()).use { c ->
            buildSet { while (c.moveToNext()) add(c.getLong(0)) }
        }
    }

    fun record(
        url: String,
        posts: List<MonitoredPost>,
        canContinue: () -> Boolean,
        notify: (MonitoredSite, List<MonitoredPost>) -> Unit,
    ) = transaction { db ->
        val site = sites().firstOrNull { it.url == url }
        // Re-read opt-ins inside the write transaction: disabling/deleting a
        // forum while its request is in flight must prevent a notification.
        if (site == null || !site.enabled || !enabled() || !canContinue()) return@transaction
        val seen = known(url, posts.map { it.tid })
        val fresh = if (site.seeded) NewPostPolicy.unseen(posts, site.baselineTid, seen) else emptyList()
        for (post in posts) db.insertWithOnConflict("seen", null, ContentValues().apply {
            put("site", url); put("tid", post.tid)
        }, SQLiteDatabase.CONFLICT_IGNORE)
        val now = System.currentTimeMillis()
        db.update("sites", ContentValues().apply {
            put("seeded", 1); put("last_check", now); put("last_attempt", now); put("failed", 0)
            if (!site.seeded) put("baseline_tid", posts.maxOfOrNull { it.tid } ?: 0)
        }, "url=?", arrayOf(url))
        if (!canContinue()) throw java.util.concurrent.CancellationException()
        if (fresh.isNotEmpty()) notify(site, fresh)
        // A failed notification throws and rolls back these IDs for a later run.
    }

    private inline fun <T> transaction(block: (SQLiteDatabase) -> T): T {
        val db = writableDatabase
        db.beginTransaction()
        try {
            val value = block(db)
            db.setTransactionSuccessful()
            return value
        } finally { db.endTransaction() }
    }

    companion object {
        @Volatile private var instance: NewPostStore? = null
        fun get(context: Context): NewPostStore = instance ?: synchronized(this) {
            instance ?: NewPostStore(context).also { instance = it }
        }
    }
}
