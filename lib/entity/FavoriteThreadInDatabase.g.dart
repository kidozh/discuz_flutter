// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FavoriteThreadInDatabase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteThreadInDatabaseAdapter
    extends TypeAdapter<FavoriteThreadInDatabase> {
  @override
  final int typeId = 4;

  @override
  FavoriteThreadInDatabase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteThreadInDatabase(
      (fields[0] as num).toInt(),
      (fields[1] as num).toInt(),
      (fields[2] as num).toInt(),
      fields[3] as String,
      (fields[4] as num).toInt(),
      fields[5] as String,
      fields[6] as String,
      fields[7] as String,
      (fields[8] as num).toInt(),
      fields[9] as DateTime,
      fields[10] as Discuz,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteThreadInDatabase obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.favid)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.idInServer)
      ..writeByte(3)
      ..write(obj.idType)
      ..writeByte(4)
      ..write(obj.spaceUid)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.author)
      ..writeByte(8)
      ..write(obj.replies)
      ..writeByte(9)
      ..write(obj.date)
      ..writeByte(10)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteThreadInDatabaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
