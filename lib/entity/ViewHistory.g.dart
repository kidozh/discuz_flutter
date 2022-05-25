// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewHistory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewHistoryAdapter extends TypeAdapter<ViewHistory> {
  @override
  final int typeId = 6;

  @override
  ViewHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewHistory(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as int,
      fields[5] as String,
      fields[6] as int,
      fields[9] as Discuz,
      fields[8] as DateTime,
    )..insertTime = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ViewHistory obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.identification)
      ..writeByte(5)
      ..write(obj.author)
      ..writeByte(6)
      ..write(obj.authorId)
      ..writeByte(7)
      ..write(obj.insertTime)
      ..writeByte(8)
      ..write(obj.updateTime)
      ..writeByte(9)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
