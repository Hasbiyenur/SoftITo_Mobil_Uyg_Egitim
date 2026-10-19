import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';

/// Kaydedilen günlüklerin kronolojik (en yeniden en eskiye) listelendiği ekran.
class DiaryListView extends StatelessWidget {
  final DiaryController controller;
  final ValueChanged<DateTime> onEntrySelected;

  const DiaryListView({
    super.key,
    required this.controller,
    required this.onEntrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<DateTime, DiaryEntry>>(
      valueListenable: controller.entries,
      builder: (context, entriesMap, _) {
        if (entriesMap.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz günlük yazmadınız',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Takvimden bir gün seçerek ilk günlüğünüzü yazmaya başlayabilirsiniz.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // Günlükleri en yeni tarihten eskiye sırala
        final sortedList = entriesMap.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: sortedList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = sortedList[index];
            final formattedDate = DateUtilsHelper.formatDate(entry.date);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.event_note_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                ),
                onTap: () {
                  controller.selectDate(entry.date);
                  onEntrySelected(entry.date);
                },
              ),
            );
          },
        );
      },
    );
  }
}
