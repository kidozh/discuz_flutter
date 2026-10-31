package com.kidozh.discuz_flutter

import androidx.work.NetworkType
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import java.util.concurrent.CancellationException
import java.util.concurrent.TimeUnit

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35], manifest = Config.NONE)
class NewPostStoreTest {
    private lateinit var store: NewPostStore
    private val site = "https://forum.example/subforum"
    private val other = "https://other.example"
    private val notifications = mutableListOf<Pair<String, List<Long>>>()
    private fun catalog(url: String, name: String = "Forum") = mapOf("url" to url, "name" to name, "charset" to "utf-8")
    private fun posts(vararg ids: Long) = ids.map { MonitoredPost(it, "Thread $it") }
    private fun record(url: String, vararg ids: Long) = store.record(url, posts(*ids), { true }) { s, rows ->
        notifications.add(s.url to rows.map { it.tid })
    }

    @Before fun setUp() {
        RuntimeEnvironment.getApplication().deleteDatabase("background_new_posts.db")
        store = NewPostStore(RuntimeEnvironment.getApplication())
        store.syncSites(listOf(catalog(site), catalog(other)))
    }

    @After fun tearDown() { store.close() }

    @Test fun `monitoring starts off and never processes an unselected site`() {
        assertFalse(store.enabled())
        assertTrue(store.sites().all { !it.enabled })
        record(site, 100)
        assertTrue(store.known(site, listOf(100)).isEmpty())
        store.setEnabled(true)
        record(site, 100)
        assertTrue(notifications.isEmpty())
        assertTrue(store.known(site, listOf(100)).isEmpty())
    }

    @Test fun `first crawl seeds database then new IDs notify exactly once`() {
        store.setEnabled(true)
        store.setSiteEnabled(site, true)
        record(site, 100, 99)
        assertTrue(notifications.isEmpty())
        record(site, 102, 101, 101, 100, 50)
        assertEquals(listOf(site to listOf(102L, 101L)), notifications)
        record(site, 102, 101, 100)
        assertEquals(1, notifications.size)
        assertTrue(store.sites().first { it.url == site }.seeded)
    }

    @Test fun `same ID on another site is independent`() {
        store.setEnabled(true)
        for (url in listOf(site, other)) {
            store.setSiteEnabled(url, true)
            record(url, 100)
            record(url, 101)
        }
        assertEquals(listOf(site to listOf(101L), other to listOf(101L)), notifications)
    }

    @Test fun `catalog updates and reopening preserve deduplication`() {
        store.setEnabled(true)
        store.setSiteEnabled(site, true)
        record(site, 100)
        record(site, 101)
        store.syncSites(listOf(catalog(site, "Renamed"), catalog(other)))
        store.close()
        store = NewPostStore(RuntimeEnvironment.getApplication())
        record(site, 101)
        assertEquals(1, notifications.size)
        assertEquals("Renamed", store.sites().first { it.url == site }.name)
    }

    @Test fun `disable remove and reenable cannot produce a backlog of alerts`() {
        store.setEnabled(true)
        store.setSiteEnabled(site, true)
        record(site, 100)
        store.setSiteEnabled(site, false)
        record(site, 101)
        store.setSiteEnabled(site, true)
        record(site, 102, 101, 100)
        assertTrue(notifications.isEmpty())
        store.setEnabled(false)
        record(site, 103)
        store.setEnabled(true)
        record(site, 104, 103)
        assertTrue(notifications.isEmpty())
        store.removeSite(site)
        record(site, 105)
        assertTrue(store.known(site, listOf(100, 101, 102, 103, 104, 105)).isEmpty())
    }

    @Test fun `failed notification and cancellation roll back IDs`() {
        store.setEnabled(true)
        store.setSiteEnabled(site, true)
        record(site, 100)
        try {
            store.record(site, posts(101), { true }) { _, _ -> throw IllegalStateException("notification failed") }
            fail("Expected notification failure")
        } catch (_: IllegalStateException) { }
        assertTrue(store.known(site, listOf(101)).isEmpty())
        var activeChecks = 0
        try {
            store.record(site, posts(101), { ++activeChecks == 1 }) { _, _ -> fail("Cancelled") }
            fail("Expected cancellation")
        } catch (_: CancellationException) { }
        assertTrue(store.known(site, listOf(101)).isEmpty())
        record(site, 101)
        assertEquals(listOf(site to listOf(101L)), notifications)
    }

    @Test fun `scheduled checks require idle non-low battery and a network`() {
        val spec = NewPostWorker.workRequest().workSpec
        assertTrue(spec.constraints.requiresDeviceIdle())
        assertTrue(spec.constraints.requiresBatteryNotLow())
        assertEquals(NetworkType.CONNECTED, spec.constraints.requiredNetworkType)
        assertEquals(TimeUnit.HOURS.toMillis(1), spec.intervalDuration)
    }
}
