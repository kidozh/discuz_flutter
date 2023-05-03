

import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'CheveretoApiClient.g.dart';

@RestApi(baseUrl: "https://sm.ms")
abstract class CheveretoApiClient {
  factory CheveretoApiClient(Dio dio, {required String baseUrl}) = _CheveretoApiClient;
}