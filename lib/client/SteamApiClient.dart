

import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'SteamApiClient.g.dart';

@RestApi(baseUrl: "https://store.steampowered.com/")
abstract class SteamApiClient {
  factory SteamApiClient(Dio dio, {required String baseUrl}) = _SteamApiClient;

  @GET("/api/appdetails")
  Future<String> getSteamGameResultByAppId(
      @Query("appids") String appId,
      @Query("l") String language
      );
}