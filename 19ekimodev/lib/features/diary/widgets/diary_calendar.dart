import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';

/// Takvim üzerinden gün seçimi yapılmasını sağlayan widget.
/// Kayıtlı günleri görsel olarak da kontrol edebilmek için controller'ı dinler.
class DiaryCalendar extends StatelessWidget {
  final DiaryController controller;

  const DiaryCalendar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.selectedDate,
      builder: (context, selectedDate, _) {
        return ValueListenableBuilder<Map<DateTime, DiaryEntry>>(
          valueListenable: controller.entries,
          builder: (context, entries, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  onDateChanged: (date) {
                    controller.selectDate(date);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entries.length} kayıt',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.today_rounded, size: 16),
                        label: const Text('Bugün'),
                        onPressed: () {
                          controller.selectDate(DateTime.now());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
