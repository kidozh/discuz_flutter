import 'package:json_annotation/json_annotation.dart';

part 'SmmsProfileResult.g.dart'; // Name your file, e.g., user_profile_response.dart

@JsonSerializable(explicitToJson: true)
class SmmsProfileResult {
  bool success;
  String code;
  String message;
  SmmsProfileData data;

  @JsonKey(name: 'RequestId')
  String requestId;

  SmmsProfileResult({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    required this.requestId,
  });

  factory SmmsProfileResult.fromJson(Map<String, dynamic> json) =>
      _$SmmsProfileResultFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsProfileResultToJson(this);
}

@JsonSerializable()
class SmmsProfileData {
  String username;
  String email; // Empty string in example, so String is fine
  String role;

  @JsonKey(name: 'group_expire')
  String groupExpire; // "0000-00-00", could be DateTime with a converter if needed

  @JsonKey(name: 'email_verified')
  int emailVerified; // 0 or 1, could be bool with a converter

  @JsonKey(name: 'disk_usage')
  String diskUsage; // e.g., "2.58 MB"

  @JsonKey(name: 'disk_limit')
  String diskLimit; // e.g., "50.00 GB"

  @JsonKey(name: 'disk_usage_raw')
  int diskUsageRaw; // Raw bytes

  @JsonKey(name: 'disk_limit_raw')
  int diskLimitRaw; // Raw bytes

  SmmsProfileData({
    required this.username,
    required this.email,
    required this.role,
    required this.groupExpire,
    required this.emailVerified,
    required this.diskUsage,
    required this.diskLimit,
    required this.diskUsageRaw,
    required this.diskLimitRaw,
  });

  factory SmmsProfileData.fromJson(Map<String, dynamic> json) =>
      _$SmmsProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsProfileDataToJson(this);
}
