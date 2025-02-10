import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Setting extends HiveObject {
  @HiveField(0)
  String viewStyle;

  @HiveField(1)
  String sortBy;

  @HiveField(2)
  bool sortAscending;

  @HiveField(3)
  bool showPinnedSection;

  @HiveField(4)
  bool syncEnabled;

  Setting({
    this.viewStyle = 'grid',
    this.sortBy = 'dateModified',
    this.sortAscending = false,
    this.showPinnedSection = true,
    this.syncEnabled = false,
  });

  Setting copyWith({
    String? viewStyle,
    String? sortBy,
    bool? sortAscending,
    bool? showPinnedSection,
    bool? syncEnabled,
  }) {
    return Setting(
      viewStyle: viewStyle ?? this.viewStyle,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      showPinnedSection: showPinnedSection ?? this.showPinnedSection,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }
}