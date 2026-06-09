import 'package:flutter/material.dart';

import 'package:hone_mobile/core/animations/animation_presets.dart';

class RevealStagger extends StatelessWidget {
  const RevealStagger({
    super.key,
    required this.child,
    required this.index,
    this.total = 6,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final int index;
  final int total;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AnimationPresets.normal,
      curve: AnimationPresets.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, t, _) {
        final localT = (t * 1.0).clamp(0.0, 1.0);

        final opacity = localT;
        final translate = (1 - localT) * 16;
        final scaleValue = 0.98 + (localT * 0.02);

        final transform = axis == Axis.vertical
            ? (Matrix4.translationValues(0, translate, 0)
              ..multiply(Matrix4.diagonal3Values(scaleValue, scaleValue, 1.0)))
            : (Matrix4.translationValues(translate, 0, 0)
              ..multiply(Matrix4.diagonal3Values(scaleValue, scaleValue, 1.0)));

        return Opacity(
          opacity: opacity,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}
