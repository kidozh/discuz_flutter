import '../entity/Discuz.dart';

Uri? forumBaseUri(Discuz forum) {
  final uri = resolveForumImageUri(null, forum.baseURL);
  if (uri == null) return null;
  final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
  return Uri.parse('${uri.origin}$path/');
}

Uri? resolveForumImageUri(Uri? base, String url) {
  final value = url.trim();
  final reference = Uri.tryParse(value);
  if (value.isEmpty || reference == null) return null;
  final uri = base?.resolveUri(reference) ?? reference;
  if ((uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  // Some HTTPS forums emit their own image links with an HTTP scheme.
  if (base != null &&
      base.scheme == 'https' &&
      base.port == 443 &&
      uri.scheme == 'http' &&
      uri.port == 80 &&
      uri.host == base.host) {
    return uri.replace(scheme: 'https', port: 443);
  }
  return uri;
}
