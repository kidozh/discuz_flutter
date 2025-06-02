// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewThreadCache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewThreadCacheAdapter extends TypeAdapter<ViewThreadCache> {
  @override
  final typeId = 11;

  @override
  ViewThreadCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewThreadCache(
      (fields[0] as num).toInt(),
      fields[1] as String,
      fields[5] as Discuz,
      fields[2] as DateTime,
      (fields[3] as num).toInt(),
      fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ViewThreadCache obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.tid)
      ..writeByte(1)
      ..write(obj.json)
      ..writeByte(2)
      ..write(obj.updateTime)
      ..writeByte(3)
      ..write(obj.page)
      ..writeByte(4)
      ..write(obj.isAscend)
      ..writeByte(5)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewThreadCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
