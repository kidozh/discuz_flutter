import 'dart:convert';

import 'package:discuz_flutter/entity/Post.dart';
import 'package:json_annotation/json_annotation.dart';

class AttachmentConverter implements JsonConverter<Map<String,Attachment>, List<Attachment>> {
  const AttachmentConverter();

  @override
  Map<String, Attachment> fromJson(List<Attachment> json) {
    // TODO: implement fromJson
    return {};

  }

  @override
  List<Attachment> toJson(Map<String, Attachment> object) {
    // TODO: implement toJson
    throw [];
  }

  
}