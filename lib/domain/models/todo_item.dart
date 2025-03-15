import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'dart:developer' as developer;
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
  }) : id = id ?? const Uuid().v4() {
    // Debug print when creating a todo item
    developer.log(
        'Creating TodoItem: id=$id, content=$content, isDone=$isDone, index=$index',
        name: 'TodoItem');
  }

  // For JSON serialization
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'content': content,
      'isDone': isDone,
      'index': index,
    };
    // Debug: log JSON serialization
    developer.log('TodoItem.toJson: $json', name: 'TodoItem');
    return json;
  }

  // For JSON deserialization
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    // Debug: log JSON deserialization
    developer.log('TodoItem.fromJson: $json', name: 'TodoItem');
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
