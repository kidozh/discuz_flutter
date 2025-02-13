

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../utility/ConstUtils.dart';
import 'Discuz.dart';

part 'User.g.dart';

@HiveType(typeId: ConstUtils.HIVE_TYPE_ID_USER)
class User extends HiveObject {
  @HiveField(0)
  String auth;
  @HiveField(1)
  String saltkey;
  @HiveField(2)
  String username;
  @HiveField(3)
  String avatarUrl;
  @HiveField(4)
  int groupId;
  @HiveField(5)
  int uid;
  @HiveField(6)
  int readPerm;
  @HiveField(7)
  Discuz discuz;

  User(this.auth, this.saltkey, this.username, this.avatarUrl,
      this.groupId, this.uid, this.readPerm, this.discuz);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          uid == other.uid &&
          discuz == other.discuz;

  @override
  int get hashCode =>
      auth.hashCode ^
      saltkey.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode ^
      groupId.hashCode ^
      uid.hashCode ^
      readPerm.hashCode ^
      discuz.hashCode;
}