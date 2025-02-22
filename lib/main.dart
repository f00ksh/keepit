import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keepit/core/constants/app_constants.dart';
import 'package:keepit/data/providers/service_providers.dart';
import 'package:keepit/data/services/hive_stoarge_service.dart';
import 'package:keepit/data/services/supabase_stoarge_service.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/domain/models/settings.dart';
import 'package:keepit/domain/models/user.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(SettingAdapter());

  // Initialize Supabase with your actual credentials
  await Supabase.initialize(
    url: AppConstants.projectUrl,
    anonKey: AppConstants.anonKey,
  );

  final storageService = StorageService();
  await storageService.init();
  final supabaseService = SupabaseService(Supabase.instance.client);
  await supabaseService.init();
  final authService = AuthRepositoryImpl(Supabase.instance.client);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        supabaseServiceProvider.overrideWithValue(supabaseService),
        authServiceProvider.overrideWithValue(authService),
      ],
      child: const MyApp(),
    ),
  );
}
