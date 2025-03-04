import 'package:hive/hive.dart';
import 'package:keepit/core/constants/app_constants.dart';

part 'note.g.dart';

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
  }) {
    return Note(
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
    );
  }

  Map<String, dynamic> toJson() {
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
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isPinned: json['is_pinned'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      colorIndex: json['color_index'] ?? AppConstants.defaultNoteColorIndex,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isArchived: json['is_archived'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      index: json['index'] ?? 0,
      labelIds: (json['label_ids'] as List?)?.cast<String>() ?? [],
    );
  }
}
