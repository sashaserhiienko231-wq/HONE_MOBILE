import 'dart:async';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWindowService {
  static Future<bool> requestPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      final bool? granted = await FlutterOverlayWindow.requestPermission();
      return granted ?? false;
    }
    return true;
  }

  static Future<void> showOverlay() async {
    final bool granted = await requestPermission();
    if (!granted) return;

    if (await FlutterOverlayWindow.isActive()) {
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.topRight,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: 250,
      width: 200,
      overlayTitle: "Hone Game Booster",
      overlayContent: "Monitoring performance",
    );
  }

  static Future<void> hideOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<bool> isActive() async {
    return await FlutterOverlayWindow.isActive();
  }

  static Future<void> sendDataToOverlay(Map<String, dynamic> data) async {
    if (await isActive()) {
      await FlutterOverlayWindow.shareData(data);
    }
  }
}
