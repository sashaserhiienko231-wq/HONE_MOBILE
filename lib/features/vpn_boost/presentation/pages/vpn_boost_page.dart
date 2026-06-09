import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/core/navigation/responsive_layout.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/vpn_boost/models/vpn_models.dart';
import 'package:hone_mobile/features/vpn_boost/providers/vpn_boost_providers.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';
import 'package:hone_mobile/shared/widgets/performance_graph.dart';

class VpnBoostPage extends ConsumerStatefulWidget {
  const VpnBoostPage({super.key});

  @override
  ConsumerState<VpnBoostPage> createState() => _VpnBoostPageState();
}

class _VpnBoostPageState extends ConsumerState<VpnBoostPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration:
          animEnabled ? const Duration(milliseconds: 1800) : Duration.zero,
    );

    if (animEnabled) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vpnBoostStateProvider);
    final notifier = ref.read(vpnBoostStateProvider.notifier);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF03050A),
              Color(0xFF080915),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: 'VPN BOOST',
                subtitle: 'Premium private routes for gaming traffic',
                applySafeArea: false,
                actions: [
                  _HeaderChip(
                    icon: Icons.shield_outlined,
                    label: state.connection.isSecure ? 'SECURE' : 'READY',
                    color: state.connection.isSecure
                        ? AppTheme.neonGreen
                        : AppTheme.neonBlue,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppTheme.neonBlue,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: TextStyle(
                    fontSize: isTablet ? 12.sp : 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  tabs: const [
                    Tab(text: 'DASHBOARD'),
                    Tab(text: 'SERVERS'),
                    Tab(text: 'PROFILES'),
                    Tab(text: 'ANALYTICS'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DashboardTab(
                      state: state,
                      notifier: notifier,
                      pulse: _pulseController,
                    ),
                    _ServerBrowserTab(
                      state: state,
                      notifier: notifier,
                      searchController: _searchController,
                    ),
                    _ProfilesTab(state: state, notifier: notifier),
                    _AnalyticsTab(state: state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final VpnBoostState state;
  final VpnBoostNotifier notifier;
  final Animation<double> pulse;

  const _DashboardTab({
    required this.state,
    required this.notifier,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final veryWide = constraints.maxWidth >= 1080;
        final padding = EdgeInsets.all(wide ? 24.w : 16.w);

        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: veryWide ? 4 : 5,
                      child: _ConnectionConsole(
                        state: state,
                        notifier: notifier,
                        pulse: pulse,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 5,
                      child: _DashboardMetrics(state: state),
                    ),
                  ],
                )
              else ...[
                _ConnectionConsole(
                  state: state,
                  notifier: notifier,
                  pulse: pulse,
                ),
                SizedBox(height: 14.h),
                _DashboardMetrics(state: state),
              ],
              SizedBox(height: 16.h),
              _QuickConnectPanel(state: state, notifier: notifier),
              SizedBox(height: 16.h),
              _LiveDiagnosticsPanel(logs: state.diagnosticLogs),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectionConsole extends StatelessWidget {
  final VpnBoostState state;
  final VpnBoostNotifier notifier;
  final Animation<double> pulse;

  const _ConnectionConsole({
    required this.state,
    required this.notifier,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(state.connection.status);
    final server = state.connection.server ?? state.selectedServer;

    return _GlassPanel(
      accent: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (context, child) {
                  final glow =
                      state.isConnected ? 0.22 + pulse.value * 0.22 : 0.08;
                  return Container(
                    width: 86.w,
                    height: 86.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: glow),
                          blurRadius: 28 + pulse.value * 18,
                          spreadRadius: 1,
                        ),
                      ],
                      gradient: RadialGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                    child: Icon(
                      state.isConnected
                          ? Icons.vpn_lock
                          : Icons.vpn_key_outlined,
                      color: statusColor,
                      size: 38.w,
                    ),
                  );
                },
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CapsLabel(label: 'CONNECTION STATUS', color: statusColor),
                    SizedBox(height: 6.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        _statusText(state.connection.status),
                        key: ValueKey(state.connection.status),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${server.flag} ${server.country} - ${server.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      state.selectedProfile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: AppTheme.neonBlue, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: state.isConnected ? 'DISCONNECT' : 'CONNECT',
                  icon:
                      state.isConnected ? Icons.power_settings_new : Icons.bolt,
                  height: 48.h,
                  startColor: state.isConnected
                      ? AppTheme.accentRed
                      : AppTheme.neonGreen,
                  endColor: state.isConnected
                      ? AppTheme.neonOrange
                      : AppTheme.neonBlue,
                  isLoading: state.isBusy,
                  onPressed: state.isBusy
                      ? null
                      : () {
                          if (state.isConnected) {
                            notifier.disconnect();
                          } else {
                            notifier.connect();
                          }
                        },
                ),
              ),
              SizedBox(width: 10.w),
              _IconGlassButton(
                icon: Icons.auto_awesome,
                color: AppTheme.neonPurple,
                tooltip: 'Auto best server',
                onTap: state.isBusy
                    ? null
                    : () =>
                        notifier.quickConnect(VpnQuickConnectOption.autoBest),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardMetrics extends StatelessWidget {
  final VpnBoostState state;

  const _DashboardMetrics({required this.state});

  @override
  Widget build(BuildContext context) {
    final connection = state.connection;
    final server = connection.server ?? state.selectedServer;

    final items = [
      _MetricData(
        'Current IP',
        connection.currentIp,
        Icons.language,
        AppTheme.neonBlue,
      ),
      _MetricData(
        'Selected Region',
        server.region,
        Icons.public,
        AppTheme.neonPurple,
      ),
      _MetricData(
        'Ping',
        state.isConnected ? '${connection.pingMs.toStringAsFixed(1)} ms' : '--',
        Icons.network_ping,
        AppTheme.neonGreen,
      ),
      _MetricData(
        'Download',
        state.isConnected
            ? '${connection.downloadMbps.toStringAsFixed(0)} Mbps'
            : '--',
        Icons.download,
        AppTheme.neonBlue,
      ),
      _MetricData(
        'Upload',
        state.isConnected
            ? '${connection.uploadMbps.toStringAsFixed(0)} Mbps'
            : '--',
        Icons.upload,
        AppTheme.neonOrange,
      ),
      _MetricData(
        'Duration',
        _formatDuration(connection.duration),
        Icons.timer_outlined,
        AppTheme.accentGreen,
      ),
      _MetricData(
        'Security',
        connection.securityStatus,
        Icons.verified_user_outlined,
        connection.isSecure ? AppTheme.neonGreen : Colors.white54,
      ),
    ];

    return _GlassPanel(
      accent: AppTheme.neonBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'VPN DASHBOARD',
            subtitle: 'Live route, throughput, and security telemetry',
            color: AppTheme.neonBlue,
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: columns == 3 ? 2.45 : 2.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _MetricTile(data: items[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickConnectPanel extends StatelessWidget {
  final VpnBoostState state;
  final VpnBoostNotifier notifier;

  const _QuickConnectPanel({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accent: AppTheme.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'QUICK CONNECT',
            subtitle: 'Jump into the best route without browsing servers',
            color: AppTheme.neonPurple,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: VpnQuickConnectOption.values.map((option) {
              return _ActionPill(
                label: option.label,
                icon: _quickIcon(option),
                color: _quickColor(option),
                enabled: !state.isBusy,
                onTap: () => notifier.quickConnect(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LiveDiagnosticsPanel extends StatelessWidget {
  final List<String> logs;

  const _LiveDiagnosticsPanel({required this.logs});

  @override
  Widget build(BuildContext context) {
    final visibleLogs = logs.take(8).toList();
    return _GlassPanel(
      accent: AppTheme.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'VPN ENGINE LOG',
            subtitle: 'Provider abstraction and simulated route lifecycle',
            color: AppTheme.neonGreen,
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 118.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: visibleLogs.isEmpty
                  ? const [
                      Text(
                        'Awaiting VPN engine events.',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ]
                  : visibleLogs
                      .map(
                        (log) => Padding(
                          padding: EdgeInsets.only(bottom: 5.h),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'Courier',
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerBrowserTab extends ConsumerWidget {
  final VpnBoostState state;
  final VpnBoostNotifier notifier;
  final TextEditingController searchController;

  const _ServerBrowserTab({
    required this.state,
    required this.notifier,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(vpnFilteredServersProvider);

    if (searchController.text != state.serverQuery) {
      searchController.text = state.serverQuery;
      searchController.selection = TextSelection.collapsed(
        offset: searchController.text.length,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 720
                ? 2
                : 1;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: notifier.setSearchQuery,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.neonBlue,
                        ),
                        suffixIcon: state.serverQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white54),
                                onPressed: () {
                                  searchController.clear();
                                  notifier.setSearchQuery('');
                                },
                              ),
                        hintText: 'Search country, region, or city',
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: VpnServerCategory.values.map((category) {
                          final selected = state.selectedCategory == category;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: ChoiceChip(
                              selected: selected,
                              label: Text(category.label),
                              avatar: Icon(
                                _categoryIcon(category),
                                size: 16,
                                color:
                                    selected ? Colors.black : AppTheme.neonBlue,
                              ),
                              onSelected: (_) => notifier.setCategory(category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _RegionCatalog(
                      catalog: VpnServer.regionCatalog,
                      onRegionTap: notifier.setSearchQuery,
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              sliver: servers.isEmpty
                  ? const SliverToBoxAdapter(
                      child: _EmptyServers(),
                    )
                  : SliverGrid.builder(
                      itemCount: servers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: columns == 1 ? 1.12 : 1.18,
                      ),
                      itemBuilder: (context, index) {
                        final server = servers[index];
                        return _ServerCard(
                          server: server,
                          selected: state.selectedServer.id == server.id,
                          favorite: state.favoriteServerIds.contains(server.id),
                          onSelect: () => notifier.selectServer(server),
                          onConnect: state.isBusy
                              ? null
                              : () => notifier.connect(server: server),
                          onFavorite: () => notifier.toggleFavorite(server.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfilesTab extends StatelessWidget {
  final VpnBoostState state;
  final VpnBoostNotifier notifier;

  const _ProfilesTab({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassPanel(
                accent: AppTheme.neonPurple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'GAMING VPN PROFILES',
                      subtitle: 'Profile routing behavior before connecting',
                      color: AppTheme.neonPurple,
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.profiles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: columns == 1 ? 2.42 : 1.82,
                      ),
                      itemBuilder: (context, index) {
                        final profile = state.profiles[index];
                        return _ProfileCard(
                          profile: profile,
                          selected: state.selectedProfile.id == profile.id,
                          onTap: () => notifier.selectProfile(profile),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _GlassPanel(
                accent: AppTheme.neonBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'VPN SETTINGS',
                      subtitle:
                          'Runtime controls prepared for real SDK binding',
                      color: AppTheme.neonBlue,
                    ),
                    SizedBox(height: 8.h),
                    _SettingsSwitch(
                      title: 'Kill Switch',
                      subtitle: 'Block traffic when the VPN tunnel drops.',
                      value: state.settings.killSwitch,
                      onChanged: notifier.setKillSwitch,
                    ),
                    _SettingsSwitch(
                      title: 'Auto Reconnect',
                      subtitle:
                          'Reconnect to the selected route after link loss.',
                      value: state.settings.autoReconnect,
                      onChanged: notifier.setAutoReconnect,
                    ),
                    _SettingsSwitch(
                      title: 'Tracker Blocking',
                      subtitle:
                          'Route known tracking domains through a blocklist layer.',
                      value: state.settings.blockTrackers,
                      onChanged: notifier.setBlockTrackers,
                    ),
                    _SettingsSwitch(
                      title: 'LAN Bypass',
                      subtitle:
                          'Keep local network devices outside the tunnel.',
                      value: state.settings.lanBypass,
                      onChanged: notifier.setLanBypass,
                    ),
                    _SettingsSwitch(
                      title: 'Diagnostics Logging',
                      subtitle:
                          'Store provider lifecycle events for support exports.',
                      value: state.settings.diagnosticsLogging,
                      onChanged: notifier.setDiagnosticsLogging,
                    ),
                    _SettingsSwitch(
                      title: 'SDK Bridge Mode',
                      subtitle:
                          'Keep provider hooks active for future VPN SDK calls.',
                      value: state.settings.prepareSdkBridge,
                      onChanged: notifier.setPrepareSdkBridge,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final VpnBoostState state;

  const _AnalyticsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnalyticsSummary(state: state),
              SizedBox(height: 16.h),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _GraphPanel(state: state)),
                    SizedBox(width: 16.w),
                    Expanded(child: _RegionUsagePanel(state: state)),
                  ],
                )
              else ...[
                _GraphPanel(state: state),
                SizedBox(height: 16.h),
                _RegionUsagePanel(state: state),
              ],
              SizedBox(height: 16.h),
              _SessionHistoryPanel(sessions: state.sessionHistory),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final Color accent;

  const _GlassPanel({
    required this.child,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF080A12).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapsLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _CapsLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.icon, this.color);
}

class _MetricTile extends StatelessWidget {
  final _MetricData data;

  const _MetricTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: data.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(data.icon, color: data.color, size: 18.w),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 9.sp,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGlassButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconGlassButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          width: 48.h,
          height: 48.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: onTap == null ? 0.05 : 0.14),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: color.withValues(alpha: 0.34)),
          ),
          child: Icon(icon, color: onTap == null ? Colors.white24 : color),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.12 : 0.04),
          borderRadius: BorderRadius.circular(14.r),
          border:
              Border.all(color: color.withValues(alpha: enabled ? 0.34 : 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: enabled ? color : Colors.white24, size: 16.w),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white24,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionCatalog extends StatelessWidget {
  final Map<String, List<String>> catalog;
  final ValueChanged<String> onRegionTap;

  const _RegionCatalog({
    required this.catalog,
    required this.onRegionTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accent: AppTheme.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'REGION CATALOG',
            subtitle:
                'All premium VPN regions are modeled for provider integration',
            color: AppTheme.neonGreen,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: catalog.entries.map((entry) {
              return InkWell(
                onTap: () => onRegionTap(entry.key),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    '${entry.key} (${entry.value.length})',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final VpnServer server;
  final bool selected;
  final bool favorite;
  final VoidCallback onSelect;
  final VoidCallback? onConnect;
  final VoidCallback onFavorite;

  const _ServerCard({
    required this.server,
    required this.selected,
    required this.favorite,
    required this.onSelect,
    required this.onConnect,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppTheme.neonBlue : AppTheme.neonPurple;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.neonBlue.withValues(alpha: 0.12)
              : const Color(0xFF080A12).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
              color: accent.withValues(alpha: selected ? 0.7 : 0.22)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.13),
                    blurRadius: 22,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(server.flag, style: TextStyle(fontSize: 25.sp)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${server.city} - ${server.region}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: favorite ? 'Remove favorite' : 'Favorite server',
                  visualDensity: VisualDensity.compact,
                  onPressed: onFavorite,
                  icon: Icon(
                    favorite ? Icons.star : Icons.star_border,
                    color: favorite ? AppTheme.neonOrange : Colors.white38,
                    size: 20.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: GridView(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.0,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                children: [
                  _ServerStat(
                      label: 'Ping',
                      value: '${server.pingMs} ms',
                      color: AppTheme.neonGreen),
                  _ServerStat(
                      label: 'Load',
                      value: '${server.loadPercent}%',
                      color: AppTheme.neonOrange),
                  _ServerStat(
                      label: 'Stability',
                      value: '${server.stabilityPercent}%',
                      color: AppTheme.neonBlue),
                  _ServerStat(
                      label: 'Speed',
                      value: '${server.speedScore}',
                      color: AppTheme.neonPurple),
                  _ServerStat(
                      label: 'Gaming',
                      value: '${server.gamingScore}',
                      color: AppTheme.accentGreen),
                  _ServerStat(
                      label: 'Score',
                      value: '${server.connectionScore}',
                      color: Colors.white70),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSelect,
                    icon: Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16.w,
                    ),
                    label: Text(selected ? 'Selected' : 'Select'),
                  ),
                ),
                SizedBox(width: 8.w),
                _IconGlassButton(
                  icon: Icons.flash_on,
                  color: AppTheme.neonGreen,
                  tooltip: 'Connect server',
                  onTap: onConnect,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ServerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white38, fontSize: 9.sp),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VpnGamingProfile profile;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _profileColor(profile.id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(16.r),
          border:
              Border.all(color: color.withValues(alpha: selected ? 0.7 : 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(_profileIcon(profile.id), color: color, size: 24.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    profile.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _TinyScore(
                          label: 'Ping',
                          value: _percentFromMultiplier(profile.pingMultiplier,
                              invert: true),
                          color: AppTheme.neonGreen),
                      SizedBox(width: 6.w),
                      _TinyScore(
                          label: 'Speed',
                          value:
                              _percentFromMultiplier(profile.speedMultiplier),
                          color: AppTheme.neonBlue),
                      SizedBox(width: 6.w),
                      _TinyScore(
                          label: 'Secure',
                          value: (profile.securityLevel * 100).round(),
                          color: AppTheme.neonPurple),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? color : Colors.white24,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyScore extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TinyScore({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          '$label $value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  final VpnBoostState state;

  const _AnalyticsSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final analytics = state.analytics;
    final totalTraffic = analytics.totalTrafficMb +
        state.connection.trafficDownloadedMb +
        state.connection.trafficUploadedMb;

    final items = [
      _MetricData('Sessions', '${analytics.sessionCount}', Icons.history,
          AppTheme.neonPurple),
      _MetricData(
          'Average Ping',
          '${analytics.averagePingMs.toStringAsFixed(1)} ms',
          Icons.network_ping,
          AppTheme.neonGreen),
      _MetricData('Traffic Usage', _formatTraffic(totalTraffic),
          Icons.data_usage, AppTheme.neonBlue),
      _MetricData(
          'Active Region',
          (state.connection.server ?? state.selectedServer).region,
          Icons.travel_explore,
          AppTheme.neonOrange),
    ];

    return _GlassPanel(
      accent: AppTheme.neonPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'VPN ANALYTICS',
            subtitle: 'Session history, traffic, ping, and region usage',
            color: AppTheme.neonPurple,
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: columns == 4 ? 2.05 : 2.1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _MetricTile(data: items[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GraphPanel extends StatelessWidget {
  final VpnBoostState state;

  const _GraphPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final pingData =
        state.pingHistory.isEmpty ? const <double>[0] : state.pingHistory;
    final trafficData =
        state.trafficHistory.isEmpty ? const <double>[0] : state.trafficHistory;
    final maxPing =
        pingData.reduce((a, b) => a > b ? a : b).clamp(50, 160).toDouble();
    final maxTraffic =
        trafficData.reduce((a, b) => a > b ? a : b).clamp(10, 800).toDouble();

    return _GlassPanel(
      accent: AppTheme.neonBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'PERFORMANCE GRAPHS',
            subtitle: 'Live ping and traffic curves update during sessions',
            color: AppTheme.neonBlue,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 150.h,
            child: PerformanceGraph(
              data: pingData,
              color: AppTheme.neonGreen,
              label: 'Average ping',
              max: maxPing,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 150.h,
            child: PerformanceGraph(
              data: trafficData,
              color: AppTheme.neonBlue,
              label: 'Traffic usage',
              max: maxTraffic,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionUsagePanel extends StatelessWidget {
  final VpnBoostState state;

  const _RegionUsagePanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final usage = Map<String, int>.from(state.analytics.regionUsage);
    final activeRegion =
        (state.connection.server ?? state.selectedServer).region;
    if (state.isConnected) {
      usage[activeRegion] = (usage[activeRegion] ?? 0) + 1;
    }

    final entries = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);

    return _GlassPanel(
      accent: AppTheme.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'REGION USAGE',
            subtitle: 'Most used private routing regions',
            color: AppTheme.neonGreen,
          ),
          SizedBox(height: 16.h),
          if (entries.isEmpty)
            const Text(
              'Connect once to populate region usage.',
              style: TextStyle(color: Colors.white38),
            )
          else
            ...entries.map((entry) {
              final fraction = total == 0 ? 0.0 : entry.value / total;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${(fraction * 100).round()}%',
                          style: TextStyle(
                              color: AppTheme.neonGreen, fontSize: 11.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6.h,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SessionHistoryPanel extends StatelessWidget {
  final List<VpnSessionRecord> sessions;

  const _SessionHistoryPanel({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accent: AppTheme.neonOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'SESSION HISTORY',
            subtitle: 'Recent VPN sessions retained for integration exports',
            color: AppTheme.neonOrange,
          ),
          SizedBox(height: 12.h),
          if (sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                'No VPN sessions yet.',
                style: TextStyle(color: Colors.white38, fontSize: 12.sp),
              ),
            )
          else
            ...sessions.map((session) => _SessionRow(session: session)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final VpnSessionRecord session;

  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppTheme.neonOrange.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: const Icon(Icons.history, color: AppTheme.neonOrange),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.country} - ${session.profileName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${_formatDuration(session.duration)} | ${session.averagePingMs.toStringAsFixed(1)} ms | ${_formatTraffic(session.trafficDownloadedMb + session.trafficUploadedMb)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${session.stabilityPercent}%',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyServers extends StatelessWidget {
  const _EmptyServers();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      accent: AppTheme.neonOrange,
      child: Column(
        children: [
          Icon(Icons.search_off, color: AppTheme.neonOrange, size: 36.w),
          SizedBox(height: 10.h),
          Text(
            'No VPN servers match this search.',
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(VpnConnectionStatus status) {
  switch (status) {
    case VpnConnectionStatus.connected:
      return AppTheme.neonGreen;
    case VpnConnectionStatus.connecting:
    case VpnConnectionStatus.disconnecting:
      return AppTheme.neonOrange;
    case VpnConnectionStatus.disconnected:
      return AppTheme.neonBlue;
  }
}

String _statusText(VpnConnectionStatus status) {
  switch (status) {
    case VpnConnectionStatus.connected:
      return 'CONNECTED';
    case VpnConnectionStatus.connecting:
      return 'CONNECTING';
    case VpnConnectionStatus.disconnecting:
      return 'DISCONNECTING';
    case VpnConnectionStatus.disconnected:
      return 'STANDBY';
  }
}

IconData _quickIcon(VpnQuickConnectOption option) {
  switch (option) {
    case VpnQuickConnectOption.autoBest:
      return Icons.auto_awesome;
    case VpnQuickConnectOption.fastest:
      return Icons.speed;
    case VpnQuickConnectOption.lowestPing:
      return Icons.network_ping;
    case VpnQuickConnectOption.lastUsed:
      return Icons.history;
    case VpnQuickConnectOption.favorite:
      return Icons.star;
  }
}

Color _quickColor(VpnQuickConnectOption option) {
  switch (option) {
    case VpnQuickConnectOption.autoBest:
      return AppTheme.neonPurple;
    case VpnQuickConnectOption.fastest:
      return AppTheme.neonBlue;
    case VpnQuickConnectOption.lowestPing:
      return AppTheme.neonGreen;
    case VpnQuickConnectOption.lastUsed:
      return AppTheme.neonOrange;
    case VpnQuickConnectOption.favorite:
      return AppTheme.accentGreen;
  }
}

IconData _categoryIcon(VpnServerCategory category) {
  switch (category) {
    case VpnServerCategory.recommended:
      return Icons.workspace_premium;
    case VpnServerCategory.lowestPing:
      return Icons.network_ping;
    case VpnServerCategory.gaming:
      return Icons.sports_esports;
    case VpnServerCategory.streaming:
      return Icons.live_tv;
    case VpnServerCategory.security:
      return Icons.shield;
  }
}

IconData _profileIcon(String id) {
  switch (id) {
    case 'ai_smart':
      return Icons.psychology;
    case 'ultra_low_ping':
      return Icons.bolt;
    case 'competitive':
      return Icons.military_tech;
    case 'streaming':
      return Icons.cast;
    case 'balanced':
      return Icons.balance;
    case 'battery_saver':
      return Icons.battery_saver;
    default:
      return Icons.vpn_lock;
  }
}

Color _profileColor(String id) {
  switch (id) {
    case 'ai_smart':
      return AppTheme.neonPurple;
    case 'ultra_low_ping':
      return AppTheme.neonGreen;
    case 'competitive':
      return AppTheme.neonOrange;
    case 'streaming':
      return AppTheme.neonBlue;
    case 'balanced':
      return AppTheme.accentGreen;
    case 'battery_saver':
      return AppTheme.accentBlue;
    default:
      return Colors.white70;
  }
}

int _percentFromMultiplier(double value, {bool invert = false}) {
  final normalized = invert ? 2 - value : value;
  return (normalized * 72).round().clamp(1, 100).toInt();
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}

String _formatTraffic(double valueMb) {
  if (valueMb >= 1024) {
    return '${(valueMb / 1024).toStringAsFixed(2)} GB';
  }
  return '${valueMb.toStringAsFixed(1)} MB';
}
