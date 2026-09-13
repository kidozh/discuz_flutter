import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/entity/Post.dart';

void main() {
  test(
    'permission response can omit attachment fields and the base envelope',
    () {
      final result = CheckPostResult.fromJson({
        'Variables': {
          'allowperm': {'allowpost': '0', 'allowreply': 1},
        },
      });
      expect(result.variables.allowPerm.allowPost, false);
      expect(result.variables.allowPerm.allowReply, true);
      expect(result.variables.allowPerm.allowUpload.limits, isEmpty);
      expect(
        CheckPostResult.fromJson({
          'error': 'module_not_exists',
        }).getErrorString(),
        'module_not_exists',
      );
      expect(
        CheckPostResult.fromJson({}).variables.allowPerm.allowPost,
        isNull,
      );
    },
  );

  AllowPerm permission({Object? count = '-1', Object? size = '-1'}) =>
      AllowPerm.fromJson({
        'uploadhash': 'hash',
        'allowupload': {'jpg': '-1', 'png': 1024, 'gif': '0', 'webp': '2048'},
        'attachremain': {'count': count, 'size': size},
      });
  test(
    'unlimited quotas permit an upload and dynamic extension limits survive decoding',
    () {
      expect(permission().validateUpload('IMAGE.JPG', 10000000), isNull);
      expect(permission().validateUpload('test.webp', 2048), isNull);
      expect(
        permission().validateUpload('test.webp', 2049),
        UploadRestriction.fileSize,
      );
    },
  );
  test('denied and missing types are not upload grants', () {
    expect(permission().validateUpload('image.gif', 1), UploadRestriction.type);
    expect(
      permission().validateUpload('image.heic', 1),
      UploadRestriction.type,
    );
    expect(AllowPerm().validateUpload('image.jpg', 1), UploadRestriction.type);
  });
  test(
    'exact quota boundary is allowed; exhausted count and exceeded size are blocked',
    () {
      expect(permission(size: 100).validateUpload('a.jpg', 100), isNull);
      expect(
        permission(size: 100).validateUpload('a.jpg', 101),
        UploadRestriction.dailySize,
      );
      expect(
        permission(count: 0).validateUpload('a.jpg', 1),
        UploadRestriction.count,
      );
      expect(
        permission(size: 0).validateUpload('a.jpg', 1),
        UploadRestriction.dailySize,
      );
      expect(
        permission(size: null, count: null).validateUpload('a.jpg', 1),
        isNull,
      );
    },
  );
  test(
    'attachment IDs, bools and mixed numeric scalars decode rather than silently disappear',
    () {
      final post = Post.fromJson({
        'pid': 30,
        'tid': '20',
        'number': 2,
        'attachlist': [123, '124'],
        'imagelist': {'0': '123'},
        'attachments': {
          '123': {
            'aid': 123,
            'tid': '20',
            'pid': 30,
            'uid': 4,
            'remote': '1',
            'thumb': true,
            'payed': 1,
            'filesize': 10,
          },
        },
      });
      final attachment = post.attachmentMapper['123']!;
      expect(post.attachmentIdList, ['123', '124']);
      expect(post.imageIdList, ['123']);
      expect(attachment.aid, 123);
      expect(attachment.pid, 30);
      expect(attachment.remote && attachment.thumb && attachment.payed, true);
    },
  );
  test(
    'special payloads support PHP empty arrays and keyed option lists; survive cache JSON',
    () {
      final result = ViewThreadResult.fromJson({
        'Variables': {
          'thread': {'tid': 20, 'subject': 'Example'},
          'ppp': 15,
          'special_reward': {
            'rewardprice': '10 credits',
            'bestpost': {'pid': '99'},
          },
          'special_activity': {
            'allapplynum': '2',
            'status': 'wait',
            'closed': '0',
          },
          'threadsortshow': {
            'threadsortname': 'Sale',
            'optionlist': {
              '7': {'title': 'Price', 'value': '100', 'unit': 'USD'},
              '8': null,
            },
          },
        },
      });
      final restored = ViewThreadResult.fromJson(
        jsonDecode(jsonEncode(result)),
      );
      expect(restored.threadVariables.reward!.bestPid, 99);
      expect(restored.threadVariables.activity!.applicants, 2);
      expect(restored.threadVariables.activity!.closed, false);
      expect(
        restored.threadVariables.threadSort!.options.single.title,
        'Price',
      );
      expect(
        ViewThreadResult.fromJson({
          'Variables': {'special_reward': [], 'special_activity': []},
        }).threadVariables.reward,
        isNull,
      );
      expect(
        ViewThreadResult.fromJson({
          'error': 'permission_denied',
        }).getErrorString(),
        'permission_denied',
      );
    },
  );
  test(
    'optional profile fields do not wipe out the user; gender retains all three values',
    () {
      for (final gender in [0, 1, 2]) {
        final profile = SpaceVariables.fromJson({
          'uid': '5',
          'username': 'Reader',
          'gender': gender,
        });
        expect(profile.uid, 5);
        expect(profile.username, 'Reader');
        expect(profile.gender, gender);
      }
    },
  );
  test('missing or malformed timestamps do not fabricate the current date', () {
    const converter = SecondToDateTimeConverter();
    expect(converter.fromJson('bad').millisecondsSinceEpoch, 0);
    expect(converter.fromJson(null).millisecondsSinceEpoch, 0);
    expect(converter.fromJson(1700000000), converter.fromJson('1700000000'));
  });
}
