# LifeSync Journal

A privacy-first personal journaling app for Android and iOS, built with Flutter. All data is stored locally in Obsidian-compatible Markdown files and encrypted with AES-256-GCM — no cloud account required.

> **Status:** Alpha (v0.1.0+1) — core functionality works, not yet production-ready.

---

## Features

- **Journal** — Markdown editor with YAML frontmatter, Obsidian-compatible file format
- **Quick Entry** — Bottom-sheet capture for notes, moods, photos, audio, workouts, meals, books, and more
- **Habit Tracker** — Daily check-ins with streaks and statistics
- **Dashboard** — Heatmap, mood chart, habit progress, XP/streak system
- **Search** — Full-text and filtered search across all entries
- **Health Integration** — Apple HealthKit / Google Health Connect, Samsung Health
- **Audiobookshelf** — Track books/podcasts from your self-hosted Audiobookshelf server
- **LAN Sync** — Peer-to-peer sync over local network (no cloud)
- **Backup** — AES-encrypted local backup and restore
- **Multi-Vault** — Separate encrypted vaults per topic or person
- **Home Screen Widgets** — Streak and quick-entry widgets

## Privacy & Security

- All data stays **on-device** — no mandatory cloud sync, no telemetry
- Encryption: **AES-256-GCM** with PBKDF2 key derivation (100,000 iterations)
- Keys stored in **Android Keystore / iOS Keychain**, held in RAM only during the session
- Backup files are encrypted; only decryptable with your password

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State | Riverpod 2 (code-gen) |
| Database | Isar 3 |
| Navigation | GoRouter |
| Encryption | `package:cryptography` (AES-256-GCM) |
| Markdown | `flutter_markdown` |
| Storage format | Markdown + YAML frontmatter (Obsidian-compatible) |
| Web preview | Next.js 15 / React 19 (standalone sub-project) |

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.16 (`flutter --version`)
- Dart ≥ 3.2
- Android Studio / Xcode for device targets

### Setup

```bash
# Clone
git clone https://github.com/Fenron-dev/lifesync_journal.git
cd lifesync_journal

# Install dependencies
flutter pub get

# Generate code (Isar schemas, Riverpod providers, Freezed classes)
flutter pub run build_runner build

# Run
flutter run
```

Re-run `build_runner` whenever you modify files with `@collection`, `@riverpod`, `@freezed`, or `@JsonSerializable` annotations.

### Lint

```bash
flutter analyze
```

### Tests

```bash
flutter test
```

> Tests are not yet implemented in this alpha phase.

## Project Structure

```
lib/
├── main.dart                        # App entry point, Isar init
├── core/
│   ├── constants/app_config.dart    # App-wide constants
│   ├── models/                      # Isar collections (*.g.dart generated)
│   ├── providers/app_provider.dart  # ~50 Riverpod providers
│   ├── router/app_router.dart       # GoRouter, shell navigation
│   ├── services/                    # Business logic
│   │   ├── storage_service.dart     # Isar + Markdown file I/O
│   │   ├── encryption_service.dart  # AES-256-GCM, PBKDF2
│   │   ├── backup_service.dart      # Encrypted backup/restore
│   │   ├── lan_sync_service.dart    # LAN peer sync
│   │   ├── health_service.dart      # HealthKit / Health Connect
│   │   └── ...
│   └── theme/app_theme.dart         # Material 3 theme
├── features/                        # Feature modules (self-contained)
│   ├── journal/
│   ├── habits/
│   ├── dashboard/
│   ├── health/
│   ├── search/
│   ├── backup/
│   ├── sync/
│   ├── quick_entry/
│   └── ...
└── shared/widgets/                  # Reusable UI components

web-preview/                         # Standalone Next.js sub-project
```

## Roadmap

| Phase | Scope | Status |
|---|---|---|
| 1 — Foundation | Markdown editor, encryption, search, daily notes | ✅ Alpha |
| 2 — Capture | Quick entry, templates, mood tracking, media | 🚧 In progress |
| 3 — Integration | LAN sync, vault system, tags | 🔜 Planned |
| 4 — Polish | Gamification, health, audiobook tracking | 🔜 Planned |
| 5 — AI & Desktop | AI writing assist, desktop (Windows/macOS/Linux) | 🔜 Planned |

## Contributing

This project is in early alpha. Contributions, issues, and feature requests are welcome. Please open an issue before submitting a large PR.

## License

MIT — see [LICENSE](LICENSE) for details.
