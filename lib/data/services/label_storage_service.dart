import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/label.dart';
import 'package:flutter/foundation.dart';

class LabelStorageService {
  // static const String _tag = 'LabelStorageService';
  static const String labelsBoxName = 'labels';
  late Box<Label> _labelsBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LabelAdapter());
    }

    _labelsBox = await Hive.openBox<Label>(labelsBoxName);
  }

  Future<List<Label>> getAllLabels() async {
    debugPrint('LabelStorageService: Getting all labels');
    final labels = _labelsBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    debugPrint('LabelStorageService: Found ${labels.length} labels');
    return labels;
  }

  Future<void> addLabel(Label label) async {
    debugPrint(
        'LabelStorageService: Adding label: ${label.name} (${label.id})');
    await _labelsBox.put(label.id, label);
    debugPrint('LabelStorageService: Label saved to box');
  }

  Future<void> updateLabel(Label label) async {
    await _labelsBox.put(label.id, label.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteLabel(String id) async {
    await _labelsBox.delete(id);
  }

  Future<Label?> getLabelById(String id) async {
    return _labelsBox.get(id);
  }

  Future<void> clearAll() async {
    await _labelsBox.clear();
  }
}
