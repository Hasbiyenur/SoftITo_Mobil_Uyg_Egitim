import 'package:flutter/material.dart';

// Proje İçi Modeller ve Controller Tanımları
// Gerçek projede 'features/diary/models/diary_entry.dart' ve
// 'features/diary/controllers/diary_controller.dart' üzerinden import edilir.

/// Günlük veri modeli (Yalnızca bellek içi kullanım).
class DiaryEntry {
  final DateTime date;
  final String content;

  const DiaryEntry({
    required this.date,
    required this.content,
  });
}

/// Tarihleri saat/dakika/saniye olmaksızın karşılaştırmak için yardımcı sınıf.
class DateUtilsHelper {
  static DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Günlük durumunu yöneten denetleyici sınıfı.
class DiaryController {
  final selectedDate = ValueNotifier<DateTime>(
    DateUtilsHelper.dayOnly(DateTime.now()),
  );

  final entries = ValueNotifier<Map<DateTime, DiaryEntry>>({});

  // Bellek içi kaydedilmemiş taslaklar havuzu
  final Map<DateTime, String> _drafts = {};

  void selectDate(DateTime date) {
    selectedDate.value = DateUtilsHelper.dayOnly(date);
  }

  DiaryEntry? getEntry(DateTime date) {
    final normalized = DateUtilsHelper.dayOnly(date);
    return entries.value[normalized];
  }

  String getDraft(DateTime date) {
    final normalized = DateUtilsHelper.dayOnly(date);
    return _drafts[normalized] ?? '';
  }

  void updateDraft(DateTime date, String text) {
    final normalized = DateUtilsHelper.dayOnly(date);
    if (text.trim().isEmpty) {
      _drafts.remove(normalized);
    } else {
      _drafts[normalized] = text;
    }
  }

  bool saveEntry(String content) {
    final text = content.trim();
    if (text.isEmpty) return false;

    final date = selectedDate.value;

    // Değişmez (immutable) harita güncellemesi
    entries.value = {
      ...entries.value,
      date: DiaryEntry(date: date, content: text),
    };

    // Kayıt tamamlandığında o günün taslağını temizle
    _drafts.remove(date);
    return true;
  }

  void dispose() {
    selectedDate.dispose();
    entries.dispose();
  }
}

/// Örnek Günlük Yazma Ekranı (DiaryEditorView).
///
/// Duyarlı (Responsive) tasarım prensiplerine uygundur:
/// - Geniş ekranda (>= 650dp) takvim sol tarafta, yazma alanı sağ tarafta yer alır.
/// - Dar ekranda (mobil) takvim üstte, yazma alanı altta dikey sıralanır.
/// - Klavye açıldığında SingleChildScrollView ile taşma engellenir.
class SampleDiaryScreen extends StatefulWidget {
  final DiaryController controller;

  const SampleDiaryScreen({
    super.key,
    required this.controller,
  });

  @override
  State<SampleDiaryScreen> createState() => _SampleDiaryScreenState();
}

class _SampleDiaryScreenState extends State<SampleDiaryScreen> {
  late final TextEditingController _textController;
  DateTime? _lastDate;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _lastDate = widget.controller.selectedDate.value;

    // Başlangıç tarihindeki kayıt veya taslak metnini yükle
    _loadContentForDate(_lastDate!);

    // Tarih değişimini dinle ve metin alanını güncelle
    widget.controller.selectedDate.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    final newDate = widget.controller.selectedDate.value;
    if (_lastDate != null && _lastDate != newDate) {
      // Önceki günün yazılan ancak kaydedilmemiş metnini taslak havuzuna al
      final currentText = _textController.text;
      widget.controller.updateDraft(_lastDate!, currentText);
    }

    _lastDate = newDate;
    _loadContentForDate(newDate);
  }

  void _loadContentForDate(DateTime date) {
    final savedEntry = widget.controller.getEntry(date);
    if (savedEntry != null) {
      _textController.text = savedEntry.content;
    } else {
      final draft = widget.controller.getDraft(date);
      _textController.text = draft;
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
    // Çıkarken mevcut taslağı son kez kaydet
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
        final isWideScreen = constraints.maxWidth >= 650;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_rounded),
                SizedBox(width: 8),
                Text('Günlüğüm'),
              ],
            ),
            actions: [
              // Kayıtlı günlük sayısını canlı gösteren sayaç
              ValueListenableBuilder<Map<DateTime, DiaryEntry>>(
                valueListenable: widget.controller.entries,
                builder: (context, entries, child) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        '${entries.length} Kayıt',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
          ),
        );
      },
    );
  }

  /// Geniş ekran düzeni: Sol panelde takvim, sağ panelde editör.
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCalendarWidget(),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildEditorForm(),
          ),
        ),
      ],
    );
  }

  /// Dar ekran düzeni (Mobil): Üstte takvim, altta editör.
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCalendarWidget(),
            ),
          ),
          _buildEditorForm(),
        ],
      ),
    );
  }

  /// Takvim seçici widget'ı.
  Widget _buildCalendarWidget() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.controller.selectedDate,
      builder: (context, selectedDate, child) {
        return CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          onDateChanged: (date) {
            widget.controller.selectDate(date);
          },
        );
      },
    );
  }

  /// Metin düzenleme alanı ve işlem düğmeleri.
  Widget _buildEditorForm() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.controller.selectedDate,
      builder: (context, selectedDate, child) {
        final formattedDate = DateUtilsHelper.formatDate(selectedDate);
        final hasSavedEntry = widget.controller.getEntry(selectedDate) != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  label: Text(hasSavedEntry ? 'Kayıtlı' : 'Yeni / Taslak'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 8,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Seçili gün için düşüncelerinizi buraya yazın...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (text) {
                // Her yazımda taslak belleğini canlı tut
                widget.controller.updateDraft(selectedDate, text);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ],
        );
      },
    );
  }
}
