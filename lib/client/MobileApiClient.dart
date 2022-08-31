import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:discuz_flutter/JsonResult/ApiResult.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/JsonResult/CheckLoginResult.dart';
import 'package:discuz_flutter/JsonResult/CheckPostResult.dart';
import 'package:discuz_flutter/JsonResult/CheckResult.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/JsonResult/FavoriteForumResult.dart';
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
import 'package:retrofit/retrofit.dart';

import '../JsonResult/NewThreadResult.dart';
import '../JsonResult/PushTokenListResult.dart';

part 'MobileApiClient.g.dart';

@RestApi(baseUrl: "https://keylol.com/")
abstract class MobileApiClient {
  factory MobileApiClient(Dio dio, {required String baseUrl}) =
      _MobileApiClient;

  @GET("/api/mobile/index.php?version=4&module=check")
  @Headers(<String, dynamic>{"Content-Type": "application/json"})
  Future<CheckResult> getCheckResult();

  @GET("/api/mobile/index.php?version=4&module=check")
  @Headers(<String, dynamic>{"Content-Type": "application/json"})
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
      @Field("seccodeverify") String verification);

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
      @Field("seccodeverify") String verification);

  @GET("/api/mobile/index.php?version=4&module=forumindex")
  Future<DiscuzIndexResult> getDiscuzPortalResult();

  @GET("/api/mobile/index.php?version=4&module=forumindex")
  Future<String> getDiscuzPortalRaw();

  @GET("/api/mobile/index.php?version=4&module=forumdisplay")
  Future<DisplayForumResult> displayForumResult(@Query("fid") String fid,
      @Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=forumdisplay")
  Future<String> displayForumRaw(@Query("fid") String fid,
      @Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=viewthread&ppp=15")
  Future<ViewThreadResult> viewThreadResult(@Query("tid") int tid,
      @Query("page") int page, @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=viewthread&ppp=15")
  Future<String> viewThreadRaw(@Query("tid") int tid, @Query("page") int page,
      @Queries() Map<String, dynamic> queries);

  // map{
  // "seccodemodid", "forum::viewthread",
  // "seccodehash" , CAPTCHA_HASH,
  // "seccodeverify", CAPTCHA_CODE
  // }
  @POST(
      "/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread")
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

  @POST(
      "/api/mobile/index.php?version=4&module=sendreply&action=reply&replysubmit=yes&usesig=1&seccodemodid=forum::viewthread")
  @FormUrlEncoded()
  Future<ApiResult> sendReplyResult(
      @Field() int fid,
      @Field("tid") int tid,
      @Field("formhash") String formhash,
      @Field("reppid") int? replyPostId,
      @Query("repquote") int? replyPId,
      @Field("noticetrimstr") String? notifyTriPostMessage,
      @Field("message") String message,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification,
      @Queries() Map<String, dynamic> queries);

  @GET("/api/mobile/index.php?version=4&module=mynotelist")
  Future<String> userNotificationRaw(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=mynotelist")
  Future<UserDiscuzNotificationResult> userNotificationResult(
      @Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=hotthread")
  Future<String> hotThreadRaw(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=hotthread")
  Future<HotThreadResult> hotThreadResult(@Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=secure")
  Future<CaptchaResult> captchaResult(@Query("type") String type);

  @POST(
      "/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll")
  @FormUrlEncoded()
  Future<ApiResult> votePoll(
      @Query("fid") int fid,
      @Query("tid") int tid,
      @Field("formhash") String formHash,
      @Field("pollanswers[]") List<int> checkedOptionId);

  @POST(
      "/api/mobile/index.php?version=4&module=pollvote&pollsubmit=yes&action=votepoll")
  @FormUrlEncoded()
  Future<String> votePollRaw(
      @Query("fid") int fid,
      @Query("tid") int tid,
      @Field("formhash") String formHash,
      @Field("pollanswers[]") List<int> checkedOptionId);

  @GET("/api/mobile/index.php?version=4&module=login")
  Future<CheckLoginResult> checkLoginResult();

  @GET("/api/mobile/index.php?version=4&module=profile")
  Future<UserProfileResult> userProfileResult(@Query("uid") int uid);

  @GET("/api/mobile/index.php?version=4&module=profile")
  Future<String> userProfileResultRaw(@Query("uid") int uid);

  @GET("/api/mobile/index.php?version=4&module=smiley")
  Future<SmileyResult> smileyResult();

  @GET("/api/mobile/index.php?version=4&module=mypm")
  Future<PrivateMessagePortalResult> privateMessagePortalResult(
      @Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=mypm&subop=view")
  Future<PrivateMessageDetailResult> privateMessageDetailResult(
      @Query("touid") int toUid, @Query("page") int page);

  @POST(
      "/api/mobile/index.php?version=4&ac=pm&op=send&daterange=0&module=sendpm&pmsubmit=yes")
  @FormUrlEncoded()
  Future<ApiResult> sendPrivateMessageResult(@Field("formhash") String formHash,
      @Field("message") String message, @Field("touid") int toUid);

  @GET("/api/mobile/index.php?version=4&module=publicpm")
  Future<PublicMessagePortalResult> publicMessagePortalResult(
      @Query("page") int page);

  @GET("/api/mobile/index.php?version=4&module=myfavthread")
  Future<FavoriteThreadResult> favoriteThreadResult(@Query("page") int page);

  @MultiPart()
  @POST("/api/mobile/index.php?version=4&module=forumupload&type=image")
  Future<String> uploadImage(@Part(name: "uid") int uid,
      @Part(name: "hash") String uploadHash, @Part(name: "Filedata") File file);

  @GET("/api/mobile/index.php?version=4&module=checkpost")
  Future<CheckPostResult> checkPost(
      @Query("fid") int? fid, @Query("tid") int? tid);

  @POST(
      "/misc.php?mod=report&inajax=1&handlekey=miscreport120&reportsubmit=true")
  @FormUrlEncoded()
  Future<String> reportContent(
    @Field("formhash") String formHash,
    @Field("report_select") String report_select,
    @Field("message") String message,
    @Field("rtype") String rtype,
    @Field("rid") int rid,
  );

  @POST(
      "/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&favoritesubmit=true")
  @FormUrlEncoded()
  Future<ApiResult> favoriteThreadActionResult(
    @Field("formhash") String formhash,
    @Field("id") int tid,
  );

  @POST(
      "/api/mobile/index.php?version=4&module=favthread&type=thread&ac=favorite&deletesubmit=true&op=delete")
  @FormUrlEncoded()
  Future<ApiResult> unfavoriteThreadActionResult(
    @Field("formhash") String formhash,
    @Field("favid") int favid,
  );

  @GET("/api/mobile/index.php?version=4&module=myfavforum")
  Future<FavoriteForumResult> favoriteForumResult(@Query("page") int page);

  @POST(
      "/api/mobile/index.php?version=4&module=favforum&type=thread&ac=favorite&favoritesubmit=true")
  @FormUrlEncoded()
  Future<ApiResult> favoriteForumActionResult(
    @Field("formhash") String formhash,
    @Field("id") int fid,
  );

  @POST(
      "/api/mobile/index.php?version=4&module=favforum&type=thread&ac=favorite&deletesubmit=true&op=delete")
  @FormUrlEncoded()
  Future<ApiResult> unfavoriteForumActionResult(
    @Field("formhash") String formhash,
    @Field("favid") int favid,
  );

  @GET("/api/mobile/index.php?version=4&module=newthreads&limit=20")
  Future<NewThreadResult> newThreadsResult(
      @Query("fids") String fids, @Query("start") int start);

  // push notification
  @GET("/plugin.php?id=dhpush:token")
  Future<PushTokenListResult> getPushTokenListResult();

  @POST("/plugin.php?id=dhpush:token")
  @FormUrlEncoded()
  Future<PostTokenResult> sendToken(
      @Field("formhash") String formHash,
      @Field("token") String token,
      @Field("deviceName") String deviceName,
      @Field("packageId") String packageId,
      @Field("channel") String pushChannel);

  @POST("/api/mobile/index.php?version=4&module=newthread&topicsubmit=yes&usesig=1")
  @FormUrlEncoded()
  Future<ApiResult> postNewThread(
      @Field("formhash") String formhash,
      @Field("fid") int fid,
      @Field("typeid") String typeId,
      @Field("subject") String subject,
      @Field("message") String message,
      // for captcha services
      @Field("seccodehash") String captchaHash,
      @Field("seccodemodid") String captchaType,
      @Field("seccodeverify") String verification,
      @Field("unused[]") List<String> attachAid,
      @Queries() Map<String, dynamic> formMap
      );
}
