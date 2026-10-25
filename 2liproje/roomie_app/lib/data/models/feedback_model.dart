import 'package:equatable/equatable.dart';

class FeedbackModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String category;
  final String message;
  final int rating;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.message,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'category': category,
      'message': message,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<dynamic, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      category: map['category'] as String? ?? 'Genel',
      message: map['message'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    category,
    message,
    rating,
    createdAt,
  ];
}
