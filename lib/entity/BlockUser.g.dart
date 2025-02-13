// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BlockUser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockUserAdapter extends TypeAdapter<BlockUser> {
  @override
  final int typeId = 2;

  @override
  BlockUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockUser(
      (fields[1] as num).toInt(),
      fields[2] as String,
      fields[4] as DateTime,
      fields[5] as Discuz,
    )..insertTime = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, BlockUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.insertTime)
      ..writeByte(4)
      ..write(obj.updateTime)
      ..writeByte(5)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
