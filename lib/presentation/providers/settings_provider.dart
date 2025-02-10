import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/settings.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const String _boxName = 'settings';
  late Box<Setting> _box;

  @override
  Future<Setting> build() async {
    _box = await Hive.openBox<Setting>(_boxName);
    
    // Ensure default settings are created if they don't exist
    if (!_box.containsKey('user_settings')) {
      final defaultSettings = Setting(syncEnabled: false);
      await _box.put('user_settings', defaultSettings);
      return defaultSettings;
    }
    
    return _box.get('user_settings')!;
  }

  Future<void> setViewStyle(String style) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;
    final newSettings = currentSettings.copyWith(viewStyle: style);
    await _saveSettings(newSettings);
  }

  Future<void> setSortBy(String sortBy) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;
    final newSettings = currentSettings.copyWith(sortBy: sortBy);
    await _saveSettings(newSettings);
  }

  Future<void> toggleSortDirection() async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;
    final newSettings = currentSettings.copyWith(
      sortAscending: !currentSettings.sortAscending,
    );
    await _saveSettings(newSettings);
  }

  Future<void> togglePinnedSection() async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;
    final newSettings = currentSettings.copyWith(
      showPinnedSection: !currentSettings.showPinnedSection,
    );
    await _saveSettings(newSettings);
  }

  Future<void> toggleSync() async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;
    final newSettings = currentSettings.copyWith(
      syncEnabled: !currentSettings.syncEnabled,
    );
    
    try {
      await _saveSettings(newSettings);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> _saveSettings(Setting settings) async {
    try {
      await _box.put('user_settings', settings);
      state = AsyncData(settings);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  bool get isSyncEnabled => state.valueOrNull?.syncEnabled ?? false;
}