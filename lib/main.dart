import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepit/core/constants/app_constants.dart';
import 'package:keepit/data/providers/service_providers.dart';
import 'package:keepit/data/repositories/auth_repository_impl.dart';
import 'package:keepit/data/services/hive_stoarge_service.dart';
import 'package:keepit/data/services/supabase_stoarge_service.dart';
import 'package:keepit/domain/models/label.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/domain/models/settings.dart';
import 'package:keepit/domain/models/todo_item.dart';
import 'package:keepit/domain/models/user.dart';
import 'app.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await Hive.initFlutter();
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(LabelAdapter());
  Hive.registerAdapter(SettingAdapter());
  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(NoteTypeAdapter());

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.projectUrl,
    anonKey: AppConstants.anonKey,
  );

  // Initialize services
  final storageService = StorageService()..init();
  final supabaseService = SupabaseService(Supabase.instance.client)..init();
  final authService = AuthRepositoryImpl(Supabase.instance.client);

  // Create provider overrides
  final providers = [
    storageServiceProvider.overrideWithValue(storageService),
    supabaseServiceProvider.overrideWithValue(supabaseService),
    authServiceProvider.overrideWithValue(authService),
  ];

  runApp(
    ProviderScope(
      overrides: providers,
      child: const MyApp(),
    ),
  );
}
