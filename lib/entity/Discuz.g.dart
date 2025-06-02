// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Discuz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscuzAdapter extends TypeAdapter<Discuz> {
  @override
  final typeId = 0;

  @override
  Discuz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Discuz(
      fields[13] as String,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as num).toInt(),
      fields[4] as String,
      fields[5] as String,
      fields[6] as bool,
      fields[7] as String,
      fields[8] as String,
      fields[9] as String,
      fields[10] as String,
      fields[11] as String,
      fields[12] as String,
      trueDiscuzVersion: fields[14] == null ? "X3.4" : fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Discuz obj) {
    writer
      ..writeByte(14)
      ..writeByte(1)
      ..write(obj.discuzVersion)
      ..writeByte(2)
      ..write(obj.charset)
      ..writeByte(3)
      ..write(obj.apiVersion)
      ..writeByte(4)
      ..write(obj.pluginVersion)
      ..writeByte(5)
      ..write(obj.regname)
      ..writeByte(6)
      ..write(obj.qqconnect)
      ..writeByte(7)
      ..write(obj.wsqqqconnect)
      ..writeByte(8)
      ..write(obj.wsqhideregister)
      ..writeByte(9)
      ..write(obj.siteName)
      ..writeByte(10)
      ..write(obj.siteId)
      ..writeByte(11)
      ..write(obj.uCenterURL)
      ..writeByte(12)
      ..write(obj.defaultFid)
      ..writeByte(13)
      ..write(obj.baseURL)
      ..writeByte(14)
      ..write(obj.trueDiscuzVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscuzAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
