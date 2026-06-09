

import 'package:flutter/widgets.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';

/// Central motion behavior switch.
///
/// - Reduced motion: minimize animation or remove non-essential effects.
/// - Premium mode: use higher-fidelity curves/durations.
/// - Enabled: allow animations.
class MotionSystem {
  const MotionSystem({required this.settings});

  final AnimationSettings settings;

  bool get animationsEnabled => settings.enabled;

  bool get reduceMotion => settings.reduceMotion;

  bool get premiumMode => settings.premiumMode;

  /// Returns duration to use for route transitions / lightweight UI motion.
  Duration durationFor({Duration? fallback}) {
    if (!animationsEnabled || reduceMotion) {
      return fallback ?? AnimationPresets.fast;
    }

    if (premiumMode) return AnimationPresets.premium;
    return AnimationPresets.normal;
  }

  /// Returns curve to use for route transitions / lightweight UI motion.
  Curve curveFor() {
    if (!animationsEnabled || reduceMotion) {
      return Curves.easeOut;
    }

    return premiumMode ? AnimationPresets.easeOutQuart : AnimationPresets.easeOutCubic;
  }

  /// Scale factor used for "selected" states, nav bounce, etc.
  double navSelectedScale() {
    if (!animationsEnabled || reduceMotion) return 1.0;
    return premiumMode ? 1.15 : 1.1;
  }
}

