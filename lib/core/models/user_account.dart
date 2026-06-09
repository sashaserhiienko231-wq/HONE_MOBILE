import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAccount {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? bio;
  final bool isGuest;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  final List<String> deviceIds;
  final SubscriptionInfo? subscription;
  final UserStats stats;

  const UserAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.bio,
    required this.isGuest,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.preferences,
    required this.deviceIds,
    this.subscription,
    required this.stats,
  });

  factory UserAccount.create(User firebaseUser) {
    return UserAccount(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'User',
      photoURL: firebaseUser.photoURL,
      bio: null,
      isGuest: false,
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: {},
      deviceIds: [],
      subscription: null,
      stats: UserStats.empty(),
    );
  }

  factory UserAccount.guest() {
    return UserAccount(
      id: 'guest',
      email: 'guest@hone.mobile',
      displayName: 'Guest User',
      photoURL: null,
      bio: 'Guest user with limited functionality',
      isGuest: true,
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: {
        'theme': 'dark',
        'notifications': true,
        'auto_optimization': true,
        'guest_mode': true,
      },
      deviceIds: [],
      subscription: null,
      stats: UserStats.empty(),
    );
  }

  UserAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    bool? isGuest,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    List<String>? deviceIds,
    SubscriptionInfo? subscription,
    UserStats? stats,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      isGuest: isGuest ?? this.isGuest,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      deviceIds: deviceIds ?? this.deviceIds,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'isGuest': isGuest,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'preferences': preferences,
      'deviceIds': deviceIds,
      'subscription': subscription?.toJson(),
      'stats': stats.toJson(),
    };
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      bio: json['bio'] as String?,
      isGuest: json['isGuest'] as bool,
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      deviceIds: (json['deviceIds'] as List).cast<String>(),
      subscription: json['subscription'] != null 
          ? SubscriptionInfo.fromJson(json['subscription'])
          : null,
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'isGuest': isGuest,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'preferences': preferences,
      'deviceIds': deviceIds,
      'subscription': subscription?.toFirebaseMap(),
      'stats': stats.toFirebaseMap(),
    };
  }

  factory UserAccount.fromFirebase(Map<String, dynamic> data, User firebaseUser) {
    return UserAccount(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoURL: data['photoURL'] as String?,
      bio: data['bio'] as String?,
      isGuest: data['isGuest'] as bool? ?? false,
      isPremium: data['isPremium'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      deviceIds: (data['deviceIds'] as List).cast<String>(),
      subscription: data['subscription'] != null 
          ? SubscriptionInfo.fromFirebase(data['subscription'])
          : null,
      stats: UserStats.fromFirebase(data['stats'] as Map<String, dynamic>),
    );
  }

  // Helper methods
  String get initials {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  String get displayNameOrEmail {
    return displayName.isNotEmpty ? displayName : email.split('@')[0];
  }

  bool get hasPhotoURL => photoURL != null && photoURL!.isNotEmpty;

  String get statusEmoji {
    if (isGuest) return '👤';
    if (isPremium) return '💎';
    return '👤';
  }

  String get statusText {
    if (isGuest) return 'Guest';
    if (isPremium) return 'Premium';
    return 'Free';
  }

  Color get statusColor {
    if (isGuest) return Colors.grey;
    if (isPremium) return Colors.amber;
    return Colors.blue;
  }

  // Preference getters
  bool get darkTheme => preferences['theme'] == 'dark';
  bool get notificationsEnabled => preferences['notifications'] ?? true;
  bool get autoOptimization => preferences['auto_optimization'] ?? true;
  bool get guestMode => preferences['guest_mode'] ?? false;
  
  // Stats helpers
  int get totalOptimizations => stats.totalOptimizations;
  int get successfulOptimizations => stats.successfulOptimizations;
  double get successRate => stats.successRate;
  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;

  // Subscription helpers
  bool get hasActiveSubscription => subscription?.isActive ?? false;
  bool get isSubscriptionActive => hasActiveSubscription;
  String? get subscriptionType => subscription?.type;
  DateTime? get subscriptionExpiry => subscription?.expiryDate;

  // Device management
  void addDeviceId(String deviceId) {
    if (!deviceIds.contains(deviceId)) {
      deviceIds.add(deviceId);
    }
  }

  void removeDeviceId(String deviceId) {
    deviceIds.remove(deviceId);
  }

  bool get hasMultipleDevices => deviceIds.length > 1;

  // Validation
  bool get isValidEmail {
    return email.contains('@') && email.contains('.');
  }

  bool get hasValidDisplayName {
    return displayName.trim().isNotEmpty && displayName.length >= 2;
  }
}

class SubscriptionInfo {
  final String id;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime? expiryDate;
  final double price;
  final String currency;
  final Map<String, dynamic> features;
  final DateTime createdAt;
  final DateTime? cancelledAt;

  const SubscriptionInfo({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    this.expiryDate,
    required this.price,
    required this.currency,
    required this.features,
    required this.createdAt,
    this.cancelledAt,
  });

  bool get isActive => status == 'active' && (expiryDate == null || expiryDate!.isAfter(DateTime.now()));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'price': price,
      'currency': currency,
      'features': features,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      features: Map<String, dynamic>.from(json['features'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'price': price,
      'currency': currency,
      'features': features,
      'createdAt': Timestamp.fromDate(createdAt),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  factory SubscriptionInfo.fromFirebase(Map<String, dynamic> data) {
    return SubscriptionInfo(
      id: data['id'] as String,
      type: data['type'] as String,
      status: data['status'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: data['expiryDate'] != null 
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] as String,
      features: Map<String, dynamic>.from(data['features'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class UserStats {
  final int totalOptimizations;
  final int successfulOptimizations;
  final int failedOptimizations;
  final double successRate;
  final int totalCleanedStorage;
  final int gamesOptimized;
  final int hoursSaved;
  final DateTime? lastOptimization;
  final Map<String, int> optimizationCounts;
  final Map<String, double> performanceImprovements;

  const UserStats({
    required this.totalOptimizations,
    required this.successfulOptimizations,
    required this.failedOptimizations,
    required this.successRate,
    required this.totalCleanedStorage,
    required this.gamesOptimized,
    required this.hoursSaved,
    required this.lastOptimization,
    required this.optimizationCounts,
    required this.performanceImprovements,
  });

  static UserStats empty() {
    return const UserStats(
      totalOptimizations: 0,
      successfulOptimizations: 0,
      failedOptimizations: 0,
      successRate: 0.0,
      totalCleanedStorage: 0,
      gamesOptimized: 0,
      hoursSaved: 0,
      lastOptimization: null,
      optimizationCounts: {},
      performanceImprovements: {},
    );
  }

  UserStats copyWith({
    int? totalOptimizations,
    int? successfulOptimizations,
    int? failedOptimizations,
    double? successRate,
    int? totalCleanedStorage,
    int? gamesOptimized,
    int? hoursSaved,
    DateTime? lastOptimization,
    Map<String, int>? optimizationCounts,
    Map<String, double>? performanceImprovements,
  }) {
    return UserStats(
      totalOptimizations: totalOptimizations ?? this.totalOptimizations,
      successfulOptimizations: successfulOptimizations ?? this.successfulOptimizations,
      failedOptimizations: failedOptimizations ?? this.failedOptimizations,
      successRate: successRate ?? this.successRate,
      totalCleanedStorage: totalCleanedStorage ?? this.totalCleanedStorage,
      gamesOptimized: gamesOptimized ?? this.gamesOptimized,
      hoursSaved: hoursSaved ?? this.hoursSaved,
      lastOptimization: lastOptimization ?? this.lastOptimization,
      optimizationCounts: optimizationCounts ?? this.optimizationCounts,
      performanceImprovements: performanceImprovements ?? this.performanceImprovements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOptimizations': totalOptimizations,
      'successfulOptimizations': successfulOptimizations,
      'failedOptimizations': failedOptimizations,
      'successRate': successRate,
      'totalCleanedStorage': totalCleanedStorage,
      'gamesOptimized': gamesOptimized,
      'hoursSaved': hoursSaved,
      'lastOptimization': lastOptimization?.toIso8601String(),
      'optimizationCounts': optimizationCounts,
      'performanceImprovements': performanceImprovements,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOptimizations: json['totalOptimizations'] as int,
      successfulOptimizations: json['successfulOptimizations'] as int,
      failedOptimizations: json['failedOptimizations'] as int,
      successRate: (json['successRate'] as num).toDouble(),
      totalCleanedStorage: json['totalCleanedStorage'] as int,
      gamesOptimized: json['gamesOptimized'] as int,
      hoursSaved: json['hoursSaved'] as int,
      lastOptimization: json['lastOptimization'] != null 
          ? DateTime.parse(json['lastOptimization'] as String)
          : null,
      optimizationCounts: Map<String, int>.from(json['optimizationCounts'] ?? {}),
      performanceImprovements: Map<String, double>.from(json['performanceImprovements'] ?? {}),
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'totalOptimizations': totalOptimizations,
      'successfulOptimizations': successfulOptimizations,
      'failedOptimizations': failedOptimizations,
      'successRate': successRate,
      'totalCleanedStorage': totalCleanedStorage,
      'gamesOptimized': gamesOptimized,
      'hoursSaved': hoursSaved,
      'lastOptimization': lastOptimization != null 
          ? Timestamp.fromDate(lastOptimization!)
          : null,
      'optimizationCounts': optimizationCounts,
      'performanceImprovements': performanceImprovements,
    };
  }

  factory UserStats.fromFirebase(Map<String, dynamic> data) {
    return UserStats(
      totalOptimizations: data['totalOptimizations'] as int,
      successfulOptimizations: data['successfulOptimizations'] as int,
      failedOptimizations: data['failedOptimizations'] as int,
      successRate: (data['successRate'] as num).toDouble(),
      totalCleanedStorage: data['totalCleanedStorage'] as int,
      gamesOptimized: data['gamesOptimized'] as int,
      hoursSaved: data['hoursSaved'] as int,
      lastOptimization: data['lastOptimization'] != null 
          ? (data['lastOptimization'] as Timestamp).toDate()
          : null,
      optimizationCounts: Map<String, int>.from(data['optimizationCounts'] ?? {}),
      performanceImprovements: Map<String, double>.from(data['performanceImprovements'] ?? {}),
    );
  }

  String get successRateFormatted {
    return '${(100 * successRate).toStringAsFixed(1)}%';
  }

  String get cleanedStorageFormatted {
    if (totalCleanedStorage < 1024) return '${totalCleanedStorage}B';
    if (totalCleanedStorage < 1024 * 1024) return '${(totalCleanedStorage / 1024).toStringAsFixed(1)}KB';
    if (totalCleanedStorage < 1024 * 1024 * 1024) return '${(totalCleanedStorage / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalCleanedStorage / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

class UserProfile {
  final String? avatarUrl;
  final String? bannerUrl;
  final String? status;
  final String? location;
  final String? website;
  final List<String> interests;
  final Map<String, dynamic> socialLinks;
  final Map<String, dynamic> achievements;
  final DateTime? birthDate;

  UserProfile({
    this.avatarUrl,
    this.bannerUrl,
    this.status,
    this.location,
    this.website,
    this.interests = const [],
    this.socialLinks = const {},
    this.achievements = const {},
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'status': status,
      'location': location,
      'website': website,
      'interests': interests,
      'socialLinks': socialLinks,
      'achievements': achievements,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      status: json['status'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      interests: (json['interests'] as List?)?.cast<String>() ?? [],
      socialLinks: Map<String, dynamic>.from(json['socialLinks'] ?? {}),
      achievements: Map<String, dynamic>.from(json['achievements'] ?? {}),
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String)
          : null,
    );
  }
}
