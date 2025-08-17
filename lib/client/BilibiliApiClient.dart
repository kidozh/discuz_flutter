

import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/BilibiliDynamicDetailResult.dart';
import 'package:discuz_flutter/JsonResult/BilibiliVideoResult.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'BilibiliApiClient.g.dart';

@RestApi(baseUrl: "https://api.bilibili.com")
abstract class BilibiliApiClient {
  factory BilibiliApiClient(Dio dio, {required String baseUrl}) = _BilibiliApiClient;

  @GET("/x/web-interface/view/detail")
  Future<BilibiliVideoResult> getVideoResultByAid(
      @Query("aid") String aid,
      );

  @GET("/x/web-interface/view/detail")
  Future<BilibiliVideoResult> getVideoResultByBvid(
      @Query("bvid") String bvid,
      );

  @GET("/x/article/viewinfo")
  Future<BilibiliVideoResult> getArticleResultByCvid(
      @Query("id") int cvid,
      );

  @GET("/x/polymer/web-dynamic/v1/detail")
  Future<BilibiliDynamicDetailResult> getOpusDynamicResultById(
      @Query("id") int id,
      @Query("w_rid") String w_rid,
      @Query("wts") int wts,
      );

  @GET("/x/polymer/web-dynamic/v1/detail")
  Future<BilibiliDynamicDetailResult> getOpusDynamicResultByIdInMaps(
      @Queries() Map<String, dynamic> queries
      );
}