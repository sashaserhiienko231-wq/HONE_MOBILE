
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/animations/motion_system.dart';

/// Central access point for animation configuration.
class AnimationManager {
  const AnimationManager({required this.settings});

  final AnimationSettings settings;

  MotionSystem get motion => MotionSystem(settings: settings);

  /// Lightweight helper for widgets that need "premium" fade/scale values.
  ///
  /// If animations are disabled or reduced motion is enabled, returns values
  /// that effectively disable motion.
  double easedScaleForSelected({double premiumScale = 1.15}) {
    if (!settings.enabled || settings.reduceMotion) return 1.0;
    return settings.premiumMode ? premiumScale : 1.1;
  }
}

