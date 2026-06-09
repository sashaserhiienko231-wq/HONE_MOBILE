import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/game_info.dart';

/// Animated game card with hover, tap, press, and release effects
/// Respects Reduce Motion settings
class AnimatedGameCard extends ConsumerStatefulWidget {
  final GameInfo game;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isPinned;
  final bool isFavorite;
  final Widget? trailing;

  const AnimatedGameCard({
    super.key,
    required this.game,
    this.onTap,
    this.onLongPress,
    this.isPinned = false,
    this.isFavorite = false,
    this.trailing,
  });

  @override
  ConsumerState<AnimatedGameCard> createState() => _AnimatedGameCardState();
}

class _AnimatedGameCardState extends ConsumerState<AnimatedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final enabled = settings.enabled && !settings.reduceMotion;
    final duration =
        enabled ? const Duration(milliseconds: 200) : Duration.zero;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final settings = ref.read(animationSettingsProvider);
    if (settings.enabled && !settings.reduceMotion) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final settings = ref.read(animationSettingsProvider);
    if (settings.enabled && !settings.reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    final settings = ref.read(animationSettingsProvider);
    if (settings.enabled && !settings.reduceMotion) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(animationSettingsProvider);
    final enabled = settings.enabled && !settings.reduceMotion;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: enabled ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: widget.isPinned
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.04),
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: AppTheme.neonPurple.withValues(
                            alpha: 0.2 * _glowAnimation.value,
                          ),
                          blurRadius: 10 * _shadowAnimation.value,
                          offset: Offset(0, 4 * _shadowAnimation.value),
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text('🎮', style: TextStyle(fontSize: 20.sp)),
                ),
                if (widget.isPinned)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.push_pin, size: 10.sp, color: Colors.black),
                  ),
                if (widget.isFavorite)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite,
                          size: 10.sp, color: Colors.white),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              widget.game.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              widget.game.category,
              style: TextStyle(color: Colors.white38, fontSize: 9.sp),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}
