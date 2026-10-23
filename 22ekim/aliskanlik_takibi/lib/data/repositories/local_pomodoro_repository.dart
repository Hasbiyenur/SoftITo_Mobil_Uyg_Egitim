import '../../core/storage/local_store.dart';
import '../models/pomodoro_preferences.dart';
import '../models/pomodoro_session.dart';
import '../models/pomodoro_state.dart';
import 'pomodoro_repository.dart';

class LocalPomodoroRepository implements PomodoroRepository {
  final LocalStore store;

  LocalPomodoroRepository({required this.store});

  @override
  Future<PomodoroPreferences> getPreferences(String userId) async {
    final doc = await store.load();
    final prefs = doc.pomodoroPreferencesByUser[userId];
    if (prefs != null) return prefs;
    return PomodoroPreferences.defaults(userId);
  }

  @override
  Future<void> savePreferences(
    String userId,
    PomodoroPreferences preferences,
  ) async {
    final doc = await store.load();
    final updatedMap = Map<String, PomodoroPreferences>.from(
      doc.pomodoroPreferencesByUser,
    );
    updatedMap[userId] = preferences;
    final updated = doc.copyWith(pomodoroPreferencesByUser: updatedMap);
    await store.save(updated);
  }

  @override
  Future<PomodoroState> getState(String userId) async {
    final doc = await store.load();
    final state = doc.pomodoroStatesByUser[userId];
    if (state != null) return state;

    final prefs = doc.pomodoroPreferencesByUser[userId];
    final focus = prefs?.focusMinutes ?? 25;
    return PomodoroState.initial(userId, focus);
  }

  @override
  Future<void> saveState(String userId, PomodoroState state) async {
    final doc = await store.load();
    final updatedMap = Map<String, PomodoroState>.from(
      doc.pomodoroStatesByUser,
    );
    updatedMap[userId] = state;
    final updated = doc.copyWith(pomodoroStatesByUser: updatedMap);
    await store.save(updated);
  }

  @override
  Future<List<PomodoroSession>> getSessions(String userId) async {
    final doc = await store.load();
    final userSessions = doc.pomodoroSessions
        .where((s) => s.userId == userId)
        .toList();
    // En yeni tarih en üstte
    userSessions.sort((a, b) => b.startedAtUtc.compareTo(a.startedAtUtc));
    return userSessions;
  }

  @override
  Future<void> saveSession(String userId, PomodoroSession session) async {
    final doc = await store.load();
    final updatedList = List<PomodoroSession>.from(doc.pomodoroSessions);
    final index = updatedList.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      updatedList[index] = session;
    } else {
      updatedList.add(session);
    }
    final updated = doc.copyWith(pomodoroSessions: updatedList);
    await store.save(updated);
  }
}
