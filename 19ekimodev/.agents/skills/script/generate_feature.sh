#!/usr/bin/env bash
# ==============================================================================
# Script: generate_feature.sh
# Açıklama: Günlüğüm projesi standartlarına uygun olarak yeni bir özellik (feature)
#           veya eksik bileşenlerin iskeletini (scaffold) otomatik oluşturur.
# Standartlar: ValueNotifier durum yönetimi, in-memory saklama, const widget'lar,
#              modeller, controller'lar, view'lar ve widget'ların ayrımı.
# ==============================================================================

set -euo pipefail

# Renk tanımları
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"

log_info() {
  echo -e "${COLOR_BLUE}[BİLGİ]${COLOR_RESET} $1"
}

log_success() {
  echo -e "${COLOR_GREEN}[BAŞARILI]${COLOR_RESET} $1"
}

log_warn() {
  echo -e "${COLOR_YELLOW}[UYARI]${COLOR_RESET} $1"
}

log_error() {
  echo -e "${COLOR_RED}[HATA]${COLOR_RESET} $1"
}

print_help() {
  cat << EOF
Kullanım:
  $0 [ÖZELLİK_ADI] [SEÇENEKLER]

Parametreler:
  ÖZELLİK_ADI      Oluşturulacak özelliğin adı (varsayılan: "diary").
                   Örnekler: diary, notes, reminder

Seçenekler:
  -f, --force      Var olan dosyaları sormadan üzerine yazar.
  -h, --help       Bu yardım mesajını gösterir.

Örnekler:
  $0 diary
  $0 notes --force
EOF
}

# Parametre işleme
FEATURE_NAME="diary"
FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      print_help
      exit 0
      ;;
    -f|--force)
      FORCE_OVERWRITE=true
      shift
      ;;
    -*)
      log_error "Bilinmeyen seçenek: $1"
      print_help
      exit 1
      ;;
    *)
      FEATURE_NAME="$1"
      shift
      ;;
  esac
done

# İsim dönüşümleri (snake_case -> PascalCase / CamelCase)
FEATURE_SNAKE=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
FEATURE_PASCAL=$(echo "$FEATURE_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS="")

TARGET_BASE="lib/features/${FEATURE_SNAKE}"

log_info "Özellik iskeleti oluşturuluyor: '${FEATURE_SNAKE}' (Pascal: ${FEATURE_PASCAL})"
log_info "Hedef dizin: ${TARGET_BASE}"

# Dizin yapısının oluşturulması
mkdir -p "${TARGET_BASE}/models"
mkdir -p "${TARGET_BASE}/controllers"
mkdir -p "${TARGET_BASE}/views"
mkdir -p "${TARGET_BASE}/widgets"

write_file() {
  local file_path="$1"
  local content="$2"

  if [[ -f "$file_path" && "$FORCE_OVERWRITE" != true ]]; then
    log_warn "Dosya zaten mevcut, atlandı: $file_path (üzerine yazmak için --force kullanın)"
    return
  fi

  echo "$content" > "$file_path"
  log_success "Oluşturuldu: $file_path"
}

# 1. Model Dosyası
MODEL_FILE="${TARGET_BASE}/models/${FEATURE_SNAKE}_entry.dart"
MODEL_CONTENT=$(cat << 'EOF'
/// Günlük veri modeli (Yalnızca bellek içi kullanım).
class DiaryEntry {
  final DateTime date;
  final String content;

  const DiaryEntry({
    required this.date,
    required this.content,
  });
}
EOF
)
write_file "$MODEL_FILE" "$MODEL_CONTENT"

# 2. Controller Dosyası
CONTROLLER_FILE="${TARGET_BASE}/controllers/${FEATURE_SNAKE}_controller.dart"
CONTROLLER_CONTENT=$(cat << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

class DiaryController {
  final selectedDate = ValueNotifier<DateTime>(
    DateUtilsHelper.dayOnly(DateTime.now()),
  );

  final entries = ValueNotifier<Map<DateTime, DiaryEntry>>({});
  final Map<DateTime, String> _drafts = {};

  void selectDate(DateTime date) {
    selectedDate.value = DateUtilsHelper.dayOnly(date);
  }

  DiaryEntry? getEntry(DateTime date) {
    return entries.value[DateUtilsHelper.dayOnly(date)];
  }

  String getDraft(DateTime date) {
    return _drafts[DateUtilsHelper.dayOnly(date)] ?? '';
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

    entries.value = {
      ...entries.value,
      date: DiaryEntry(date: date, content: text),
    };

    _drafts.remove(date);
    return true;
  }

  void dispose() {
    selectedDate.dispose();
    entries.dispose();
  }
}

class DateUtilsHelper {
  static DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
EOF
)
write_file "$CONTROLLER_FILE" "$CONTROLLER_CONTENT"

# 3. Widgets: AppLogo ve DiaryCalendar
LOGO_FILE="${TARGET_BASE}/widgets/app_logo.dart"
LOGO_CONTENT=$(cat << 'EOF'
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_stories_rounded),
        SizedBox(width: 8),
        Text('Günlüğüm'),
      ],
    );
  }
}
EOF
)
write_file "$LOGO_FILE" "$LOGO_CONTENT"

CALENDAR_FILE="${TARGET_BASE}/widgets/${FEATURE_SNAKE}_calendar.dart"
CALENDAR_CONTENT=$(cat << 'EOF'
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';

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
      builder: (context, selectedDate, child) {
        return CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          onDateChanged: (date) {
            controller.selectDate(date);
          },
        );
      },
    );
  }
}
EOF
)
write_file "$CALENDAR_FILE" "$CALENDAR_CONTENT"

# 4. Views: Editor, List, Home
EDITOR_VIEW_FILE="${TARGET_BASE}/views/${FEATURE_SNAKE}_editor_view.dart"
EDITOR_VIEW_CONTENT=$(cat << 'EOF'
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../widgets/diary_calendar.dart';

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
    _loadDateContent(_lastDate!);
    widget.controller.selectedDate.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    final newDate = widget.controller.selectedDate.value;
    if (_lastDate != null && _lastDate != newDate) {
      widget.controller.updateDraft(_lastDate!, _textController.text);
    }
    _lastDate = newDate;
    _loadDateContent(newDate);
  }

  void _loadDateContent(DateTime date) {
    final entry = widget.controller.getEntry(date);
    if (entry != null) {
      _textController.text = entry.content;
    } else {
      _textController.text = widget.controller.getDraft(date);
    }
  }

  void _saveEntry() {
    final ok = widget.controller.saveEntry(_textController.text);
    if (ok) {
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
          content: Text('Lütfen boş bırakmayınız.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
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
        final isWide = constraints.maxWidth >= 650;
        return isWide ? _buildWideLayout() : _buildNarrowLayout();
      },
    );
  }

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
              child: DiaryCalendar(controller: widget.controller),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ],
    );
  }

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
              child: DiaryCalendar(controller: widget.controller),
            ),
          ),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.controller.selectedDate,
      builder: (context, selectedDate, child) {
        final formatted = DateUtilsHelper.formatDate(selectedDate);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              formatted,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 8,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: 'Günlük düşüncelerinizi yazın...',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                widget.controller.updateDraft(selectedDate, text);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
EOF
)
write_file "$EDITOR_VIEW_FILE" "$EDITOR_VIEW_CONTENT"

LIST_VIEW_FILE="${TARGET_BASE}/views/${FEATURE_SNAKE}_list_view.dart"
LIST_VIEW_CONTENT=$(cat << 'EOF'
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';

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
      builder: (context, entriesMap, child) {
        if (entriesMap.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Henüz günlük yazmadınız.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final sortedList = entriesMap.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: sortedList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = sortedList[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_rounded),
                title: Text(
                  DateUtilsHelper.formatDate(entry.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  entry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
EOF
)
write_file "$LIST_VIEW_FILE" "$LIST_VIEW_CONTENT"

HOME_VIEW_FILE="${TARGET_BASE}/views/${FEATURE_SNAKE}_home_view.dart"
HOME_VIEW_CONTENT=$(cat << 'EOF'
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../widgets/app_logo.dart';
import 'diary_editor_view.dart';
import 'diary_list_view.dart';

class DiaryHomeView extends StatefulWidget {
  final DiaryController controller;
  final VoidCallback onToggleTheme;

  const DiaryHomeView({
    super.key,
    required this.controller,
    required this.onToggleTheme,
  });

  @override
  State<DiaryHomeView> createState() => _DiaryHomeViewState();
}

class _DiaryHomeViewState extends State<DiaryHomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_rounded),
            tooltip: 'Temayı Değiştir',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DiaryEditorView(controller: widget.controller),
          DiaryListView(
            controller: widget.controller,
            onEntrySelected: (_) {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_rounded),
            label: 'Günlük Yaz',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_rounded),
            label: 'Günlüklerim',
          ),
        ],
      ),
    );
  }
}
EOF
)
write_file "$HOME_VIEW_FILE" "$HOME_VIEW_CONTENT"

log_success "Tüm özellik bileşenleri başarıyla üretildi!"
log_info "Mimari kurallar eksiksiz uygulandı."
