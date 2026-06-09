import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/app_info_provider.dart';
import 'package:hone_mobile/core/compatibility/device_compatibility_engine.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';

/// Application version block for Settings (mobile + tablet).
class AppVersionSection extends ConsumerWidget {
  const AppVersionSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return appInfoAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 8 : 16.h),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      ),
      error: (e, _) => _VersionCard(
        compact: compact,
        lines: const [
          'Gaming Hub Ultimate',
          'Version unavailable',
        ],
      ),
      data: (info) => FutureBuilder<DeviceProfile>(
        future: DeviceCompatibilityEngine.resolve(context),
        builder: (context, deviceSnap) {
          final lines = <String>[
            info.appName,
            'Version ${info.version}',
            'Build ${info.buildNumber}',
            'Release ${info.releaseChannel}',
            'Engine ${info.engineVersion}',
            'Flutter ${info.flutterVersion}',
          ];
          if (deviceSnap.hasData) {
            lines.add(
              AppLocalizations.of(context).optimizedForDevice(deviceSnap.data!.displayName),
            );
          }
          return _VersionCard(compact: compact, lines: lines);
        },
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.lines, required this.compact});

  final List<String> lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(compact ? 16 : 20.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: AppTheme.neonGreen, size: compact ? 22 : 24.sp),
              SizedBox(width: compact ? 8 : 10.w),
              Text(
                AppLocalizations.of(context).applicationSection,
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: compact ? 13 : 13.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 16.h),
          ...List.generate(lines.length, (index) {
            final line = lines[index];
            return Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 6.h),
              child: Text(
                line,
                style: TextStyle(
                  color: index == 0 ? Colors.white : Colors.white70,
                  fontSize: index == 0
                      ? (compact ? 18 : 18.sp)
                      : (compact ? 14 : 14.sp),
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
