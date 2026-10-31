# Android 新帖后台提醒

入口：设置 → 新帖后台提醒。总开关与每个站点默认关闭；可选择多个已添加的
Discuz 站点。开启总开关时请求系统通知权限。iOS 不显示此入口，也不注册任务。

使用原生 Android WorkManager 的唯一周期任务，目标间隔 1 小时，必须同时满足
`requiresDeviceIdle`、`requiresBatteryNotLow`、`NetworkType.CONNECTED`。
不启用前台保活服务。系统可延迟检查；用户强行停止应用后，重新打开才恢复调度。
主清单显式保留 `RECEIVE_BOOT_COMPLETED`，覆盖广告 SDK 的移除标记，供
WorkManager 在设备重启后恢复已开启的任务。

后台以游客身份调用站点原有 Mobile API（`forumindex` / `newthreads`）。不会读取
账户 Cookie、Hive 数据库或启动 Flutter 引擎。版块目录缓存 24 小时；每站点最多
获取 5 页、每页 20 条，遇到已抓取记录就停止翻页；每轮最多运行 90 秒。
因此高流量站点在两次检查之间出现超过 100 篇帖子时可能无法覆盖全部新帖。

独立 SQLite 数据库 `background_new_posts.db` 保存站点开关、初始 TID 基线、
检查状态和 `(site URL, thread ID)` 唯一记录。首次成功检查仅建立基线；重启
保留记录。重新开启总开关或某站点会重建基线，避免补发停用期间的历史帖子。
更早的帖子即使重新出现在列表也不提醒。关闭或删除站点时，正在请求的任务在
提交记录前再次检查开关。SQLite 事务避免并发重复登记；通知调用失败会回滚。

同一轮同一站点的新帖合并为一条本地通知，点击进入该站点最新一篇新帖。
通知点击使用完整站点 URL 匹配，区分同一域名下的不同 Discuz 安装。

验证：`flutter test test/background_new_posts_test.dart`；
Android 目录中运行 `./gradlew :app:testDebugUnitTest`。原生测试覆盖 SQLite
基线、重启与重命名、跨站点去重、关闭与删除、通知失败/取消回滚，以及调度约束。
