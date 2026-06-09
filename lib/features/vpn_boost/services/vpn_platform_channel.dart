import 'dart:async';

import 'package:flutter/services.dart';

/// Platform channel contract to Android VpnService/WireGuard.
///
/// This file intentionally does not simulate values. If Android has not been
/// wired yet, it should return explicit "Not Configured" or null stats.
class VpnPlatformChannel {
  VpnPlatformChannel._();

  static final VpnPlatformChannel instance = VpnPlatformChannel._();

  static const MethodChannel _channel = MethodChannel('hone_mobile_vpn');

  Future<void> connect({
    required String? serverId,
    required String wireGuardConfig,
  }) async {
    await _channel.invokeMethod<void>(
      'connect',
      {
        'serverId': serverId,
        'wireGuardConfig': wireGuardConfig,
      },
    );
  }

  Future<void> disconnect() async {
    await _channel.invokeMethod<void>('disconnect');
  }

  Future<void> reconnect() async {
    await _channel.invokeMethod<void>('reconnect');
  }

  Future<Map<String, dynamic>> _invokeMap(String method) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>?>(method);
    return Map<String, dynamic>.from(result ?? const <dynamic, dynamic>{});
  }

  Future<Map<String, dynamic>> getStatus() async {
    return _invokeMap('getStatus');
  }

  Future<Map<String, dynamic>> getTransferStats() async {
    return _invokeMap('getTransferStats');
  }

  Future<Map<String, dynamic>> getCurrentServer() async {
    return _invokeMap('getCurrentServer');
  }

  Future<Duration?> getSessionDuration() async {
    final res = await _invokeMap('getSessionDuration');
    final durationMs = res['durationMs'];
    if (durationMs is int) {
      return Duration(milliseconds: durationMs);
    }
    return null;
  }

  Future<void> importWireGuardConfig({
    required String? serverId,
    required String wireGuardConfig,
  }) async {
    await _channel.invokeMethod<void>(
      'importWireGuardConfig',
      {
        'serverId': serverId,
        'wireGuardConfig': wireGuardConfig,
      },
    );
  }
}


