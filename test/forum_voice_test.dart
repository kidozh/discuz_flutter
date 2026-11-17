import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/utility/forum_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AllowPerm permission({int? mp3, int? remaining, int count = -1}) =>
      AllowPerm.fromJson({
        'uploadhash': 'fixture',
        'allowupload': {if (mp3 != null) 'mp3': mp3},
        'attachremain': {'size': remaining ?? -1, 'count': count},
      });

  int seconds(AllowPerm value) => forumVoiceOptions(value)?.maxSeconds ?? 0;

  test('a forum can offer M4A or WAV without granting MP3', () {
    final permission = AllowPerm.fromJson({
      'uploadhash': 'fixture',
      'allowupload': {'mp3': 0, 'wav': -1, 'm4a': 14048},
      'attachremain': {'size': 202048},
    });
    expect(forumVoiceOptions(permission), (
      format: ForumVoiceFormat.wav,
      maxSeconds: 6,
    ));
    final compressed = AllowPerm.fromJson({
      'uploadhash': 'fixture',
      'allowupload': {'mp3': 0, 'm4a': -1},
    });
    expect(forumVoiceOptions(compressed), (
      format: ForumVoiceFormat.m4a,
      maxSeconds: 60,
    ));
  });

  test('recording requires permission to upload MP3 and a remaining slot', () {
    expect(seconds(permission()), 0);
    expect(seconds(permission(mp3: 0)), 0);
    expect(seconds(permission(mp3: -1, count: 0)), 0);
    expect(seconds(permission(mp3: -1)), 60);
  });

  test(
    'recording time follows the stricter of the attachment and daily limits',
    () {
      expect(seconds(permission(mp3: 22048, remaining: 14048)), 3);
      expect(seconds(permission(mp3: 14047, remaining: 22048)), 2);
      expect(seconds(permission(mp3: 6047)), 0);
      expect(seconds(permission(mp3: 1200000)), 60);
    },
  );

  test(
    'only generated voice filenames provide an unverified duration hint',
    () {
      expect(
        forumVoiceDuration('disfly-voice-123-9s.mp3'),
        const Duration(seconds: 9),
      );
      expect(forumVoiceDuration('disfly-voice-123-61s.mp3'), isNull);
      expect(forumVoiceDuration('interview.mp3'), isNull);
      expect(isForumAudioFile('interview.MP3'), isTrue);
      expect(isForumAudioFile('interview.mp3.zip'), isFalse);
    },
  );
}
