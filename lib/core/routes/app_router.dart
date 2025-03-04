import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/pages/home_page.dart';
import 'package:keepit/presentation/pages/login_page.dart';
import 'package:keepit/presentation/pages/note_page.dart';
import 'package:keepit/presentation/pages/settings_page.dart';
import 'package:keepit/presentation/pages/label_screen.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String addNote = '/add-note';
  static const String note = '/note';
  static const String labels = '/labels';
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
    AppRoutes.addNote: (context) => const NotePage(
          heroTag: 'add_note_fab',
        ),
    AppRoutes.note: (context) {
      final noteId = ModalRoute.of(context)?.settings.arguments as String?;
      if (noteId == null) return const HomePage();

      return Consumer(
        builder: (context, ref, child) {
          return NotePage(
            noteId: noteId,
            heroTag: 'note_$noteId',
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
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeBuilder = routes[settings.name];
    if (routeBuilder != null) {
      return MaterialPageRoute(
        builder: routeBuilder,
        settings: settings,
      );
    }
    return onUnknownRoute(settings);
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
