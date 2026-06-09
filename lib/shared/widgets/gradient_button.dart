import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Widget? child;
  final bool isLoading;
  final bool isDisabled;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 56.h;
    final buttonRadius = borderRadius ?? 16.r;
    
    final start = startColor ?? AppTheme.neonGreen;
    final end = endColor ?? AppTheme.neonBlue;
    
    final isButtonDisabled = isDisabled || isLoading || onPressed == null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: isButtonDisabled
            ? LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.2),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, end],
              ),
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: isButtonDisabled
            ? null
            : [
                BoxShadow(
                  color: start.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: end.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(buttonRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryDark,
                      ),
                    ),
                  )
                : child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: AppTheme.primaryDark, size: 20.sp),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          text,
                          style: textStyle ??
                              TextStyle(
                                color: AppTheme.primaryDark,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class OutlinedGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? startColor;
  final Color? endColor; // reserved for gradient border variants
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Widget? child;
  final bool isLoading;
  final bool isDisabled;

  const OutlinedGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 56.h;
    final buttonRadius = borderRadius ?? 16.r;
    
    final start = startColor ?? AppTheme.neonGreen;
    
    final isButtonDisabled = isDisabled || isLoading || onPressed == null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonRadius),
        border: Border.all(
          color: isButtonDisabled
              ? Colors.grey.withValues(alpha: 0.3)
              : start,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(buttonRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isButtonDisabled ? Colors.grey : start,
                      ),
                    ),
                  )
                : child ??
                    Text(
                      text,
                      style: textStyle ??
                          TextStyle(
                            color: isButtonDisabled ? Colors.grey : start,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                    ),
          ),
        ),
      ),
    );
  }
}
