import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_label_provider.g.dart';

@riverpod
class SelectedLabel extends _$SelectedLabel {
  @override
  String? build() => null;

  void setSelectedLabel(String? labelId) => state = labelId;
}
