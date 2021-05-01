import 'package:floor/floor.dart';

import 'Discuz.dart';

@Entity(
    foreignKeys:[
      ForeignKey(
          childColumns: ["discuz_id"],
          parentColumns: ["id"],
          entity: Discuz,
          onDelete: ForeignKeyAction.cascade)
    ]
)
class User {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String auth;
  String saltkey;
  String username;
  String avatarUrl;
  int groupId;
  int uid;
  int readPerm;
  @ColumnInfo(name: "discuz_id")
  final int discuzId;

  User(this.id, this.auth, this.saltkey, this.username, this.avatarUrl,
      this.groupId, this.uid, this.readPerm, this.discuzId);



}