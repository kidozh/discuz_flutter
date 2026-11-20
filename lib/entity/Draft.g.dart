// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftAdapter extends TypeAdapter<Draft> {
  @override
  final typeId = 9;

  @override
  Draft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Draft(
        fields[1] as String,
        fields[2] as String,
        (fields[6] as num).toInt(),
        fields[7] as String,
        fields[4] as DateTime,
        fields[5] as Discuz,
      )
      ..insertTime = fields[3] as DateTime
      ..pollJson = fields[8] == null ? '' : fields[8] as String
      ..attachmentNames = fields[9] == null
          ? {}
          : (fields[9] as Map).cast<String, String>()
      ..specialThreadJson = fields[10] == null ? '' : fields[10] as String
      ..uid = fields[11] == null ? 0 : (fields[11] as num).toInt()
      ..pendingAttachmentsJson = fields[12] == null ? '' : fields[12] as String
      ..replyRewardJson = fields[13] == null ? '' : fields[13] as String
      ..classifiedJson = fields[14] == null ? '' : fields[14] as String
      ..rushJson = fields[15] == null ? '' : fields[15] as String;
  }

  @override
  void write(BinaryWriter writer, Draft obj) {
    writer
      ..writeByte(15)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.insertTime)
      ..writeByte(4)
      ..write(obj.updateTime)
      ..writeByte(5)
      ..write(obj.discuz)
      ..writeByte(6)
      ..write(obj.fid)
      ..writeByte(7)
      ..write(obj.typeid)
      ..writeByte(8)
      ..write(obj.pollJson)
      ..writeByte(9)
      ..write(obj.attachmentNames)
      ..writeByte(10)
      ..write(obj.specialThreadJson)
      ..writeByte(11)
      ..write(obj.uid)
      ..writeByte(12)
      ..write(obj.pendingAttachmentsJson)
      ..writeByte(13)
      ..write(obj.replyRewardJson)
      ..writeByte(14)
      ..write(obj.classifiedJson)
      ..writeByte(15)
      ..write(obj.rushJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
