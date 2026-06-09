import 'package:flutter/material.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';

/// Wraps a game card child with press / hover scale + glow animation.
class AnimatedGameCard extends StatefulWidget {
  const AnimatedGameCard({
    super.key,
    required this.child,
    required this.glowColor,
    required this.settings,
    this.onTap,
    this.onLongPress,
    this.borderRadius = 20.0,
  });

  final Widget child;
  final Color glowColor;
  final AnimationSettings settings;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;

  @override
  State<AnimatedGameCard> createState() => _AnimatedGameCardState();
}

class _AnimatedGameCardState extends State<AnimatedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimationPresets.fast,
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: AnimationPresets.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _animated =>
      widget.settings.enabled && !widget.settings.reduceMotion;

  void _onTapDown(TapDownDetails _) {
    if (_animated) _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_animated) _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (_animated) _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animated) {
      return GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: AnimatedContainer(
            duration: AnimationPresets.fast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: (1 - _scale.value) / 0.05 * 0.18,
                  ),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
