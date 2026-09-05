import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

/// Normalizes the different shapes used to expose a Discuz `module=check`
/// response: raw JSON, a browser-generated `<pre>` document, or a
/// JSON-encoded JavaScript return value.
class DiscuzCheckResponseUtils {
  static const _stringDefaults = <String, String>{
    'discuzversion': '',
    'truediscuzversion': '',
    'charset': 'utf-8',
    'version': '4',
    'pluginversion': '',
    'regname': '',
    'qqconnect': '',
    'wsqqqconnect': '',
    'wsqhideregister': '',
    'sitename': '',
    'mysiteid': '',
    'ucenterurl': '',
    'defaultfid': '0',
  };

  static Map<String, dynamic>? tryDecode(String rawResponse) {
    final candidates = <String>[];
    final seen = <String>{};

    void addCandidate(String? value) {
      if (value == null) return;
      final normalized = value.replaceFirst('\ufeff', '').trim();
      if (normalized.isNotEmpty && seen.add(normalized)) {
        candidates.add(normalized);
      }
    }

    addCandidate(rawResponse);

    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];

      try {
        final decoded = jsonDecode(candidate);
        if (decoded is String) {
          addCandidate(decoded);
        } else if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          if (_isDiscuzCheckResponse(map)) return _normalize(map);
        }
      } catch (_) {
        // Try the browser/HTML representations below.
      }

      if (candidate.startsWith('<')) {
        final document = html_parser.parse(candidate);
        for (final pre in document.querySelectorAll('pre')) {
          addCandidate(pre.text);
        }
        addCandidate(document.body?.text);
        addCandidate(document.documentElement?.text);
      }

      final objectStart = candidate.indexOf('{');
      final objectEnd = candidate.lastIndexOf('}');
      if (objectStart >= 0 && objectEnd > objectStart) {
        addCandidate(candidate.substring(objectStart, objectEnd + 1));
      }
    }

    return null;
  }

  static bool _isDiscuzCheckResponse(Map<String, dynamic> value) {
    return value['discuzversion']?.toString().trim().isNotEmpty == true &&
        value['sitename']?.toString().trim().isNotEmpty == true;
  }

  static Map<String, dynamic> _normalize(Map<String, dynamic> value) {
    final normalized = Map<String, dynamic>.from(value);
    for (final entry in _stringDefaults.entries) {
      normalized[entry.key] = value[entry.key]?.toString() ?? entry.value;
    }
    return normalized;
  }
}
