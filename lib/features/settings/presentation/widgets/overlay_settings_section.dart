import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class OverlaySettingsSection extends ConsumerWidget {
  const OverlaySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = ref.watch(overlaySettingsProvider);
    final notifier = ref.read(overlaySettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gaming Overlay', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              children: [
                _toggleItem(
                  title: 'Enable Overlay',
                  subtitle: 'Show gaming overlay globally',
                  icon: Icons.gamepad,
                  color: AppTheme.neonPurple,
                  value: overlay.enabled,
                  onToggle: () => notifier.setEnabled(!overlay.enabled),
                ),
                _toggleItem(
                  title: 'Auto show during games',
                  subtitle: 'Automatically show overlay when a game launches',
                  icon: Icons.play_circle_fill,
                  color: AppTheme.neonBlue,
                  value: overlay.autoShowDuringGames,
                  onToggle: () => notifier.setAutoShowDuringGames(!overlay.autoShowDuringGames),
                ),
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visibility', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                      Slider(
                        value: overlay.opacity,
                        min: 0.2,
                        max: 1.0,
                        onChanged: (v) => notifier.setOpacity(v),
                        activeColor: AppTheme.neonGreen,
                      ),
                      SizedBox(height: 8.h),
                      Text('Size', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                      Slider(
                        value: overlay.size.width.clamp(160.0, 420.0),
                        min: 160,
                        max: 420,
                        onChanged: (v) => notifier.setSize(Size(v, overlay.size.height)),
                        activeColor: AppTheme.neonGreen,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Column(
                    children: [
                      _moduleToggle('Show FPS', 'fps', overlay, notifier),
                      _moduleToggle('Show RAM', 'ram', overlay, notifier),
                      _moduleToggle('Show CPU', 'cpu', overlay, notifier),
                      _moduleToggle('Show Temperature', 'temp', overlay, notifier),
                      _moduleToggle('Show Battery', 'battery', overlay, notifier),
                      _moduleToggle('Show Ping', 'ping', overlay, notifier),
                      _moduleToggle('Show DNS Status', 'dns', overlay, notifier),
                      _moduleToggle('Show Current Profile', 'profile', overlay, notifier),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleItem({required String title, required String subtitle, required IconData icon, required Color color, required bool value, required VoidCallback onToggle}) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(icon, color: color, size: 22.w)),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)), Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 12.sp))])),
            Switch.adaptive(value: value, onChanged: (_) => onToggle(), activeThumbColor: AppTheme.neonGreen, activeTrackColor: AppTheme.neonGreen.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _moduleToggle(String title, String key, OverlaySettings overlay, OverlaySettingsNotifier notifier) {
    final enabled = overlay.modules[key] ?? false;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
          Switch.adaptive(value: enabled, onChanged: (v) => notifier.setModuleEnabled(key, v), activeThumbColor: AppTheme.neonGreen),
        ],
      ),
    );
  }
}
