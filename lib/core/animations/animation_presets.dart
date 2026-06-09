import 'package:flutter/animation.dart';

/// Curves used across the app.
///
/// Keep these as simple statics so they can be reused without allocations.
class AnimationPresets {
  const AnimationPresets._();

  // 250-350ms target, used by default.
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration premium = Duration(milliseconds: 320);

  // EaseOutCubic / EaseOutQuart equivalents.
  static const Curve easeOutCubic = Cubic(0.215, 0.61, 0.355, 1.0);
  // quart: roughly matches an ease-out quart (0,1) -> (1) curve.
  // Flutter doesn't ship "easeOutQuart" by name, so we approximate with a cubic.
  static const Curve easeOutQuart = Cubic(0.165, 0.84, 0.44, 1.0);
}

