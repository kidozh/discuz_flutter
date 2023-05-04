

import 'package:dio/dio.dart' hide Headers;
import 'package:discuz_flutter/JsonResult/ChevertoUploadResult.dart';
import 'package:retrofit/http.dart';

part 'CheveretoApiClient.g.dart';

@RestApi(baseUrl: "https://sm.ms")
abstract class CheveretoApiClient {
  factory CheveretoApiClient(Dio dio, {required String baseUrl}) = _CheveretoApiClient;

  @POST("/api/1/upload/")
  @FormUrlEncoded()
  Future<ChevertoUploadResult> uploadImageToChevereto(
      @Header("X-API-Key") String apiToken,
      @Field("source") String base64String,
      );
}