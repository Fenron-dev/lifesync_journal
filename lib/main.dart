import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/models/entry.dart';
import 'core/models/habit.dart';
import 'core/models/daily_mood.dart';
import 'core/models/journal_attachment.dart';
import 'core/models/vault.dart';
import 'core/models/media.dart';
import 'core/models/properties.dart';
import 'core/router/app_router.dart';

/// Global Isar instance
late Isar db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();

  try {
    db = await Isar.open(
      [
        EntrySchema,
        HabitSchema,
        HabitCompletionSchema,
        DailyMoodSchema,
        JournalAttachmentSchema,
        VaultSchema,
        MediaSchema,
        PropertiesSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
  } catch (e) {
    // Fatal: cannot continue without database
    FlutterError.reportError(FlutterErrorDetails(exception: e));
    rethrow;
  }

  // Initialize services
  // In production, attachment service would be initialized here

  runApp(
    const ProviderScope(
      child: LifeSyncApp(),
    ),
  );
}

/// Main App Widget
class LifeSyncApp extends ConsumerWidget {
  const LifeSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LifeSync',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        
        // App Bar
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        
        // Cards
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // FAB
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
        ),
        
        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          showDragHandle: true,
        ),
      ),
      
      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      
      themeMode: ThemeMode.system,
      
      // Router
      routerConfig: router,
    );
  }
}
