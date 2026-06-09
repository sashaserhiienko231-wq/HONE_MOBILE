// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GamingSettingsPage extends StatefulWidget {
  const GamingSettingsPage({super.key});

  @override
  State<GamingSettingsPage> createState() => _GamingSettingsPageState();
}

class _GamingSettingsPageState extends State<GamingSettingsPage> {
  // Settings values (some stored, some mocked statefully)
  bool _syncAccount = true;
  bool _autoRefresh = true;
  bool _hubOnly = true; // Show game apps in Gaming Hub only
  bool _allowPromos = true;
  bool _allowNotifs = true;
  bool _dndGame = true;
  String _autoPlayMode = 'Wi-Fi only';

  late String _username;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    _username = GamingHubStorage.getUsername();
    _avatar = GamingHubStorage.getAvatarEmoji();
  }

  void _resetData() async {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gaming Hub Data?'),
        content: const Text('This will delete all bookmarks, notifications, custom game configurations, and profile stats. Your system apps will remain untouched.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await GamingHubStorage.clearAllData();
              if (!mounted) return;
              setState(() {
                _username = GamingHubStorage.getUsername();
                _avatar = GamingHubStorage.getAvatarEmoji();
              });
              messenger.showSnackBar(
                const SnackBar(content: Text('All data successfully deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0E1A),
              AppTheme.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Settings List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  children: [
                    SizedBox(height: 16.h),

                    // Samsung Account Banner
                    _buildAccountCard(),

                    SizedBox(height: 24.h),

                    // Display section
                    _buildSectionHeader('DISPLAY & GAME BOOSTER'),
                    _buildSettingsCard([
                      _buildSwitchTile('Auto Refresh Rate Boost', 'Automatically switch to high refresh rates in games.', _autoRefresh, (v) {
                        setState(() => _autoRefresh = v);
                      }),
                      const Divider(),
                      _buildSwitchTile('Show game apps in Hub only', 'Hide game icons from the normal Apps drawer so they only appear inside the Gaming Hub.', _hubOnly, (v) {
                        setState(() => _hubOnly = v);
                      }),
                    ]),

                    SizedBox(height: 24.h),

                    // Notifications section
                    _buildSectionHeader('NOTIFICATION PARAMETERS'),
                    _buildSettingsCard([
                      _buildSwitchTile('Enable Gaming Notifications', 'Get alerts about game performance boosts and achievements.', _allowNotifs, (v) {
                        setState(() => _allowNotifs = v);
                      }),
                      const Divider(),
                      _buildSwitchTile('Promotional Campaigns', 'Receive news about community events and instant game promos.', _allowPromos, (v) {
                        setState(() => _allowPromos = v);
                      }),
                    ]),

                    SizedBox(height: 24.h),

                    // Privacy section
                    _buildSectionHeader('PRIVACY & PERMISSIONS'),
                    _buildSettingsCard([
                      _buildSwitchTile('Do Not Disturb in Games', 'Block floating banners, alerts, and calls during full-screen gaming.', _dndGame, (v) {
                        setState(() => _dndGame = v);
                      }),
                      const Divider(),
                      _buildSwitchTile('Sync Profile with Samsung Cloud', 'Automatically back up statistics, playtime logs, and badges.', _syncAccount, (v) {
                        setState(() => _syncAccount = v);
                      }),
                    ]),

                    SizedBox(height: 24.h),

                    // Advanced / Connectivity Section
                    _buildSectionHeader('AUTO-PLAY PARAMETERS'),
                    _buildSettingsCard([
                      _buildNavigationTile('Auto-play over Mobile Data', _autoPlayMode, () {
                        _showAutoPlayDialog();
                      }),
                    ]),

                    SizedBox(height: 24.h),

                    // Support Section
                    _buildSectionHeader('HELP & SUPPORT'),
                    _buildSettingsCard([
                      _buildNavigationTile('Help & FAQs', 'Online guides and help manual', () {
                        _showInfoDialog('Help Center', 'Connect to Samsung Mobile support database: https://support.samsung.com/gaminghub');
                      }),
                      const Divider(),
                      _buildNavigationTile('About Gaming Hub', 'Version 6.2.09.12 (Production Ready)', () {
                        _showInfoDialog('About Hub', 'Samsung Gaming Hub Integration Layer\nHone Mobile Engine v1.0.0\nRunning: 60fps stable UI thread.');
                      }),
                    ]),

                    SizedBox(height: 24.h),

                    // Dangerous Zone
                    _buildSectionHeader('DATA MANAGEMENT'),
                    _buildSettingsCard([
                      ListTile(
                        title: const Text('Wipe Local Data', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Delete bookmarks, notifications, stats, and configs.', style: TextStyle(color: Colors.white30, fontSize: 11)),
                        trailing: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onTap: _resetData,
                      ),
                    ]),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          SizedBox(width: 8.w),
          Text(
            'GAMING HUB SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _avatar,
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Samsung Account Connected',
                  style: TextStyle(color: Colors.purple[200], fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.sync, color: AppTheme.neonPurple),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 10.sp, height: 1.3)),
      activeThumbColor: AppTheme.neonPurple,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  Widget _buildNavigationTile(String title, String trailingValue, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailingValue, style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
          SizedBox(width: 8.w),
          const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 12),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      onTap: onTap,
    );
  }

  void _showAutoPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Auto-play games media'),
        backgroundColor: AppTheme.cardDark,
        children: [
          _buildRadioOption('Always'),
          _buildRadioOption('Wi-Fi only'),
          _buildRadioOption('Never'),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String val) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _autoPlayMode = val;
        });
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Radio<String>(
            value: val,
            groupValue: _autoPlayMode,
            activeColor: AppTheme.neonPurple,
            onChanged: (v) {
              setState(() {
                _autoPlayMode = v!;
              });
              Navigator.pop(context);
            },
          ),
          Text(val, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
