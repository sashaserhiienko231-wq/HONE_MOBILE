import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/settings_providers.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/settings/presentation/widgets/language_settings_section.dart';
import 'package:hone_mobile/features/settings/presentation/widgets/overlay_settings_section.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';
import 'package:hone_mobile/shared/widgets/app_version_section.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryDark,
            AppTheme.secondaryDark,
            AppTheme.surfaceDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              title: AppLocalizations.of(context).settingsTitle,
              subtitle: AppLocalizations.of(context).settingsSubtitle,
              applySafeArea: false,
            ),
            Expanded(
              child: settingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.neonGreen),
                ),
                error: (e, _) => _SettingsError(
                  message: e.toString(),
                  onRetry: () => settingsNotifier.reload(),
                ),
                data: (settings) => _SettingsBody(
                  settings: settings,
                  onToggle: settingsNotifier.toggleSetting,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.accentRed, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Could not load settings',
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
            SizedBox(height: 24.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.settings, required this.onToggle});

  final Map<String, bool> settings;
  final Future<void> Function(String key) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          const AppVersionSection(),
          SizedBox(height: 24.h),
          const LanguageSettingsSection(),
          SizedBox(height: 24.h),
          _SettingsSection(
            title: l10n.optimizationSettings,
            children: [
              _SettingsItem(
                title: 'Auto-Optimization',
                subtitle: 'Automatically optimize system performance',
                icon: Icons.auto_fix_high,
                color: AppTheme.neonGreen,
                value: settings['auto_optimization'],
                onToggle: () => onToggle('auto_optimization'),
              ),
              _SettingsItem(
                title: 'Background Monitoring',
                subtitle: 'Monitor performance in background',
                icon: Icons.monitor,
                color: AppTheme.neonBlue,
                value: settings['background_monitoring'],
                onToggle: () => onToggle('background_monitoring'),
              ),
              _SettingsItem(
                title: 'Game Mode',
                subtitle: 'Auto-enable optimizations when gaming',
                icon: Icons.videogame_asset,
                color: AppTheme.neonOrange,
                value: settings['game_mode'],
                onToggle: () => onToggle('game_mode'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _SettingsSection(
            title: 'Performance Settings',
            children: [
              _SettingsItem(
                title: 'Performance Alerts',
                subtitle: 'Get notified of performance issues',
                icon: Icons.notifications_active,
                color: AppTheme.neonPurple,
                value: settings['performance_alerts'],
                onToggle: () => onToggle('performance_alerts'),
              ),
              _SettingsItem(
                title: 'Temperature Alerts',
                subtitle: 'Alert when device gets too hot',
                icon: Icons.thermostat,
                color: AppTheme.accentRed,
                value: settings['thermal_alerts'],
                onToggle: () => onToggle('thermal_alerts'),
              ),
              _SettingsItem(
                title: 'Battery Alerts',
                subtitle: 'Alert when battery is low',
                icon: Icons.battery_alert,
                color: AppTheme.accentGreen,
                value: settings['battery_alerts'],
                onToggle: () => onToggle('battery_alerts'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _SettingsSection(
            title: 'Home Screen Widgets',
            children: [
              _SettingsItem(
                title: 'Enable Widgets',
                subtitle: 'Update launcher performance widgets',
                icon: Icons.widgets_outlined,
                color: AppTheme.neonGreen,
                value: settings['home_widgets_enabled'],
                onToggle: () => onToggle('home_widgets_enabled'),
              ),
              _SettingsItem(
                title: 'Performance Widget',
                subtitle: 'CPU, RAM, temperature',
                icon: Icons.speed,
                color: AppTheme.neonBlue,
                value: settings['widget_performance_enabled'],
                onToggle: () => onToggle('widget_performance_enabled'),
              ),
              _SettingsItem(
                title: 'FPS Widget',
                subtitle: 'Live frame rate',
                icon: Icons.show_chart,
                color: AppTheme.neonPurple,
                value: settings['widget_fps_enabled'],
                onToggle: () => onToggle('widget_fps_enabled'),
              ),
              _SettingsItem(
                title: 'Gaming Mode Widget',
                subtitle: 'Quick gaming mode status',
                icon: Icons.sports_esports,
                color: AppTheme.neonOrange,
                value: settings['widget_gaming_mode_enabled'],
                onToggle: () => onToggle('widget_gaming_mode_enabled'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const OverlaySettingsSection(),
          SizedBox(height: 24.h),
          _SettingsSection(
            title: 'Appearance',
            children: [
              const _SettingsItem(
                title: 'Dark Theme',
                subtitle: 'Use dark theme (always enabled)',
                icon: Icons.dark_mode,
                color: AppTheme.neonGreen,
                value: true,
                onToggle: null,
              ),
              _SettingsItem(
                title: 'Neon Effects',
                subtitle: 'Enable neon glow effects',
                icon: Icons.lightbulb_outline,
                color: AppTheme.neonBlue,
                value: settings['neon_effects'],
                onToggle: () => onToggle('neon_effects'),
              ),
              _SettingsItem(
                title: 'Animations',
                subtitle: 'Enable UI animations',
                icon: Icons.animation,
                color: AppTheme.neonOrange,
                value: settings['animations_enabled'],
                onToggle: () => onToggle('animations_enabled'),
              ),
              _SettingsItem(
                title: 'Premium Mode',
                subtitle: 'Enable flagship-quality motion',
                icon: Icons.auto_awesome,
                color: AppTheme.neonPurple,
                value: settings['animations_premium_mode'],
                onToggle: () => onToggle('animations_premium_mode'),
              ),
              _SettingsItem(
                title: 'Reduce Motion',
                subtitle: 'Minimize motion for comfort & performance',
                icon: Icons.accessibility_new,
                color: AppTheme.neonBlue,
                value: settings['animations_reduce_motion'],
                onToggle: () => onToggle('animations_reduce_motion'),
              ),
            ],
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool? value;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                ],
              ),
            ),
            if (value != null && onToggle != null)
              Switch.adaptive(
                value: value!,
                onChanged: (_) => onToggle!(),
                activeThumbColor: AppTheme.neonGreen,
                activeTrackColor: AppTheme.neonGreen.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
