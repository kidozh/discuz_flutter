import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../JsonResult/CheckPostResult.dart';
import 'forum_voice.dart';

typedef ForumComposerScope = ({String site, int uid, int fid});

/// A hint for opening the editor, never an upload credential or a send grant.
/// Discuz checkpost capabilities are board-level; thread state is checked by
/// viewthread and all actual submissions still fetch current permissions.
class ForumComposerCapabilities {
  const ForumComposerCapabilities(this.permission, this.voice);
  final AllowPerm permission;
  final ForumVoiceOptions? voice;
}

class ForumComposerCapabilityCache {
  static const lifetime = Duration(hours: 1);

  static String _key(ForumComposerScope scope) =>
      'forum_composer_v1.${base64Url.encode(utf8.encode(jsonEncode([scope.site, scope.uid, scope.fid])))}';

  static Future<ForumComposerCapabilities?> read(
    ForumComposerScope scope, {
    DateTime? now,
  }) async {
    if (scope.uid <= 0 || scope.fid <= 0) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(scope));
      if (raw == null) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final checked = data['checked'] as int;
      final age = (now ?? DateTime.now()).millisecondsSinceEpoch - checked;
      if (age < 0 || age >= lifetime.inMilliseconds) return null;
      final permission = AllowPerm.fromJson(data['permission'])
        ..uploadHash = '';
      if (permission.allowPost == null || permission.allowReply == null) {
        return null;
      }
      ForumVoiceOptions? voice;
      if (data['voice'] case final Map value) {
        final format = ForumVoiceFormat.values.byName(
          value['format'] as String,
        );
        final seconds = value['seconds'] as int;
        if (seconds < 1 || seconds > forumVoiceMaxSeconds) return null;
        voice = (format: format, maxSeconds: seconds);
      }
      return ForumComposerCapabilities(permission, voice);
    } catch (_) {
      return null;
    }
  }

  /// Any fresh server result supersedes a cached grant, including denial.
  static Future<void> remember(
    ForumComposerScope scope,
    CheckPostResult result, {
    DateTime? now,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permission = result.variables.allowPerm;
      if (scope.uid <= 0 ||
          scope.fid <= 0 ||
          result.variables.member_uid != scope.uid ||
          result.errorResult != null ||
          (result.error?.isNotEmpty ?? false) ||
          permission.allowPost == null ||
          permission.allowReply == null) {
        await prefs.remove(_key(scope));
        return;
      }
      final voice = forumVoiceOptions(permission);
      final fields = permission.toJson()..remove('uploadhash');
      await prefs.setString(
        _key(scope),
        jsonEncode({
          'checked': (now ?? DateTime.now()).millisecondsSinceEpoch,
          'permission': fields,
          'voice': voice == null
              ? null
              : {'format': voice.format.name, 'seconds': voice.maxSeconds},
        }),
      );
    } catch (_) {
      // Preference storage must not prevent editing or a real submission.
    }
  }
}
