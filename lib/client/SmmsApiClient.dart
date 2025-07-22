
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/SmmsTokenResult.dart';
import 'package:discuz_flutter/JsonResult/SmmsUploadImageResult.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../JsonResult/SmmsProfileResult.dart';

part 'SmmsApiClient.g.dart';

@RestApi(baseUrl: "https://sm.ms/api/v2")
abstract class SmmsApiClient {
  factory SmmsApiClient(Dio dio, {required String baseUrl}) = _SmmsApiClient;

  @POST("/token")
  @FormUrlEncoded()
  Future<SmmsTokenResult> getApiTokenResult(
      @Header("Authorization") String authorization,
      );

  @POST("/profile")
  @FormUrlEncoded()
  Future<SmmsProfileResult> getProfileResult(
      @Header("Authorization") String authorization,
      );

  @POST("/upload")
  @FormUrlEncoded()
  Future<SmmsUploadImageResult> uploadImageResult(
      @Header("Authorization") String authorization,
      @Part() File smfile,
      );
}