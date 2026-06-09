import 'package:flutter/material.dart';
import 'package:hone_mobile/core/navigation/responsive_layout.dart';

class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final type = ResponsiveLayout.getDeviceType(width);

    final horizontal = switch (type) {
      DeviceType.mobile => 16.0,
      DeviceType.largePhone => 20.0,
      DeviceType.tablet => 28.0,
      DeviceType.largeTablet => 32.0,
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: child,
    );
  }
}
