import 'package:discuz_flutter/converter/SecondToDateTimeConverter.dart';
import 'package:discuz_flutter/converter/StringToIntConverter.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:json_annotation/json_annotation.dart';

import '../utility/discuz_json.dart';
import '../utility/forum_image_url.dart';
import '../utility/post_locator.dart';
import 'Discuz.dart';

part 'DiscuzNotification.g.dart';

@JsonSerializable()
class DiscuzNotification {
  @StringToIntConverter()
  int id = 0, uid = 0;
  String type = "";
  @JsonKey(name: "new", required: false, defaultValue: "0")
  String isNew = "0";
  @JsonKey(required: false, defaultValue: "")
  String author = "";
  @JsonKey(name: "authorid")
  @StringToIntConverter()
  int authorId = 0;
  String note = "";
  @JsonKey(name: "dateline")
  @SecondToDateTimeConverter()
  DateTime dateline = DateTime.now();
  @JsonKey(name: "from_id")
  @StringToIntConverter()
  int fromId = 0;
  @JsonKey(name: "from_idtype", defaultValue: "")
  String fromIdType = "";

  @JsonKey(includeFromJson: false, includeToJson: false)
  int? threadId, postId;

  DiscuzNotification();
  factory DiscuzNotification.fromJson(Map<String, dynamic> json) {
    final result = _$DiscuzNotificationFromJson(json);
    final target = discuzMap(json['notevar']);
    final tid = discuzInt(target['tid']);
    final pid = discuzInt(target['pid']);
    if (tid > 0 && pid > 0) {
      result.threadId = tid;
      result.postId = pid;
    }
    return result;
  }

  (int tid, int pid)? replyTarget(Discuz forum) {
    if (threadId case final tid?) {
      if (postId case final pid?) return (tid, pid);
    }

    final base = forumBaseUri(forum);
    if (base == null) return null;
    for (final link in parseFragment(note).querySelectorAll('a[href]')) {
      var ancestor = link.parent;
      while (ancestor != null &&
          ancestor.localName != 'blockquote' &&
          !ancestor.classes.contains('quote')) {
        ancestor = ancestor.parent;
      }
      if (ancestor != null) continue;

      final reference = Uri.tryParse(link.attributes['href']!.trim());
      if (reference == null) continue;
      final uri = base.resolveUri(reference);
      if (uri.scheme != base.scheme ||
          uri.host != base.host ||
          uri.port != base.port ||
          uri.userInfo.isNotEmpty ||
          !uri.path.startsWith(base.path)) {
        continue;
      }
      if (uri.path == '${base.path}forum.php' ||
          uri.pathSegments.lastOrNull?.startsWith('thread-') == true) {
        final target = PostLinkTarget.parse(uri);
        if (target?.pid case final pid?) return (target!.tid, pid);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => _$DiscuzNotificationToJson(this);
}
