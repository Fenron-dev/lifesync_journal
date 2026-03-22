import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/encryption_service.dart';
import '../services/lan_sync_service.dart';
import '../services/samsung_health_service.dart';
import '../services/home_widget_service.dart';
import '../services/audiobookshelf_service.dart';

/// App Providers - Globale Zustandsverwaltung
/// 
/// Verwaltet:
/// - Theme-Einstellungen
/// - Initialisierungsstatus
/// - Service-Provider
/// - Streak-Daten
/// - Navigation

// ==================== SERVICE PROVIDERS ====================

/// Storage Service Provider
final storageServiceProvider = StateProvider<StorageService?>((ref) => null);

/// Encryption Service Provider
final encryptionServiceProvider = StateProvider<EncryptionService?>((ref) => null);

/// LAN Sync Service Provider
final lanSyncServiceProvider = StateProvider<LanSyncService?>((ref) => null);

/// Samsung Health Service Provider
final samsungHealthServiceProvider = StateProvider<SamsungHealthService?>((ref) => null);

/// Home Widget Service Provider
final homeWidgetServiceProvider = StateProvider<HomeWidgetService?>((ref) => null);

/// Audiobookshelf Service Provider
final audiobookshelfServiceProvider = StateProvider<AudiobookshelfService?>((ref) => null);

// ==================== APP STATE PROVIDERS ====================

/// Initialization Status
final initializedProvider = StateProvider<bool>((ref) => false);

/// Initialization Error
final initializationErrorProvider = StateProvider<String?>((ref) => null);

/// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// First Launch Provider
final isFirstLaunchProvider = StateProvider<bool>((ref) => true);

// ==================== USER PROGRESS PROVIDERS ====================

/// Streak Provider
final streakProvider = StateProvider<int>((ref) => 0);

/// XP Provider
final xpProvider = StateProvider<int>((ref) => 0);

/// Level Provider (computed from XP)
final levelProvider = Provider<int>((ref) {
  final xp = ref.watch(xpProvider);
  // Level = floor(sqrt(xp / 100)) + 1
  return (xp / 100).floor() + 1;
});

/// Level Progress Provider
final levelProgressProvider = Provider<double>((ref) {
  final xp = ref.watch(xpProvider);
  final level = ref.watch(levelProvider);
  final xpInCurrentLevel = xp - ((level - 1) * 100);
  return (xpInCurrentLevel / 100).clamp(0.0, 1.0);
});

// ==================== VAULT PROVIDERS ====================

/// Current Vault ID Provider
final currentVaultProvider = StateProvider<int?>((ref) => null);

/// Active Vault Provider
final activeVaultProvider = FutureProvider.autoDispose((ref) async {
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return null;
  
  final vaultId = ref.watch(currentVaultProvider);
  if (vaultId != null) {
    return await storage.loadVault(vaultId);
  }
  
  return await storage.loadDefaultVault();
});

/// All Vaults Provider
final allVaultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return [];
  return await storage.loadVaults();
});

// ==================== ENTRY PROVIDERS ====================

/// Entries for Date Provider
final entriesForDateProvider = FutureProvider.family
    .autoDispose<List<dynamic>, DateTime>((ref, date) async {
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return [];
  
  final vaultId = ref.watch(currentVaultProvider);
  return await storage.loadEntriesForDate(date, vaultId: vaultId);
});

/// Selected Entry Provider
final selectedEntryProvider = StateProvider<int?>((ref) => null);

/// Daily Note Provider
final dailyNoteProvider = FutureProvider.family
    .autoDispose<dynamic, DateTime>((ref, date) async {
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return null;
  
  final vaultId = ref.watch(currentVaultProvider);
  return await storage.getOrCreateDailyNote(date, vaultId: vaultId);
});

// ==================== SEARCH PROVIDERS ====================

/// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search Results Provider
final searchResultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return [];
  
  final vaultId = ref.watch(currentVaultProvider);
  return await storage.searchEntries(query, vaultId: vaultId);
});

/// Search Filter Type Provider
final searchFilterTypeProvider = StateProvider<String?>((ref) => null);

/// Search Date Range Provider
final searchDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// ==================== UI STATE PROVIDERS ====================

/// Loading State Provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Error Message Provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Selected Tab Provider (for bottom navigation)
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Calendar Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Calendar View Type Provider
final calendarViewProvider = StateProvider<String>((ref) => 'month');

// ==================== QUICK ENTRY PROVIDERS ====================

/// Quick Entry Type Provider
final quickEntryTypeProvider = StateProvider<String>((ref) => 'note');

/// Quick Entry Form Data Provider
final quickEntryFormDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// ==================== HEALTH PROVIDERS ====================

/// Health Connection Status Provider
final healthConnectionStatusProvider = StateProvider<int>((ref) => 0);

/// Health Data Provider (cached)
final healthDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Health Last Sync Provider
final healthLastSyncProvider = StateProvider<DateTime?>((ref) => null);

// ==================== SYNC PROVIDERS ====================

/// Sync Status Provider
final syncStatusProvider = StateProvider<String>((ref) => 'idle');

/// Sync Progress Provider
final syncProgressProvider = StateProvider<double>((ref) => 0.0);

/// Paired Devices Provider
final pairedDevicesProvider = StateProvider<List<dynamic>>((ref) => []);

/// Discovered Devices Provider
final discoveredDevicesProvider = StateProvider<List<dynamic>>((ref) => []);

// ==================== PROPERTIES PROVIDERS ====================

/// Properties Provider
final propertiesProvider = FutureProvider<List<dynamic>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  if (storage == null) return [];
  return await storage.loadProperties();
});

/// Selected Property Provider
final selectedPropertyProvider = StateProvider<int?>((ref) => null);

// ==================== ONBOARDING PROVIDERS ====================

/// Onboarding Step Provider
final onboardingStepProvider = StateProvider<int>((ref) => 0);

/// Onboarding Complete Provider
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

// ==================== SETTINGS PROVIDERS ====================

/// Auto Sync Enabled Provider
final autoSyncProvider = StateProvider<bool>((ref) => true);

/// Auto Sync Interval Provider (in minutes)
final autoSyncIntervalProvider = StateProvider<int>((ref) => 60);

/// Biometric Lock Enabled Provider
final biometricLockProvider = StateProvider<bool>((ref) => false);

/// Auto Backup Enabled Provider
final autoBackupProvider = StateProvider<bool>((ref) => false);

/// Default Entry Type Provider
final defaultEntryTypeProvider = StateProvider<String>((ref) => 'note');

/// Editor Font Size Provider
final editorFontSizeProvider = StateProvider<double>((ref) => 16.0);

/// Editor Font Family Provider
final editorFontFamilyProvider = StateProvider<String>((ref) => 'system');

// ==================== HELPER EXTENSIONS ====================

/// Extension to easily update state
extension RefExtension on Ref {
  /// Update a StateProvider's value
  void update<T>(StateProvider<T> provider, T Function(T) updater) {
    read(provider.notifier).state = updater(read(provider));
  }
}
