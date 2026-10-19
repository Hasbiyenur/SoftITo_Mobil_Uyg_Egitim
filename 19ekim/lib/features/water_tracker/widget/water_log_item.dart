import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../models/water_log_model.dart';

class WaterLogItem extends StatelessWidget {
  const WaterLogItem({
    super.key,
    required this.log,
    required this.onDelete,
  });

  final WaterLogModel log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

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
          const Icon(Icons.water_drop_outlined,
              color: AppColor.neonCyan, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${log.amountInMl} ml (${log.containerName})',
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 12,
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
