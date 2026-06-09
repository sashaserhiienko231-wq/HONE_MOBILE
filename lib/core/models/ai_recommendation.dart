import 'package:flutter/material.dart';

enum RecommendationType {
  optimization,
  thermal,
  memory,
  battery,
  gaming,
  device,
  network,
  storage,
  system,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

enum RecommendationImpact {
  low,
  medium,
  high,
  critical,
}

class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final double confidence;
  final List<String> actions;
  final RecommendationImpact impact;
  final String estimatedBenefit;
  final DateTime timestamp;
  final bool isApplied;
  final bool isDismissed;
  final Map<String, dynamic> metadata;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.confidence,
    required this.actions,
    required this.impact,
    required this.estimatedBenefit,
    required this.timestamp,
    this.isApplied = false,
    this.isDismissed = false,
    this.metadata = const {},
  });

  AIRecommendation copyWith({
    String? id,
    String? title,
    String? description,
    RecommendationType? type,
    RecommendationPriority? priority,
    double? confidence,
    List<String>? actions,
    RecommendationImpact? impact,
    String? estimatedBenefit,
    DateTime? timestamp,
    bool? isApplied,
    bool? isDismissed,
    Map<String, dynamic>? metadata,
  }) {
    return AIRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      confidence: confidence ?? this.confidence,
      actions: actions ?? this.actions,
      impact: impact ?? this.impact,
      estimatedBenefit: estimatedBenefit ?? this.estimatedBenefit,
      timestamp: timestamp ?? this.timestamp,
      isApplied: isApplied ?? this.isApplied,
      isDismissed: isDismissed ?? this.isDismissed,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'confidence': confidence,
      'actions': actions,
      'impact': impact.name,
      'estimatedBenefit': estimatedBenefit,
      'timestamp': timestamp.toIso8601String(),
      'isApplied': isApplied,
      'isDismissed': isDismissed,
      'metadata': metadata,
    };
  }

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RecommendationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => RecommendationType.optimization,
      ),
      priority: RecommendationPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => RecommendationPriority.medium,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      actions: (json['actions'] as List).cast<String>(),
      impact: RecommendationImpact.values.firstWhere(
        (impact) => impact.name == json['impact'],
        orElse: () => RecommendationImpact.medium,
      ),
      estimatedBenefit: json['estimatedBenefit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isApplied: json['isApplied'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Helper methods
  String get priorityEmoji {
    switch (priority) {
      case RecommendationPriority.critical:
        return '🔴';
      case RecommendationPriority.high:
        return '🟠';
      case RecommendationPriority.medium:
        return '🟡';
      case RecommendationPriority.low:
        return '🟢';
    }
  }

  String get impactEmoji {
    switch (impact) {
      case RecommendationImpact.critical:
        return '⚡';
      case RecommendationImpact.high:
        return '🚀';
      case RecommendationImpact.medium:
        return '📈';
      case RecommendationImpact.low:
        return '📊';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case RecommendationPriority.critical:
        return const Color(0xFFE74C3C);
      case RecommendationPriority.high:
        return const Color(0xFFE67E22);
      case RecommendationPriority.medium:
        return const Color(0xFFF39C12);
      case RecommendationPriority.low:
        return const Color(0xFF2ECC71);
    }
  }

  Color get typeColor {
    switch (type) {
      case RecommendationType.optimization:
        return const Color(0xFF3498DB);
      case RecommendationType.thermal:
        return const Color(0xFFE74C3C);
      case RecommendationType.memory:
        return const Color(0xFF9B59B6);
      case RecommendationType.battery:
        return const Color(0xFF2ECC71);
      case RecommendationType.gaming:
        return const Color(0xFFE67E22);
      case RecommendationType.device:
        return const Color(0xFF34495E);
      case RecommendationType.network:
        return const Color(0xFF1ABC9C);
      case RecommendationType.storage:
        return const Color(0xFF95A5A6);
      case RecommendationType.system:
        return const Color(0xFF34495E);
    }
  }

  String get typeIcon {
    switch (type) {
      case RecommendationType.optimization:
        return '⚙️';
      case RecommendationType.thermal:
        return '🌡️';
      case RecommendationType.memory:
        return '💾';
      case RecommendationType.battery:
        return '🔋';
      case RecommendationType.gaming:
        return '🎮';
      case RecommendationType.device:
        return '📱';
      case RecommendationType.network:
        return '🌐';
      case RecommendationType.storage:
        return '💿';
      case RecommendationType.system:
        return '🖥️';
    }
  }

  bool get isExpired {
    return DateTime.now().difference(timestamp).inHours > 24;
  }

  bool get canApply {
    return !isApplied && !isDismissed && !isExpired;
  }
}

class RecommendationHistory {
  final String id;
  final AIRecommendation recommendation;
  final RecommendationAction action;
  final DateTime timestamp;
  final String? result;
  final bool success;

  RecommendationHistory({
    required this.id,
    required this.recommendation,
    required this.action,
    required this.timestamp,
    this.result,
    required this.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommendation': recommendation.toJson(),
      'action': action.name,
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'success': success,
    };
  }

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      id: json['id'] as String,
      recommendation: AIRecommendation.fromJson(json['recommendation']),
      action: RecommendationAction.values.firstWhere(
        (action) => action.name == json['action'],
        orElse: () => RecommendationAction.applied,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      result: json['result'] as String?,
      success: json['success'] as bool,
    );
  }
}

enum RecommendationAction {
  applied,
  dismissed,
  expired,
  failed,
}

class AIModelMetrics {
  final int totalRecommendations;
  final int appliedRecommendations;
  final int dismissedRecommendations;
  final double averageConfidence;
  final double successRate;
  final Map<RecommendationType, int> typeDistribution;
  final Map<RecommendationPriority, int> priorityDistribution;
  final DateTime lastUpdated;

  AIModelMetrics({
    required this.totalRecommendations,
    required this.appliedRecommendations,
    required this.dismissedRecommendations,
    required this.averageConfidence,
    required this.successRate,
    required this.typeDistribution,
    required this.priorityDistribution,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRecommendations': totalRecommendations,
      'appliedRecommendations': appliedRecommendations,
      'dismissedRecommendations': dismissedRecommendations,
      'averageConfidence': averageConfidence,
      'successRate': successRate,
      'typeDistribution': typeDistribution.map((k, v) => MapEntry(k.name, v)),
      'priorityDistribution': priorityDistribution.map((k, v) => MapEntry(k.name, v)),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AIModelMetrics.fromJson(Map<String, dynamic> json) {
    return AIModelMetrics(
      totalRecommendations: json['totalRecommendations'] as int,
      appliedRecommendations: json['appliedRecommendations'] as int,
      dismissedRecommendations: json['dismissedRecommendations'] as int,
      averageConfidence: (json['averageConfidence'] as num).toDouble(),
      successRate: (json['successRate'] as num).toDouble(),
      typeDistribution: Map.from(json['typeDistribution']).map((k, v) => 
        MapEntry(RecommendationType.values.firstWhere((type) => type.name == k), v as int)),
      priorityDistribution: Map.from(json['priorityDistribution']).map((k, v) => 
        MapEntry(RecommendationPriority.values.firstWhere((priority) => priority.name == k), v as int)),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class RecommendationFeedback {
  final String recommendationId;
  final bool wasHelpful;
  final String? comment;
  final int rating; // 1-5 stars
  final DateTime timestamp;

  RecommendationFeedback({
    required this.recommendationId,
    required this.wasHelpful,
    this.comment,
    required this.rating,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'recommendationId': recommendationId,
      'wasHelpful': wasHelpful,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RecommendationFeedback.fromJson(Map<String, dynamic> json) {
    return RecommendationFeedback(
      recommendationId: json['recommendationId'] as String,
      wasHelpful: json['wasHelpful'] as bool,
      comment: json['comment'] as String?,
      rating: json['rating'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class RecommendationBatch {
  final String id;
  final String name;
  final String description;
  final List<AIRecommendation> recommendations;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final bool isApplied;

  RecommendationBatch({
    required this.id,
    required this.name,
    required this.description,
    required this.recommendations,
    required this.createdAt,
    this.appliedAt,
    this.isApplied = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'appliedAt': appliedAt?.toIso8601String(),
      'isApplied': isApplied,
    };
  }

  factory RecommendationBatch.fromJson(Map<String, dynamic> json) {
    return RecommendationBatch(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      recommendations: (json['recommendations'] as List)
          .map((r) => AIRecommendation.fromJson(r))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      appliedAt: json['appliedAt'] != null 
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
      isApplied: json['isApplied'] as bool? ?? false,
    );
  }
}
