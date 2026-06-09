# Hone Mobile

Hone Mobile is a performance and system optimization suite built with Flutter.

## Features
- Gaming Hub
- Game Booster
- DNS Boost
- VPN Boost
- Analytics
- Achievements
- Overlay
- Instant Games
- Game Profiles

## Installation
### Requirements
- Flutter SDK
- Android Studio / Android SDK

### Get dependencies
```bash
flutter pub get
```

## Build instructions
```bash
flutter analyze
flutter test
flutter build apk --release
```

## Project architecture
- `lib/core/`: shared infrastructure (routing, theme, utilities)
- `lib/features/`: feature modules (VPN Boost, DNS Boost, etc.)

See `docs/ARCHITECTURE.md`.

## Screenshots
*(Add screenshots here)*

## Roadmap
- WireGuard real VPN runtime integration (Phase 6+)
- Server inventory + premium subscription hooks

## License
MIT (see `LICENSE`)

## Contributing
See `docs/CONTRIBUTING.md`.

