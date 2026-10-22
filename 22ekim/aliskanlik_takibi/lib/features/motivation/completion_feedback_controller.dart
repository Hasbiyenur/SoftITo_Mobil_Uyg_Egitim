import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/motivation/motivation_repository.dart';
import 'motivation_controller.dart';

enum CelebrationType { none, message, sparkle, flame }

class CompletionFeedbackController extends ChangeNotifier {
  final MotivationRepository motivationRepository;
  final MotivationController? motivationController;

  CelebrationType _activeCelebration = CelebrationType.none;
  String _activeMessage = '';
  Timer? _celebrationTimer;
  bool _isCelebrating = false;

  CompletionFeedbackController({
    required this.motivationRepository,
    this.motivationController,
  });

  CelebrationType get activeCelebration => _activeCelebration;
  String get activeMessage => _activeMessage;
  bool get isCelebrating => _isCelebrating;

  /// Görev ilk kez tamamlandığında çağrılır
  void triggerCelebration({
    required String mode, // 'message', 'sparkle', 'flame', 'off'
    String? habitTitle,
  }) {
    if (mode == 'off') return;

    // Maskotun periyodik balonunu ertele
    motivationController?.postponePeriodicMessage();

    // Hızlı ardışık tamamlamalarda mevcut zamanlayıcıyı sıfırla ve birleşik mesaj göster
    _celebrationTimer?.cancel();

    final msg = motivationRepository.getCompletionMessage();
    _activeMessage = habitTitle != null
        ? '${habitTitle.trim()} tamamlandı! ${msg.text}'
        : msg.text;

    switch (mode) {
      case 'sparkle':
        _activeCelebration = CelebrationType.sparkle;
        _isCelebrating = true;
        notifyListeners();
        // 1.5 saniye sonra kapat
        _celebrationTimer = Timer(const Duration(milliseconds: 1500), () {
          _reset();
        });
        break;

      case 'flame':
        _activeCelebration = CelebrationType.flame;
        _isCelebrating = true;
        notifyListeners();
        // 1.5 saniye sonra kapat
        _celebrationTimer = Timer(const Duration(milliseconds: 1500), () {
          _reset();
        });
        break;

      case 'message':
      default:
        _activeCelebration = CelebrationType.message;
        _isCelebrating = true;
        notifyListeners();
        // 2.5 saniye görünür kalır
        _celebrationTimer = Timer(const Duration(milliseconds: 2500), () {
          _reset();
        });
        break;
    }
  }

  void _reset() {
    _activeCelebration = CelebrationType.none;
    _isCelebrating = false;
    _activeMessage = '';
    notifyListeners();
  }

  void dismissNow() {
    _celebrationTimer?.cancel();
    _reset();
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }
}
