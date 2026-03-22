# Security Policy

## Scope

LifeSync Journal processes sensitive personal data (journal entries, health data, mood logs). Security is a core design goal.

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Instead, report them via GitHub's private vulnerability reporting:
**Security → Report a vulnerability** (in the repository sidebar)

Or send a mail to the maintainer listed in the repository contact.

We aim to acknowledge reports within 72 hours and provide a fix or mitigation plan within 14 days for confirmed vulnerabilities.

## Security Architecture

- **Encryption**: AES-256-GCM for all vault data and backups
- **Key derivation**: PBKDF2-SHA256 with 100,000 iterations and a random 32-byte salt per vault
- **Key storage**: Android Keystore (hardware-backed where available) / iOS Keychain; keys are never written to disk in plaintext
- **RAM-only keys**: Encryption keys are held in RAM only for the duration of the session and cleared on lock
- **No cloud by default**: No data leaves the device unless the user explicitly initiates LAN sync or backup sharing
- **LAN sync**: All sync traffic is encrypted with AES-256-GCM using a session key exchanged over a pairing flow

## Known Limitations (Alpha)

- LAN sync pairing is not yet hardened against MITM on untrusted networks — use only on trusted local networks
- The audiobookshelf API token is stored in `SharedPreferences` (not yet in Keychain/Keystore)
- No certificate pinning for audiobookshelf server connections
