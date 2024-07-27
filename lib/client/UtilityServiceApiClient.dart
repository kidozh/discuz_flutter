
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/SubscribeChannelResult.dart';
import 'package:discuz_flutter/JsonResult/ThreadSlideShowResult.dart';
import 'package:retrofit/http.dart';

part 'UtilityServiceApiClient.g.dart';

@RestApi(baseUrl: "https://discuzhub.kidozh.com")
abstract class UtilityServiceApiClient {
  factory UtilityServiceApiClient(Dio dio, {required String baseUrl}) = _UtilityServiceApiClient;

  @GET("/support-discuz-list.min.json")
  Future<String> getAllSuggestedDiscuzList();

}