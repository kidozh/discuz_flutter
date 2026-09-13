import 'package:json_annotation/json_annotation.dart';
import 'BaseResult.dart';
import 'ErrorResult.dart';
import '../converter/StringToIntConverter.dart';
import 'BaseVariableResult.dart';
import '../utility/discuz_json.dart';

part 'CheckPostResult.g.dart';

@JsonSerializable(explicitToJson: true)
class CheckPostResult extends BaseResult {
  @JsonKey(name: 'Variables', fromJson: _variablesFromJson)
  CheckPostVariables variables = CheckPostVariables();
  CheckPostResult();
  factory CheckPostResult.fromJson(Map<String, dynamic> json) =>
      _$CheckPostResultFromJson(json);
}

CheckPostVariables _variablesFromJson(Object? json) =>
    CheckPostVariables.fromJson(discuzMap(json));

@JsonSerializable(explicitToJson: true)
class CheckPostVariables extends BaseVariableResult {
  @JsonKey(name: 'allowperm', fromJson: AllowPerm.fromJson)
  AllowPerm allowPerm = AllowPerm();
  CheckPostVariables();
  @override
  Map<String, dynamic> toJson() => _$CheckPostVariablesToJson(this);
  factory CheckPostVariables.fromJson(Map<String, dynamic> json) =>
      _$CheckPostVariablesFromJson(json);
}

class AllowPerm {
  // Missing permission is unknown, never an affirmative grant.
  bool? allowPost;
  bool? allowReply;
  String uploadHash = '';
  AllowUpload allowUpload = AllowUpload();
  AttachRemain attachRemain = AttachRemain();
  AllowPerm();
  factory AllowPerm.fromJson(Object? value) {
    final json = discuzMap(value);
    return AllowPerm()
      ..allowPost = discuzPermission(json['allowpost'])
      ..allowReply = discuzPermission(json['allowreply'])
      ..uploadHash = discuzString(json['uploadhash'])
      ..allowUpload = AllowUpload.fromJson(json['allowupload'])
      ..attachRemain = AttachRemain.fromJson(json['attachremain']);
  }
  Map<String, dynamic> toJson() => {
    'allowpost': allowPost,
    'allowreply': allowReply,
    'uploadhash': uploadHash,
    'allowupload': allowUpload.toJson(),
    'attachremain': attachRemain.toJson(),
  };

  UploadRestriction? validateUpload(String filename, int bytes) {
    final extension = filename.split('.').last.toLowerCase();
    final limit = allowUpload.limits[extension];
    if (uploadHash.isEmpty || limit == null || limit == 0 || limit < -1)
      return UploadRestriction.type;
    if (attachRemain.count == 0) return UploadRestriction.count;
    if (attachRemain.size != null &&
        attachRemain.size! >= 0 &&
        bytes > attachRemain.size!)
      return UploadRestriction.dailySize;
    if (limit > 0 && bytes > limit) return UploadRestriction.fileSize;
    return null;
  }
}

enum UploadRestriction { type, count, dailySize, fileSize }

/// Official sub_checkpost: 0 denied, -1 no per-type limit supplied, positive bytes.
class AllowUpload {
  final Map<String, int> limits;
  AllowUpload([this.limits = const {}]);
  factory AllowUpload.fromJson(Object? json) => AllowUpload({
    for (final entry in discuzMap(json).entries)
      entry.key.toLowerCase(): discuzInt(entry.value),
  });
  Map<String, int> toJson() => limits;
}

/// -1 is unlimited; omitted is unknown; zero is exhausted.
class AttachRemain {
  int? size;
  int? count;
  AttachRemain();
  factory AttachRemain.fromJson(Object? value) {
    final json = discuzMap(value);
    return AttachRemain()
      ..size = json['size'] == null ? null : discuzInt(json['size'])
      ..count = json['count'] == null ? null : discuzInt(json['count']);
  }
  Map<String, dynamic> toJson() => {'size': size, 'count': count};
}
