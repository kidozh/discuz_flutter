import 'dart:io';

import 'package:discuz_flutter/JsonResult/ApiResult.dart';
import 'package:discuz_flutter/JsonResult/BaseVariableResult.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/JsonResult/CheckLoginResult.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/JsonResult/HotThreadResult.dart';
import 'package:discuz_flutter/JsonResult/LoginResult.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:discuz_flutter/JsonResult/PrivateMessagePortalResult.dart';
import 'package:discuz_flutter/JsonResult/PublicMessagePortalResult.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/JsonResult/UserDiscuzNotificationResult.dart';
import 'package:discuz_flutter/JsonResult/UserProfileResult.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/entity/HotThread.dart';
import 'package:discuz_flutter/entity/Post.dart';
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
  Future<DisplayForumResult> displayForumResult(@Query("fid") String fid,@Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=forumdisplay")
  Future<String> displayForumRaw(@Query("fid") String fid,@Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=viewthread")
  Future<ViewThreadResult> viewThreadResult(@Query("tid") int tid,@Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=viewthread")
  Future<String> viewThreadRaw(@Query("tid") int tid,@Query("page") int page, @Queries() Map<String, dynamic> queries);

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
      @Field("seccodeverify") String verification,
      @Queries() Map<String, dynamic> queries
      // @Body() Map<String, dynamic> map
      );

  @POST("/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread")
  @FormUrlEncoded()
  Future<ApiResult> sendReplyResult(
      @Field() int fid,
      @Field("tid") int tid,
      @Field("formhash") String formhash,
      @Field("reppid") int? replyPostId,
      @Field("noticetrimstr") String? notifyTriPostMessage,
      @Field("message") String message,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification,
      @Queries() Map<String, dynamic> queries
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

  @POST("/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll")
  @FormUrlEncoded()
  Future<ApiResult> votePoll(@Query("fid") int fid,@Query("tid") int tid,@Field("formhash") String formHash, @Field("pollanswers[]") List<int> checkedOptionId);

  @POST("/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll")
  @FormUrlEncoded()
  Future<String> votePollRaw(@Query("fid") int fid,@Query("tid") int tid,@Field("formhash") String formHash, @Field("pollanswers[]") List<int> checkedOptionId);

  @GET("/api/mobile/index.php?version=4&module=login")
  Future<CheckLoginResult> checkLoginResult();

  @GET("/api/mobile/index.php?version=4&module=profile")
  Future<UserProfileResult> userProfileResult(@Query("uid") int uid);

  @GET("/api/mobile/index.php?version=4&module=profile")
  Future<String> userProfileResultRaw(@Query("uid") int uid);

  @GET("/api/mobile/index.php?version=4&module=smiley")
  Future<SmileyResult> smileyResult();

  @GET("/api/mobile/index.php?version=4&module=mypm")
  Future<PrivateMessagePortalResult> privateMessagePortalResult(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=mypm&subop=view")
  Future<PrivateMessageDetailResult> privateMessageDetailResult(@Query("touid") int toUid,@Query("page") int page);

  @POST("/api/mobile/index.php?version=4&ac=pm&op=send&daterange=0&module=sendpm&pmsubmit=yes")
  @FormUrlEncoded()
  Future<ApiResult> sendPrivateMessageResult(
      @Field("formhash") String formHash,
      @Field("message") String message,
      @Field("touid") int toUid);

  @GET("/api/mobile/index.php?version=4&module=publicpm")
  Future<PublicMessagePortalResult> publicMessagePortalResult(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=myfavthread")
  Future<FavoriteThreadResult> favoriteThreadResult(@Query("page") int page);

  @MultiPart()
  @POST("/api/mobile/index.php?version=4&module=forumupload&type=image")
  Future<String> uploadImage(@Part(name:"uid") int uid, @Part(name:"hash") String uploadHash, @Part(name:"Filedata") File file);

  @GET("/api/mobile/index.php?version=4&module=checkpost")
  Future<CheckPostResult> checkPost(@Query("fid") int? fid, @Query("tid") int? tid);


  @POST("/misc.php?mod=report&inajax=1&handlekey=miscreport120&reportsubmit=true")
  @FormUrlEncoded()
  Future<String> reportContent(@Field("formhash") String formHash,
      @Field("report_select") String report_select,
      @Field("message") String message,
      @Field("rtype") String rtype,
      @Field("rid") int rid,

      );
}