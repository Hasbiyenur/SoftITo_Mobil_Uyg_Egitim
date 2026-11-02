import 'dart:math';

import '../models/motivation_message.dart';
import '../models/motivation_preferences.dart';
import '../repositories/habit_repository.dart';
import 'hugging_face_motivation_source.dart';
import 'local_motivation_messages.dart';

class MotivationRepository {
  final HabitRepository habitRepository;
  final HuggingFaceMotivationSource remoteSource;

  List<MotivationMessage> _memoryCache = [];
  bool _initialized = false;

  MotivationRepository({
    required this.habitRepository,
    this.remoteSource = const HuggingFaceMotivationSource(),
  });

  Future<void> initialize(String userId) async {
    if (_initialized) return;

    final prefs = await habitRepository.getMotivationPreferences(userId);
    final cached = await habitRepository.getMotivationCache();

    if (cached.isNotEmpty) {
      _memoryCache = cached;
    }

    // Uzak kaynak tercih edilmişse ve veri 24 saatten eskiyse arka planda dene
    if (prefs.remoteSourceEnabled) {
      _tryRefreshRemote();
    }

    _initialized = true;
  }

  Future<void> _tryRefreshRemote() async {
    try {
      final remoteList = await remoteSource.fetchRemoteMessages();
      if (remoteList != null && remoteList.isNotEmpty) {
        _memoryCache = remoteList;
        await habitRepository.saveMotivationCache(
          remoteList,
          DateTime.now().toUtc().toIso8601String(),
        );
      }
    } catch (_) {
      // Arka plan yenileme hatası kritik değildir
    }
  }

  /// Maskot için gösterilecek bir sonraki motivasyon cümlesini seçer.
  /// Son 5 cümleyi (recentIds) tekrar etmemeye özen gösterir.
  MotivationMessage getNextMascotMessage({required List<String> recentIds}) {
    final pool = <MotivationMessage>[
      ...LocalMotivationMessages.generalMessages,
      ..._memoryCache.where((m) => m.category == 'general'),
    ];

    final candidates = pool.where((m) => !recentIds.contains(m.id)).toList();
    final sourceList = candidates.isNotEmpty ? candidates : pool;

    final random = Random();
    return sourceList[random.nextInt(sourceList.length)];
  }

  /// Görev tamamlandığında kutlama için kısa bir cümle seçer.
  MotivationMessage getCompletionMessage() {
    final list = LocalMotivationMessages.completionMessages;
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  /// Kullanıcının motivasyon tercihlerini getirir
  Future<MotivationPreferences> getPreferences(String userId) {
    return habitRepository.getMotivationPreferences(userId);
  }

  /// Kullanıcının motivasyon tercihlerini kaydeder
  Future<void> savePreferences(
    String userId,
    MotivationPreferences preferences,
  ) {
    return habitRepository.saveMotivationPreferences(userId, preferences);
  }
}
