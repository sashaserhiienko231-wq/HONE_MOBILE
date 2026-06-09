import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class TabletHomePage extends ConsumerWidget {
  const TabletHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        _buildQuickBoost(),
                        const SizedBox(height: 16),
                        _buildDnsBoost(),
                        const SizedBox(height: 16),
                        _buildPerformanceWidget(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Center Panel (Games)
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Games', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _buildGamesGrid(2),
                        ),
                        const SizedBox(height: 24),
                        const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildGamesGrid(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Panel (System Status)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildSystemStatusWidget('RAM Usage', '45%', AppTheme.neonBlue, Icons.memory),
                        const SizedBox(height: 16),
                        _buildSystemStatusWidget('Storage', '128 GB Free', AppTheme.neonGreen, Icons.storage),
                        const SizedBox(height: 16),
                        _buildSystemStatusWidget('Network', '24 ms Ping', AppTheme.neonPurple, Icons.wifi),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildQuickBoost()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDnsBoost()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPerformanceWidget()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Recent Games', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildGamesGrid(2),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildSystemStatusWidget('RAM Usage', '45%', AppTheme.neonBlue, Icons.memory)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSystemStatusWidget('Storage', '128 GB Free', AppTheme.neonGreen, Icons.storage)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSystemStatusWidget('Network', '24 ms Ping', AppTheme.neonPurple, Icons.wifi)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: _buildGamesGrid(4),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.neonGreen,
            child: Icon(Icons.person, color: AppTheme.primaryDark),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gamer_007', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Level 42', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBoost() {
    return _buildPanelCard('Quick Boost', 'Optimize RAM & CPU', Icons.rocket_launch, AppTheme.neonOrange);
  }

  Widget _buildDnsBoost() {
    return _buildPanelCard('DNS Boost', 'Lower Ping', Icons.dns, AppTheme.neonPurple);
  }

  Widget _buildPerformanceWidget() {
    return _buildPanelCard('Performance', 'View Telemetry', Icons.speed, AppTheme.neonGreen);
  }

  Widget _buildPanelCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusWidget(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(int count) {
    return GridView.builder(
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://via.placeholder.com/150'), // Placeholder
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: const Center(
            child: Text('Game Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
