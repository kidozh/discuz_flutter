// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewThreadScrollDistance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewThreadScrollDistanceAdapter
    extends TypeAdapter<ViewThreadScrollDistance> {
  @override
  final typeId = 12;

  @override
  ViewThreadScrollDistance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewThreadScrollDistance(
      (fields[0] as num).toInt(),
      (fields[1] as num).toDouble(),
      fields[4] as Discuz,
      fields[2] as DateTime,
      fields[3] as bool,
      uid: (fields[5] as num?)?.toInt(),
      pid: (fields[6] as num?)?.toInt(),
      repliesAtRead: (fields[7] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ViewThreadScrollDistance obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.tid)
      ..writeByte(1)
      ..write(obj.offset)
      ..writeByte(2)
      ..write(obj.updateTime)
      ..writeByte(3)
      ..write(obj.isAscend)
      ..writeByte(4)
      ..write(obj.discuz)
      ..writeByte(5)
      ..write(obj.uid)
      ..writeByte(6)
      ..write(obj.pid)
      ..writeByte(7)
      ..write(obj.repliesAtRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewThreadScrollDistanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
