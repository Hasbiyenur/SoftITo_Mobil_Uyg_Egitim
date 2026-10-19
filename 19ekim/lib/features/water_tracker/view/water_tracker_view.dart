import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../controller/water_tracker_controller.dart';
import '../widget/quick_water_buttons.dart';
import '../widget/water_log_item.dart';
import '../widget/water_progress_card.dart';

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({
    super.key,
    required this.controller,
  });

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WaterProgressCard(
                consumedMl: controller.totalConsumedMl,
                goalMl: controller.dailyGoalMl,
                progressRatio: controller.progressRatio,
              ),
              const SizedBox(height: 20),
              QuickWaterButtons(
                onAddWater: (amount, name) =>
                    controller.addWater(amount, containerName: name),
              ),
              const SizedBox(height: 24),
              _LogSectionHeader(onReset: controller.resetToday),
              const SizedBox(height: 12),
              _LogListSection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _LogSectionHeader extends StatelessWidget {
  const _LogSectionHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bugünün Kayıtları',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColor.textMuted),
          label: const Text(
            'Sıfırla',
            style: TextStyle(color: AppColor.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _LogListSection extends StatelessWidget {
  const _LogListSection({required this.controller});

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text(
          'Henüz su kaydı bulunmuyor. Bir bardak su içerek başla!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textMuted),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.logs.length,
      itemBuilder: (context, index) {
        final log = controller.logs[index];
        return WaterLogItem(
          key: ValueKey(log.id),
          log: log,
          onDelete: () => controller.removeLog(log.id),
        );
      },
    );
  }
}
