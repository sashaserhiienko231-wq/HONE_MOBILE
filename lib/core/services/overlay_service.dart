import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/services/performance_monitor_service.dart';

class OverlayService {
  static bool _isInitialized = false;
  static bool _isOverlayVisible = false;
  static OverlayEntry? _overlayEntry;
  static StreamController<OverlayData>? _dataController;
  static Timer? _updateTimer;
  
  // Overlay configuration
  static OverlayPosition _position = OverlayPosition.topRight;
  static OverlaySize _size = OverlaySize.small;
  static bool _showFPS = true;
  static bool _showThermal = true;
  static bool _showPing = true;
  static bool _showRAM = true;
  static bool _showCPU = true;
  static double _opacity = 0.8;
  static int _updateInterval = 1000; // ms

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _dataController = StreamController<OverlayData>.broadcast();
      _isInitialized = true;
      
      debugPrint('Overlay Service initialized');
    } catch (e) {
      debugPrint('Error initializing Overlay Service: $e');
    }
  }

  static Future<void> showOverlay({BuildContext? context}) async {
    if (_isOverlayVisible) return;
    
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => _PerformanceOverlay(
          dataStream: _dataController!.stream,
          onClose: hideOverlay,
        ),
      );
      
      Overlay.of(context ?? navigatorKey.currentContext!).insert(_overlayEntry!);
      _isOverlayVisible = true;
      
      // Start data updates
      _startDataUpdates();
      
      debugPrint('Performance overlay shown');
    } catch (e) {
      debugPrint('Error showing overlay: $e');
    }
  }

  static Future<void> hideOverlay() async {
    if (!_isOverlayVisible) return;
    
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
      
      // Stop data updates
      _stopDataUpdates();
      
      debugPrint('Performance overlay hidden');
    } catch (e) {
      debugPrint('Error hiding overlay: $e');
    }
  }

  static void _startDataUpdates() {
    _updateTimer = Timer.periodic(Duration(milliseconds: _updateInterval), (timer) {
      _updateOverlayData();
    });
  }

  static void _stopDataUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  static void _updateOverlayData() {
    if (_dataController == null || _dataController!.isClosed) return;
    
    final stats = PerformanceMonitorService.currentStats;
    final overlayData = OverlayData(
      fps: stats.fps,
      cpuUsage: stats.cpuUsage,
      memoryUsage: stats.memoryUsage,
      temperature: _getTemperature(),
      ping: stats.networkLatency,
      timestamp: DateTime.now(),
    );
    
    _dataController!.add(overlayData);
  }

  static double _getTemperature() {
    // Simulate temperature based on CPU usage
    final cpuUsage = PerformanceMonitorService.currentStats.cpuUsage;
    return 35.0 + (cpuUsage * 0.4); // 35-75°C range
  }

  // Configuration methods
  static void setPosition(OverlayPosition position) {
    _position = position;
    _refreshOverlay();
  }

  static void setSize(OverlaySize size) {
    _size = size;
    _refreshOverlay();
  }

  static void setVisibility({
    bool? showFPS,
    bool? showThermal,
    bool? showPing,
    bool? showRAM,
    bool? showCPU,
  }) {
    _showFPS = showFPS ?? _showFPS;
    _showThermal = showThermal ?? _showThermal;
    _showPing = showPing ?? _showPing;
    _showRAM = showRAM ?? _showRAM;
    _showCPU = showCPU ?? _showCPU;
    _refreshOverlay();
  }

  static void setOpacity(double opacity) {
    _opacity = opacity.clamp(0.1, 1.0);
    _refreshOverlay();
  }

  static void setUpdateInterval(int intervalMs) {
    _updateInterval = intervalMs;
    if (_isOverlayVisible) {
      _stopDataUpdates();
      _startDataUpdates();
    }
  }

  static void _refreshOverlay() {
    if (_isOverlayVisible) {
      hideOverlay();
      showOverlay();
    }
  }

  // Getters
  static bool get isOverlayVisible => _isOverlayVisible;
  static bool get isInitialized => _isInitialized;
  static OverlayPosition get position => _position;
  static OverlaySize get size => _size;
  static double get opacity => _opacity;

  static void dispose() {
    hideOverlay();
    _dataController?.close();
    _dataController = null;
    _isInitialized = false;
  }
}

enum OverlayPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

enum OverlaySize {
  small,
  medium,
  large,
}

class OverlayData {
  final double fps;
  final double cpuUsage;
  final double memoryUsage;
  final double temperature;
  final double ping;
  final DateTime timestamp;

  OverlayData({
    required this.fps,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.temperature,
    required this.ping,
    required this.timestamp,
  });
}

class _PerformanceOverlay extends StatefulWidget {
  final Stream<OverlayData> dataStream;
  final VoidCallback onClose;

  const _PerformanceOverlay({
    required this.dataStream,
    required this.onClose,
  });

  @override
  State<_PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<_PerformanceOverlay> {
  OverlayData? _data;
  late StreamSubscription<OverlayData> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _data = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    return Positioned(
      top: _getTopOffset(size),
      left: _getLeftOffset(size),
      child: GestureDetector(
        onPanUpdate: (details) {
          // Allow dragging the overlay
          // This would need more sophisticated implementation
        },
        child: Opacity(
          opacity: OverlayService.opacity,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16.w,
                      ),
                    ),
                  ],
                ),
                
                // Performance metrics
                if (OverlayService._showFPS)
                  _buildMetricRow('FPS', _data!.fps.toStringAsFixed(0), _getFPSColor()),
                
                if (OverlayService._showCPU)
                  _buildMetricRow('CPU', '${_data!.cpuUsage.toStringAsFixed(1)}%', _getCPUColor()),
                
                if (OverlayService._showRAM)
                  _buildMetricRow('RAM', '${_data!.memoryUsage.toStringAsFixed(1)}%', _getRAMColor()),
                
                if (OverlayService._showThermal)
                  _buildMetricRow('TEMP', '${_data!.temperature.toStringAsFixed(1)}°C', _getTempColor()),
                
                if (OverlayService._showPing)
                  _buildMetricRow('PING', '${_data!.ping.toStringAsFixed(0)}ms', _getPingColor()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getTopOffset(Size size) {
    switch (OverlayService._position) {
      case OverlayPosition.topLeft:
      case OverlayPosition.topRight:
        return 50.h;
      case OverlayPosition.bottomLeft:
      case OverlayPosition.bottomRight:
        return size.height - 150.h;
      case OverlayPosition.center:
        return (size.height - 100.h) / 2;
    }
  }

  double _getLeftOffset(Size size) {
    switch (OverlayService._position) {
      case OverlayPosition.topLeft:
      case OverlayPosition.bottomLeft:
        return 10.w;
      case OverlayPosition.topRight:
      case OverlayPosition.bottomRight:
        return size.width - 150.w;
      case OverlayPosition.center:
        return (size.width - 120.w) / 2;
    }
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Color _getFPSColor() {
    if (_data!.fps >= 55) return AppTheme.neonGreen;
    if (_data!.fps >= 30) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }

  Color _getCPUColor() {
    if (_data!.cpuUsage <= 60) return AppTheme.neonGreen;
    if (_data!.cpuUsage <= 80) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }

  Color _getRAMColor() {
    if (_data!.memoryUsage <= 70) return AppTheme.neonGreen;
    if (_data!.memoryUsage <= 85) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }

  Color _getTempColor() {
    if (_data!.temperature <= 45) return AppTheme.neonGreen;
    if (_data!.temperature <= 70) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }

  Color _getPingColor() {
    if (_data!.ping <= 50) return AppTheme.neonGreen;
    if (_data!.ping <= 100) return AppTheme.neonOrange;
    return AppTheme.accentRed;
  }
}

// Global navigator key for overlay access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
