
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/SubscribeChannelResult.dart';
import 'package:discuz_flutter/JsonResult/ThreadSlideShowResult.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'PushServiceClient.g.dart';

@RestApi(baseUrl: "https://dhp.kidozh.com")
abstract class PushServiceClient {
  factory PushServiceClient(Dio dio, {required String baseUrl}) = _PushServiceClient;

  @GET("/channel/api")
  Future<SubscribeChannelResult> getAllChannelByHost(@Query("host") String host, @Query("token") String token);

  @POST("/channel/api")
  Future<SubscribeChannelResult> changeSubscribeChannelByHost(
      @Query("host") String host,
      @Query("token") String token,
      @Query("add") List<String> addId,
      @Query("remove") List<String> removeId,
      @Query("packageId") String packageId,
      @Query("platform") String pushPlatform,
      );

  @PUT("/channel/api")
  Future<SubscribeChannelResult> setSubscribeChannelByHost(
      @Query("host") String host,
      @Query("token") String token,
      @Query("channel") List<String> channelList,
      @Query("packageId") String packageId,
      @Query("platform") String pushPlatform,
      );

  @DELETE("/channel/api")
  Future<SubscribeChannelResult> deleteSubscribeChannelByHost(
      @Query("host") String host,
      @Query("token") String token,
      @Query("channel") List<String> channelList,
      @Query("packageId") String packageId,
      @Query("platform") String pushPlatform,
      );

  @GET("/customize-slide/api")
  Future<ThreadSlideShowResult> getThreadSlideShowResultByHost(@Query("host") String host);
}