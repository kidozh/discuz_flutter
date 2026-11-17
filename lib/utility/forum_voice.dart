import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../JsonResult/CheckPostResult.dart';

const forumVoiceBitRate = 32;
const forumVoiceSampleRate = 16000;
const forumVoiceMaxSeconds = 60;

bool get canRecordForumVoice =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid);

enum ForumVoiceFormat {
  mp3(forumVoiceBitRate * 125),
  m4a(forumVoiceBitRate * 125),
  wav(forumVoiceSampleRate * 2);

  const ForumVoiceFormat(this.bytesPerSecond);
  final int bytesPerSecond;
}

typedef ForumVoiceOptions = ({ForumVoiceFormat format, int maxSeconds});

ForumVoiceOptions? forumVoiceOptions(AllowPerm permission) {
  ForumVoiceOptions? preferred;
  for (final format in ForumVoiceFormat.values) {
    if (permission.validateUpload('voice.${format.name}', 1) != null) continue;
    final limits = [
      permission.allowUpload.limits[format.name],
      permission.attachRemain.size,
    ].whereType<int>().where((bytes) => bytes >= 0);
    // Reserve room for the container, encoder padding and a final buffered read.
    final seconds = limits.fold(
      forumVoiceMaxSeconds,
      (seconds, bytes) => math.max(
        0,
        math.min(seconds, (bytes - 2048) ~/ format.bytesPerSecond),
      ),
    );
    if (seconds > (preferred?.maxSeconds ?? 0)) {
      preferred = (format: format, maxSeconds: seconds);
    }
  }
  return preferred;
}

bool isForumAudioFile(String name) => const {
  'mp3',
  'm4a',
  'aac',
  'wav',
  'ogg',
  'opus',
  'flac',
  'amr',
}.contains(name.trim().toLowerCase().split('.').last);

final _voiceFilename = RegExp(r'^disfly-voice-\d+-(\d+)s\.(?:mp3|m4a|wav)$');

Duration? forumVoiceDuration(String name) {
  final value = int.tryParse(_voiceFilename.firstMatch(name)?.group(1) ?? '');
  return value == null || value < 1 || value > forumVoiceMaxSeconds
      ? null
      : Duration(seconds: value);
}

String voiceTime(Duration duration) {
  final seconds = duration.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class RecordedForumVoice {
  RecordedForumVoice(this.file, this.duration, ForumVoiceFormat format)
    : name =
          'disfly-voice-${DateTime.now().millisecondsSinceEpoch}-${duration.inSeconds}s.${format.name}';

  final File file;
  final Duration duration;
  final String name;

  Future<void> delete() async {
    try {
      await file.parent.delete(recursive: true);
    } on FileSystemException {
      // The system may already have removed the temporary recording.
    }
  }
}
