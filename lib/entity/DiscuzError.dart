
import 'package:dio/dio.dart';

class DiscuzError{
  String key = "", content = "";
  ErrorType? errorType = null;
  DioException? dioError = null;
  DiscuzError(this.key,this.content, {this.errorType, this.dioError, this.errorURL});
  String? errorURL = "";

}

enum ErrorType{
  userExpired
}