// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DiscuzAuthentication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscuzAuthenticationAdapter extends TypeAdapter<DiscuzAuthentication> {
  @override
  final typeId = 10;

  @override
  DiscuzAuthentication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscuzAuthentication()
      ..account = fields[1] as String
      ..password = fields[2] as String
      ..discuz_host = fields[3] as String
      ..updateTime = fields[4] as DateTime
      ..note = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, DiscuzAuthentication obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.account)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.discuz_host)
      ..writeByte(4)
      ..write(obj.updateTime)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscuzAuthenticationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
