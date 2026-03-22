# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LifeSync Journal is a mobile-first personal journaling app built with Flutter/Dart, featuring Obsidian-compatible Markdown storage, AES-256-GCM encryption, and multi-vault support. Current version: 0.1.0+1 (Alpha).

## Common Commands

```bash
# Install dependencies
flutter pub get

# Regenerate Isar models, Riverpod providers, Freezed classes, JSON serialization
flutter pub run build_runner build

# Run app
flutter run

# Lint
flutter analyze

# Test (currently no tests implemented)
flutter test
```

Run `build_runner` after modifying any files with `@collection`, `@riverpod`, `@freezed`, or `@JsonSerializable` annotations.

## Architecture

### State Management (Riverpod)

All state lives in [lib/core/providers/app_provider.dart](lib/core/providers/app_provider.dart) — ~50 providers covering services (storage, encryption, sync), UI state (selected entries, search, filters), and user progress (streaks, XP). Providers are consumed via `ref.watch`/`ref.read` throughout the feature widgets.

### Database (Isar)

A global `late Isar db` instance is initialized in [lib/main.dart](lib/main.dart). Collections: `JournalEntry`, `Habit`, `DailyMood`, `JournalAttachment`, `Vault`. Schema files generate `.g.dart` companions — never edit these manually.

### Navigation (GoRouter)

Defined in [lib/core/router/app_router.dart](lib/core/router/app_router.dart). A bottom-navigation shell wraps the four main tabs (Journal, Habits, Dashboard, More); nested routes handle editing, stats, and configuration screens.

### Services

Business logic lives in [lib/core/services/](lib/core/services/). Key services:

| Service | Responsibility |
|---|---|
| `storage_service.dart` | Isar queries, Markdown file I/O, YAML frontmatter, vault operations |
| `encryption_service.dart` | AES-256-GCM encryption, PBKDF2 key derivation, secure key storage |
| `lan_sync_service.dart` | Local-network device sync |
| `backup_service.dart` | Encrypted local backup/restore |
| `attachment_service.dart` | Media file management |
| `dashboard_service.dart` | Aggregates stats for the dashboard |

### Data Format

Entries are stored as Markdown files with YAML frontmatter (Obsidian-compatible). Vault folder layout: `/attachments`, `/daily`, `/templates`. Isar provides metadata indexing and full-text search on top of the file store.

### Encryption

Keys are derived via PBKDF2 and stored in platform secure storage (Android Keystore / iOS Keychain). Keys are kept in RAM only during the session. All encryption uses AES-256-GCM.

### Feature Modules

Each feature in [lib/features/](lib/features/) is self-contained (widgets + local state). Shared, reusable widgets go in [lib/shared/widgets/](lib/shared/widgets/).

### Web Preview

A separate Next.js 15/React 19 subproject lives in [web-preview/](web-preview/) and is independent of the Flutter build.

## Code Generation Notes

- Isar model files with `@collection` generate `<model>.g.dart` with query extensions.
- Riverpod providers annotated with `@riverpod` generate `<provider>.g.dart`.
- Freezed data classes generate `<class>.freezed.dart`.
- All generated files are committed; re-run `build_runner` when annotations change.
