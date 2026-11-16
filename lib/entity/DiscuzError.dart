import 'package:dio/dio.dart';

class DiscuzError implements Exception {
  final String key, content;
  final ErrorType? errorType;
  final DioException? dioError;
  final String? errorURL;
  final bool reportable;

  const DiscuzError(
    this.key,
    this.content, {
    this.errorType,
    this.dioError,
    this.errorURL,
    this.reportable = false,
  });
}

enum ErrorType { userExpired }
