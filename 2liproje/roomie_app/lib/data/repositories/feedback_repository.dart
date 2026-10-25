import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../datasources/hive_storage_service.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class FeedbackRepository {
  final HiveStorageService _storage;
  static const _uuid = Uuid();

  FeedbackRepository({HiveStorageService? storage})
    : _storage = storage ?? HiveStorageService.instance;

  List<FeedbackModel> getAllFeedbacks({String? userId}) {
    final List<FeedbackModel> list = [];
    for (var key in _storage.feedbacksBox.keys) {
      final data = _storage.feedbacksBox.get(key);
      if (data is Map) {
        list.add(FeedbackModel.fromMap(Map<dynamic, dynamic>.from(data)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (userId != null && userId.isNotEmpty) {
      return list.where((f) => f.userId == userId).toList();
    }
    return list;
  }

  Future<FeedbackModel> submitFeedback({
    required UserModel user,
    required String category,
    required String message,
    required int rating,
  }) async {
    if (user.id.trim().isEmpty) {
      throw const ValidationFailure(
        'Geri bildirim için geçerli bir kullanıcı kimliği zorunludur.',
      );
    }
    if (category.trim().isEmpty) {
      throw const ValidationFailure('Lütfen bir konu başlığı seçiniz.');
    }
    if (message.trim().isEmpty) {
      throw const ValidationFailure('Lütfen geri bildirim mesajınızı yazınız.');
    }
    if (rating < 1 || rating > 5) {
      throw const ValidationFailure(
        'Değerlendirme puanı 1 ile 5 arasında olmalıdır.',
      );
    }

    final feedback = FeedbackModel(
      id: _uuid.v4(),
      userId: user.id.trim(),
      userName: user.fullName.trim().isNotEmpty
          ? user.fullName.trim()
          : 'Kullanıcı',
      category: category.trim(),
      message: message.trim(),
      rating: rating,
      createdAt: DateTime.now(),
    );

    await _storage.feedbacksBox.put(feedback.id, feedback.toMap());
    return feedback;
  }
}
