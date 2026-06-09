import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class PerformanceOverlayWindow extends StatefulWidget {
  const PerformanceOverlayWindow({super.key});

  @override
  State<PerformanceOverlayWindow> createState() => _PerformanceOverlayWindowState();
}

class _PerformanceOverlayWindowState extends State<PerformanceOverlayWindow> {
  String fps = '0';
  String cpu = '0%';
  String ram = '0%';
  String temp = '0°C';

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null && event is Map) {
        setState(() {
          fps = event['fps']?.toString() ?? fps;
          cpu = event['cpu']?.toString() ?? cpu;
          ram = event['ram']?.toString() ?? ram;
          temp = event['temp']?.toString() ?? temp;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('HONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                GestureDetector(
                  onTap: () => FlutterOverlayWindow.closeOverlay(),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMetricRow('FPS', fps, Colors.greenAccent),
            _buildMetricRow('CPU', cpu, Colors.orangeAccent),
            _buildMetricRow('RAM', ram, Colors.blueAccent),
            _buildMetricRow('TEMP', temp, Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label:', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
