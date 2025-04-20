import 'package:hive/hive.dart';
import 'package:keepit/core/constants/app_constants.dart';
import 'package:keepit/domain/models/todo_item.dart';

part 'note.g.dart';

// Define NoteType enum
@HiveType(typeId: 6)
enum NoteType {
  @HiveField(0)
  text,

  @HiveField(1)
  todo
}

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final bool isPinned;

  @HiveField(4)
  final bool isFavorite;

  @HiveField(5)
  final int colorIndex;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool isArchived;

  @HiveField(9)
  final bool isDeleted;

  @HiveField(10)
  final int index;

  @HiveField(11)
  final List<String> labelIds;

  @HiveField(12)
  final List<TodoItem> todos;

  @HiveField(13)
  final String deltaContent;

  @HiveField(14)
  final NoteType noteType;

  @HiveField(15)
  final int wallpaperIndex;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.isFavorite = false,
    this.colorIndex = AppConstants.defaultNoteColorIndex,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.index = 0,
    this.labelIds = const [],
    this.todos = const [],
    this.deltaContent = '',
    this.noteType = NoteType.text,
    this.wallpaperIndex = AppConstants.defaultWallpaperIndex,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    bool? isFavorite,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isDeleted,
    int? index,
    List<String>? labelIds,
    List<TodoItem>? todos,
    String? deltaContent,
    NoteType? noteType,
    int? wallpaperIndex,
  }) {
    final newNote = Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      index: index ?? this.index,
      labelIds: labelIds ?? this.labelIds,
      todos: todos ?? this.todos,
      deltaContent: deltaContent ?? this.deltaContent,
      noteType: noteType ?? this.noteType,
      wallpaperIndex: wallpaperIndex ?? this.wallpaperIndex,
    );

    return newNote;
  }

  Map<String, dynamic> toJson() {
    final todoJsonList = todos.map((todo) => todo.toJson()).toList();

    return {
      'id': id,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_favorite': isFavorite,
      'color_index': colorIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'index': index,
      'label_ids': labelIds,
      'todos': todoJsonList,
      'delta_content': deltaContent,
      'note_type': noteType.index, // Store as integer
      'wallpaper_index': wallpaperIndex,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    // Determine note type from json or infer based on content if not available
    NoteType type = NoteType.text;
    if (json.containsKey('note_type')) {
      // If the note_type is present in the JSON, use it
      type = NoteType.values[json['note_type'] as int];
    } else {
      // Otherwise infer from content/todos
      final todos = (json['todos'] as List?)
              ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      final content = json['content'] as String? ?? '';
      type = (todos.isEmpty || (content.isNotEmpty && todos.isEmpty))
          ? NoteType.text
          : NoteType.todo;
    }

    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isPinned: json['is_pinned'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      colorIndex: json['color_index'] ?? AppConstants.defaultNoteColorIndex,
      wallpaperIndex:
          json['wallpaper_index'] ?? AppConstants.defaultWallpaperIndex,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isArchived: json['is_archived'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      index: json['index'] ?? 0,
      labelIds: (json['label_ids'] as List?)?.cast<String>() ?? [],
      todos: (json['todos'] as List?)
              ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deltaContent: json['delta_content'] ?? '',
      noteType: type,
    );
  }
}
