// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DiscuzAuthentification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscuzAuthentificationAdapter
    extends TypeAdapter<DiscuzAuthentification> {
  @override
  final int typeId = 10;

  @override
  DiscuzAuthentification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscuzAuthentification()
      ..account = fields[1] as String
      ..password = fields[2] as String
      ..discuz_host = fields[3] as String
      ..updateTime = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, DiscuzAuthentification obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.account)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.discuz_host)
      ..writeByte(4)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscuzAuthentificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
