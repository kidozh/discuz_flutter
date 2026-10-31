package com.kidozh.discuz_flutter

internal data class MonitoredPost(val tid: Long, val subject: String)

internal object NewPostPolicy {
    // Discuz thread IDs increase as threads are created. The initial ceiling
    // also excludes old threads that later become publicly visible.
    fun unseen(posts: List<MonitoredPost>, baselineTid: Long, seen: Set<Long>): List<MonitoredPost> =
        posts.distinctBy { it.tid }.filter { it.tid > baselineTid && it.tid !in seen }
}
