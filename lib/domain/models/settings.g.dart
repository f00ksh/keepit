// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingAdapter extends TypeAdapter<Setting> {
  @override
  final int typeId = 2;

  @override
  Setting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setting(
      viewStyle: fields[0] as String,
      sortBy: fields[1] as String,
      sortAscending: fields[2] as bool,
      showPinnedSection: fields[3] as bool,
      syncEnabled: fields[4] as bool,
      useDynamicColors: fields[5] as bool,
      accentColorIndex: fields[6] as int,
      themeMode: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Setting obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.viewStyle)
      ..writeByte(1)
      ..write(obj.sortBy)
      ..writeByte(2)
      ..write(obj.sortAscending)
      ..writeByte(3)
      ..write(obj.showPinnedSection)
      ..writeByte(4)
      ..write(obj.syncEnabled)
      ..writeByte(5)
      ..write(obj.useDynamicColors)
      ..writeByte(6)
      ..write(obj.accentColorIndex)
      ..writeByte(7)
      ..write(obj.themeMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
