/// Recognize the official song iframe and rebuild its URL from known fields.
class NeteaseMusicEmbed {
  final String songId;
  const NeteaseMusicEmbed._(this.songId);

  static NeteaseMusicEmbed? parse(String? value) {
    if (value == null) return null;
    final text = value.trim().replaceAll('&amp;', '&');
    final uri = Uri.tryParse(text.startsWith('//') ? 'https:$text' : text);
    if (uri == null ||
        !{'https', 'http'}.contains(uri.scheme) ||
        uri.host != 'music.163.com' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.path != '/outchain/player' ||
        uri.queryParameters['type'] != '2')
      return null;
    final id = uri.queryParameters['id'] ?? '';
    if (!RegExp(r'^[0-9]+$').hasMatch(id) || (int.tryParse(id) ?? 0) <= 0)
      return null;
    return NeteaseMusicEmbed._(id);
  }

  Uri get playerUrl => Uri.https('music.163.com', '/outchain/player', {
    'type': '2',
    'id': songId,
    'auto': '0',
    'height': '66',
  });
  Uri get songUrl => Uri.https('music.163.com', '/song', {'id': songId});
}
