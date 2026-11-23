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

bool isForumAttachmentUrl(Uri uri) {
  if (uri.pathSegments.lastOrNull != 'forum.php') return false;
  try {
    final params = uri.queryParameters;
    return params['mod'] == 'attachment' &&
        (params['aid']?.isNotEmpty ?? false);
  } on FormatException {
    return false;
  }
}

/// Resolve the server's attachment directory or a URL for the file itself.
Uri? resolveForumAttachmentUri(Uri? forum, String path, String url) {
  final supplied = resolveForumImageUri(forum, url);
  final reference = Uri.tryParse(path.trim());
  final filename = reference?.pathSegments.lastOrNull;
  if (supplied != null &&
      (path.trim().isEmpty ||
          isForumAttachmentUrl(supplied) ||
          (filename != null && filename == supplied.pathSegments.lastOrNull))) {
    return supplied;
  }
  if (reference != null &&
      (reference.hasAuthority || isForumAttachmentUrl(reference))) {
    return resolveForumImageUri(forum, path);
  }
  final base = supplied ?? forum;
  final directory = base == null || base.path.endsWith('/')
      ? base
      : base.replace(path: '${base.path}/');
  return resolveForumImageUri(directory, path);
}
