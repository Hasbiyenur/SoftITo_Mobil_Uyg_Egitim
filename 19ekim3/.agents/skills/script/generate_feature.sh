#!/usr/bin/env bash
# ==============================================================================
# generate_feature.sh
# Flutter Feature Scaffold Oluşturucu Betiği
#
# SKILL.md ve project.md prensiplerine uygun olarak;
# Clean Architecture, ValueNotifier Reaktif State ve Atomik UI katmanlarını
# standart klasör ve dosya şablonlarıyla otomatik olarak üretir.
# ==============================================================================

set -euo pipefail

# ANSI Renk Kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Yardım Mesajı
show_help() {
  echo -e "${BLUE}Flutter Feature Scaffold Üretici${NC}"
  echo -e "Kullanım: ${YELLOW}$0 <feature_name> [target_directory]${NC}"
  echo -e ""
  echo -e "Örnekler:"
  echo -e "  $0 water_tracker"
  echo -e "  $0 workout /path/to/project"
  echo -e ""
  echo -e "Oluşturulacak Dizin Yapısı:"
  echo -e "  lib/features/<feature_name>/"
  echo -e "      ├── controllers/<feature_name>_controller.dart"
  echo -e "      ├── models/<feature_name>_model.dart"
  echo -e "      ├── view/<feature_name>_view.dart"
  echo -e "      └── widgets/<feature_name>_card.dart"
  echo -e "  test/features/<feature_name>/"
  echo -e "      └── <feature_name>_controller_test.dart"
  exit 1
}

# Parametre Kontrolü
if [ $# -lt 1 ]; then
  echo -e "${RED}Hata: Lütfen bir feature adı belirtin!${NC}"
  show_help
fi

FEATURE_NAME="$1"
TARGET_DIR="${2:-.}"

# snake_case Doğrulaması
if [[ ! "$FEATURE_NAME" =~ ^[a-z0-9_]+$ ]]; then
  echo -e "${RED}Hata: Feature adı sadece küçük harf, rakam ve alt çizgi (snake_case) içermelidir! (Örn: water_tracker)${NC}"
  exit 1
fi

# PascalCase Dönüşümü (örnek: water_tracker -> WaterTracker)
to_pascal_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

PASCAL_NAME=$(to_pascal_case "$FEATURE_NAME")

FEATURE_ROOT="${TARGET_DIR}/lib/features/${FEATURE_NAME}"
TEST_ROOT="${TARGET_DIR}/test/features/${FEATURE_NAME}"

echo -e "${BLUE}=== Feature Üretimi Başlatılıyor: ${GREEN}${FEATURE_NAME}${BLUE} (${PASCAL_NAME}) ===${NC}"

# Klasörleri Oluştur
mkdir -p "${FEATURE_ROOT}/controllers"
mkdir -p "${FEATURE_ROOT}/models"
mkdir -p "${FEATURE_ROOT}/view"
mkdir -p "${FEATURE_ROOT}/widgets"
mkdir -p "${TEST_ROOT}"

# 1. CONTROLLER DOSYASI
CONTROLLER_FILE="${FEATURE_ROOT}/controllers/${FEATURE_NAME}_controller.dart"
cat <<EOF > "$CONTROLLER_FILE"
import 'package:flutter/foundation.dart';

/// ${PASCAL_NAME} modülü için reaktif durum yöneticisi (ValueNotifier).
class ${PASCAL_NAME}Controller {
  /// Birincil durum göstergesi
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  /// Yüklenme/işlem durumu
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  /// Değer artırma işlemi
  void increment() {
    counter.value++;
  }

  /// Değeri sıfırlama işlemi
  void reset() {
    counter.value = 0;
  }

  /// Bellek sızıntılarını önlemek için dinleyicileri serbest bırakır.
  void dispose() {
    counter.dispose();
    isLoading.dispose();
  }
}
EOF
echo -e "  [+] ${GREEN}${CONTROLLER_FILE}${NC}"

# 2. MODEL DOSYASI
MODEL_FILE="${FEATURE_ROOT}/models/${FEATURE_NAME}_model.dart"
cat <<EOF > "$MODEL_FILE"
import 'package:flutter/foundation.dart';

/// ${PASCAL_NAME} için değişmez (immutable) veri modeli.
@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final String title;
  final int value;
  final DateTime createdAt;

  const ${PASCAL_NAME}Model({
    required this.id,
    required this.title,
    required this.value,
    required this.createdAt,
  });

  ${PASCAL_NAME}Model copyWith({
    String? id,
    String? title,
    int? value,
    DateTime? createdAt,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => '${PASCAL_NAME}Model(id: \$id, title: \$title, value: \$value)';
}
EOF
echo -e "  [+] ${GREEN}${MODEL_FILE}${NC}"

# 3. WIDGET DOSYASI
WIDGET_FILE="${FEATURE_ROOT}/widgets/${FEATURE_NAME}_card.dart"
cat <<EOF > "$WIDGET_FILE"
import 'package:flutter/material.dart';

/// ${PASCAL_NAME} modülü için atomik bilgi kartı bileşeni.
class ${PASCAL_NAME}Card extends StatelessWidget {
  final int value;
  final VoidCallback onAction;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.value,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${PASCAL_NAME} Değeri',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '\$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: const Text('Artır'),
            ),
          ],
        ),
      ),
    );
  }
}
EOF
echo -e "  [+] ${GREEN}${WIDGET_FILE}${NC}"

# 4. VIEW DOSYASI
VIEW_FILE="${FEATURE_ROOT}/view/${FEATURE_NAME}_view.dart"
cat <<EOF > "$VIEW_FILE"
import 'package:flutter/material.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

/// ${PASCAL_NAME} için Clean UI ekranı.
class ${PASCAL_NAME}View extends StatelessWidget {
  final ${PASCAL_NAME}Controller controller;

  const ${PASCAL_NAME}View({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_NAME} Modülü'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
            tooltip: 'Sıfırla',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<int>(
            valueListenable: controller.counter,
            builder: (context, val, child) {
              return ${PASCAL_NAME}Card(
                value: val,
                onAction: controller.increment,
              );
            },
          ),
        ),
      ),
    );
  }
}
EOF
echo -e "  [+] ${GREEN}${VIEW_FILE}${NC}"

# 5. TEST DOSYASI
TEST_FILE="${TEST_ROOT}/${FEATURE_NAME}_controller_test.dart"
cat <<EOF > "$TEST_FILE"
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/${FEATURE_NAME}/controllers/${FEATURE_NAME}_controller.dart';

void main() {
  group('${PASCAL_NAME}Controller Birim Testleri', () {
    late ${PASCAL_NAME}Controller controller;

    setUp(() {
      controller = ${PASCAL_NAME}Controller();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıç sayacı 0 olmalıdır', () {
      expect(controller.counter.value, 0);
    });

    test('increment() çağrıldığında sayaç 1 artmalıdır', () {
      controller.increment();
      expect(controller.counter.value, 1);
    });

    test('reset() çağrıldığında sayaç 0 olmalıdır', () {
      controller.increment();
      controller.increment();
      expect(controller.counter.value, 2);
      controller.reset();
      expect(controller.counter.value, 0);
    });
  });
}
EOF
echo -e "  [+] ${GREEN}${TEST_FILE}${NC}"

echo -e "\n${GREEN}✔ ${PASCAL_NAME} feature iskeleti başarıyla üretildi!${NC}"
