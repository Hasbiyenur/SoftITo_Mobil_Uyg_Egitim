import 'package:flutter/material.dart';

import '../models/task_model.dart';

typedef SaveTask = void Function(
  String title,
  TaskCategory category,
  DateTime date,
  TaskPriority priority,
  String note,
);

class TaskFormScreen extends StatefulWidget {
  final SaveTask onSave;
  const TaskFormScreen({super.key, required this.onSave});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  TaskCategory _category = TaskCategory.study;
  TaskPriority _priority = TaskPriority.normal;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: now,
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (mounted && selected != null) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (mounted && selected != null) setState(() => _time = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      _title.text.trim(),
      _category,
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
      _priority,
      _note.text.trim(),
    );
    _formKey.currentState!.reset();
    _title.clear();
    _note.clear();
    setState(() {
      _category = TaskCategory.study;
      _priority = TaskPriority.normal;
      _date = DateUtils.dateOnly(DateTime.now());
      _time = const TimeOfDay(hour: 9, minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Bir sonraki adımın ne?',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text('Küçük ve yapılabilir bir görevle başla.'),
      const SizedBox(height: 24),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Görev adı',
                hintText: 'Örn. Günlük tekrar',
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Bir görev adı yaz.' : null,
            ),
            const SizedBox(height: 12),
            const Text('Kategori'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values
                  .map(
                    (category) => ChoiceChip(
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                'Tarih: ${MaterialLocalizations.of(context).formatMediumDate(_date)}',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule),
              label: Text('Saat: ${_time.format(context)}'),
            ),
            const SizedBox(height: 20),
            const Text('Öncelik'),
            Wrap(
              spacing: 8,
              children: TaskPriority.values
                  .map(
                    (priority) => ChoiceChip(
                      label: Text(
                        priority == TaskPriority.normal ? 'Normal' : 'Yüksek',
                      ),
                      selected: _priority == priority,
                      onSelected: (_) => setState(() => _priority = priority),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _note,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add_task),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Görevi kaydet'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'İskelet sürüm: Görevler uygulama yeniden başlatıldığında sıfırlanır.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
