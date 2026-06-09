import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';

/// A small draggable, resizable gaming overlay showing key telemetry.
class GamingOverlay extends ConsumerStatefulWidget {
  const GamingOverlay({super.key});

  @override
  ConsumerState<GamingOverlay> createState() => _GamingOverlayState();
}

class _GamingOverlayState extends ConsumerState<GamingOverlay>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  Timer? _hideTimer;

  // Smoothed metric values for interpolation
  double _smoothFps = 0;
  double _smoothRam = 0;
  double _smoothCpu = 0;
  double _smoothPing = 0;

  late AnimationController _visibilityCtrl;
  late Animation<double> _fadeScale;

  bool _wasEnabled = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _visibilityCtrl = AnimationController(
      vsync: this,
      duration: animEnabled ? AnimationPresets.normal : Duration.zero,
    );
    _fadeScale = CurvedAnimation(
      parent: _visibilityCtrl,
      curve: AnimationPresets.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _visibilityCtrl.dispose();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      ref.read(overlaySettingsProvider.notifier).setMinimized(true);
    });
  }

  /// Lerp toward target with smoothing factor for metric interpolation.
  double _lerp(double current, double target) =>
      current + (target - current) * 0.25;

  @override
  Widget build(BuildContext context) {
    final perf = ref.watch(performanceStatsProvider).valueOrNull;
    final overlay = ref.watch(overlaySettingsProvider);
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    // Smooth metric interpolation
    if (perf != null) {
      _smoothFps = _lerp(_smoothFps, perf.fps);
      _smoothRam = _lerp(_smoothRam, perf.memoryUsage);
      _smoothCpu = _lerp(_smoothCpu, perf.cpuUsage);
      _smoothPing = _lerp(_smoothPing, perf.networkLatency);
    }

    // Animate show/hide when enabled toggles
    if (overlay.enabled && !_wasEnabled) {
      _visibilityCtrl.forward();
      _wasEnabled = true;
    } else if (!overlay.enabled && _wasEnabled) {
      _visibilityCtrl.reverse();
      _wasEnabled = false;
    }

    final left = overlay.position.dx + _dragOffset.dx;
    final top = overlay.position.dy + _dragOffset.dy;
    final screen = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top + 8;
    final safeBottom = screen.height - (kToolbarHeight + 64);
    final clampedLeft = left.clamp(8.0, screen.width - overlay.size.width - 8.0);
    final clampedTop = top.clamp(safeTop, safeBottom - overlay.size.height);

    if (!overlay.enabled) return const SizedBox.shrink();

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: GestureDetector(
        onPanStart: (_) => _hideTimer?.cancel(),
        onPanUpdate: (d) => setState(() => _dragOffset += d.delta),
        onPanEnd: (_) {
          ref.read(overlaySettingsProvider.notifier)
              .setPosition(Offset(clampedLeft, clampedTop));
          setState(() => _dragOffset = Offset.zero);
          _resetHideTimer();
        },
        onTap: _resetHideTimer,
        child: FadeTransition(
          opacity: _fadeScale,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(_fadeScale),
            alignment: Alignment.topLeft,
            child: AnimatedContainer(
              duration: animEnabled ? AnimationPresets.normal : Duration.zero,
              curve: AnimationPresets.easeOutCubic,
              width: overlay.minimized ? 56.0 : overlay.size.width,
              height: overlay.minimized ? 56.0 : overlay.size.height,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: overlay.opacity * 255.0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.neonPurple.withValues(alpha: 72.0)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPurple.withValues(alpha: 15.0),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: animEnabled ? AnimationPresets.fast : Duration.zero,
                child: overlay.minimized
                    ? _buildMinimized()
                    : _buildExpanded(perf, overlay.modules),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimized() {
    return SizedBox(
      key: const ValueKey('minimized'),
      width: 56,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 92.0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 51.0)),
        ),
        child: IconButton(
          icon: const Icon(Icons.gamepad, color: Colors.white),
          onPressed: () =>
              ref.read(overlaySettingsProvider.notifier).setMinimized(false),
        ),
      ),
    );
  }

  Widget _buildExpanded(perf, Map<String, bool> modules) {
    final fps = _smoothFps > 0 ? _smoothFps.toStringAsFixed(0) : '--';
    final ram = _smoothRam > 0 ? '${_smoothRam.toStringAsFixed(0)}%' : '--';
    final cpu = _smoothCpu > 0 ? '${_smoothCpu.toStringAsFixed(0)}%' : '--';
    final ping = _smoothPing > 0 ? '${_smoothPing.toStringAsFixed(0)} ms' : '--';
    final temp = perf?.thermalState != null ? perf!.thermalState.name : '--';
    final battery = perf?.batteryLevel != null ? '${perf!.batteryLevel}%' : '--';
    final dns = perf != null ? perf.networkStatus : '--';

    return Row(
      key: const ValueKey('expanded'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatsColumn(modules, fps, ram, cpu, ping, temp, battery, dns),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _controlButton(Icons.remove,
                () => ref.read(overlaySettingsProvider.notifier).setMinimized(true)),
            const SizedBox(height: 6),
            _controlButton(Icons.close,
                () => ref.read(overlaySettingsProvider.notifier).setEnabled(false)),
          ],
        ),
        GestureDetector(
          onPanUpdate: (e) {
            final newW = (ref.read(overlaySettingsProvider).size.width + e.delta.dx)
                .clamp(160.0, MediaQuery.of(context).size.width - 32.0);
            ref
                .read(overlaySettingsProvider.notifier)
                .setSize(Size(newW, ref.read(overlaySettingsProvider).size.height));
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.drag_handle, color: Colors.white24, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsColumn(Map<String, bool> modules, String fps, String ram,
      String cpu, String ping, String temp, String battery, String dns) {
    final rows = <Widget>[];
    if (modules['fps'] == true) rows.add(_statRow('FPS', fps, AppTheme.neonPurple));
    if (modules['ram'] == true) rows.addAll([const SizedBox(height: 6), _statRow('RAM', ram, AppTheme.neonBlue)]);
    if (modules['cpu'] == true) rows.addAll([const SizedBox(height: 6), _statRow('CPU', cpu, AppTheme.neonGreen)]);
    if (modules['temp'] == true) rows.addAll([const SizedBox(height: 6), _statRow('Temp', temp, AppTheme.accentRed)]);
    if (modules['battery'] == true) rows.addAll([const SizedBox(height: 6), _statRow('Batt', battery, AppTheme.accentGreen)]);
    if (modules['ping'] == true) rows.addAll([const SizedBox(height: 6), _statRow('Ping', ping, AppTheme.neonBlue)]);
    if (modules['dns'] == true) rows.addAll([const SizedBox(height: 6), _statRow('DNS', dns, AppTheme.neonPurple)]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                value,
                key: ValueKey(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 92.0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }
}
