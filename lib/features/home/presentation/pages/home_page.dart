import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/app/providers/performance_providers.dart';
import 'package:hone_mobile/core/compatibility/device_compatibility_engine.dart';
import 'package:hone_mobile/core/models/performance_stats.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/theme/spacing.dart';
import 'package:hone_mobile/features/home/presentation/widgets/dns_boost_banner.dart';
import 'package:hone_mobile/features/home/presentation/widgets/optimization_summary_widget.dart';
import 'package:hone_mobile/features/home/presentation/widgets/performance_card.dart';
import 'package:hone_mobile/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:hone_mobile/features/home/presentation/widgets/system_stats_widget.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  DeviceProfile? _deviceProfile;
  late AnimationController _entranceCtrl;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final enabled = settings.enabled && !settings.reduceMotion;
    final totalDuration = enabled
        ? const Duration(milliseconds: 300 + (_sectionCount * 80))
        : Duration.zero;

    _entranceCtrl = AnimationController(vsync: this, duration: totalDuration);
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: AnimationPresets.easeOutCubic),
      ));
    });

    if (enabled) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _entranceCtrl.forward());
    } else {
      _entranceCtrl.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DeviceCompatibilityEngine.resolve(context).then((profile) {
      if (mounted) setState(() => _deviceProfile = profile);
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(position: _slideAnims[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(performanceStatsProvider);
    final stats = statsAsync.value ?? PerformanceStats.empty;
    final optimizationState = ref.watch(optimizationProvider);
    final width = MediaQuery.sizeOf(context).width;
    final scale = _deviceProfile?.horizontalPaddingScale ?? 1.0;
    final hPad = AppSpacing.horizontalPadding(width, scale: scale);
    final sectionGap = AppSpacing.sectionGap(width, scale: scale);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              title: l10n.homeTitle,
              subtitle: l10n.homeSubtitle,
              applySafeArea: false,
              actions: [
                IconButton(
                  onPressed: () => context.push('/diagnostics'),
                  icon: Icon(Icons.analytics_outlined,
                      color: AppTheme.neonGreen, size: 24.w),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(performanceStatsProvider);
                },
                backgroundColor: AppTheme.cardDark,
                color: AppTheme.neonGreen,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: _stagger(
                            0,
                            RepaintBoundary(
                                child: PerformanceCard(stats: stats))),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 0),
                      sliver: SliverToBoxAdapter(
                          child: _stagger(1, const DnsBoostBanner())),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: _stagger(
                            2,
                            Text(
                              l10n.quickActions,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: _stagger(
                            3,
                            QuickActionsGrid(
                              isOptimizing: optimizationState.isLoading,
                              onOptimizeAll: () => ref
                                  .read(optimizationProvider.notifier)
                                  .runFullOptimization(),
                            )),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: _stagger(
                            4,
                            RepaintBoundary(
                                child: SystemStatsWidget(stats: stats))),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: _stagger(
                            5,
                            const RepaintBoundary(
                                child: OptimizationSummaryWidget())),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                          bottom: AppSpacing.bottomScrollPadding(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
