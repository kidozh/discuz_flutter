
import 'package:json_annotation/json_annotation.dart';

part 'ErrorResult.g.dart';

@JsonSerializable()
class ErrorResult{
  @JsonKey(name: "messageval")
  String key = "";
  @JsonKey(name: "messagestr")
  String content = "";

  ErrorResult(){}

  factory ErrorResult.fromJson(Map<String, dynamic> json) => _$ErrorResultFromJson(json);

}