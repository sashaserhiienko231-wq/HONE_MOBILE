import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/navigation/responsive_layout.dart';
import 'package:hone_mobile/core/animations/animation_presets.dart';
import 'package:hone_mobile/core/app/providers/animation_settings_provider.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';
import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/core/services/game_database_service.dart';
import 'package:hone_mobile/features/dns_boost/models/dns_provider_info.dart';
import 'package:hone_mobile/features/dns_boost/services/dns_engine_service.dart';
import 'package:hone_mobile/features/dns_boost/providers/dns_boost_providers.dart';
import 'package:hone_mobile/features/dns_boost/presentation/widgets/latency_chart.dart';
import 'package:hone_mobile/features/dns_boost/presentation/widgets/jitter_meter.dart';
import 'package:hone_mobile/features/dns_boost/presentation/widgets/per_game_dns_dialog.dart';

class DnsBoostPage extends ConsumerStatefulWidget {
  const DnsBoostPage({super.key});

  @override
  ConsumerState<DnsBoostPage> createState() => _DnsBoostPageState();
}

class _DnsBoostPageState extends ConsumerState<DnsBoostPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pingChangeController;
  late Animation<double> _pingAnimation;
  
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customIpController = TextEditingController();
  final ScrollController _logScrollController = ScrollController();

  String _previousPing = '';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    _tabController = TabController(length: 4, vsync: this);

    _pingChangeController = AnimationController(
      vsync: this,
      duration: animEnabled ? const Duration(milliseconds: 300) : Duration.zero,
    );
    _pingAnimation = CurvedAnimation(
      parent: _pingChangeController,
      curve: AnimationPresets.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pingChangeController.dispose();
    _customNameController.dispose();
    _customIpController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dnsBoostStateProvider);
    final notifier = ref.read(dnsBoostStateProvider.notifier);
    final engine = ref.watch(dnsEngineServiceProvider);
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;
    
    final isTablet = ResponsiveLayout.isTablet(context);

    // Animate ping changes
    final currentPing = state.isBoostEnabled ? '${state.currentPing.toStringAsFixed(1)} ms' : 'Off-loop';
    if (currentPing != _previousPing && animEnabled) {
      _pingChangeController.forward(from: 0);
      _previousPing = currentPing;
    }

    // Auto-scroll diagnostics log on changes
    ref.listen(dnsEngineServiceProvider, (prev, curr) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.secondaryDark,
              Color(0xFF0F0726), // subtle deep purple background glow
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Gaming DNS Boost',
                subtitle: 'Network routing packet optimization',
              ),
              
              // Top Status Panel (Gauge and Current DNS Card)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: _buildTopStatusPanel(state, notifier, isTablet),
              ),

              // Tab Selector
              TabBar(
                isScrollable: true,
                controller: _tabController,
                indicatorColor: AppTheme.neonPurple,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
                tabs: const [
                  Tab(text: 'DASHBOARD'),
                  Tab(text: 'BENCHMARK'),
                  Tab(text: 'GAMES'),
                  Tab(text: 'TUNING'),
                ],
              ),

              // Expanded Viewports
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(state, notifier, engine, isTablet),
                    _buildBenchmarkTab(state, notifier, isTablet),
                    _buildGamesTab(state, notifier, isTablet),
                    _buildTuningTab(state, notifier),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // TOP PANEL (Status & Quick Switches)
  // ----------------------------------------------------
  Widget _buildTopStatusPanel(DnsBoostState state, DnsBoostNotifier notifier, bool isTablet) {
    final settings = ref.watch(animationSettingsProvider);
    final animEnabled = settings.enabled && !settings.reduceMotion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: state.isBoostEnabled ? AppTheme.neonPurple.withValues(alpha: 0.3) : Colors.white10,
          width: 1,
        ),
        boxShadow: [
          if (state.isBoostEnabled)
            BoxShadow(
              color: AppTheme.neonPurple.withValues(alpha: 0.08),
              blurRadius: 15,
              spreadRadius: 2,
            )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSideBySide = isTablet || constraints.maxWidth > 550;
          
          final content = [
            // Gauge Dial / Stability Meter
            SizedBox(
              width: showSideBySide ? 180.w : double.infinity,
              child: JitterMeter(
                jitter: state.currentJitter,
                packetLoss: state.currentPacketLoss,
                score: state.isBoostEnabled ? state.connectionScore : 100,
              ),
            ),
            if (!showSideBySide) SizedBox(height: 16.h),
            // Current DNS connection details Card
            Expanded(
              flex: showSideBySide ? 2 : 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DNS TUNNEL ENGINE',
                            style: TextStyle(
                              color: AppTheme.neonPurple,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            state.isBoostEnabled 
                                ? (state.isBoosting ? 'OPTIMIZING ROUTE...' : 'ACTIVE') 
                                : 'STANDBY',
                            style: TextStyle(
                              color: state.isBoostEnabled 
                                  ? (state.isBoosting ? AppTheme.neonOrange : AppTheme.neonGreen)
                                  : Colors.white38,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: state.isBoostEnabled,
                        onChanged: (val) {
                          notifier.toggleBoost(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow('Active Server', state.isBoostEnabled ? state.activeProvider.name : 'System Default'),
                  _buildStatusRow('IP Address', state.isBoostEnabled ? state.activeProvider.addresses.first : 'Dynamic System Bound'),
                  _buildAnimatedStatusRow('Ping Latency', state.isBoostEnabled ? '${state.currentPing.toStringAsFixed(1)} ms' : 'Off-loop', _pingAnimation, animEnabled),
                  _buildStatusRow('Routing Mode', state.selectedMode),
                  _buildStatusRow('Region Focus', state.selectedRegion),
                ],
              ),
            ),
          ];

          return showSideBySide 
              ? Row(children: content) 
              : Column(children: content);
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatusRow(String label, String value, Animation<double> animation, bool animEnabled) {
    if (!animEnabled) {
      return _buildStatusRow(label, value);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (animation.value * 0.1),
                child: Opacity(
                  opacity: 0.5 + (animation.value * 0.5),
                  child: Text(value, style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 1: DASHBOARD
  // ----------------------------------------------------
  Widget _buildDashboardTab(DnsBoostState state, DnsBoostNotifier notifier, DnsEngineService engine, bool isTablet) {
    final double spacing = 12.h;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Latency Graph Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REAL-TIME PING STABILITY',
                  style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                LatencyChart(pings: state.isBoostEnabled ? state.pingHistory : const []),
              ],
            ),
          ),
          
          SizedBox(height: spacing),

          // Gaming Mode selector Grid
          Text(
            'OPTIMIZATION PROFILES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          _buildModesPanel(state, notifier, isTablet),

          SizedBox(height: spacing),

          // Diagnostic Console Card
          Container(
            padding: const EdgeInsets.all(16),
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DIAGNOSTIC LOGS',
                      style: TextStyle(
                        color: AppTheme.neonBlue,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Icon(Icons.terminal_outlined, color: AppTheme.neonBlue, size: 14),
                  ],
                ),
                const Divider(color: Colors.white10),
                Expanded(
                  child: ListView.builder(
                    controller: _logScrollController,
                    itemCount: engine.diagnosticLogs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          engine.diagnosticLogs[index],
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                            color: Colors.greenAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModesPanel(DnsBoostState state, DnsBoostNotifier notifier, bool isTablet) {
    final modes = [
      {'name': 'Competitive', 'desc': 'Ultra low latency, prioritized packets', 'icon': Icons.bolt, 'color': AppTheme.neonGreen},
      {'name': 'Stable', 'desc': 'Lowest jitter, smooth connections', 'icon': Icons.security, 'color': AppTheme.neonBlue},
      {'name': 'Streaming', 'desc': 'Optimized bandwidth and download paths', 'icon': Icons.stream, 'color': AppTheme.neonPurple},
      {'name': 'Battery Saver', 'desc': 'Reduced background queries', 'icon': Icons.battery_saver, 'color': AppTheme.accentGreen},
      {'name': 'AI Smart', 'desc': 'Auto connection monitoring & switches', 'icon': Icons.psychology, 'color': AppTheme.neonOrange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 5 : 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: isTablet ? 1.6 : 1.3,
      ),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];
        final isSelected = state.selectedMode == mode['name'];
        final color = mode['color'] as Color;

        return GestureDetector(
          onTap: () => notifier.setMode(mode['name'] as String),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.08) : AppTheme.cardDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.04),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mode['icon'] as IconData, color: isSelected ? color : Colors.white54, size: 20.w),
                const SizedBox(height: 6),
                Text(
                  mode['name'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mode['desc'] as String,
                  style: TextStyle(color: Colors.white38, fontSize: 8.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 2: BENCHMARK
  // ----------------------------------------------------
  Widget _buildBenchmarkTab(DnsBoostState state, DnsBoostNotifier notifier, bool isTablet) {
    final allProviders = [
      ...DnsProviderInfo.defaultProviders,
      ...DnsProviderInfo.gamingProfiles,
      ...state.customProviders,
    ];

    // Use ranked results if benchmark finished, else show unsorted list
    final listToShow = state.benchmarkResults.isNotEmpty 
        ? state.benchmarkResults 
        : allProviders;

    return Column(
      children: [
        // Control Bar
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DNS BENCHMARK TOOL',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rank routing endpoints to find the fastest options.',
                    style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                  ),
                ],
              ),
              GradientButton(
                text: state.isBenchmarking ? 'Testing...' : 'Run Test',
                width: 110.w,
                height: 38.h,
                isLoading: state.isBenchmarking,
                onPressed: state.isBenchmarking ? null : () => notifier.runBenchmarkSuite(),
              ),
            ],
          ),
        ),

        // Servers List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: listToShow.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final provider = listToShow[index];
              final isCurrentlySelected = state.activeProvider.id == provider.id;
              
              // Latency color rules
              Color latencyColor = AppTheme.neonGreen;
              if (provider.latencyMs > 35.0) latencyColor = AppTheme.neonOrange;
              if (provider.latencyMs > 60.0) latencyColor = AppTheme.accentRed;

              return InkWell(
                onTap: () => notifier.selectProvider(provider),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentlySelected 
                        ? AppTheme.neonPurple.withValues(alpha: 0.06) 
                        : AppTheme.cardDark.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isCurrentlySelected ? AppTheme.neonPurple : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentlySelected ? AppTheme.neonPurple.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          provider.isGamingProfile ? Icons.sports_esports : Icons.dns_outlined,
                          color: isCurrentlySelected ? AppTheme.neonPurple : Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'IP: ${provider.addresses.first} | Region: ${provider.region}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      // Latency Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: latencyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.latencyMs.toStringAsFixed(1)} ms',
                          style: TextStyle(
                            color: latencyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Custom DNS Drawer / Button
        _buildAddCustomDnsBar(notifier),
      ],
    );
  }

  Widget _buildAddCustomDnsBar(DnsBoostNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Add Custom DNS Node'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _customNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'DNS Provider Name',
                      hintText: 'e.g. Custom Node A',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customIpController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Primary Server IP Address',
                      hintText: 'e.g. 1.1.1.2',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                GradientButton(
                  text: 'Register',
                  width: 90.w,
                  height: 38.h,
                  onPressed: () {
                    final name = _customNameController.text.trim();
                    final ip = _customIpController.text.trim();
                    if (name.isNotEmpty && ip.isNotEmpty) {
                      notifier.addCustomDns(name, ip);
                      _customNameController.clear();
                      _customIpController.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppTheme.neonPurple, size: 18),
            SizedBox(width: 8),
            Text(
              'Add Custom DNS Node',
              style: TextStyle(color: AppTheme.neonPurple, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 3: GAMES INTEGRATION
  // ----------------------------------------------------
  Widget _buildGamesTab(DnsBoostState state, DnsBoostNotifier notifier, bool isTablet) {
    final List<GameInfo> games = GameDatabaseService.localGames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PER-GAME NETWORK PROFILES',
                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'Configure explicit DNS route mappings for individual multiplayer applications.',
                style: TextStyle(color: Colors.white38, fontSize: 10.sp),
              ),
            ],
          ),
        ),

        Expanded(
          child: games.isEmpty
              ? const Center(
                  child: Text('No local games found in Gaming Hub.', style: TextStyle(color: Colors.white24)),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: games.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final hasOverride = state.perGameProviders.containsKey(game.packageName);
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: hasOverride ? AppTheme.neonPurple.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.sports_esports, color: AppTheme.neonGreen),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(game.appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(
                                  hasOverride 
                                      ? 'Custom override: ${state.perGameProviders[game.packageName]}' 
                                      : 'Inheriting global DNS boost',
                                  style: TextStyle(
                                    color: hasOverride ? AppTheme.neonPurple : Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: AppTheme.neonBlue, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => PerGameDnsDialog(game: game),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // TAB 4: TUNING (SETTINGS)
  // ----------------------------------------------------
  Widget _buildTuningTab(DnsBoostState state, DnsBoostNotifier notifier) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Region Affinity Selector
        Text(
          'ROUTING REGION PREFERENCE',
          style: TextStyle(
            color: AppTheme.neonPurple,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppTheme.cardDark,
              value: state.selectedRegion,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: ['Europe', 'North America', 'South America', 'Asia', 'Middle East', 'Africa', 'Oceania'].map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setRegion(val);
              },
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Settings toggles
        _buildSettingsToggleTile(
          'Auto-Connect on Launch',
          'Optimize networking instantly when Gaming Hub runs.',
          state.autoConnectOnLaunch,
          (v) => notifier.setAutoConnect(v),
        ),
        _buildSettingsToggleTile(
          'Startup Cache Optimization',
          'Automatically purge DNS cache indexes at boot.',
          state.startupOptimization,
          (v) => notifier.setStartupOptimization(v),
        ),
        _buildSettingsToggleTile(
          'Background Ping Analysis',
          'Allow polling of DNS servers while app is in background.',
          state.backgroundOptimization,
          (v) => notifier.setBackgroundOptimization(v),
        ),
        _buildSettingsToggleTile(
          'Aggressive Route Forcing',
          'Reduce socket timeouts and force direct connections.',
          state.aggressiveRouting,
          (v) => notifier.setAggressiveRouting(v),
        ),
        _buildSettingsToggleTile(
          'Auto optimization',
          'Auto-apply fastest benchmarked DNS to active slot.',
          state.autoOptimization,
          (v) => notifier.toggleAutoOptimization(v),
        ),
        _buildSettingsToggleTile(
          'Smart routing engine',
          'Enable intelligent regional DNS matching calculations.',
          state.smartRouting,
          (v) => notifier.toggleSmartRouting(v),
        ),

        SizedBox(height: 20.h),

        // Advanced Tools (Cache Clear, Repair Socket)
        Text(
          'ADVANCED RECOVERY ACTIONS',
          style: TextStyle(
            color: AppTheme.neonOrange,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.black),
                label: const Text('Flush Cache'),
                onPressed: () async {
                  final freed = await notifier.clearDnsCache();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Flushed DNS Cache. Cleared $freed mapping routes.')),
                    );
                  }
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.build_outlined, color: Colors.black),
                label: const Text('Repair Socket'),
                onPressed: () async {
                  await notifier.repairNetwork();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Network Stack repaired successfully.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  Widget _buildSettingsToggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
