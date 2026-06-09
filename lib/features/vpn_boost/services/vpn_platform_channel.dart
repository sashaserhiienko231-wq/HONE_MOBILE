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

  Future<Map<String, dynamic>> getStatus() async {
    final res = await _channel.invokeMapMethod<String, dynamic>('getStatus');
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> getTransferStats() async {
    final res = await _channel.invokeMapMethod<String, dynamic>('getTransferStats');
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> getCurrentServer() async {
    final res = await _channel.invokeMapMethod<String, dynamic>('getCurrentServer');
    return Map<String, dynamic>.from(res);
  }

  Future<Duration?> getSessionDuration() async {
    final res = await _channel.invokeMapMethod<String, dynamic>('getSessionDuration');
    final durationMs = res['durationMs'];
    if (durationMs == null) return null;
    return Duration(milliseconds: durationMs as int);
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

extension _MethodChannelX on MethodChannel {
  Future<Map<K, V>> invokeMapMethod<K, V>(String method) async {
    final value = await invokeMethod<Map<dynamic, dynamic>>(method);
    final map = value ?? const <dynamic, dynamic>{};
    return map.map((key, v) => MapEntry(key as K, v as V));
  }
}

