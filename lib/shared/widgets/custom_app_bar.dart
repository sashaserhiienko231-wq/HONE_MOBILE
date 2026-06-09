import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  /// When false, parent [SafeArea] should handle insets (avoids double padding).
  final bool applySafeArea;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBackButton = false,
    this.onBackPressed,
    this.applySafeArea = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 88.h : 72.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withValues(alpha: 204),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: applySafeArea
          ? SafeArea(
              bottom: false,
              child: _buildBarContent(context),
            )
          : _buildBarContent(context),
    );
  }

  Widget _buildBarContent(BuildContext context) {
    return Row(
          children: [
            // Back Button
            if (showBackButton)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.neonGreen.withValues(alpha: 77),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.neonGreen,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
            
            // Title Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 179),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            if (actions.isNotEmpty) ...[
              SizedBox(width: 12.w),
              Row(
                children: actions,
              ),
            ],
          ],
        );
  }
}
