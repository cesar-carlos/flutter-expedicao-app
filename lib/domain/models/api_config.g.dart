// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiConfigAdapter extends TypeAdapter<ApiConfig> {
  @override
  final int typeId = 0;

  @override
  ApiConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return ApiConfig(
      apiUrl: fields[0] as String,
      apiPort: fields[1] as int,
      useHttps: fields[2] as bool,
      lastUpdated: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApiConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.apiUrl)
      ..writeByte(1)
      ..write(obj.apiPort)
      ..writeByte(2)
      ..write(obj.useHttps)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ApiConfigAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
