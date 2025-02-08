import 'package:flutter/material.dart';

class DrawerDestination {
  const DrawerDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<DrawerDestination> destinations = <DrawerDestination>[
  DrawerDestination(
    'Notes',
    Icon(Icons.note_outlined),
    Icon(Icons.note),
  ),
  DrawerDestination(
    'Favorites',
    Icon(Icons.favorite_outline),
    Icon(Icons.favorite),
  ),
  DrawerDestination(
      'Archive', Icon(Icons.archive_outlined), Icon(Icons.archive)),
  DrawerDestination(
    'Trash',
    Icon(Icons.delete_outline),
    Icon(Icons.delete),
  ),
  DrawerDestination(
    'Settings',
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
  ),
];
