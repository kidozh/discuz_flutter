/// Both Steam store pages and embeddable widgets identify an app, including DLC
/// and soundtracks. Package/bundle IDs belong to different API namespaces.
String? steamAppId(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  final uri = Uri.tryParse(
    trimmed.startsWith('//') ? 'https:$trimmed' : trimmed,
  );
  if (uri == null ||
      !const ['http', 'https'].contains(uri.scheme) ||
      !const [
        'store.steampowered.com',
        'store.steamchina.com',
      ].contains(uri.host.toLowerCase()))
    return null;
  final parts = uri.pathSegments;
  if (parts.length < 2 || !const ['app', 'widget'].contains(parts[0]))
    return null;
  final id = parts[1];
  return RegExp(r'^[0-9]+$').hasMatch(id) && (int.tryParse(id) ?? 0) > 0
      ? id
      : null;
}

/// Keep store-specific catalogues and links on their original storefront.
String steamStoreBaseUrl(String value) {
  final uri = Uri.tryParse(
    value.trim().startsWith('//') ? 'https:${value.trim()}' : value.trim(),
  );
  return uri?.host.toLowerCase() == 'store.steamchina.com'
      ? 'https://store.steamchina.com/'
      : 'https://store.steampowered.com/';
}
