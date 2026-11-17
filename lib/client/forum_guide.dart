import '../utility/discuz_json.dart';
import 'ForumInteractionClient.dart';

/// The official extension classes inherit output() from extends_data. The
/// response key is therefore extends_data, not the requested dz_* identifier.
extension ForumGuideClient on ForumInteractionClient {
  Future<Set<String>> guideSections() async {
    final reply = await request('extends', {'check': 1});
    reply.requireData('extends');
    final list = discuzMap(reply.variables['extends'])['extendlist'];
    if (list is! List && list is! Map) throw const FormatException();
    return forumRows(list)
        .map(discuzMap)
        .map((row) => discuzString(row['identifier']))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<List<Map<String, dynamic>>> guideThreads(
    String identifier,
    int page,
  ) async {
    final reply = await request('extends', {
      'identifier': identifier,
      'page': page,
    });
    // Retain compatibility with customized plugins using the identifier key.
    final key = reply.variables.containsKey('extends_data')
        ? 'extends_data'
        : identifier;
    reply.requireData(key);
    final list = discuzMap(reply.variables[key])['list'];
    if (list is! List && list is! Map) throw const FormatException();
    return forumRows(list)
        .map(discuzMap)
        .where((row) {
          final type = discuzString(row['clicktype']);
          return type.isEmpty || type == 'tid';
        })
        .map((row) {
          final fields = {
            for (final field in forumRows(row['fields']).map(discuzMap))
              discuzString(field['id']): field['value'],
          };
          return <String, dynamic>{
            'tid': row['clickvalue'] ?? row['id'],
            'subject': row['title'],
            'image': row['image'],
            'author': fields['author'],
            'replies': fields['replies'],
            'views': fields['views'],
            'dateline': fields['dateline'],
          };
        })
        .where((row) => discuzInt(row['tid']) > 0)
        .toList();
  }
}
