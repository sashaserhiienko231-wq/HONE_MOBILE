import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final String releaseChannel;
  final String engineVersion;
  final String flutterVersion;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.releaseChannel,
    required this.engineVersion,
    required this.flutterVersion,
  });
}

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return AppInfo(
    appName: 'Gaming Hub Ultimate',
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
    releaseChannel: 'Stable',
    engineVersion: Platform.version.split(' ').first,
    flutterVersion: 'Flutter SDK',
  );
});
