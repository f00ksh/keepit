import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
part 'todo_item.g.dart';

// Add HiveType annotation
@HiveType(
    typeId:
        5) // Using typeId 4 (make sure it doesn't conflict with other types)
class TodoItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isDone;

  @HiveField(3)
  final int index;

  TodoItem({
    String? id,
    required this.content,
    this.isDone = false,
    required this.index,
  }) : id = id ?? const Uuid().v4();

  // For JSON serialization
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'content': content,
      'isDone': isDone,
      'index': index,
    };

    return json;
  }

  // For JSON deserialization
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      content: json['content'] as String,
      isDone: json['isDone'] as bool,
      index: json['index'] as int,
    );
  }

  TodoItem copyWith({
    String? id,
    String? content,
    bool? isDone,
    int? index,
  }) {
    return TodoItem(
      id: id ?? this.id,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      index: index ?? this.index,
    );
  }
}
