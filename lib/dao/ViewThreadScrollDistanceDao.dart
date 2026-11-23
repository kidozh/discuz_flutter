import 'package:hive_ce/hive.dart';

import '../entity/Discuz.dart';
import '../entity/ViewThreadScrollDistance.dart';

class ViewThreadScrollDistanceDao {
  final Box<ViewThreadScrollDistance> viewThreadScrollDistanceBox;
  ViewThreadScrollDistanceDao(this.viewThreadScrollDistanceBox);

  String _key(Discuz discuz, int uid, int tid, bool isAscend) =>
      '${discuz.siteIdentity}|$uid|$tid|${isAscend ? 1 : 0}';

  ViewThreadScrollDistance? findViewThreadCacheListByDiscuz(
    Discuz discuz,
    int tid,
    bool isAscend, {
    required int uid,
  }) => viewThreadScrollDistanceBox.get(_key(discuz, uid, tid, isAscend));

  ViewThreadScrollDistance? latestProgress(Discuz discuz, int uid, int tid) {
    final ascend = findViewThreadCacheListByDiscuz(discuz, tid, true, uid: uid);
    final descend = findViewThreadCacheListByDiscuz(
      discuz,
      tid,
      false,
      uid: uid,
    );
    if (ascend == null) return descend;
    if (descend == null) return ascend;
    return descend.updateTime.isAfter(ascend.updateTime) ? descend : ascend;
  }

  Future<void> insertViewThreadScrollDistance(ViewThreadScrollDistance entry) {
    final uid = entry.uid;
    if (uid == null) return viewThreadScrollDistanceBox.add(entry);
    final key = _key(entry.discuz, uid, entry.tid, entry.isAscend);
    final existing = viewThreadScrollDistanceBox.get(key);
    if (existing != null && existing.updateTime.isAfter(entry.updateTime)) {
      return Future.value();
    }
    return viewThreadScrollDistanceBox.put(key, entry);
  }

  Future<void> deleteAllExpiredViewThreadCache() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keys = viewThreadScrollDistanceBox.values
        .where(
          (entry) => entry.uid == null && entry.updateTime.isBefore(cutoff),
        )
        .map((entry) => entry.key)
        .toList();
    return viewThreadScrollDistanceBox.deleteAll(keys);
  }
}
