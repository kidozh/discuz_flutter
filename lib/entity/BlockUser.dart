

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
class BlockUser{
  @PrimaryKey(autoGenerate: true)
  final int? id;
  int uid;
  String name;

  DateTime insertTime = DateTime.now();
  DateTime updateTime;

  @ColumnInfo(name: "discuz_id")
  final int discuzId;

  BlockUser(this.id,this.uid, this.name, this.discuzId, this.updateTime);
}