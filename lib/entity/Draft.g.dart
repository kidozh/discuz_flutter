// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftAdapter extends TypeAdapter<Draft> {
  @override
  final typeId = 9;

  @override
  Draft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Draft(
      fields[1] as String,
      fields[2] as String,
      (fields[6] as num).toInt(),
      fields[7] as String,
      fields[4] as DateTime,
      fields[5] as Discuz,
    )..insertTime = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Draft obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.insertTime)
      ..writeByte(4)
      ..write(obj.updateTime)
      ..writeByte(5)
      ..write(obj.discuz)
      ..writeByte(6)
      ..write(obj.fid)
      ..writeByte(7)
      ..write(obj.typeid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
