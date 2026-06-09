import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/services/settings_service.dart';

/// Persisted animation preferences stored in SharedPreferences.
class AnimationSettings {
  final bool enabled;
  final bool premiumMode;
  final bool reduceMotion;

  const AnimationSettings({
    required this.enabled,
    required this.premiumMode,
    required this.reduceMotion,
  });

  static const defaults = AnimationSettings(
    enabled: true,
    premiumMode: true,
    reduceMotion: false,
  );
}

class AnimationSettingsNotifier extends StateNotifier<AnimationSettings> {
  AnimationSettingsNotifier() : super(AnimationSettings.defaults) {
    _init();
  }

  Future<void> _init() async {
    if (!SettingsService.isInitialized) {
      await SettingsService.initialize();
    }

    state = AnimationSettings(
      enabled: SettingsService.animationsEnabled,
      premiumMode: SettingsService.animationsPremiumMode,
      reduceMotion: SettingsService.animationsReduceMotion,
    );
  }

  Future<void> setEnabled(bool v) async {
    await SettingsService.setBool('animations_enabled', v);
    state = AnimationSettings(
      enabled: v,
      premiumMode: state.premiumMode,
      reduceMotion: state.reduceMotion,
    );
  }

  Future<void> setPremiumMode(bool v) async {
    await SettingsService.setBool('animations_premium_mode', v);
    state = AnimationSettings(
      enabled: state.enabled,
      premiumMode: v,
      reduceMotion: state.reduceMotion,
    );
  }

  Future<void> setReduceMotion(bool v) async {
    await SettingsService.setBool('animations_reduce_motion', v);
    state = AnimationSettings(
      enabled: state.enabled,
      premiumMode: state.premiumMode,
      reduceMotion: v,
    );
  }
}

final animationSettingsProvider =
    StateNotifierProvider<AnimationSettingsNotifier, AnimationSettings>(
  (ref) => AnimationSettingsNotifier(),
);

