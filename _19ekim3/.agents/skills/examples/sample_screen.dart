import 'package:flutter/material.dart';

// ============================================================================
// 1. MODEL KATMANI (models/sample_water_model.dart)
// ============================================================================

/// İmmutable su tüketim kayıt modeli.
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

  WaterLogItem copyWith({String? id, int? amountMl, DateTime? timestamp}) {
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

  @override
  String toString() =>
      'WaterLogItem(id: $id, amountMl: $amountMl, time: $timestamp)';
}

// ============================================================================
// 2. CONTROLLER KATMANI (controllers/sample_water_controller.dart)
// ============================================================================

/// Reaktif ValueNotifier tabanlı durum ve iş mantığı yöneticisi.
class WaterTrackerController {
  final int dailyGoalWater;

  /// Anlık tüketilen toplam su miktarı (ml)
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);

  /// Gün içindeki tüketim kayıtları listesi
  final ValueNotifier<List<WaterLogItem>> logList =
      ValueNotifier<List<WaterLogItem>>([]);

  /// İşlem yüklenme/asenkron kayıt durumu
  final ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  WaterTrackerController({this.dailyGoalWater = 2500});

  /// Su ekleme işlemi
  void addWater(int amount) {
    if (amount <= 0) return;

    final newLog = WaterLogItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: DateTime.now(),
    );

    currentWater.value += amount;
    logList.value = [newLog, ...logList.value];
  }

  /// Belirli bir tüketim kaydını silme
  void removeLog(String id) {
    final targetIndex = logList.value.indexWhere((item) => item.id == id);
    if (targetIndex == -1) return;

    final targetItem = logList.value[targetIndex];
    currentWater.value = (currentWater.value - targetItem.amountMl).clamp(
      0,
      99999,
    );

    final updated = List<WaterLogItem>.from(logList.value)
      ..removeAt(targetIndex);
    logList.value = updated;
  }

  /// Tüm veriyi sıfırlama
  void reset() {
    currentWater.value = 0;
    logList.value = const [];
  }

  /// Bellek sızıntısını önlemek için dinleyicileri serbest bırak
  void dispose() {
    currentWater.dispose();
    logList.dispose();
    isProcessing.dispose();
  }
}

// ============================================================================
// 3. ATOMİK WIDGETLAR (widgets/sample_water_widgets.dart)
// ============================================================================

/// Hidrasyon ilerlemesini gösteren Obsidian & Neon temalı dairesel kart.
class WaterProgressCard extends StatelessWidget {
  final int current;
  final int goal;

  const WaterProgressCard({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (current / goal).clamp(0.0, 1.0);
    final int percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C24),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2E3240), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3300D2FF),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Günlük Hedef',
                style: TextStyle(color: Color(0xFFA0A5B5), fontSize: 14),
              ),
              Text(
                '$goal ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFF262933),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00D2FF),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ml',
                    style: TextStyle(color: Color(0xFFA0A5B5), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '%$percent Tamamlandı',
            style: const TextStyle(
              color: Color(0xFF00F5D4),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hızlı su ekleme buton grubu.
class WaterQuickActions extends StatelessWidget {
  final ValueChanged<int> onAdd;

  const WaterQuickActions({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickButton(
          title: 'Bardak',
          amount: 200,
          icon: Icons.local_cafe_outlined,
          onTap: () => onAdd(200),
        ),
        const SizedBox(width: 12),
        _QuickButton(
          title: 'Kupa',
          amount: 330,
          icon: Icons.local_drink_outlined,
          onTap: () => onAdd(330),
        ),
        const SizedBox(width: 12),
        _QuickButton(
          title: 'Matara',
          amount: 500,
          icon: Icons.water_drop_outlined,
          onTap: () => onAdd(500),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickButton({
    required this.title,
    required this.amount,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0x3300D2FF),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFF00D2FF), size: 24),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '+$amount ml',
                  style: const TextStyle(
                    color: Color(0xFFA0A5B5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Geçmiş kayıt satırı atomik bileşeni.
class WaterLogTile extends StatelessWidget {
  final WaterLogItem item;
  final VoidCallback onDelete;

  const WaterLogTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF191B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Color(0xFF00D2FF), size: 18),
          const SizedBox(width: 12),
          Text(
            '+${item.amountMl} ml',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: const TextStyle(color: Color(0xFFA0A5B5), fontSize: 12),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF4D4F),
              size: 18,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. VIEW KATMANI (view/sample_water_view.dart)
// ============================================================================

/// StatelessWidget tabanlı temiz UI ekranı.
class SampleScreenView extends StatelessWidget {
  final WaterTrackerController controller;

  const SampleScreenView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12131A),
        elevation: 0,
        title: const Text(
          'Susadım v1',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh, color: Color(0xFFA0A5B5)),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Atomik Reaktif İlerleme Kartı
              ValueListenableBuilder<int>(
                valueListenable: controller.currentWater,
                builder: (context, current, _) {
                  return WaterProgressCard(
                    current: current,
                    goal: controller.dailyGoalWater,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Hızlı Ekleme Butonları
              WaterQuickActions(onAdd: controller.addWater),
              const SizedBox(height: 32),

              // Kayıt Geçmişi Başlığı
              const Text(
                'Bugünkü Tüketim Geçmişi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // Atomik Reaktif Geçmiş Listesi
              ValueListenableBuilder<List<WaterLogItem>>(
                valueListenable: controller.logList,
                builder: (context, logs, _) {
                  if (logs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        'Henüz bir su kaydı eklenmedi.',
                        style: TextStyle(color: Color(0xFFA0A5B5)),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return WaterLogTile(
                        key: ValueKey(log.id),
                        item: log,
                        onDelete: () => controller.removeLog(log.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. ENTEGRASYON & YAŞAM DÖNGÜSÜ (pages/sample_screen_page.dart)
// ============================================================================

/// Yaşam döngüsünü (initState & dispose) yöneten sayfa iskeleti.
class SampleScreenPage extends StatefulWidget {
  const SampleScreenPage({super.key});

  @override
  State<SampleScreenPage> createState() => _SampleScreenPageState();
}

class _SampleScreenPageState extends State<SampleScreenPage> {
  late final WaterTrackerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaterTrackerController(dailyGoalWater: 2500);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SampleScreenView(controller: _controller);
  }
}
