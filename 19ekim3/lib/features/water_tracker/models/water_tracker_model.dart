import 'package:flutter/foundation.dart';

/// İmmutable su tüketim kayıt modeli.
@immutable
class WaterLogItem {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLogItem({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLogItem copyWith({String? id, int? amountMl, DateTime? timestamp}) {
    return WaterLogItem(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WaterLogItem.fromJson(Map<String, dynamic> json) {
    return WaterLogItem(
      id: json['id'] as String? ?? '',
      amountMl: json['amountMl'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'WaterLogItem(id: $id, amountMl: $amountMl, time: $timestamp)';
}
