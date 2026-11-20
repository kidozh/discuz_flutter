import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parseFragment;

import '../JsonResult/BaseResult.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/DiscuzError.dart';
import '../generated/l10n.dart';

String forumMessageKey(String key) =>
    key.split('//').first.trim().toLowerCase();

DiscuzError? forumResponseError(S strings, BaseResult result) {
  final code = result.errorResult?.key.trim() ?? '';
  final error = result.error?.trim() ?? '';
  if (code.isEmpty && error.isEmpty && result.errorResult == null) return null;
  return code.isNotEmpty || error.isNotEmpty
      ? _forumMessage(
          strings,
          code.isNotEmpty ? code : error,
          result.errorResult?.content ?? '',
        )
      : forumRequestError(strings, const FormatException());
}

DiscuzError forumRequestError(
  S strings,
  Object error, {
  String? fallback,
  bool submitted = false,
}) {
  final failure = _requestFailure(strings, error, fallback);
  if (!submitted || (failure.dioError == null && !failure.reportable)) {
    return failure;
  }
  return DiscuzError(
    failure.key,
    '${failure.content}\n${strings.forumSubmissionUnknown}',
    errorType: failure.errorType,
    dioError: failure.dioError,
    errorURL: failure.errorURL,
    reportable: failure.reportable,
  );
}

DiscuzError _requestFailure(S strings, Object error, String? fallback) {
  if (error is DiscuzError) return error;
  if (error is ForumApiException) {
    if (error.fromForum) {
      return _forumMessage(strings, error.code, error.message);
    }
    if (const {
      'empty_response',
      'unexpected_markup_response',
      'invalid_response_format',
      'invalid_response',
    }.contains(error.code)) {
      return DiscuzError(
        error.code,
        strings.forumUnexpectedResponse,
        reportable: true,
      );
    }
    return _forumMessage(
      strings,
      error.code,
      error.message,
      fallback: fallback,
    );
  }
  if (error is DioException) {
    final response = error.response;
    final status = response?.statusCode;
    final forumError = ForumReply.tryServerError(response?.data);
    if (forumError != null) {
      return _forumMessage(strings, forumError.code, forumError.message);
    }
    if (response?.statusCode == 567 ||
        ForumReply.isSecurityChallenge(response?.data)) {
      return DiscuzError(
        'forum_security_challenge',
        strings.forumSecurityChallenge,
      );
    }
    if (error.type == DioExceptionType.unknown &&
        status != null &&
        status >= 400) {
      return DiscuzError(
        'http_$status',
        _httpMessage(strings, status),
        dioError: error,
      );
    }
    final cause = error.error;
    if (cause is ForumApiException) {
      return _requestFailure(strings, cause, fallback);
    }
    final (message, reportable) = switch (error.type) {
      DioExceptionType.connectionTimeout => (
        strings.dioErrorConnectionTimeout,
        false,
      ),
      DioExceptionType.sendTimeout => (strings.dioErrorSendTimeout, false),
      DioExceptionType.receiveTimeout => (
        strings.dioErrorReceiveTimeout,
        false,
      ),
      DioExceptionType.badCertificate => (
        strings.dioErrorBadCertificate,
        false,
      ),
      DioExceptionType.badResponse => (
        _httpMessage(strings, response?.statusCode),
        false,
      ),
      DioExceptionType.cancel => (strings.dioErrorCancel, false),
      DioExceptionType.transformTimeout => (
        strings.forumResponseProcessingTimeout,
        true,
      ),
      DioExceptionType.connectionError ||
      DioExceptionType.unknown => switch (cause) {
        TlsException() => (strings.dioErrorBadCertificate, false),
        SocketException(:final message) when _looksLikeDnsFailure(message) => (
          strings.forumDnsFailure,
          false,
        ),
        SocketException() ||
        HttpException() => (strings.dioErrorConnectionError, false),
        TimeoutException() => (strings.dioErrorReceiveTimeout, false),
        FormatException() ||
        TypeError() => (strings.forumUnexpectedResponse, true),
        _ =>
          error.type == DioExceptionType.connectionError
              ? (strings.dioErrorConnectionError, false)
              : (fallback ?? strings.forumUnexpectedError, true),
      },
    };
    return DiscuzError(
      error.type.name,
      message,
      dioError: error,
      reportable: reportable,
    );
  }
  return switch (error) {
    SocketException(:final message) when _looksLikeDnsFailure(message) =>
      DiscuzError('network_fail', strings.forumDnsFailure),
    SocketException() || HttpException() => DiscuzError(
      'network_fail',
      strings.dioErrorConnectionError,
    ),
    TlsException() => DiscuzError(
      'network_fail',
      strings.dioErrorBadCertificate,
    ),
    TimeoutException() => DiscuzError(
      'network_fail',
      strings.dioErrorReceiveTimeout,
    ),
    FormatException() || TypeError() => DiscuzError(
      'invalid_response_format',
      strings.forumUnexpectedResponse,
      reportable: true,
    ),
    _ => DiscuzError(
      'unexpected_error',
      fallback ?? strings.forumUnexpectedError,
      reportable: true,
    ),
  };
}

DiscuzError _forumMessage(
  S strings,
  String rawCode,
  String message, {
  String? fallback,
}) {
  final code = forumMessageKey(rawCode);
  final plain =
      parseFragment(
        message.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' '),
      ).text?.trim() ??
      '';
  final content =
      plain.isNotEmpty &&
          plain != rawCode.trim() &&
          plain.toLowerCase() != code &&
          plain.toLowerCase() != 'mobile:$code'
      ? plain
      : switch (code) {
          'mobile_template_no_found' => strings.mobileTemplateNotFound,
          'forum_webpage_redirect' => strings.forumWebpageRedirect,
          'module_not_exists' ||
          'identifier_not_exists' ||
          'identifier_file_not_exists' => strings.forumApiUnavailable,
          'friend_status_off' ||
          'mobile_is_closed' ||
          'board_closed' ||
          'action_closed' => strings.forumFeatureDisabled,
          'forum_security_challenge' => strings.forumSecurityChallenge,
          'not_loggedin' ||
          'to_login' ||
          'login_required' ||
          'login_before_enter_home' ||
          'login_before_enter' => strings.forumSignInRequired,
          'account_changed' => strings.forumAccountChanged,
          'missing_formhash' ||
          'submit_invalid' ||
          'mobilesign_formhash_failed' => strings.forumFormExpired,
          'param_error' => strings.forumApiInvalidRequest,
          'submit_seccode_invalid' ||
          'submit_secqaa_invalid' => strings.forumCaptchaIncorrect,
          'login_invalid' ||
          'login_password_invalid' => strings.forumLoginRejected,
          'thread_nonexistence' ||
          'post_nonexistence' ||
          'post_not_found' ||
          'attachment_nonexistence' ||
          'forum_nonexistence' => strings.forumContentUnavailable,
          'forum_passwd' ||
          'forum_passwd_incorrect' => strings.forumPasswordRequired,
          'thread_closed' || 'post_thread_closed' => strings.forumThreadClosed,
          'post_flood_ctrl' ||
          'search_toomany' ||
          'thread_rate_ctrl' => strings.forumRateLimited,
          'credits_balance_insufficient' ||
          'credits_balance_insufficient_and_charge' ||
          'credits_policy_lowerlimit' ||
          'credits_policy_lowerlimit_fid' ||
          'credits_policy_lowerlimit_norule' ||
          'replycredit_morethan_self' ||
          'reward_credits_shortage' => strings.forumCreditsInsufficient,
          'poll_picture_rejected' => strings.pollPictureRejected,
          'post_options_changed' => strings.specialPostRulesChanged,
          'post_rushreply_timewrong' => strings.rushSettingsInvalid,
          'activity_is_not_manager' => strings.forumPermissionDenied,
          'activity_review_changed' => strings.activityReviewChanged,
          'post_edit_timelimit' ||
          'post_edit_nopermission' => strings.forumPermissionDenied,
          'edit_post_changed' => strings.editPostChanged,
          'edit_post_verify' => strings.editPostVerify,
          'edit_post_attachment_partial' => strings.editPostAttachmentPartial,
          'edit_post_unsupported' => strings.editPostUnsupported,
          'activity_stop' => strings.activityClosed,
          'activity_exile_field' => strings.activityRequired,
          _ when code.contains('login_nopermission') =>
            strings.forumSignInRequired,
          _
              when code.contains('nopermission') ||
                  code.contains('no_privilege') =>
            strings.forumPermissionDenied,
          _ => fallback ?? strings.forumActionFailed,
        };
  return DiscuzError(code, content);
}

bool _looksLikeDnsFailure(String message) {
  final text = message.toLowerCase();
  return text.contains('failed host lookup') ||
      text.contains('nodename nor servname') ||
      text.contains('name or service not known') ||
      text.contains('temporary failure in name resolution') ||
      text.contains('no address associated');
}

String _httpMessage(S strings, int? status) => switch (status) {
  401 => strings.forumHttpUnauthorized,
  403 => strings.forumHttpForbidden,
  404 || 410 => strings.forumHttpMissing,
  408 || 504 => strings.forumHttpTimeout('$status'),
  413 => strings.forumHttpTooLarge,
  429 => strings.forumHttpRateLimited,
  final int code when code >= 500 => strings.forumHttpServerError('$code'),
  final int code => strings.forumHttpRejected('$code'),
  null => strings.dioErrorBadResponse,
};
