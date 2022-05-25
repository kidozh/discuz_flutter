// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Smiley.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmileyAdapter extends TypeAdapter<Smiley> {
  @override
  final int typeId = 7;

  @override
  Smiley read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Smiley()
      ..code = fields[0] as String
      ..relativePath = fields[1] as String
      ..dateTime = fields[2] as DateTime
      ..discuz = fields[3] as Discuz;
  }

  @override
  void write(BinaryWriter writer, Smiley obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.relativePath)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.discuz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmileyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Smiley _$SmileyFromJson(Map<String, dynamic> json) => Smiley()
  ..code = json['code'] as String
  ..relativePath = json['image'] as String;

Map<String, dynamic> _$SmileyToJson(Smiley instance) => <String, dynamic>{
      'code': instance.code,
      'image': instance.relativePath,
    };
