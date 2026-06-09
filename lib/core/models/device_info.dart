class DeviceInfo {
  final String manufacturer;
  final String model;
  final String version;
  final int sdkInt;
  final String brand;
  final String device;
  final String product;
  final String hardware;
  final String bootloader;
  final List<String> supportedAbis;
  final String systemFeatures;

  DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.version,
    required this.sdkInt,
    required this.brand,
    required this.device,
    required this.product,
    required this.hardware,
    required this.bootloader,
    required this.supportedAbis,
    required this.systemFeatures,
  });

  @override
  String toString() {
    return 'DeviceInfo(manufacturer: $manufacturer, model: $model, version: $version, sdkInt: $sdkInt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo &&
        other.manufacturer == manufacturer &&
        other.model == model &&
        other.version == version &&
        other.sdkInt == sdkInt &&
        other.brand == brand &&
        other.device == device &&
        other.product == product &&
        other.hardware == hardware &&
        other.bootloader == bootloader &&
        other.supportedAbis == supportedAbis &&
        other.systemFeatures == systemFeatures;
  }

  @override
  int get hashCode {
    return manufacturer.hashCode ^
        model.hashCode ^
        version.hashCode ^
        sdkInt.hashCode ^
        brand.hashCode ^
        device.hashCode ^
        product.hashCode ^
        hardware.hashCode ^
        bootloader.hashCode ^
        supportedAbis.hashCode ^
        systemFeatures.hashCode;
  }

  // Helper methods for device identification
  bool get isXiaomi => ['xiaomi', 'redmi', 'poco'].contains(manufacturer.toLowerCase());
  bool get isSamsung => manufacturer.toLowerCase() == 'samsung';
  bool get isOnePlus => manufacturer.toLowerCase() == 'oneplus';
  bool get isGoogle => manufacturer.toLowerCase() == 'google';
  bool get isApple => manufacturer.toLowerCase() == 'apple';
  
  bool get isGamingDevice {
    final gamingKeywords = [
      'rog', 'tencent', 'black shark', 'nubia red magic', 
      'lenovo legion', 'asus', 'gaming'
    ];
    return gamingKeywords.any((keyword) => 
        model.toLowerCase().contains(keyword) || 
        brand.toLowerCase().contains(keyword));
  }

  String get deviceType {
    if (isApple) return 'iOS';
    if (isXiaomi) return 'Xiaomi/Redmi/Poco';
    if (isSamsung) return 'Samsung';
    if (isOnePlus) return 'OnePlus';
    if (isGoogle) return 'Google Pixel';
    return 'Android';
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'version': version,
      'sdkInt': sdkInt,
      'brand': brand,
      'device': device,
      'product': product,
      'hardware': hardware,
      'bootloader': bootloader,
      'supportedAbis': supportedAbis,
      'systemFeatures': systemFeatures,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      version: json['version'] as String,
      sdkInt: json['sdkInt'] as int,
      brand: json['brand'] as String,
      device: json['device'] as String,
      product: json['product'] as String,
      hardware: json['hardware'] as String,
      bootloader: json['bootloader'] as String,
      supportedAbis: (json['supportedAbis'] as List<dynamic>).cast<String>(),
      systemFeatures: json['systemFeatures'] as String,
    );
  }

  DeviceInfo copyWith({
    String? manufacturer,
    String? model,
    String? version,
    int? sdkInt,
    String? brand,
    String? device,
    String? product,
    String? hardware,
    String? bootloader,
    List<String>? supportedAbis,
    String? systemFeatures,
  }) {
    return DeviceInfo(
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      version: version ?? this.version,
      sdkInt: sdkInt ?? this.sdkInt,
      brand: brand ?? this.brand,
      device: device ?? this.device,
      product: product ?? this.product,
      hardware: hardware ?? this.hardware,
      bootloader: bootloader ?? this.bootloader,
      supportedAbis: supportedAbis ?? this.supportedAbis,
      systemFeatures: systemFeatures ?? this.systemFeatures,
    );
  }
  factory DeviceInfo.empty() {
    return DeviceInfo(
      manufacturer: 'Unknown',
      model: 'Unknown',
      version: 'Unknown',
      sdkInt: 0,
      brand: 'Unknown',
      device: 'Unknown',
      product: 'Unknown',
      hardware: 'Unknown',
      bootloader: 'Unknown',
      supportedAbis: [],
      systemFeatures: '',
    );
  }
}
