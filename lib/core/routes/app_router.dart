import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/pages/home_page.dart';
import 'package:keepit/presentation/pages/login_page.dart';
import 'package:keepit/presentation/pages/note_page.dart';
import 'package:keepit/presentation/pages/search_page.dart';
import 'package:keepit/presentation/pages/settings_page.dart';
import 'package:keepit/presentation/pages/label_screen.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String note = '/note';
  static const String labels = '/labels';
  static const String search = '/search';
  static const String addNote = '/add-note';
}

class AppRouter {
  static final routeGuardProvider =
      Provider<Widget Function(BuildContext, Widget)>(
    (ref) => (context, child) {
      return ref.watch(authProvider).when(
            data: (user) {
              if (user == null) {
                return const LoginPage();
              }
              return child;
            },
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => const LoginPage(),
          );
    },
  );

  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.home: (context) => Consumer(
          builder: (context, ref, child) {
            final guard = ref.watch(routeGuardProvider);
            return guard(context, const HomePage(initialIndex: 0));
          },
        ),
    AppRoutes.settings: (context) => Consumer(
          builder: (context, ref, child) {
            final guard = ref.watch(routeGuardProvider);
            return guard(context, const SettingsPage());
          },
        ),
    AppRoutes.addNote: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? noteId;
      noteId = (args as Map<String, dynamic>)['noteId'] as String;

      return NotePage(
        noteId: noteId,
        // hero tag based on note type
        heroTag: 'text_note_fab',
      );
    },
    AppRoutes.note: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? noteId;
      noteId = args as String;
      return NotePage(
        noteId: noteId,
        heroTag: 'note_$noteId',
      );
    },
    AppRoutes.labels: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      // If no arguments, open in management mode (from drawer)
      if (args == null) {
        return const LabelScreen();
      }
      // If arguments present, open in selection mode (from note)
      return LabelScreen(
        noteId: args['noteId'] as String,
        selectedLabelIds: args['selectedLabelIds'] as List<String>,
      );
    },
    AppRoutes.search: (context) => const SearchPage(),
  };
}
