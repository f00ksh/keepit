import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';

class NavigationService {
  static void handleDestinationChange(
    BuildContext context,
    WidgetRef ref,
    int index, {
    void Function(int)? onIndexChanged,
  }) {
    // Handle Settings navigation (assuming it's the last index)
    if (index == 4) {
      // Adjust index as needed for your settings
      Navigator.pushNamed(context, AppRoutes.settings);
      return;
    }

    // Handle regular tab navigation
    onIndexChanged?.call(index);

    // Close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Notes';
      case 1:
        return 'Favorites';
      case 2:
        return 'Archive';
      case 3:
        return 'Trash';
      case 4:
        return 'Settings';
      default:
        return 'Notes';
    }
  }
}
