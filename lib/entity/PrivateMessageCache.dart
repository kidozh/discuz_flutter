import 'package:discuz_flutter/JsonResult/PrivateMessageDetailResult.dart';
import 'package:hive_ce/hive.dart';

import '../utility/ConstUtils.dart';

part 'PrivateMessageCache.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_PRIVATE_MESSAGE_CACHE)
class PrivateMessageCache extends HiveObject {
  @HiveField(0)
  String siteKey;

  @HiveField(1)
  int ownerUid;

  @HiveField(2)
  int peerUid;

  @HiveField(3)
  int plid;

  @HiveField(4)
  int pmId;

  @HiveField(5)
  int toUid;

  @HiveField(6)
  int msgFromId;

  @HiveField(7)
  String msgFromName;

  @HiveField(8)
  String subject;

  @HiveField(9)
  String message;

  @HiveField(10)
  String dateTimeString;

  @HiveField(11)
  DateTime cachedAt;

  PrivateMessageCache({
    required this.siteKey,
    required this.ownerUid,
    required this.peerUid,
    required this.plid,
    required this.pmId,
    required this.toUid,
    required this.msgFromId,
    required this.msgFromName,
    required this.subject,
    required this.message,
    required this.dateTimeString,
    required this.cachedAt,
  });

  factory PrivateMessageCache.fromMessage({
    required String siteKey,
    required int ownerUid,
    required int peerUid,
    required PrivateMessageDetail message,
  }) {
    return PrivateMessageCache(
      siteKey: siteKey,
      ownerUid: ownerUid,
      peerUid: peerUid,
      plid: message.plid,
      pmId: message.pmId,
      toUid: message.toUid,
      msgFromId: message.msgFromId,
      msgFromName: message.msgFromName,
      subject: message.subject,
      message: message.message,
      dateTimeString: message.dateTimeString,
      cachedAt: DateTime.now(),
    );
  }

  String get stableIdentity =>
      pmId != 0 ? 'pm:$pmId' : '$plid|$msgFromId|$dateTimeString|$message';

  PrivateMessageDetail toMessage() {
    return PrivateMessageDetail()
      ..plid = plid
      ..pmId = pmId
      ..toUid = toUid
      ..msgFromId = msgFromId
      ..msgFromName = msgFromName
      ..subject = subject
      ..message = message
      ..dateTimeString = dateTimeString;
  }
}
