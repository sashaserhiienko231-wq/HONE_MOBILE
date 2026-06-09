import 'package:flutter/material.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';

/// Animates a numeric value from [begin] to [end] with count-up effect.
class AnimatedMetric extends StatelessWidget {
  const AnimatedMetric({
    super.key,
    required this.value,
    required this.settings,
    this.fractionDigits = 0,
    this.suffix = '',
    this.style,
  });

  final double value;
  final AnimationSettings settings;
  final int fractionDigits;
  final String suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!settings.enabled || settings.reduceMotion) {
      return Text(
        '${value.toStringAsFixed(fractionDigits)}$suffix',
        style: style,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: settings.premiumMode ? AnimationPresets.premium : AnimationPresets.normal,
      curve: AnimationPresets.easeOutCubic,
      builder: (_, v, __) => Text(
        '${v.toStringAsFixed(fractionDigits)}$suffix',
        style: style,
      ),
    );
  }
}

/// Animates a progress bar width from 0 to [fraction].
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    required this.settings,
    this.height = 6.0,
    this.borderRadius = 3.0,
    this.background,
  });

  final double fraction;
  final Color color;
  final AnimationSettings settings;
  final double height;
  final double borderRadius;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final duration = (!settings.enabled || settings.reduceMotion)
        ? Duration.zero
        : (settings.premiumMode ? AnimationPresets.premium : AnimationPresets.normal);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? Colors.white10,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: AnimatedFractionallySizedBox(
        widthFactor: fraction.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        duration: duration,
        curve: AnimationPresets.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
