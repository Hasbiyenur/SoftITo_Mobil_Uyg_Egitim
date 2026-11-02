import 'package:flutter/foundation.dart';

@immutable
class MotivationMessage {
  final String id;
  final String text;
  final String language; // 'tr'
  final String category; // 'general', 'completion'
  final String source; // 'local', 'huggingface'
  final String? sourceUrl;
  final String? license;

  const MotivationMessage({
    required this.id,
    required this.text,
    this.language = 'tr',
    this.category = 'general',
    this.source = 'local',
    this.sourceUrl,
    this.license,
  });

  MotivationMessage copyWith({
    String? id,
    String? text,
    String? language,
    String? category,
    String? source,
    String? sourceUrl,
    String? license,
  }) {
    return MotivationMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      language: language ?? this.language,
      category: category ?? this.category,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      license: license ?? this.license,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'language': language,
    'category': category,
    'source': source,
    'sourceUrl': sourceUrl,
    'license': license,
  };

  factory MotivationMessage.fromJson(Map<String, dynamic> json) {
    return MotivationMessage(
      id:
          json['id'] as String? ??
          'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: json['text'] as String? ?? '',
      language: json['language'] as String? ?? 'tr',
      category: json['category'] as String? ?? 'general',
      source: json['source'] as String? ?? 'local',
      sourceUrl: json['sourceUrl'] as String?,
      license: json['license'] as String?,
    );
  }
}
