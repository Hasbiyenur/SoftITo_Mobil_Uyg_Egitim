import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../models/sleep_log_model.dart';

class SleepLogTile extends StatelessWidget {
  const SleepLogTile({
    super.key,
    required this.log,
    required this.onDelete,
  });

  final SleepLogModel log;
  final VoidCallback onDelete;

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sleepStr = _formatTime(log.sleepTime);
    final wakeStr = _formatTime(log.wakeTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.neonPurple.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bedtime_outlined,
                color: AppColor.neonPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sleepStr  ➔  $wakeStr',
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${log.hours} saat ${log.minutesRemainder} dk • ${log.quality}',
                  style: const TextStyle(
                    color: AppColor.neonPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColor.neonRose, size: 20),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
