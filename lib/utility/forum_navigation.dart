import '../client/ForumInteractionClient.dart';
import 'discuz_json.dart';

Future<List<Map<String, dynamic>>> loadForumNavigation(
  ForumInteractionClient client,
) async {
  final reply = await client.request('forumnav', {});
  reply.requireData('forums');
  final forums = <int, Map<String, dynamic>>{
    for (final row in forumRows(reply.variables['forums']).map(discuzMap))
      if (discuzInt(row['fid']) > 0) discuzInt(row['fid']): row,
  };
  final children = <int, List<int>>{};
  for (final entry in forums.entries) {
    final parent = discuzInt(entry.value['fup']);
    (children[forums.containsKey(parent) && parent != entry.key
                ? parent
                : 0] ??=
            [])
        .add(entry.key);
  }
  final visited = <int>{};
  final ordered = <Map<String, dynamic>>[];
  void add(int id, int depth) {
    if (!visited.add(id)) return;
    final forum = forums[id]!;
    if (discuzString(forum['type']) != 'group') {
      ordered.add({...forum, 'depth': depth});
      depth++;
    }
    for (final child in children[id] ?? const <int>[]) {
      add(child, depth);
    }
  }

  for (final id in [...?children[0], ...forums.keys]) {
    add(id, 0);
  }
  return ordered;
}
