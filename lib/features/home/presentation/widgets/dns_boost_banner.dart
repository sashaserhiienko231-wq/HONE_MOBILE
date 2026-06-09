import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';
import 'package:hone_mobile/core/theme/spacing.dart';

class DnsBoostBanner extends StatelessWidget {
  const DnsBoostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.push('/dns_boost'),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 12.w : 16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.cardDark.withValues(alpha: 0.8),
                const Color(0xFF191136).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.neonPurple.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 8.w : 10.w),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.bolt, color: AppTheme.neonPurple, size: compact ? 22.w : 26.w),
              ),
              SizedBox(width: AppSpacing.gap(width)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.dnsBoostTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 13.sp : 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10n.dnsBoostBadge,
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.dnsBoostDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white60, fontSize: compact ? 10.sp : 11.sp),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white38, size: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}
