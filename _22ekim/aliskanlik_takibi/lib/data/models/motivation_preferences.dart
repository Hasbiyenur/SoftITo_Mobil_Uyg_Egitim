import 'package:flutter/foundation.dart';

@immutable
class MotivationPreferences {
  final String userId;
  final bool mascotEnabled;
  final int intervalMinutes; // 3, 5, 10
  final String completionFeedbackMode; // 'message', 'sparkle', 'flame', 'off'
  final bool remoteSourceEnabled;

  const MotivationPreferences({
    required this.userId,
    this.mascotEnabled = true,
    this.intervalMinutes = 5,
    this.completionFeedbackMode = 'message',
    this.remoteSourceEnabled = false,
  });

  /// Varsayılan kullanıcı tercihleri üretir
  factory MotivationPreferences.defaults(String userId) {
    return MotivationPreferences(userId: userId);
  }

  MotivationPreferences copyWith({
    String? userId,
    bool? mascotEnabled,
    int? intervalMinutes,
    String? completionFeedbackMode,
    bool? remoteSourceEnabled,
  }) {
    return MotivationPreferences(
      userId: userId ?? this.userId,
      mascotEnabled: mascotEnabled ?? this.mascotEnabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      completionFeedbackMode:
          completionFeedbackMode ?? this.completionFeedbackMode,
      remoteSourceEnabled: remoteSourceEnabled ?? this.remoteSourceEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'mascotEnabled': mascotEnabled,
    'intervalMinutes': intervalMinutes,
    'completionFeedbackMode': completionFeedbackMode,
    'remoteSourceEnabled': remoteSourceEnabled,
  };

  factory MotivationPreferences.fromJson(Map<String, dynamic> json) {
    return MotivationPreferences(
      userId: json['userId'] as String? ?? '',
      mascotEnabled: json['mascotEnabled'] as bool? ?? true,
      intervalMinutes: (json['intervalMinutes'] as int?) ?? 5,
      completionFeedbackMode:
          json['completionFeedbackMode'] as String? ?? 'message',
      remoteSourceEnabled: json['remoteSourceEnabled'] as bool? ?? false,
    );
  }
}
