import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/app/providers/settings_providers.dart';
import 'package:hone_mobile/shared/widgets/app_version_section.dart';

class DesktopSettingsManager extends ConsumerStatefulWidget {
  const DesktopSettingsManager({super.key});

  @override
  ConsumerState<DesktopSettingsManager> createState() => _DesktopSettingsManagerState();
}

class _DesktopSettingsManagerState extends ConsumerState<DesktopSettingsManager> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'General', 'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings, 'key': 'general'},
    {'name': 'Gaming', 'icon': Icons.sports_esports_outlined, 'selectedIcon': Icons.sports_esports, 'key': 'gaming'},
    {'name': 'DNS Boost', 'icon': Icons.dns_outlined, 'selectedIcon': Icons.dns, 'key': 'dns_boost'},
    {'name': 'Widgets', 'icon': Icons.widgets_outlined, 'selectedIcon': Icons.widgets, 'key': 'widgets'},
    {'name': 'Performance', 'icon': Icons.speed_outlined, 'selectedIcon': Icons.speed, 'key': 'performance'},
    {'name': 'Notifications', 'icon': Icons.notifications_outlined, 'selectedIcon': Icons.notifications, 'key': 'notifications'},
    {'name': 'Language', 'icon': Icons.language_outlined, 'selectedIcon': Icons.language, 'key': 'language'},
    {'name': 'About', 'icon': Icons.info_outline, 'selectedIcon': Icons.info, 'key': 'about'},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enterprise Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildCategorySidebar(),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 2,
                    child: settingsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppTheme.neonGreen),
                      ),
                      error: (e, _) => Center(
                        child: Text('Settings error: $e', style: const TextStyle(color: Colors.white)),
                      ),
                      data: (settings) => _buildSettingsContent(settings, settingsNotifier),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedCategoryIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? _categories[index]['selectedIcon'] : _categories[index]['icon'],
                    color: isSelected ? AppTheme.neonGreen : Colors.white54,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _categories[index]['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsContent(Map<String, bool> settings, SettingsNotifier notifier) {
    final category = _categories[_selectedCategoryIndex]['key'];

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categories[_selectedCategoryIndex]['name'],
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            if (category == 'general') ...[
              _buildSettingSection('System Behavior'),
              _buildToggleSetting('Auto-Optimization', 'Automatically adjust settings based on load', settings['auto_optimization'] ?? false, () => notifier.toggleSetting('auto_optimization')),
              _buildToggleSetting('Background Monitoring', 'Keep telemetry active in background', settings['background_monitoring'] ?? false, () => notifier.toggleSetting('background_monitoring')),
            ],
            if (category == 'gaming') ...[
              _buildSettingSection('Gaming Features'),
              _buildToggleSetting('Game Mode', 'Prioritize game processes automatically', settings['game_mode'] ?? false, () => notifier.toggleSetting('game_mode')),
              _buildToggleSetting('In-Game Overlay', 'Show performance metrics during gameplay', settings['ingame_overlay'] ?? false, () => notifier.toggleSetting('ingame_overlay')),
            ],
            if (category == 'dns_boost') ...[
              _buildSettingSection('DNS Optimization'),
              _buildToggleSetting('Auto-Select DNS', 'Automatically choose fastest DNS server', settings['auto_dns'] ?? false, () => notifier.toggleSetting('auto_dns')),
              _buildToggleSetting('Aggressive Caching', 'Cache DNS responses longer for less latency', settings['dns_caching'] ?? false, () => notifier.toggleSetting('dns_caching')),
            ],
            if (category == 'widgets') ...[
              _buildSettingSection('Widget Settings'),
              _buildToggleSetting('Transparent Widgets', 'Make widgets partially transparent', settings['transparent_widgets'] ?? false, () => notifier.toggleSetting('transparent_widgets')),
              _buildToggleSetting('Auto-Arrange', 'Snap widgets to grid automatically', settings['auto_arrange'] ?? false, () => notifier.toggleSetting('auto_arrange')),
            ],
            if (category == 'performance') ...[
              _buildSettingSection('Performance Tuning'),
              _buildToggleSetting('Max Performance Mode', 'Remove thermal limits (Warning: device may get hot)', settings['max_perf'] ?? false, () => notifier.toggleSetting('max_perf')),
              _buildToggleSetting('Performance Alerts', 'Notify when system load is high', settings['performance_alerts'] ?? false, () => notifier.toggleSetting('performance_alerts')),
            ],
            if (category == 'notifications') ...[
              _buildSettingSection('Alert Settings'),
              _buildToggleSetting('Thermal Alerts', 'Alert when device exceeds safe temperature', settings['thermal_alerts'] ?? false, () => notifier.toggleSetting('thermal_alerts')),
              _buildToggleSetting('Battery Alerts', 'Alert on low battery thresholds', settings['battery_alerts'] ?? false, () => notifier.toggleSetting('battery_alerts')),
            ],
            if (category == 'language') ...[
              _buildSettingSection('Localization'),
              _buildInfoRow('Current Language', 'English (US)'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Change Language'),
              )
            ],
            if (category == 'about') ...[
              const AppVersionSection(compact: true),
              const SizedBox(height: 32),
              _buildSettingSection('System Maintenance'),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.accentRed,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: AppTheme.accentRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('FACTORY RESET ENGINE SETTINGS'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: AppTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String title, String subtitle, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: (_) => onToggle(), activeThumbColor: AppTheme.neonGreen),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
