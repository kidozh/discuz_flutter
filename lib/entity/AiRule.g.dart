// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AiRule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiRuleAdapter extends TypeAdapter<AiRule> {
  @override
  final typeId = 13;

  @override
  AiRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiRule(
      fields[5] as String,
      fields[1] as String,
      fields[2] as String,
      fields[4] as DateTime,
    )..insertTime = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, AiRule obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.instruction)
      ..writeByte(2)
      ..write(obj.prompt)
      ..writeByte(3)
      ..write(obj.insertTime)
      ..writeByte(4)
      ..write(obj.updateTime)
      ..writeByte(5)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
