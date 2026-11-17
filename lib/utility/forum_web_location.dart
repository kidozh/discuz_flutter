/// Whether the top-level document is still within this forum installation.
/// HTTP/HTTPS on their standard ports are the same site for this notice, so a
/// normal HTTPS upgrade does not look like a departure from the forum.
bool isForumWebLocation(String forumUrl, String pageUrl) {
  final forum = Uri.tryParse(forumUrl);
  final page = Uri.tryParse(pageUrl);
  bool webUri(Uri? uri) =>
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty;
  if (!webUri(forum) || !webUri(page)) return false;
  if (forum!.host != page!.host) return false;
  bool standardPort(Uri uri) => uri.port == (uri.scheme == 'https' ? 443 : 80);
  if (forum.port != page.port && !(standardPort(forum) && standardPort(page))) {
    return false;
  }
  try {
    String path(Uri uri) =>
        Uri(path: Uri.decodeComponent(uri.path))
            .normalizePath()
            .path
            .replaceFirst(RegExp(r'/+$'), '');
    final root = path(forum);
    final current = path(page);
    return root.isEmpty || current == root || current.startsWith('$root/');
  } on FormatException {
    return false;
  }
}

/// Display the actual address without credentials, query tokens or fragments.
String forumWebLocationLabel(String pageUrl) {
  final uri = Uri.tryParse(pageUrl);
  if (uri == null || !uri.hasScheme) return '—';
  if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
    return '${uri.origin}${uri.path}';
  }
  return '${uri.scheme}:';
}
