// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      isPinned: fields[3] as bool,
      isFavorite: fields[4] as bool,
      colorIndex: fields[5] as int,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      isArchived: fields[8] as bool,
      isDeleted: fields[9] as bool,
      index: fields[10] as int,
      labelIds: (fields[11] as List).cast<String>(),
      todos: (fields[12] as List).cast<TodoItem>(),
      deltaContent: fields[13] as String,
      noteType: fields[14] as NoteType,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isPinned)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.colorIndex)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.isArchived)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.index)
      ..writeByte(11)
      ..write(obj.labelIds)
      ..writeByte(12)
      ..write(obj.todos)
      ..writeByte(13)
      ..write(obj.deltaContent)
      ..writeByte(14)
      ..write(obj.noteType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteTypeAdapter extends TypeAdapter<NoteType> {
  @override
  final int typeId = 6;

  @override
  NoteType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteType.text;
      case 1:
        return NoteType.todo;
      default:
        return NoteType.text;
    }
  }

  @override
  void write(BinaryWriter writer, NoteType obj) {
    switch (obj) {
      case NoteType.text:
        writer.writeByte(0);
        break;
      case NoteType.todo:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
