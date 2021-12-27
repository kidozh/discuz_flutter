import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

import 'Discuz.dart';

part 'Smiley.g.dart';

@JsonSerializable()
@Entity(
    foreignKeys:[
      ForeignKey(
          childColumns: ["discuz_id"],
          parentColumns: ["id"],
          entity: Discuz,
          onDelete: ForeignKeyAction.cascade)
    ]
)
class Smiley{
  @JsonKey(ignore: true)
  @PrimaryKey(autoGenerate: true)
  int? id;

  String code = "";
  @JsonKey(name: "image")
  String relativePath = "";

  @JsonKey(ignore: true)
  @ColumnInfo(name: "discuz_id")
  int discuzId = 0;

  Smiley();


  factory Smiley.fromJson(Map<String, dynamic> json) => _$SmileyFromJson(json);
  // Map<String, dynamic> toJson => $_SmileyToJson(this);
  Map<String, dynamic> toJson() => _$SmileyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}