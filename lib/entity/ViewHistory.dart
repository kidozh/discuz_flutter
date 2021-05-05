

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
class ViewHistory{
  @PrimaryKey(autoGenerate: true)
  final int? id;
  String title;
  String subject;
  String description;
  String type;
  int identification;

  String author;
  int authorId;

  DateTime insertTime = DateTime.now();
  DateTime updateTime;

  @ColumnInfo(name: "discuz_id")
  final int discuzId;

  ViewHistory(this.id,this.title, this.subject, this.description, this.type, this.identification,this.author, this.authorId, this.discuzId, this.updateTime);
}