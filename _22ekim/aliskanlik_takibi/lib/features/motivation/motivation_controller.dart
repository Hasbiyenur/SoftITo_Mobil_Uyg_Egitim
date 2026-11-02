import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/motivation_preferences.dart';
import '../../data/motivation/motivation_repository.dart';

class MotivationController extends ChangeNotifier {
  final MotivationRepository repository;

  MotivationPreferences _preferences = const MotivationPreferences(userId: '');
  bool _isInitialized = false;

  // Maskot ve Konuşma Balonu Durumu
  bool _isBubbleVisible = false;
  String? _currentMessageText;
  final List<String> _recentMessageIds = [];

  // Zamanlayıcılar
  Timer? _initialTimer;
  Timer? _periodicTimer;
  Timer? _bubbleDismissTimer;
  DateTime? _lastManualTapTime;
  bool _isPaused = false;

  MotivationController({required this.repository});

  MotivationPreferences get preferences => _preferences;
  bool get isBubbleVisible => _isBubbleVisible && _preferences.mascotEnabled;
  String? get currentMessageText => _currentMessageText;
  bool get isMascotEnabled => _preferences.mascotEnabled;
  bool get isInitialized => _isInitialized;

  /// Kullanıcı oturum açtığında veya açılışta başlatır
  Future<void> initUser(String userId) async {
    _preferences = await repository.getPreferences(userId);
    await repository.initialize(userId);
    _isInitialized = true;
    notifyListeners();

    if (_preferences.mascotEnabled) {
      _startTimers();
    }
  }

  /// Zamanlayıcıları başlatır: İlk mesaj 15 sn, sonrakiler intervalMinutes (varsayılan 5 dk)
  void _startTimers() {
    _cancelTimers();
    if (!_preferences.mascotEnabled) return;

    // 15 saniyelik ilk karşılama mesajı
    _initialTimer = Timer(const Duration(seconds: 15), () {
      if (!_isPaused && _preferences.mascotEnabled) {
        showNextMessage();
      }
      _startPeriodicTimer();
    });
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel();
    if (!_preferences.mascotEnabled) return;

    final interval = Duration(minutes: _preferences.intervalMinutes);
    _periodicTimer = Timer.periodic(interval, (_) {
      if (!_isPaused && _preferences.mascotEnabled) {
        showNextMessage();
      }
    });
  }

  /// Kutlama esnasında periyodik balonun çıkmasını ertele
  void postponePeriodicMessage() {
    dismissBubble();
    _startPeriodicTimer();
  }

  /// Yeni bir motivasyon mesajı gösterir (6 saniye görünür kalır)
  void showNextMessage() {
    final msg = repository.getNextMascotMessage(recentIds: _recentMessageIds);

    _recentMessageIds.add(msg.id);
    if (_recentMessageIds.length > 5) {
      _recentMessageIds.removeAt(0);
    }

    _currentMessageText = msg.text;
    _isBubbleVisible = true;
    notifyListeners();

    // Yaklaşık 6 saniye sonra otomatik kapanma
    _bubbleDismissTimer?.cancel();
    _bubbleDismissTimer = Timer(const Duration(seconds: 6), () {
      dismissBubble();
    });
  }

  /// Maskota kullanıcı dokunduğunda çalışır (en az 10 saniye aralıkla yeni cümle)
  void onMascotTapped() {
    final now = DateTime.now();
    if (_lastManualTapTime != null) {
      final diff = now.difference(_lastManualTapTime!).inSeconds;
      if (diff < 10 && _isBubbleVisible) {
        // Zaten yeni açılmış balona ardı ardına basılmasını filtrele
        return;
      }
    }
    _lastManualTapTime = now;
    showNextMessage();
  }

  /// Balonu manuel veya dokunarak kapat
  void dismissBubble() {
    if (_isBubbleVisible) {
      _isBubbleVisible = false;
      _bubbleDismissTimer?.cancel();
      notifyListeners();
    }
  }

  /// Uygulama arka plana geçtiğinde veya diyalog/klavye açıldığında duraklat
  void pause() {
    _isPaused = true;
  }

  /// Uygulama ön plana döndüğünde devam ettir
  void resume() {
    _isPaused = false;
  }

  /// Tercihleri güncelle ve kaydet
  Future<void> updatePreferences(MotivationPreferences newPrefs) async {
    _preferences = newPrefs;
    notifyListeners();
    await repository.savePreferences(newPrefs.userId, newPrefs);

    if (!_preferences.mascotEnabled) {
      dismissBubble();
      _cancelTimers();
    } else {
      _startPeriodicTimer();
    }
  }

  void _cancelTimers() {
    _initialTimer?.cancel();
    _periodicTimer?.cancel();
    _bubbleDismissTimer?.cancel();
  }

  /// Çıkış yapıldığında temizle
  void clear() {
    _cancelTimers();
    _isBubbleVisible = false;
    _currentMessageText = null;
    _recentMessageIds.clear();
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
