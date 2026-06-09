import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:hone_mobile/features/optimizations/presentation/pages/optimizations_page.dart';
import 'package:hone_mobile/features/boost/presentation/pages/boost_page.dart';
import 'package:hone_mobile/features/games/presentation/pages/games_page.dart';
import 'package:hone_mobile/features/games/presentation/pages/game_details_page.dart';
import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/instant_game.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/bubble_shooter_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/chess_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/endless_runner_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/game_2048_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/instant_placeholder_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/snake_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/sudoku_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/tic_tac_toe_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/instant_games/screens/tetris_game_screen.dart';
import 'package:hone_mobile/features/games/presentation/pages/instant_game_player.dart';
import 'package:hone_mobile/features/premium/presentation/pages/premium_page.dart';
import 'package:hone_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:hone_mobile/features/analytics/presentation/pages/gaming_analytics_page.dart';
import 'package:hone_mobile/features/achievements/presentation/pages/achievement_center_page.dart';

import 'package:hone_mobile/features/backup/presentation/pages/backup_page.dart';
import 'package:hone_mobile/features/diagnostics/presentation/pages/diagnostics_page.dart';
import 'package:hone_mobile/features/dns_boost/presentation/pages/dns_boost_page.dart';
import 'package:hone_mobile/features/vpn_boost/presentation/pages/vpn_boost_page.dart';
import 'package:hone_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:hone_mobile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';
import 'package:hone_mobile/core/navigation/responsive_layout.dart';
import 'package:hone_mobile/features/tablet/widgets/tablet_sidebar.dart';
import 'package:hone_mobile/features/tablet/dashboard/tablet_home_page.dart';
import 'package:hone_mobile/features/tablet/widgets/tablet_widget_center.dart';
import 'package:hone_mobile/features/tablet/gaming/advanced_game_grid.dart'
    hide GameInfo;
import 'package:hone_mobile/features/tablet/optimization/optimization_panel.dart';
import 'package:hone_mobile/features/tablet/premium/premium_analytics_center.dart';
import 'package:hone_mobile/features/tablet/settings/desktop_settings_manager.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Widget _instantGameScreen(InstantGame game) {
    switch (game.id) {
      case '2048':
        return const Game2048Screen();
      case 'sudoku':
        return const SudokuGameScreen();
      case 'snake':
        return const SnakeGameScreen();
      case 'tictactoe':
        return const TicTacToeGameScreen();
      case 'space_shooter':
        return InstantGamePlayer(gameId: game.id, gameName: game.title);
      case 'tetris':
        return const TetrisGameScreen();
      case 'endless-runner':
        return const EndlessRunnerGameScreen();
      case 'bubble-shooter':
        return const BubbleShooterGameScreen();
      case 'chess':
        return const ChessGameScreen();
      default:
        return InstantPlaceholderScreen(game: game);
    }
  }

  static GoRouter config({required dynamic navigationService}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainNavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const ResponsiveLayout(
                mobile: HomePage(),
                tablet: TabletHomePage(),
                largeTablet: TabletHomePage(),
              ),
            ),
            GoRoute(
              path: '/boost',
              name: 'boost',
              builder: (context, state) => const BoostPage(),
            ),
            GoRoute(
              path: '/games',
              name: 'games',
              builder: (context, state) => const ResponsiveLayout(
                mobile: GamesPage(),
                tablet: AdvancedGameGrid(),
                largeTablet: AdvancedGameGrid(),
              ),
              routes: [
                GoRoute(
                  path: 'details',
                  name: 'game_details',
                  builder: (context, state) {
                    final game = state.extra as GameInfo;
                    return GameDetailsPage(game: game);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/optimizations',
              name: 'optimizations',
              builder: (context, state) => const ResponsiveLayout(
                mobile: OptimizationsPage(),
                tablet: OptimizationPanel(),
                largeTablet: OptimizationPanel(),
              ),
            ),
            GoRoute(
              path: '/premium',
              name: 'premium',
              builder: (context, state) => const ResponsiveLayout(
                mobile: PremiumPage(),
                tablet: PremiumAnalyticsCenter(),
                largeTablet: PremiumAnalyticsCenter(),
              ),
            ),
            GoRoute(
              path: '/widgets',
              name: 'widgets',
              builder: (context, state) => const ResponsiveLayout(
                mobile:
                    TabletWidgetCenter(), // Assuming mobile also uses it or redirect, for now just show it
                tablet: TabletWidgetCenter(),
                largeTablet: TabletWidgetCenter(),
              ),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const ResponsiveLayout(
                mobile: SettingsPage(),
                tablet: DesktopSettingsManager(),
                largeTablet: DesktopSettingsManager(),
              ),
            ),
            GoRoute(
              path: '/backup',
              name: 'backup',
              builder: (context, state) => const BackupPage(),
            ),
            GoRoute(
              path: '/diagnostics',
              name: 'diagnostics',
              builder: (context, state) => const DiagnosticsPage(),
            ),
            GoRoute(
              path: '/analytics',
              name: 'analytics',
              builder: (context, state) => const ResponsiveLayout(
                mobile: GamingAnalyticsPage(),
                tablet: GamingAnalyticsPage(),
                largeTablet: GamingAnalyticsPage(),
              ),
            ),
            GoRoute(
              path: '/achievements',
              name: 'achievements',
              builder: (context, state) => const ResponsiveLayout(
                mobile: AchievementCenterPage(),
                tablet: AchievementCenterPage(),
                largeTablet: AchievementCenterPage(),
              ),
            ),
            GoRoute(
              path: '/dns_boost',
              name: 'dns_boost',
              builder: (context, state) => const DnsBoostPage(),
            ),
            GoRoute(
              path: '/vpn_boost',
              name: 'vpn_boost',
              builder: (context, state) => const ResponsiveLayout(
                mobile: VpnBoostPage(),
                tablet: VpnBoostPage(),
                largeTablet: VpnBoostPage(),
              ),
            ),
          ],
        ),
        ...InstantGame.all.map(
          (game) => GoRoute(
            path: game.route,
            name: 'instant_${game.id.replaceAll('-', '_')}',
            builder: (context, state) => _instantGameScreen(game),
          ),
        ),
      ],
      redirect: (context, state) {
        // Implement real onboarding check here if needed
        return null;
      },
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainNavigationShell({super.key, required this.child});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  List<NavigationItem> _mobileItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.navHome,
          route: '/home'),
      NavigationItem(
          icon: Icons.rocket_launch_outlined,
          selectedIcon: Icons.rocket_launch,
          label: l10n.navBoost,
          route: '/boost'),
      NavigationItem(
          icon: Icons.vpn_lock_outlined,
          selectedIcon: Icons.vpn_lock,
          label: 'VPN',
          route: '/vpn_boost'),
      NavigationItem(
          icon: Icons.games_outlined,
          selectedIcon: Icons.games,
          label: l10n.navGames,
          route: '/games'),
      NavigationItem(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: l10n.navSettings,
          route: '/settings'),
    ];
  }

  List<NavigationItem> _tabletItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      NavigationItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: l10n.navDashboard,
          route: '/home'),
      NavigationItem(
          icon: Icons.speed_outlined,
          selectedIcon: Icons.speed,
          label: l10n.navBoost,
          route: '/boost'),
      NavigationItem(
          icon: Icons.vpn_lock_outlined,
          selectedIcon: Icons.vpn_lock,
          label: 'VPN Boost',
          route: '/vpn_boost'),
      NavigationItem(
          icon: Icons.sports_esports_outlined,
          selectedIcon: Icons.sports_esports,
          label: l10n.navGamingHub,
          route: '/games'),
      NavigationItem(
          icon: Icons.tune_outlined,
          selectedIcon: Icons.tune,
          label: l10n.navOptimization,
          route: '/optimizations'),
      NavigationItem(
          icon: Icons.diamond_outlined,
          selectedIcon: Icons.diamond,
          label: l10n.navPremium,
          route: '/premium'),
      NavigationItem(
          icon: Icons.widgets_outlined,
          selectedIcon: Icons.widgets,
          label: 'Widgets',
          route: '/widgets'),
      NavigationItem(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: l10n.navSettings,
          route: '/settings'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      largeTablet: _buildTabletLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _mobileItems(context).map((item) {
              final isSelected = location.startsWith(item.route);
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(item.route),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white54,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white54,
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final tabletItems = _tabletItems(context);
    int selectedIndex =
        tabletItems.indexWhere((item) => location.startsWith(item.route));
    if (selectedIndex == -1) selectedIndex = 0;

    return Scaffold(
      body: Row(
        children: [
          TabletSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                context.go(tabletItems[index].route),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
