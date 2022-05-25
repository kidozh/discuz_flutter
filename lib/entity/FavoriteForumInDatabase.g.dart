// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FavoriteForumInDatabase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteForumInDatabaseAdapter
    extends TypeAdapter<FavoriteForumInDatabase> {
  @override
  final int typeId = 3;

  @override
  FavoriteForumInDatabase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteForumInDatabase(
      fields[0] as int,
      fields[1] as int,
      fields[2] as int,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as DateTime,
      fields[7] as Discuz,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteForumInDatabase obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.favid)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.idKey)
      ..writeByte(3)
      ..write(obj.idType)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteForumInDatabaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
