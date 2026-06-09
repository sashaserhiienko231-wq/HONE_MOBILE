import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/widgets/premium_animations/animated_metric.dart';

class AchievementCenterPage extends ConsumerStatefulWidget {
  const AchievementCenterPage({super.key});

  @override
  ConsumerState<AchievementCenterPage> createState() => _AchievementCenterPageState();
}

class _AchievementCenterPageState extends ConsumerState<AchievementCenterPage>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;

  static const _achievements = [
    _Achievement('First Win', 'Win your first match', 1.0, true, Icons.emoji_events),
    _Achievement('Marathon', 'Play for 10 hours total', 0.6, false, Icons.timer),
    _Achievement('Collector', 'Unlock 50 items', 0.3, false, Icons.category),
    _Achievement('Speedster', 'Complete a game in under 2 mins', 0.0, false, Icons.bolt),
    _Achievement('Champion', 'Reach top 10 on leaderboard', 0.85, false, Icons.leaderboard),
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: animEnabled
          ? Duration(milliseconds: 200 + _achievements.length * 100)
          : Duration.zero,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (animEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entranceCtrl.forward();
        _pulseCtrl.repeat(reverse: true);
      });
    } else {
      _entranceCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievement Center')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _achievements.length,
        itemBuilder: (context, i) {
          final a = _achievements[i];
          final start = (i * 0.15).clamp(0.0, 1.0);
          final end = (start + 0.5).clamp(0.0, 1.0);

          final fadeAnim = animEnabled
              ? CurvedAnimation(
                  parent: _entranceCtrl,
                  curve: Interval(start, end, curve: Curves.easeOut),
                )
              : const AlwaysStoppedAnimation(1.0);

          final slideAnim = animEnabled
              ? Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
                  CurvedAnimation(
                    parent: _entranceCtrl,
                    curve: Interval(start, end, curve: AnimationPresets.easeOutCubic),
                  ),
                )
              : const AlwaysStoppedAnimation(Offset.zero);

          return FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AchievementCard(
                  achievement: a,
                  settings: settings,
                  pulseCtrl: a.unlocked && animEnabled ? _pulseCtrl : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final AnimationSettings settings;
  final AnimationController? pulseCtrl;

  const _AchievementCard({
    required this.achievement,
    required this.settings,
    this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final color = achievement.unlocked ? AppTheme.neonGreen : Colors.white38;

    Widget card = Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(achievement.icon,
                  color: achievement.unlocked ? AppTheme.neonGreen : Colors.white38),
              title: Text(achievement.title),
              subtitle: Text(achievement.desc),
              trailing: achievement.unlocked
                  ? const Icon(Icons.check_circle, color: AppTheme.neonGreen)
                  : const Icon(Icons.lock_outline, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            AnimatedProgressBar(
              fraction: achievement.progress,
              color: color,
              settings: settings,
              height: 5,
              borderRadius: 2.5,
            ),
            const SizedBox(height: 4),
            Text(
              '${(achievement.progress * 100).toInt()}%',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    if (pulseCtrl == null) return card;

    return AnimatedBuilder(
      animation: pulseCtrl!,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withValues(
                alpha: 0.08 + pulseCtrl!.value * 0.12,
              ),
              blurRadius: 8 + pulseCtrl!.value * 12,
              spreadRadius: pulseCtrl!.value * 2,
            ),
          ],
        ),
        child: child,
      ),
      child: card,
    );
  }
}

class _Achievement {
  final String title;
  final String desc;
  final double progress;
  final bool unlocked;
  final IconData icon;

  const _Achievement(this.title, this.desc, this.progress, this.unlocked, this.icon);
}
