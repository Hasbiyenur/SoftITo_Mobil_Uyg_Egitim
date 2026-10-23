import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/time/date_key.dart';
import '../../data/models/pomodoro_preferences.dart';
import '../../data/models/pomodoro_session.dart';
import '../../data/models/pomodoro_state.dart';
import '../../data/repositories/pomodoro_repository.dart';

class PomodoroController extends ChangeNotifier {
  final PomodoroRepository repository;

  String? _userId;
  PomodoroPreferences _preferences = const PomodoroPreferences(userId: '');
  PomodoroState _state = const PomodoroState(userId: '');
  List<PomodoroSession> _sessions = [];
  Timer? _ticker;
  String? _noticeMessage;

  PomodoroController({required this.repository});

  PomodoroPreferences get preferences => _preferences;
  PomodoroState get state => _state;
  List<PomodoroSession> get sessions => List.unmodifiable(_sessions);
  String? get noticeMessage => _noticeMessage;

  bool get isFocusRunningOrPaused =>
      _state.isFocus && (_state.isRunning || _state.isPaused);

  int get todayCompletedPomodoroCount {
    final today = DateKey.today().value;
    return _sessions
        .where((s) => s.endedOnDateKey == today && s.isCompleted)
        .length;
  }

  int get todayTotalFocusedMinutes {
    final today = DateKey.today().value;
    final totalSeconds = _sessions
        .where((s) => s.endedOnDateKey == today && s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.focusedSeconds);
    return totalSeconds ~/ 60;
  }

  Future<void> initUser(String userId) async {
    _userId = userId;
    _ticker?.cancel();
    _noticeMessage = null;

    _preferences = await repository.getPreferences(userId);
    _sessions = await repository.getSessions(userId);
    _state = await repository.getState(userId);

    final now = DateTime.now();

    // Çalışan bir aşama varsa ve bitiş zamanı geçmişse tamamla
    if (_state.isRunning && _state.endsAtUtc != null) {
      final endsAt = DateTime.parse(_state.endsAtUtc!).toLocal();
      if (now.isAfter(endsAt) || now.isAtSameMomentAs(endsAt)) {
        await completePhase();
      } else {
        _state = _state.copyWith(
          remainingSeconds: endsAt.difference(now).inSeconds,
        );
        _startTicker();
      }
    } else if (_state.isReady) {
      // Henüz başlamamış aşamada süreyi güncel tercihlere göre eşitle
      int targetSec;
      if (_state.isFocus) {
        targetSec = _preferences.focusMinutes * 60;
      } else if (_state.isShortBreak) {
        targetSec = _preferences.shortBreakMinutes * 60;
      } else {
        targetSec = _preferences.longBreakMinutes * 60;
      }
      _state = _state.copyWith(
        plannedSeconds: targetSec,
        remainingSeconds: targetSec,
      );
      await repository.saveState(userId, _state);
    }

    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_state.isRunning || _state.endsAtUtc == null) {
        _ticker?.cancel();
        return;
      }

      final now = DateTime.now();
      final endsAt = DateTime.parse(_state.endsAtUtc!).toLocal();
      final diff = endsAt.difference(now).inSeconds;

      if (diff <= 0) {
        _ticker?.cancel();
        completePhase();
      } else {
        _state = _state.copyWith(remainingSeconds: diff);
        notifyListeners();
      }
    });
  }

  Future<void> saveCustomDurations({
    required int focusMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
  }) async {
    if (_userId == null) return;

    final updatedPrefs = PomodoroPreferences(
      userId: _userId!,
      focusMinutes: focusMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
    );

    await repository.savePreferences(_userId!, updatedPrefs);
    _preferences = updatedPrefs;

    if (_state.isReady) {
      int targetSec;
      if (_state.isFocus) {
        targetSec = focusMinutes * 60;
      } else if (_state.isShortBreak) {
        targetSec = shortBreakMinutes * 60;
      } else {
        targetSec = longBreakMinutes * 60;
      }
      _state = _state.copyWith(
        plannedSeconds: targetSec,
        remainingSeconds: targetSec,
      );
      await repository.saveState(_userId!, _state);
      _noticeMessage = null;
    } else {
      // Çalışan veya duraklatılmış aşamada mevcut sayaç ve döngü değişmez
      _noticeMessage = 'Yeni süreler sonraki aşamalarda kullanılacak.';
    }

    notifyListeners();
  }

  Future<void> start({String? taskId, String? title}) async {
    if (_userId == null) return;

    final now = DateTime.now();
    final endsAt = now.add(Duration(seconds: _state.remainingSeconds));
    final sessionId =
        _state.activeSessionId ?? 'pomo_${now.millisecondsSinceEpoch}';

    _state = _state.copyWith(
      status: 'running',
      activeSessionId: sessionId,
      taskId: taskId ?? _state.taskId,
      titleSnapshot:
          title ??
          _state.titleSnapshot ??
          (_state.isFocus
              ? 'Odaklanma'
              : (_state.isShortBreak ? 'Kısa Mola' : 'Uzun Mola')),
      startedAtUtc: _state.startedAtUtc ?? now.toUtc().toIso8601String(),
      lastResumedAtUtc: now.toUtc().toIso8601String(),
      endsAtUtc: endsAt.toUtc().toIso8601String(),
    );

    await repository.saveState(_userId!, _state);
    _startTicker();
    notifyListeners();
  }

  Future<void> pause() async {
    if (_userId == null || !_state.isRunning) return;

    final now = DateTime.now();
    int currentRem = _state.remainingSeconds;

    if (_state.endsAtUtc != null) {
      final endsAt = DateTime.parse(_state.endsAtUtc!).toLocal();
      currentRem = endsAt
          .difference(now)
          .inSeconds
          .clamp(0, _state.plannedSeconds);
    }

    final activeAdd = (_state.remainingSeconds - currentRem).clamp(
      0,
      _state.plannedSeconds,
    );

    _state = _state.copyWith(
      status: 'paused',
      remainingSeconds: currentRem,
      clearEndsAt: true,
      accumulatedActiveSeconds: _state.accumulatedActiveSeconds + activeAdd,
    );

    _ticker?.cancel();
    await repository.saveState(_userId!, _state);
    notifyListeners();
  }

  Future<void> resume() async {
    if (_userId == null || !_state.isPaused) return;

    final now = DateTime.now();
    final endsAt = now.add(Duration(seconds: _state.remainingSeconds));

    _state = _state.copyWith(
      status: 'running',
      lastResumedAtUtc: now.toUtc().toIso8601String(),
      endsAtUtc: endsAt.toUtc().toIso8601String(),
    );

    await repository.saveState(_userId!, _state);
    _startTicker();
    notifyListeners();
  }

  Future<void> completePhase() async {
    if (_userId == null) return;
    _ticker?.cancel();

    final now = DateTime.now();

    if (_state.isFocus) {
      final session = PomodoroSession(
        id: _state.activeSessionId ?? 'pomo_${now.millisecondsSinceEpoch}',
        userId: _userId!,
        taskId: _state.taskId,
        titleSnapshot: _state.titleSnapshot ?? 'Odaklanma',
        startedAtUtc:
            _state.startedAtUtc ??
            now
                .subtract(Duration(seconds: _state.plannedSeconds))
                .toUtc()
                .toIso8601String(),
        endedAtUtc: now.toUtc().toIso8601String(),
        endedOnDateKey: DateKey.format(now),
        plannedSeconds: _state.plannedSeconds,
        focusedSeconds: _state.plannedSeconds,
        status: 'completed',
      );

      await repository.saveSession(_userId!, session);
      _sessions.insert(0, session);

      final nextCount = _state.cycleCompletedCount + 1;
      if (nextCount >= 4) {
        final longBreakSec = _preferences.longBreakMinutes * 60;
        _state = PomodoroState(
          userId: _userId!,
          phase: 'longBreak',
          status: 'ready',
          cycleCompletedCount: 4,
          plannedSeconds: longBreakSec,
          remainingSeconds: longBreakSec,
        );
      } else {
        final shortBreakSec = _preferences.shortBreakMinutes * 60;
        _state = PomodoroState(
          userId: _userId!,
          phase: 'shortBreak',
          status: 'ready',
          cycleCompletedCount: nextCount,
          plannedSeconds: shortBreakSec,
          remainingSeconds: shortBreakSec,
        );
      }
    } else if (_state.isShortBreak) {
      final focusSec = _preferences.focusMinutes * 60;
      _state = PomodoroState(
        userId: _userId!,
        phase: 'focus',
        status: 'ready',
        cycleCompletedCount: _state.cycleCompletedCount,
        plannedSeconds: focusSec,
        remainingSeconds: focusSec,
      );
    } else if (_state.isLongBreak) {
      final focusSec = _preferences.focusMinutes * 60;
      _state = PomodoroState(
        userId: _userId!,
        phase: 'focus',
        status: 'ready',
        cycleCompletedCount: 0,
        plannedSeconds: focusSec,
        remainingSeconds: focusSec,
      );
    }

    _noticeMessage = null;
    await repository.saveState(_userId!, _state);
    notifyListeners();
  }

  Future<void> abandonSession() async {
    if (_userId == null) return;
    _ticker?.cancel();

    final now = DateTime.now();

    if (_state.isFocus && (_state.isRunning || _state.isPaused)) {
      int activeSec = _state.accumulatedActiveSeconds;
      if (_state.isRunning && _state.endsAtUtc != null) {
        final endsAt = DateTime.parse(_state.endsAtUtc!).toLocal();
        final rem = endsAt
            .difference(now)
            .inSeconds
            .clamp(0, _state.plannedSeconds);
        activeSec += (_state.remainingSeconds - rem).clamp(
          0,
          _state.plannedSeconds,
        );
      }
      activeSec = activeSec.clamp(0, _state.plannedSeconds);

      if (activeSec > 0) {
        final session = PomodoroSession(
          id: _state.activeSessionId ?? 'pomo_${now.millisecondsSinceEpoch}',
          userId: _userId!,
          taskId: _state.taskId,
          titleSnapshot: _state.titleSnapshot ?? 'Odaklanma',
          startedAtUtc: _state.startedAtUtc ?? now.toUtc().toIso8601String(),
          endedAtUtc: now.toUtc().toIso8601String(),
          endedOnDateKey: DateKey.format(now),
          plannedSeconds: _state.plannedSeconds,
          focusedSeconds: activeSec,
          status: 'abandoned',
        );
        await repository.saveSession(_userId!, session);
        _sessions.insert(0, session);
      }

      final focusSec = _preferences.focusMinutes * 60;
      _state = PomodoroState(
        userId: _userId!,
        phase: 'focus',
        status: 'ready',
        cycleCompletedCount: _state.cycleCompletedCount,
        plannedSeconds: focusSec,
        remainingSeconds: focusSec,
      );
    } else if (_state.isShortBreak) {
      final focusSec = _preferences.focusMinutes * 60;
      _state = PomodoroState(
        userId: _userId!,
        phase: 'focus',
        status: 'ready',
        cycleCompletedCount: _state.cycleCompletedCount,
        plannedSeconds: focusSec,
        remainingSeconds: focusSec,
      );
    } else if (_state.isLongBreak) {
      final focusSec = _preferences.focusMinutes * 60;
      _state = PomodoroState(
        userId: _userId!,
        phase: 'focus',
        status: 'ready',
        cycleCompletedCount: 0,
        plannedSeconds: focusSec,
        remainingSeconds: focusSec,
      );
    }

    _noticeMessage = null;
    await repository.saveState(_userId!, _state);
    notifyListeners();
  }

  void clear() {
    _ticker?.cancel();
    _userId = null;
    _preferences = const PomodoroPreferences(userId: '');
    _state = const PomodoroState(userId: '');
    _sessions = [];
    _noticeMessage = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
