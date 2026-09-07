import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class DiscuzError {
  String key = "", content = "";
  ErrorType? errorType = null;
  DioException? dioError = null;
  DiscuzError(this.key, this.content,
      {this.errorType, this.dioError, this.errorURL});
  String? errorURL = "";

  /// Transport and HTTP failures are not actionable app bug reports.
  bool get isNetworkError {
    if (key == 'network_fail') return true;
    final exception = dioError;
    if (exception == null) return false;
    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.badResponse ||
      DioExceptionType.cancel =>
        true,
      DioExceptionType.transformTimeout => false,
      DioExceptionType.unknown => exception.error is SocketException ||
          exception.error is HandshakeException ||
          exception.error is TimeoutException,
    };
  }
}

enum ErrorType { userExpired }
