import '../models/pomodoro_preferences.dart';
import '../models/pomodoro_session.dart';
import '../models/pomodoro_state.dart';

abstract class PomodoroRepository {
  Future<PomodoroPreferences> getPreferences(String userId);
  Future<void> savePreferences(String userId, PomodoroPreferences preferences);

  Future<PomodoroState> getState(String userId);
  Future<void> saveState(String userId, PomodoroState state);

  Future<List<PomodoroSession>> getSessions(String userId);
  Future<void> saveSession(String userId, PomodoroSession session);
}
