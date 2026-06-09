import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/app/providers/settings_providers.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';

class AdvancedGameGrid extends ConsumerStatefulWidget {
  const AdvancedGameGrid({super.key});

  @override
  ConsumerState<AdvancedGameGrid> createState() => _AdvancedGameGridState();
}

class _AdvancedGameGridState extends ConsumerState<AdvancedGameGrid> {
  String _selectedCategory = 'All Games';

  final List<GameInfo> _games = [
    GameInfo(name: 'PUBG Mobile', category: 'FPS', color: AppTheme.neonOrange, score: 98, lastPlayed: '2h ago'),
    GameInfo(name: 'Genshin Impact', category: 'RPG', color: AppTheme.neonBlue, score: 92, lastPlayed: '5h ago'),
    GameInfo(name: 'Mobile Legends', category: 'MOBA', color: AppTheme.neonGreen, score: 95, lastPlayed: '1d ago'),
    GameInfo(name: 'Call of Duty', category: 'FPS', color: AppTheme.accentRed, score: 99, lastPlayed: '3h ago'),
    GameInfo(name: 'Minecraft', category: 'RPG', color: AppTheme.neonPurple, score: 88, lastPlayed: '2d ago'),
    GameInfo(name: 'Fortnite', category: 'FPS', color: AppTheme.neonBlue, score: 94, lastPlayed: '1w ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(performanceStatsProvider).value ?? PerformanceStats.empty;
    final settings = ref.watch(settingsProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildCategories(),
            const SizedBox(height: 32),
            Expanded(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildGameGrid(),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: _buildOptimizationSidebar(stats, settings),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildOptimizationSidebar(stats, settings),
                        const SizedBox(height: 32),
                        Expanded(
                          child: _buildGameGrid(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gaming Hub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Enterprise-grade gaming optimization and library management',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionIcon(Icons.search),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('ADD GAME PROFILE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, color: Colors.white70),
    );
  }

  Widget _buildCategories() {
    final categories = ['All Games', 'Recent', 'Favorites', 'Optimized', 'High Performance'];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = categories[index]),
              backgroundColor: AppTheme.surfaceDark,
              selectedColor: AppTheme.neonGreen.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.neonGreen : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.neonGreen : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 32,
        crossAxisSpacing: 32,
        childAspectRatio: 0.85,
      ),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        return _buildGameCard(_games[index]);
      },
    );
  }

  Widget _buildGameCard(GameInfo game) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: game.color.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [game.color.withValues(alpha: 0.2), game.color.withValues(alpha: 0.05)],
                      ),
                    ),
                    child: Icon(Icons.sports_esports, size: 80, color: game.color.withValues(alpha: 0.3)),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: AppTheme.neonGreen, size: 16),
                          Text(' ${game.score}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last played ${game.lastPlayed}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: AppTheme.primaryDark,
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('LAUNCH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      _buildSmallIconButton(Icons.settings),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, color: Colors.white54, size: 20),
    );
  }

  Widget _buildOptimizationSidebar(PerformanceStats stats, Map<String, bool> settings) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Engine Live Tuning', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildToggleSetting('Adaptive GPU', settings['game_mode'] ?? true, () => ref.read(settingsProvider.notifier).toggleSetting('game_mode')),
          _buildToggleSetting('Kill Bg Tasks', settings['auto_optimization'] ?? true, () => ref.read(settingsProvider.notifier).toggleSetting('auto_optimization')),
          _buildToggleSetting('Latency Guard', true, () {}),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 32),
          const Text('Real-time Metrics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildProgressStat('CPU Load', stats.cpuUsage / 100, AppTheme.neonGreen),
          _buildProgressStat('MEM Scrub', stats.memoryUsage / 100, AppTheme.neonBlue),
          _buildProgressStat('Heat Index', (stats.cpuUsage / 100).clamp(0.1, 0.9), AppTheme.neonOrange),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => ref.read(optimizationProvider.notifier).runFullOptimization(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen.withValues(alpha: 0.1),
                foregroundColor: AppTheme.neonGreen,
                side: const BorderSide(color: AppTheme.neonGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('GLOBAL OPTIMIZE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String label, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Switch.adaptive(value: value, onChanged: (_) => onToggle(), activeThumbColor: AppTheme.neonGreen),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class GameInfo {
  final String name;
  final String category;
  final Color color;
  final int score;
  final String lastPlayed;
  GameInfo({required this.name, required this.category, required this.color, required this.score, required this.lastPlayed});
}
