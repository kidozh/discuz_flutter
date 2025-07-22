import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:discuz_flutter/JsonResult/ChevertoUploadResult.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'CheveretoApiClient.g.dart';

@RestApi(baseUrl: "https://api.imgbb.com/1/")
abstract class CheveretoApiClient {
  factory CheveretoApiClient(Dio dio, {required String baseUrl}) = _CheveretoApiClient;

  @POST("/upload/")
  @FormUrlEncoded()
  Future<ChevertoUploadResult> uploadImageToCheveretoByBase64(
      @Header("X-API-Key") String apiToken,
      @Field("source") String base64String,
      );

  @POST("/upload/")
  @FormUrlEncoded()
  Future<ChevertoUploadResult> uploadImageToCheveretoByBinaryFile(
      @Header("X-API-Key") String apiToken,
      @Part() File source,
      );
}