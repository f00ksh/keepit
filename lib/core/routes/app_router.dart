import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/pages/home_page.dart';
import 'package:keepit/presentation/pages/login_page.dart';
import 'package:keepit/presentation/pages/note_page.dart';
import 'package:keepit/presentation/pages/search_page.dart';
import 'package:keepit/presentation/pages/settings_page.dart';
import 'package:keepit/presentation/pages/label_screen.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/domain/models/note.dart';

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
  static Widget initialRoute(BuildContext context, WidgetRef ref) {
    return ref.watch(authProvider).when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        return const LoginPage();
      },
    );
  }

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
              body: Center(child: CircularProgressIndicator()),
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
      NoteType noteType = NoteType.text; // Default to text note

      if (args is String) {
        // Handle old format for backward compatibility
        noteId = args;
      } else if (args is Map<String, dynamic>) {
        // Handle new format with note type
        noteId = args['noteId'] as String?;
        if (args.containsKey('initialNoteType')) {
          noteType = args['initialNoteType'] as NoteType;
        } else if (args.containsKey('isTextNote')) {
          // Legacy support for isTextNote boolean
          noteType = (args['isTextNote'] as bool?) == true
              ? NoteType.text
              : NoteType.todo;
        }
      }

      if (noteId == null) return const HomePage();

      return Consumer(
        builder: (context, ref, child) {
          return NotePage(
            noteId: noteId!,
            // hero tag based on note type
            heroTag:
                noteType == NoteType.text ? 'text_note_fab' : 'todo_note_fab',

            initialNoteType: noteType,
          );
        },
      );
    },
    AppRoutes.note: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? noteId;
      NoteType? noteType;

      if (args is String) {
        // Handle old format for backward compatibility
        noteId = args;
      } else if (args is Map<String, dynamic>) {
        // Handle new format with note type
        noteId = args['noteId'] as String?;
        if (args.containsKey('initialNoteType')) {
          noteType = args['initialNoteType'] as NoteType;
        } else if (args.containsKey('isTextNote')) {
          // Legacy support for isTextNote boolean
          noteType = (args['isTextNote'] as bool?) == true
              ? NoteType.text
              : NoteType.todo;
        }
      }

      if (noteId == null) return const HomePage();

      return Consumer(
        builder: (context, ref, child) {
          return NotePage(
            noteId: noteId!,
            heroTag: 'note_$noteId',
            initialNoteType: noteType,
          );
        },
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

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.search => PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SearchPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                // Fade in the background
                FadeTransition(
                  opacity: animation,
                  child:
                      Container(color: Theme.of(context).colorScheme.surface),
                ),
                // Scale up the search page content except the AppBar
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ],
            );
          },
        ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
