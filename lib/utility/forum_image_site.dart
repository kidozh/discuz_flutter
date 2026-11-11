import 'dart:io';

import 'public_suffix_rules.dart';

final _suffixRules = publicSuffixRules.trim().split('\n').toSet();
final _dnsLabels = RegExp(r'^[a-z0-9-]+(?:\.[a-z0-9-]+)*$');

String? registrableDomain(String host) {
  if (!_dnsLabels.hasMatch(host) || InternetAddress.tryParse(host) != null) {
    return null;
  }
  final labels = host.split('.');
  var suffixLength = 1;
  for (var i = labels.length - 1; i >= 0; i--) {
    final suffix = labels.skip(i).join('.');
    if (_suffixRules.contains('!$suffix')) {
      return suffix;
    }
    if (_suffixRules.contains(suffix)) {
      suffixLength = labels.length - i;
    }
    if (i > 0 && _suffixRules.contains('*.$suffix')) {
      suffixLength = labels.length - i + 1;
    }
  }
  if (labels.length <= suffixLength) return null;
  return labels.skip(labels.length - suffixLength - 1).join('.');
}

bool sameForumImageSite(Uri forum, Uri image) {
  if (forum.scheme != image.scheme || forum.port != image.port) return false;
  if (forum.host == image.host) return true;
  final forumDomain = registrableDomain(forum.host);
  return forumDomain != null && forumDomain == registrableDomain(image.host);
}
