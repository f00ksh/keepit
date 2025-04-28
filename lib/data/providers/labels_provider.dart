import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/label.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

part 'labels_provider.g.dart';

@riverpod
class Labels extends _$Labels {
  @override
  List<Label> build() {
    _loadLabels();
    return [];
  }

  Future<void> _loadLabels() async {
    final labels = await ref.read(storageServiceProvider).getAllLabels();
    state = labels;
  }

  Future<void> addLabel(Label label) async {
    final currentLabels = List<Label>.from(state);
    state = [...currentLabels, label];

    await ref.read(storageServiceProvider).addLabel(label);

    // Sync with cloud if user is authenticated
  }

  Future<void> updateLabel(String id, Label updatedLabel) async {
    final currentLabels = List<Label>.from(state);
    final index = currentLabels.indexWhere((label) => label.id == id);

    if (index == -1) return;

    currentLabels[index] = updatedLabel;
    state = currentLabels;

    await ref.read(storageServiceProvider).updateLabel(updatedLabel);
    _syncWithCloud((service) => service.updateLabel(updatedLabel)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'LabelsProvider'));
  }

  Future<void> deleteLabel(String id) async {
    final currentLabels = List<Label>.from(state);
    currentLabels.removeWhere((label) => label.id == id);
    state = currentLabels;

    await ref.read(storageServiceProvider).deleteLabel(id);
    _syncWithCloud((service) => service.deleteLabelPermanently(id)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'LabelsProvider'));
  }

  Future<void> _syncWithCloud(
      Future<void> Function(dynamic service) operation) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      await operation(ref.read(supabaseServiceProvider));
    }
  }
}

// Provider to get a label by ID
@riverpod
Label? labelById(Ref ref, String id) {
  final labels = ref.watch(labelsProvider);
  final index = labels.indexWhere((label) => label.id == id);
  return index >= 0 ? labels[index] : null;
}

// Provider to filter notes by label ID
@riverpod
List<Note> notesByLabelId(Ref ref, String labelId) {
  final allNotes = ref.watch(notesProvider);

  return allNotes.where((Note note) {
    final labelIds = note.labelIds;
    return !note.isDeleted && labelIds.contains(labelId);
  }).toList();
}
