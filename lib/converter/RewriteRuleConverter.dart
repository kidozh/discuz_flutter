
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:json_annotation/json_annotation.dart';

class RewriteRuleConverter implements JsonConverter<RewriteRule, Object?> {
  const RewriteRuleConverter();

  @override
  RewriteRule fromJson(Object? json) {
    if(json is Map<String, dynamic>){
      return RewriteRule.fromJson(json);

    }
    return RewriteRule();

  }

  @override
  Object toJson(RewriteRule object) {
    return object.toString();
  }

  
}