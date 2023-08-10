
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/SubscribeChannelResult.dart';
import 'package:retrofit/http.dart';

part 'PushServiceClient.g.dart';

@RestApi(baseUrl: "https://dhp.kidozh.com")
abstract class PushServiceClient {
  factory PushServiceClient(Dio dio, {required String baseUrl}) = _PushServiceClient;

  @GET("/channel/api")
  Future<SubscribeChannelResult> getAllChannelByHost(@Query("host") String host, @Query("token") String token);

}