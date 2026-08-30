// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PrivateMessageCache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrivateMessageCacheAdapter extends TypeAdapter<PrivateMessageCache> {
  @override
  final typeId = 14;

  @override
  PrivateMessageCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivateMessageCache(
      siteKey: fields[0] as String,
      ownerUid: (fields[1] as num).toInt(),
      peerUid: (fields[2] as num).toInt(),
      plid: (fields[3] as num).toInt(),
      pmId: (fields[4] as num).toInt(),
      toUid: (fields[5] as num).toInt(),
      msgFromId: (fields[6] as num).toInt(),
      msgFromName: fields[7] as String,
      subject: fields[8] as String,
      message: fields[9] as String,
      dateTimeString: fields[10] as String,
      cachedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrivateMessageCache obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.siteKey)
      ..writeByte(1)
      ..write(obj.ownerUid)
      ..writeByte(2)
      ..write(obj.peerUid)
      ..writeByte(3)
      ..write(obj.plid)
      ..writeByte(4)
      ..write(obj.pmId)
      ..writeByte(5)
      ..write(obj.toUid)
      ..writeByte(6)
      ..write(obj.msgFromId)
      ..writeByte(7)
      ..write(obj.msgFromName)
      ..writeByte(8)
      ..write(obj.subject)
      ..writeByte(9)
      ..write(obj.message)
      ..writeByte(10)
      ..write(obj.dateTimeString)
      ..writeByte(11)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateMessageCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
