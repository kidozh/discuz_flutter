import 'package:dio/dio.dart';

import '../client/ForumInteractionClient.dart';

/// Diagnostics deliberately exclude URLs, credentials, form data and reasons.
String ratingFailureCode(Object error) {
  if (error is ForumApiException) {
    return RegExp(r'^[a-zA-Z0-9_:.-]{1,100}$').hasMatch(error.code)
        ? error.code
        : 'forum_error';
  }
  if (error is DioException) {
    final status = error.response?.statusCode;
    return 'network_${error.type.name}${status == null ? '' : '_http_$status'}';
  }
  if (error is FormatException) return 'invalid_response_format';
  return 'unexpected_error';
}
