import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/presentation/providers/selected_label_provider.dart';

class NavigationService {
  static void handleDestinationChange(
    BuildContext context,
    WidgetRef ref,
    int index, {
    void Function(int)? onIndexChanged,
    Map<String, dynamic>? labelData,
  }) {
    debugPrint('NavigationService: Handling destination change');
    debugPrint('Index: $index');
    debugPrint('Label data: $labelData');

    // Handle label-related navigation first
    if (labelData != null) {
      if (labelData['isCreateNew'] == true) {
        debugPrint('NavigationService: Creating new label');
        Navigator.pushNamed(context, AppRoutes.labels);
      } else if (labelData['labelId'] != null) {
        debugPrint(
            'NavigationService: Filtering by label: ${labelData['labelId']}');
        // Set selected label
        ref
            .read(selectedLabelProvider.notifier)
            .setSelectedLabel(labelData['labelId']);

        // Close drawer if open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        return;
      }
      return;
    }

    // Clear selected label for non-label navigation
    ref.read(selectedLabelProvider.notifier).setSelectedLabel(null);

    // Handle regular navigation
    debugPrint('NavigationService: Regular navigation to index $index');
    if (index == 4) {
      Navigator.pushNamed(context, AppRoutes.settings);
      return;
    }

    onIndexChanged?.call(index);

    // Close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
