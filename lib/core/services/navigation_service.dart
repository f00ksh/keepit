import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';

class NavigationService {
  static void handleDestinationChange(
    BuildContext context,
    WidgetRef ref,
    int index,
    Function(int) setState,
  ) {
    if (index == 4) {
      // Settings
      Navigator.pushNamed(context, AppRoutes.settings);
      setState(0);
      return;
    }
    setState(index);
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
