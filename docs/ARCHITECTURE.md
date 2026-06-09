# Architecture

## Overview
Hone Mobile is organized into a feature-based Clean Architecture style:

- `lib/core/`: shared infrastructure (routing, diagnostics, models, utilities, theme)
- `lib/features/`: feature modules (vpn_boost, dns_boost, games, settings, etc.)
- `lib/shared/`: shared UI widgets

## VPN (WireGuard) Architecture (Phase 6+)
The VPN Boost feature is designed around an Android platform channel.

- Dart side:
  - `lib/features/vpn_boost/services/vpn_connection_service.dart`
  - `lib/features/vpn_boost/services/vpn_platform_channel.dart`
- Android side:
  - `android/app/src/main/kotlin/com/hone/mobile/vpn/VpnBridge.kt`
  - `android/app/src/main/kotlin/com/hone/mobile/vpn/VpnBridgeChannel.kt`

Planned real runtime components:
- `WireGuardService`
- `VpnTunnelManager`
- `VpnConnectionProvider`
- `VpnPermissionManager`
- `VpnConfigurationManager`

## Notes
This repository uses platform channel messaging to avoid coupling the Flutter UI/state to Android VPN runtime details.

