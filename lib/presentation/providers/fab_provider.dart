import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fab_provider.g.dart';

@riverpod
class FabExpansion extends _$FabExpansion {
  @override
  bool build() {
    return false; // Default to not expanded
  }

  void toggle() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}
