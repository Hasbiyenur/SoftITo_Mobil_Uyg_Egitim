/// Günlük veri modeli (Yalnızca bellek içi saklama).
/// Kalıcı depolama veya JSON serileştirme içermez.
class DiaryEntry {
  final DateTime date;
  final String content;

  const DiaryEntry({
    required this.date,
    required this.content,
  });
}
