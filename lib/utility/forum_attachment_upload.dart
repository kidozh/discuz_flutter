import 'dart:convert';

import '../generated/l10n.dart';
import 'discuz_json.dart';

class ForumUploadResult {
  final int? aid;
  final int? errorCode;

  const ForumUploadResult._({this.aid, this.errorCode});

  factory ForumUploadResult.parse(String response) {
    final text = response.trim();
    final number = int.tryParse(text);
    if (number != null) {
      return number > 0
          ? ForumUploadResult._(aid: number)
          : ForumUploadResult._(errorCode: number < 0 ? -number : null);
    }

    final fields = text.split('|');
    if (fields.length >= 5 && fields.first == 'DISCUZUPLOAD') {
      final statusIndex = fields.length >= 8 ? 2 : 1;
      return ForumUploadResult._fromFields(
        fields[statusIndex],
        fields[statusIndex + 1],
      );
    }
    if (text.startsWith('{')) {
      try {
        final variables = discuzMap(discuzMap(jsonDecode(text))['Variables']);
        return ForumUploadResult._fromFields(
          variables['code'],
          discuzMap(variables['ret'])['aId'],
        );
      } on FormatException {
        return const ForumUploadResult._();
      }
    }
    return const ForumUploadResult._();
  }

  factory ForumUploadResult._fromFields(Object? status, Object? attachment) {
    final code = int.tryParse(discuzString(status));
    final aid = int.tryParse(discuzString(attachment));
    return ForumUploadResult._(
      aid: code == 0 && aid != null && aid > 0 ? aid : null,
      errorCode: code == 0 ? null : code,
    );
  }
}

String forumUploadErrorText(S s, int? code, String fallback) => switch (code) {
  -1 => s.uploadImageErrorNegative1,
  1 => s.uploadImageError1,
  2 => s.uploadImageError2,
  3 => s.uploadImageError3,
  4 => s.uploadImageError4,
  5 => s.uploadImageError5,
  6 => s.uploadImageError6,
  7 => s.uploadImageError7,
  8 => s.uploadImageError8,
  9 => s.uploadImageError9,
  10 => s.uploadImageError10,
  11 => s.uploadImageError11,
  12 => s.uploadImageError12,
  13 => s.uploadImageError13,
  _ => fallback,
};
