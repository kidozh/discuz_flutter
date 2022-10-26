
import 'package:dio/dio.dart';

class DiscuzError{
  String key = "", content = "";
  ErrorType? errorType = null;
  DioError? dioError = null;
  DiscuzError(this.key,this.content, {this.errorType, this.dioError});

}

enum ErrorType{
  userExpired
}