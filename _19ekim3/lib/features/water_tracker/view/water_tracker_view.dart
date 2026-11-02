import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_tracker_model.dart';
import '../widgets/water_tracker_card.dart';
import '../../../core/theme.dart';

/// Clean UI Su Takip Modülü Ekranı
class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: AppTheme.neonCyan),
            SizedBox(width: 8),
            Text('Su Takibi'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
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
                  color: AppTheme.textPrimary,
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
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Text(
                        'Henüz bir su kaydı eklenmedi.',
                        style: TextStyle(color: AppTheme.textSecondary),
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
