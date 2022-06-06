// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ImageAttachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageAttachmentAdapter extends TypeAdapter<ImageAttachment> {
  @override
  final int typeId = 8;

  @override
  ImageAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageAttachment(
      fields[0] as String,
      fields[2] as Discuz,
      fields[3] as String,
    )..updateAt = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ImageAttachment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.aid)
      ..writeByte(1)
      ..write(obj.updateAt)
      ..writeByte(2)
      ..write(obj.discuz)
      ..writeByte(3)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
