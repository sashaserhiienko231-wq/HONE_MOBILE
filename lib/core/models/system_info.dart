class SystemInfo {
  final String osVersion;
  final String deviceModel;
  final String manufacturer;
  final String androidId;
  final String kernelVersion;
  final String cpuInfo;
  final String memInfo;
  final String cpuFrequency;
  final bool isRooted;

  SystemInfo({
    required this.osVersion,
    required this.deviceModel,
    required this.manufacturer,
    required this.cpuInfo,
    required this.memInfo,
    required this.cpuFrequency,
    this.androidId = '',
    this.kernelVersion = '',
    this.isRooted = false,
  });

  factory SystemInfo.empty() {
    return SystemInfo(
      osVersion: 'Unknown',
      deviceModel: 'Unknown',
      manufacturer: 'Unknown',
      cpuInfo: 'Unknown',
      memInfo: 'Unknown',
      cpuFrequency: '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'androidId': androidId,
      'kernelVersion': kernelVersion,
      'cpuInfo': cpuInfo,
      'memInfo': memInfo,
      'cpuFrequency': cpuFrequency,
      'isRooted': isRooted,
    };
  }
}
