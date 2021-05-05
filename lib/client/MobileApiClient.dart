import 'package:discuz_flutter/JsonResult/ApiResult.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/JsonResult/HotThreadResult.dart';
import 'package:discuz_flutter/JsonResult/LoginResult.dart';
import 'package:discuz_flutter/JsonResult/UserDiscuzNotificationResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'MobileApiClient.g.dart';

@RestApi(baseUrl: "https://keylol.com/")
abstract class MobileApiClient {
  factory MobileApiClient(Dio dio, {required String baseUrl}) = _MobileApiClient;


  @GET("/api/mobile/index.php?version=4&module=check")
  @Headers(<String, dynamic>{
    "Content-Type" : "application/json"
  })
  Future<CheckResult> getCheckResult();

  @GET("/api/mobile/index.php?version=4&module=check")
  @Headers(<String, dynamic>{
    "Content-Type" : "application/json"
  })
  Future<String> getCheckResultInString();

  @POST("/api/mobile/index.php?version=4"
      "&module=login&mod=logging&action=login"
      "&loginfield=username&loginsubmit=yes"
      "&cookietime=2592000")
  @FormUrlEncoded()
  Future<LoginResult> sendLoginRequest(
      @Field("username") String username,
      @Field("password") String password,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification

      );

  @POST("/api/mobile/index.php?version=4"
      "&module=login&mod=logging&action=login"
      "&loginfield=username&loginsubmit=yes"
      "&cookietime=2592000")
  @FormUrlEncoded()
  Future<String> sendLoginRequestInString(
      @Field("username") String username,
      @Field("password") String password,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification
      );

  @GET("/api/mobile/index.php?version=4&module=forumindex")
  Future<DiscuzIndexResult> getDiscuzPortalResult();

  @GET("/api/mobile/index.php?version=4&module=forumindex")
  Future<String> getDiscuzPortalRaw();

  @GET("/api/mobile/index.php?version=4&module=forumdisplay")
  Future<DisplayForumResult> displayForumResult(@Query("fid") String fid,@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=forumdisplay")
  Future<String> displayForumRaw(@Query("fid") String fid,@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=viewthread&ppp=10")
  Future<ViewThreadResult> viewThreadResult(@Query("tid") int tid,@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=viewthread&ppp=10")
  Future<String> viewThreadRaw(@Query("tid") int tid,@Query("page") int page);

  // map{
  // "seccodemodid", "forum::viewthread",
  // "seccodehash" , CAPTCHA_HASH,
  // "seccodeverify", CAPTCHA_CODE
  // }
  @POST("/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread")
  @FormUrlEncoded()
  Future<String> sendReplyRaw(
      @Field() int fid,
      @Field("tid") int tid,
      @Field("formhash") String formhash,
      @Field("message") String message,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification

      // @Body() Map<String, dynamic> map
      );

  @POST("/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread")
  @FormUrlEncoded()
  Future<ApiResult> sendReplyResult(
      @Field() int fid,
      @Field("tid") int tid,
      @Field("formhash") String formhash,
      @Field("message") String message,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification
      );

  @GET("/api/mobile/index.php?version=4&module=mynotelist")
  Future<String> userNotificationRaw(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=mynotelist")
  Future<UserDiscuzNotificationResult> userNotificationResult(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=hotthread")
  Future<String> hotThreadRaw(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=hotthread")
  Future<HotThreadResult> hotThreadResult(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=secure")
  Future<CaptchaResult> captchaResult(@Query("type") String type);
}