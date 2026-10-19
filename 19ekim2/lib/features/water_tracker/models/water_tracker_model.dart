class WaterRecordModel {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String label;

  const WaterRecordModel({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.label,
  });

  WaterRecordModel copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
    String? label,
  }) {
    return WaterRecordModel(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
      label: label ?? this.label,
    );
  }

  factory WaterRecordModel.fromJson(Map<String, dynamic> json) {
    return WaterRecordModel(
      id: json['id'] as String? ?? '',
      amountMl: json['amountMl'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      label: json['label'] as String? ?? 'Su',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
      'label': label,
    };
  }
}
