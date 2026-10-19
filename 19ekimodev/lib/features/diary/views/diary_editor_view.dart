import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_calendar.dart';

/// Günlük Yazma ve Düzenleme Ekranı.
///
/// Duyarlı (Responsive) mimariye sahiptir:
/// - Geniş ekranlarda (>= 650dp) takvim solda sabit kalır, yazma alanı sağda açılır.
/// - Dar ekranlarda (mobil) takvim üstte, yazma alanı altta dikey sıralanır.
/// - Klavye açıldığında taşmayı önlemek için SingleChildScrollView kullanılır.
class DiaryEditorView extends StatefulWidget {
  final DiaryController controller;

  const DiaryEditorView({
    super.key,
    required this.controller,
  });

  @override
  State<DiaryEditorView> createState() => _DiaryEditorViewState();
}

class _DiaryEditorViewState extends State<DiaryEditorView> {
  late final TextEditingController _textController;
  DateTime? _lastDate;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _lastDate = widget.controller.selectedDate.value;

    // Başlangıç tarihindeki kayıt veya taslağı yükle
    _loadContentForDate(_lastDate!);

    // Tarih değişimini dinle
    widget.controller.selectedDate.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    final newDate = widget.controller.selectedDate.value;
    if (_lastDate != null && _lastDate != newDate) {
      // Önceki tarihin kaydedilmemiş metnini taslak havuzunda sakla
      widget.controller.updateDraft(_lastDate!, _textController.text);
    }

    _lastDate = newDate;
    _loadContentForDate(newDate);
  }

  void _loadContentForDate(DateTime date) {
    final savedEntry = widget.controller.getEntry(date);
    if (savedEntry != null) {
      _textController.text = savedEntry.content;
    } else {
      _textController.text = widget.controller.getDraft(date);
    }
  }

  void _saveEntry() {
    final success = widget.controller.saveEntry(_textController.text);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Günlük başarıyla kaydedildi.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kaydedilecek bir metin girin.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Ekrandan çıkılırken son yazılan taslağı belleğe aktar
    if (_lastDate != null) {
      widget.controller.updateDraft(_lastDate!, _textController.text);
    }
    widget.controller.selectedDate.removeListener(_onDateChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 700;
        return isWideScreen ? _buildWideLayout() : _buildNarrowLayout();
      },
    );
  }

  /// Geniş ekran düzeni (Tablet / Web / Masaüstü)
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: DiaryCalendar(controller: widget.controller),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: _buildEditorForm(),
          ),
        ),
      ],
    );
  }

  /// Dar ekran düzeni (Mobil)
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: DiaryCalendar(controller: widget.controller),
          ),
          const SizedBox(height: 16),
          _buildEditorForm(),
        ],
      ),
    );
  }

  /// Günlük metin düzenleme ve kaydetme bileşeni
  Widget _buildEditorForm() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.controller.selectedDate,
      builder: (context, selectedDate, _) {
        final formattedDate = DateUtilsHelper.formatDate(selectedDate);

        return ValueListenableBuilder<Map<DateTime, DiaryEntry>>(
          valueListenable: widget.controller.entries,
          builder: (context, _, child) {
            final hasSavedEntry = widget.controller.getEntry(selectedDate) != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Chip(
                      avatar: Icon(
                        hasSavedEntry ? Icons.check_circle : Icons.edit_note,
                        size: 18,
                        color: hasSavedEntry ? Colors.green : Colors.orange,
                      ),
                      label: Text(
                        hasSavedEntry ? 'Kayıtlı' : 'Yeni / Taslak',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  minLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Seçili gün için düşüncelerinizi buraya yazın...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (text) {
                    widget.controller.updateDraft(selectedDate, text);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saveEntry,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Kaydet'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
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
