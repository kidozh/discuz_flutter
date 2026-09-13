import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/utility/discuz_json.dart';
import 'package:json_annotation/json_annotation.dart';

class ViewThreadCommentConverter
    implements JsonConverter<Map<String, List<Comment>>, Object?> {
  const ViewThreadCommentConverter();

  @override
  Map<String, List<Comment>> fromJson(Object? json) => discuzMap(json).map(
    (pid, value) => MapEntry(
      pid,
      (value is Map
              ? value.values
              : value is List
              ? value
              : const [])
          .whereType<Map>()
          .map((row) => Comment.fromJson(discuzMap(row)))
          .toList(),
    ),
  );

  @override
  Object? toJson(Map<String, List<Comment>> object) => object.map(
    (pid, comments) =>
        MapEntry(pid, comments.map((comment) => comment.toJson()).toList()),
  );
}
