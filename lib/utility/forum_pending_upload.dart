import 'dart:io';

import 'package:dio/dio.dart';

import '../JsonResult/CheckPostResult.dart';
import '../client/ForumInteractionClient.dart';
import '../client/MobileApiClient.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';
import 'forum_attachment_upload.dart';
import 'forum_error.dart';
import 'forum_image_upload_utils.dart';

Future<String> uploadPendingForumAttachment({
  required MobileApiClient api,
  required S strings,
  required int fid,
  required int tid,
  required int uid,
  required File file,
  required String name,
  required bool image,
  required bool Function() isCurrent,
  bool replying = true,
}) async {
  if (!await file.exists() || await file.length() <= 0) {
    throw DiscuzError('attachment_unreadable', strings.replyDraftUploadMissing);
  }
  final post = await api.checkPost(fid, tid > 0 ? tid : null);
  final error = forumResponseError(strings, post);
  if (error != null) throw error;
  final permission = post.variables.allowPerm;
  if (!isCurrent() || post.variables.member_uid != uid) {
    throw const ForumApiException('account_changed', '');
  }
  if (replying && permission.allowReply != true) {
    throw DiscuzError(
      'reply_permission',
      permission.allowReply == false
          ? strings.replyPermissionDenied
          : strings.postPermissionUnknown,
    );
  }
  if (tid <= 0 && permission.allowPost != true) {
    throw DiscuzError(
      'post_permission',
      permission.allowPost == false
          ? strings.postPermissionDenied
          : strings.postPermissionUnknown,
    );
  }
  final prepared = image
      ? await prepareForumImageUpload(file, permission)
      : file;
  final failure = permission.validateUpload(name, await file.length());
  if (prepared == null || (!image && failure != null)) {
    throw DiscuzError('attachment_restriction', switch (failure) {
      UploadRestriction.type => strings.uploadTypeDenied,
      UploadRestriction.count => strings.uploadCountExhausted,
      UploadRestriction.dailySize => strings.uploadDailySizeExceeded,
      UploadRestriction.fileSize => strings.uploadFileSizeExceeded,
      null => strings.attachmentUploadFailed,
    });
  }
  if (!isCurrent()) throw const ForumApiException('account_changed', '');
  final response = image
      ? await api.uploadImage(uid, permission.uploadHash, prepared)
      : await api.uploadAttachment(
          fid,
          uid,
          permission.uploadHash,
          MultipartFile.fromStream(
            prepared.openRead,
            await prepared.length(),
            filename: Uri.encodeComponent(name),
          ),
        );
  final upload = ForumUploadResult.parse(response);
  if (upload.aid case final aid?) return '$aid';
  if (upload.errorCode case final number?) {
    throw DiscuzError(
      'forum_upload_$number',
      forumUploadErrorText(strings, number, strings.attachmentUploadFailed),
    );
  }
  final reply = ForumReply.tryServerError(response);
  throw reply ?? const FormatException('Unrecognized attachment response');
}
