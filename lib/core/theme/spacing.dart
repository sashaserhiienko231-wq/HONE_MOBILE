import 'package:flutter/material.dart';

/// Width-tier spacing for responsive layouts (plan breakpoints).
class AppSpacing {
  static double horizontalPadding(double width, {double scale = 1.0}) {
    if (width <= 480) return 16 * scale;
    if (width <= 720) return 20 * scale;
    if (width <= 900) return 24 * scale;
    if (width <= 1200) return 28 * scale;
    return 32 * scale;
  }

  static double sectionGap(double width, {double scale = 1.0}) {
    if (width <= 480) return 16 * scale;
    if (width <= 720) return 20 * scale;
    return 24 * scale;
  }

  static double gap(double width) => width < 360 ? 10 : 14;

  static double bottomScrollPadding(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return padding.bottom + 88;
  }
}
