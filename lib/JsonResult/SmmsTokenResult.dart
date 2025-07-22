import 'package:json_annotation/json_annotation.dart';

part 'SmmsTokenResult.g.dart'; // Name your file, e.g., api_token_response.dart

@JsonSerializable(explicitToJson: true) // Good practice for nested objects
class SmmsTokenResult {
  bool success;
  String code;
  String message;
  SmmsTokenData data;

  @JsonKey(name: 'RequestId') // Matches the JSON key capitalization
  String requestId;

  SmmsTokenResult({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    required this.requestId,
  });

  factory SmmsTokenResult.fromJson(Map<String, dynamic> json) =>
      _$SmmsTokenResultFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsTokenResultToJson(this);
}

@JsonSerializable()
class SmmsTokenData {
  String token;

  SmmsTokenData({
    required this.token,
  });

  factory SmmsTokenData.fromJson(Map<String, dynamic> json) =>
      _$SmmsTokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$SmmsTokenDataToJson(this);
}
