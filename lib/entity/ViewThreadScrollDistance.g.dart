// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewThreadScrollDistance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewThreadScrollDistanceAdapter
    extends TypeAdapter<ViewThreadScrollDistance> {
  @override
  final int typeId = 12;

  @override
  ViewThreadScrollDistance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewThreadScrollDistance(
      fields[0] as int,
      fields[1] as double,
      fields[4] as Discuz,
      fields[2] as DateTime,
      fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ViewThreadScrollDistance obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tid)
      ..writeByte(1)
      ..write(obj.offset)
      ..writeByte(2)
      ..write(obj.updateTime)
      ..writeByte(3)
      ..write(obj.isAscend)
      ..writeByte(4)
      ..write(obj.discuz);
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
