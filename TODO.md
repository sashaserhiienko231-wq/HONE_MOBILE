# TODO ? PHASE 6: REAL VPN IMPLEMENTATION (WireGuard)

## Plan checkpoints
- [ ] Discover existing VPN UI integration points (vpn_boost page/providers/state)
- [x] Replace simulated gateway with real abstraction layers:
  - [ ] WireGuardService
  - [ ] VpnTunnelManager
  - [ ] VpnConnectionProvider
  - [ ] VpnPermissionManager
  - [ ] VpnConfigurationManager

- [ ] Add Android integration using `com.wireguard.android:wireguard-android`
  - [ ] Wire WireGuardService/VpnService bridge
  - [ ] Add required manifest permissions/services
  - [ ] Expose real tunnel state + transfer statistics to Flutter via platform channel
- [ ] Implement Connect / Disconnect / Auto Reconnect / Server Switching
- [ ] Implement real monitoring
  - [ ] Transfer stats (download/upload speed)
  - [ ] Ping/latency metric strategy (real if available; otherwise fallback clearly identified)
- [ ] Implement real session tracking (duration + bytes)
- [ ] Server inventory + premium architecture hooks (placeholders only)
- [ ] Update Dart models/state to reflect real tunnel data
- [ ] Run:
  - [ ] `flutter analyze`
  - [ ] `flutter test`
- [ ] Produce final integration report

