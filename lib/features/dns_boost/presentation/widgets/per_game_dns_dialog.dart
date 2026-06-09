import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/models/game_info.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/dns_boost/models/dns_provider_info.dart';
import 'package:hone_mobile/features/dns_boost/providers/dns_boost_providers.dart';
import 'package:hone_mobile/shared/widgets/gradient_button.dart';

class PerGameDnsDialog extends ConsumerStatefulWidget {
  final GameInfo game;

  const PerGameDnsDialog({
    super.key,
    required this.game,
  });

  @override
  ConsumerState<PerGameDnsDialog> createState() => _PerGameDnsDialogState();
}

class _PerGameDnsDialogState extends ConsumerState<PerGameDnsDialog> {
  late String _selectedProviderId;
  late String _selectedRegion;
  bool _useOverride = false;

  final List<String> _regions = [
    'Europe', 'North America', 'South America', 'Asia', 'Middle East', 'Africa', 'Oceania'
  ];

  @override
  void initState() {
    super.initState();
    final dnsState = ref.read(dnsBoostStateProvider);
    
    // Load current override values if they exist
    final overrideId = dnsState.perGameProviders[widget.game.packageName];
    final overrideRegion = dnsState.perGameRegions[widget.game.packageName];

    _useOverride = overrideId != null || overrideRegion != null;
    _selectedProviderId = overrideId ?? dnsState.activeProvider.id;
    _selectedRegion = overrideRegion ?? dnsState.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    final dnsState = ref.watch(dnsBoostStateProvider);
    final allProviders = [
      ...DnsProviderInfo.defaultProviders,
      ...DnsProviderInfo.gamingProfiles,
      ...dnsState.customProviders,
    ];

    return AlertDialog(
      backgroundColor: AppTheme.cardDark,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          if (widget.game.icon != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.memory(
                widget.game.icon!,
                width: 32.w,
                height: 32.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 32.w,
                  height: 32.w,
                  color: AppTheme.surfaceDark,
                  child: const Icon(Icons.sports_esports, color: AppTheme.neonGreen),
                ),
              ),
            )
          else
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.sports_esports, color: AppTheme.neonGreen),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.game.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Per-Game Net Optimization',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Custom Game DNS Profile',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Override global optimization settings when launching this game.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              value: _useOverride,
              onChanged: (val) {
                setState(() => _useOverride = val);
              },
            ),
            
            if (_useOverride) ...[
              const Divider(color: Colors.white10),
              SizedBox(height: 12.h),
              
              // Provider Selector
              Text(
                'PREFERRED DNS PROVIDER',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppTheme.cardDark,
                    value: _selectedProviderId,
                    isExpanded: true,
                    items: allProviders.map((provider) {
                      return DropdownMenuItem<String>(
                        value: provider.id,
                        child: Text(
                          provider.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedProviderId = val);
                      }
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Region Selector
              Text(
                'REGIONAL AFFINITY ROUTE',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppTheme.cardDark,
                    value: _selectedRegion,
                    isExpanded: true,
                    items: _regions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(
                          region,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRegion = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        GradientButton(
          text: 'Apply',
          width: 100.w,
          height: 38.h,
          onPressed: () {
            final notifier = ref.read(dnsBoostStateProvider.notifier);
            if (_useOverride) {
              notifier.setGameDnsOverride(widget.game.packageName, _selectedProviderId);
              notifier.setGameRegionOverride(widget.game.packageName, _selectedRegion);
            } else {
              notifier.removeGameOverrides(widget.game.packageName);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
