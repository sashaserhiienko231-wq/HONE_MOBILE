import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  largePhone,
  tablet,
  largeTablet,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? largePhone;
  final Widget? tablet;
  final Widget? largeTablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.largePhone,
    this.tablet,
    this.largeTablet,
  });

  static DeviceType getDeviceType(double width) {
    if (width >= 1201) return DeviceType.largeTablet;
    if (width >= 901) return DeviceType.tablet;
    if (width >= 721) return DeviceType.largePhone;
    return DeviceType.mobile;
  }

  static DeviceType getDeviceTypeFromContext(BuildContext context) =>
      getDeviceType(MediaQuery.sizeOf(context).width);

  static bool isMobile(BuildContext context) {
    final t = getDeviceTypeFromContext(context);
    return t == DeviceType.mobile || t == DeviceType.largePhone;
  }

  static bool isTablet(BuildContext context) {
    final t = getDeviceTypeFromContext(context);
    return t == DeviceType.tablet || t == DeviceType.largeTablet;
  }
  
  static bool isLargeTablet(BuildContext context) =>
      getDeviceTypeFromContext(context) == DeviceType.largeTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final type = getDeviceType(width);

        switch (type) {
          case DeviceType.largeTablet:
            return largeTablet ?? tablet ?? largePhone ?? mobile;
          case DeviceType.tablet:
            return tablet ?? largePhone ?? mobile;
          case DeviceType.largePhone:
            return largePhone ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}
