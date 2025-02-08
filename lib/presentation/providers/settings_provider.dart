import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

enum GridViewStyle { masonry, uniform }

@riverpod
class Settings extends _$Settings {
  @override
  AsyncValue<Map<String, dynamic>> build() {
    return const AsyncValue.data({
      'gridViewStyle': GridViewStyle.masonry,
      'sortBy': 'dateModified',
      'sortAscending': false,
      'showPinnedSection': true,
    });
  }

  Future<void> setGridViewStyle(GridViewStyle style) async {
    state = const AsyncValue.loading();
    try {
      final currentSettings = state.valueOrNull ?? {};
      state = AsyncValue.data({
        ...currentSettings,
        'gridViewStyle': style,
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setSortBy(String sortBy) async {
    state = const AsyncValue.loading();
    try {
      final currentSettings = state.valueOrNull ?? {};
      state = AsyncValue.data({
        ...currentSettings,
        'sortBy': sortBy,
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleSortDirection() async {
    state = const AsyncValue.loading();
    try {
      final currentSettings = state.valueOrNull ?? {};
      state = AsyncValue.data({
        ...currentSettings,
        'sortAscending': !(currentSettings['sortAscending'] ?? false),
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> togglePinnedSection() async {
    state = const AsyncValue.loading();
    try {
      final currentSettings = state.valueOrNull ?? {};
      state = AsyncValue.data({
        ...currentSettings,
        'showPinnedSection': !(currentSettings['showPinnedSection'] ?? true),
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
