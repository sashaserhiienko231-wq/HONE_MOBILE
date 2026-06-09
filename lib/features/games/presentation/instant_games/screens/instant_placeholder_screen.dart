import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/instant_game.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class InstantPlaceholderScreen extends StatefulWidget {
  final InstantGame game;

  const InstantPlaceholderScreen({super.key, required this.game});

  @override
  State<InstantPlaceholderScreen> createState() =>
      _InstantPlaceholderScreenState();
}

class _InstantPlaceholderScreenState extends State<InstantPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    GamingHubStorage.recordGameLaunch(widget.game.id);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF060913), Color(0xFF111427)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                ),
                const Spacer(),
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: AppTheme.neonPurple.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: AppTheme.neonPurple.withValues(alpha: 0.28),
                    ),
                  ),
                  child:
                      Icon(game.icon, color: AppTheme.neonPurple, size: 34.w),
                ),
                SizedBox(height: 22.h),
                Text(
                  game.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  game.description,
                  style: TextStyle(color: Colors.white60, fontSize: 14.sp),
                ),
                SizedBox(height: 22.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _MetaChip(
                        label: game.category, icon: Icons.category_outlined),
                    _MetaChip(
                      label: '${game.achievements.length} achievements',
                      icon: Icons.emoji_events_outlined,
                    ),
                    _MetaChip(
                      label: '${game.statistics.length} stats',
                      icon: Icons.query_stats_outlined,
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.sports_esports_outlined),
                    label: const Text('Back to Hub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetaChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: AppTheme.neonPurple),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
