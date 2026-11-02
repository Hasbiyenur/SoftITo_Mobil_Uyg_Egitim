import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../controller/sleep_controller.dart';
import '../widget/add_sleep_bottom_sheet.dart';
import '../widget/sleep_log_tile.dart';
import '../widget/sleep_progress_card.dart';

class SleeptimerView extends StatelessWidget {
  const SleeptimerView({
    super.key,
    required this.controller,
  });

  final SleepController controller;

  void _showAddModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSleepBottomSheet(
        onSave: (sleepTime, wakeTime, quality) {
          controller.addSleepLog(
            sleepTime: sleepTime,
            wakeTime: wakeTime,
            quality: quality,
          );
        },
      ),
    );
  }

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
              SleepProgressCard(
                totalHours: controller.totalHoursToday,
                totalMinutes: controller.remainingMinutesToday,
                targetHours: controller.targetHours,
                progressRatio: controller.progressRatio,
              ),
              const SizedBox(height: 16),
              _AddSleepTriggerButton(onTap: () => _showAddModal(context)),
              const SizedBox(height: 24),
              _SleepSectionHeader(onReset: controller.resetToday),
              const SizedBox(height: 12),
              _SleepListSection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _AddSleepTriggerButton extends StatelessWidget {
  const _AddSleepTriggerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.neonPurple, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded, color: AppColor.neonPurple),
        label: const Text(
          'Uyku Kaydı Ekle',
          style: TextStyle(
            color: AppColor.neonPurple,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _SleepSectionHeader extends StatelessWidget {
  const _SleepSectionHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Geçmiş Uyku Kayıtları',
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

class _SleepListSection extends StatelessWidget {
  const _SleepListSection({required this.controller});

  final SleepController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text(
          'Henüz uyku kaydı girilmedi. Dün gecenin uykusunu kaydedin!',
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
        return SleepLogTile(
          key: ValueKey(log.id),
          log: log,
          onDelete: () => controller.removeLog(log.id),
        );
      },
    );
  }
}
