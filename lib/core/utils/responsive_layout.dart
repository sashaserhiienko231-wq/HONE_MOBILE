import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  largePhone,
  tablet,
  largeTablet,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget? phone;
  final Widget? largePhone;
  final Widget? tablet;
  final Widget? largeTablet;

  const ResponsiveLayout({
    super.key,
    this.phone,
    this.largePhone,
    this.tablet,
    this.largeTablet,
  });

  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1201) {
      return DeviceType.largeTablet;
    } else if (width >= 901) {
      return DeviceType.tablet;
    } else if (width >= 721) {
      return DeviceType.largePhone;
    } else {
      return DeviceType.phone;
    }
  }

  static bool isPhone(BuildContext context) => getDeviceType(context) == DeviceType.phone;
  static bool isLargePhone(BuildContext context) => getDeviceType(context) == DeviceType.largePhone;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool isLargeTablet(BuildContext context) => getDeviceType(context) == DeviceType.largeTablet;
  
  static bool isAnyTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tablet || type == DeviceType.largeTablet;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (width >= 1201 && largeTablet != null) {
          return largeTablet!;
        } else if (width >= 901 && tablet != null) {
          return tablet!;
        } else if (width >= 721 && largePhone != null) {
          return largePhone!;
        } else if (phone != null) {
          return phone!;
        }

        // Fallbacks
        if (width >= 901 && largeTablet != null) return largeTablet!;
        if (width >= 721 && tablet != null) return tablet!;
        if (tablet != null) return tablet!;
        if (largePhone != null) return largePhone!;
        if (phone != null) return phone!;
        
        return const SizedBox.shrink();
      },
    );
  }
}
