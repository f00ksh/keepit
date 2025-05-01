import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import 'home_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (next.value != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const HomePage(
                    initialIndex: 0,
                  )),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Keepit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(authProvider.notifier).signInWithGoogle(),
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(authProvider.notifier).signInAnonymously(),
              icon: const Icon(Icons.login),
              label: const Text('Annymous Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
