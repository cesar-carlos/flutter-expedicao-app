// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_config_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiConfigEntityAdapter extends TypeAdapter<ApiConfigEntity> {
  @override
  final int typeId = 0;

  @override
  ApiConfigEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiConfigEntity(
      apiUrl: fields[0] as String,
      apiPort: fields[1] as int,
      useHttps: fields[2] as bool,
      lastUpdated: fields[3] as DateTime?,
      scannerModeIndex: fields[4] as int? ?? 0,
      broadcastAction: fields[5] as String?,
      broadcastExtraKey: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ApiConfigEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.apiUrl)
      ..writeByte(1)
      ..write(obj.apiPort)
      ..writeByte(2)
      ..write(obj.useHttps)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.scannerModeIndex)
      ..writeByte(5)
      ..write(obj.broadcastAction)
      ..writeByte(6)
      ..write(obj.broadcastExtraKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiConfigEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
