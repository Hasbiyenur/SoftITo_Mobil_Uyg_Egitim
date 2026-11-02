---
name: flutter-feature-scaffold
description: Flutter projelerinde feature bazlı kod yazmak için gerekli klasör yapısını oluşturur. ValueNotifier state mimarisini, Clean UI ayrımını ve birim test iskeletini standartlara uygun olarak üretir.
---

# Flutter Feature Scaffold (Modüler Ekran İskeleti)

Bu yetenek, projede yeni bir ekran ya da işlev modülü açarken Clean UI ve reaktif State kurallarına tam uyulmasını garanti altına alır.

## Temel Prensipler

1. **Asla Tek Dosyada Toplama (Separation of Concerns):**
   - UI Görünümü: `view/<feature_name>_view.dart`
   - Durum ve İş Mantığı: `controllers/<feature_name>_controller.dart`
   - Veri Modeli: `models/<feature_name>_model.dart`
   - Parçalı Bileşenler: `widgets/<feature_name>_card.dart`
   Tüm bu katmanlar ayrı dosyalarda olmalıdır.

2. **Reaktif State Yönetimi (`ValueNotifier`):**
   - Basit ve performanslı durumlar için `ValueNotifier<T>` ve `ValueListenableBuilder<T>` kullanılmalıdır.
   - Tüm ekranı gereksiz yere baştan çizen devasa `StatefulWidget`'lar yerine, sadece ilgili widget alanını reaktif güncelleyen atomik yapılar tercih edilmelidir.

3. **Const Zorunluluğu ve Bellek Tasarrufu:**
   - Mümkün olan tüm widget'lar `const` yapılandırıcı (constructor) ile tanımlanmalıdır.
   - Controller nesneleri ekran kapandığında `dispose()` edilerek bellek sızıntıları (memory leak) önlenmelidir.

---

## Adım Adım Uygulama Akışı

### Adım 1: Klasör Yapısı Oluşturma
Hedeflenen modül adını (örneğin: `water_tracker` veya `workout`), `lib/features/<feature_name>/` dizini altına kur:

```text
lib/features/<feature_name>/
    controllers/
        <feature_name>_controller.dart
    models/
        <feature_name>_model.dart
    view/
        <feature_name>_view.dart
    widgets/
        <feature_name>_card.dart
```

---

### Adım 2: Controller Dosyasını Yaz
`controllers/<feature_name>_controller.dart` içinde iş mantığını ve `ValueNotifier` durumlarını tanımla:

```dart
import 'package:flutter/foundation.dart';

class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);
  final int dailyGoalWater = 2500; // 2500 ml hedef

  void addWater(int amount) {
    currentWater.value += amount;
  }

  void resetWater() {
    currentWater.value = 0;
  }

  void dispose() {
    currentWater.dispose();
  }
}
```

---

### Adım 3: Model Dosyasını Oluşturma
`models/<feature_name>_model.dart` dosyasını `copyWith`, `fromJson` ve `toJson` metotlarını içerecek şekilde `immutable` (`@immutable` / `final` alanlar) olarak tanımla:

```dart
import 'package:flutter/foundation.dart';

@immutable
class WaterLogItem {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLogItem({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLogItem copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
  }) {
    return WaterLogItem(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WaterLogItem.fromJson(Map<String, dynamic> json) {
    return WaterLogItem(
      id: json['id'] as String? ?? '',
      amountMl: json['amountMl'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
```

---

### Adım 4: View Dosyasını Oluşturma
`view/<feature_name>_view.dart` dosyasında `StatelessWidget` kullanarak UI katmanını oluştur. Durum dinlemesi için `ValueListenableBuilder` kullan:

```dart
import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../widgets/water_tracker_card.dart';

class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Takip Modülü'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetWater,
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: controller.currentWater,
        builder: (context, currentWater, child) {
          final double progress = (currentWater / controller.dailyGoalWater).clamp(0.0, 1.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WaterTrackerCard(
                  currentWater: currentWater,
                  goalWater: controller.dailyGoalWater,
                  progress: progress,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.addWater(200),
                        icon: const Icon(Icons.local_drink),
                        label: const Text('+200 ml'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.addWater(500),
                        icon: const Icon(Icons.water_drop),
                        label: const Text('+500 ml'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

### Adım 5: Widget Dosyasını Oluşturma
`widgets/<feature_name>_card.dart` dosyasında atomik, bağımsız ve yeniden kullanılabilir widget bileşenini yaz:

```dart
import 'package:flutter/material.dart';

class WaterTrackerCard extends StatelessWidget {
  final int currentWater;
  final int goalWater;
  final double progress;

  const WaterTrackerCard({
    super.key,
    required this.currentWater,
    required this.goalWater,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Günlük Hidrasyon Durumu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Text(
              '$currentWater / $goalWater ml (%${(progress * 100).toInt()})',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Adım 6: Clean Architecture & Test Kurallarına Uyum
- **Separation of Concerns:** Her dosyanın tek ve net bir sorumluluğu olmalıdır. UI dosyalarında doğrudan veri işleme veya karmaşık hesaplama yapılmaz.
- **Reusability:** Widget'lar ve iş mantığı diğer ekranlarda da kullanılabilecek bağımsız yapıda kurgulanır.
- **Testability:** Controller katmanı Flutter UI motoruna ihtiyaç duymadan saf Dart birim testleri (`test/features/...`) ile test edilebilir olmalıdır.

---

## Kullanım Örnekleri

### Örnek 1: Sayfayı Başlatma ve Entegrasyon
```dart
import 'package:flutter/material.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';
import 'package:susadim/features/water_tracker/view/water_tracker_view.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  late final WaterTrackerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaterTrackerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaterTrackerView(controller: _controller);
  }
}
```

---

## Ekstra İpuçları
- **Dependency Injection:** Controller'ı widget ağacına enjekte etmek için GetIt veya InheritedWidget yapılarından faydalanabilirsiniz.
- **Navigation:** Ekranlar arası geçişte Navigator 2.0 veya `go_router` paketini modüler rota yapılarıyla kullanabilirsiniz.
- **Testing:** Her controller için `test/features/<feature_name>/<feature_name>_controller_test.dart` dosyasında `ValueNotifier` değer değişimlerini test edin.

---

## SSS (Sıkça Sorulan Sorular)

### Soru: Hangi durumlarda bu yeteneği kullanmalıyım?
**Cevap:** Projeye yeni bir ekran, alt modül veya bağımsız bir işlev grubu eklenirken her zaman bu yetenek kullanılmalıdır.

### Soru: Hangi durumlarda bu yeteneği kullanmamalıyım?
**Cevap:** Küçük bir hata düzeltmesi (bugfix), tek satırlık UI stil düzenlemesi veya global çekirdek kütüphane (`core/`) güncellemelerinde kullanılmamalıdır.
