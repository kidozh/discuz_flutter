// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TrustHost.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrustHostAdapter extends TypeAdapter<TrustHost> {
  @override
  final int typeId = 5;

  @override
  TrustHost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrustHost(
      fields[0] as String,
    )..trustAt = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, TrustHost obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.host)
      ..writeByte(1)
      ..write(obj.trustAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustHostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
