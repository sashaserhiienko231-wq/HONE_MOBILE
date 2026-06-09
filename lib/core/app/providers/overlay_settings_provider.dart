import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlaySettings {
  final bool enabled;
  final double opacity;
  final Offset position;
  final Size size;
  final bool minimized;
  final bool autoShowDuringGames;
  final Map<String, bool> modules;

  OverlaySettings({
    required this.enabled,
    required this.opacity,
    required this.position,
    required this.size,
    required this.minimized,
    required this.autoShowDuringGames,
    required this.modules,
  });

  factory OverlaySettings.initial() => OverlaySettings(
        enabled: false,
        opacity: 0.88,
        position: const Offset(16, 200),
        size: const Size(220, 88),
        minimized: false,
        autoShowDuringGames: true,
        modules: {
          'fps': true,
          'ram': true,
          'cpu': true,
          'temp': true,
          'battery': true,
          'ping': true,
          'dns': false,
          'profile': true,
        },
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'opacity': opacity,
        'position': {'dx': position.dx, 'dy': position.dy},
        'size': {'w': size.width, 'h': size.height},
        'minimized': minimized,
        'autoShowDuringGames': autoShowDuringGames,
        'modules': modules,
      };

  factory OverlaySettings.fromJson(Map<String, dynamic> j) {
    final pos = j['position'] ?? {'dx': 16.0, 'dy': 200.0};
    final sz = j['size'] ?? {'w': 220.0, 'h': 88.0};
    final mods = Map<String, bool>.from(j['modules'] ?? {});
    return OverlaySettings(
      enabled: j['enabled'] ?? false,
      opacity: (j['opacity'] ?? 0.88).toDouble(),
      position: Offset((pos['dx'] ?? 16.0).toDouble(), (pos['dy'] ?? 200.0).toDouble()),
      size: Size((sz['w'] ?? 220.0).toDouble(), (sz['h'] ?? 88.0).toDouble()),
      minimized: j['minimized'] ?? false,
      autoShowDuringGames: j['autoShowDuringGames'] ?? true,
      modules: mods,
    );
  }
}

class OverlaySettingsNotifier extends StateNotifier<OverlaySettings> {
  static const _prefsKey = 'overlay_settings_v1';
  OverlaySettingsNotifier() : super(OverlaySettings.initial()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final j = json.decode(raw) as Map<String, dynamic>;
      state = OverlaySettings.fromJson(j);
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(state.toJson()));
  }

  void setEnabled(bool v) {
    state = OverlaySettings(
      enabled: v,
      opacity: state.opacity,
      position: state.position,
      size: state.size,
      minimized: state.minimized,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: state.modules,
    );
    _save();
  }

  void setOpacity(double v) {
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: v.clamp(0.1, 1.0),
      position: state.position,
      size: state.size,
      minimized: state.minimized,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: state.modules,
    );
    _save();
  }

  void setPosition(Offset o) {
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: state.opacity,
      position: o,
      size: state.size,
      minimized: state.minimized,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: state.modules,
    );
    _save();
  }

  void setSize(Size s) {
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: state.opacity,
      position: state.position,
      size: s,
      minimized: state.minimized,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: state.modules,
    );
    _save();
  }

  void setMinimized(bool v) {
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: state.opacity,
      position: state.position,
      size: state.size,
      minimized: v,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: state.modules,
    );
    _save();
  }

  void setAutoShowDuringGames(bool v) {
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: state.opacity,
      position: state.position,
      size: state.size,
      minimized: state.minimized,
      autoShowDuringGames: v,
      modules: state.modules,
    );
    _save();
  }

  void setModuleEnabled(String key, bool v) {
    final mods = Map<String, bool>.from(state.modules);
    mods[key] = v;
    state = OverlaySettings(
      enabled: state.enabled,
      opacity: state.opacity,
      position: state.position,
      size: state.size,
      minimized: state.minimized,
      autoShowDuringGames: state.autoShowDuringGames,
      modules: mods,
    );
    _save();
  }
}

final overlaySettingsProvider = StateNotifierProvider<OverlaySettingsNotifier, OverlaySettings>((ref) {
  return OverlaySettingsNotifier();
});
