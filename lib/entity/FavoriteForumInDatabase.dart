import 'package:discuz_flutter/converter/FloorDateTimeConverter.dart';
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
@TypeConverters([FloorDateTimeConverter])
class FavoriteForumInDatabase{
  @PrimaryKey(autoGenerate: true)
  final int? id;

  int favid = 0, uid = 0;
  int idKey = 0;

  String idType = "";
  int spaceUid = 0;

  String title = "";
  String description = "";

  DateTime date = DateTime.now();

  @ColumnInfo(name: "discuz_id")
  final int discuzId;

  FavoriteForumInDatabase(
      this.id,
      this.favid,
      this.uid,
      this.idKey,
      this.idType,
      this.spaceUid,
      this.title,
      this.description,
      this.date,
      this.discuzId);
}