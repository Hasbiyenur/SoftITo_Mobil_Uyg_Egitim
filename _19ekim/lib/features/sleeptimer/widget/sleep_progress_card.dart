import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class SleepProgressCard extends StatelessWidget {
  const SleepProgressCard({
    super.key,
    required this.totalHours,
    required this.totalMinutes,
    required this.targetHours,
    required this.progressRatio,
  });

  final int totalHours;
  final int totalMinutes;
  final int targetHours;
  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            _SleepRing(
              ratio: progressRatio,
              hours: totalHours,
              minutes: totalMinutes,
            ),
            const SizedBox(height: 18),
            _SleepTargetSubInfo(targetHours: targetHours, ratio: progressRatio),
          ],
        ),
      ),
    );
  }
}

class _SleepRing extends StatelessWidget {
  const _SleepRing({
    required this.ratio,
    required this.hours,
    required this.minutes,
  });

  final double ratio;
  final int hours;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: CircularProgressIndicator(
            value: ratio,
            strokeWidth: 14,
            backgroundColor: AppColor.surfaceVariant,
            color: AppColor.neonPurple,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bedtime_rounded,
                color: AppColor.neonPurple, size: 30),
            const SizedBox(height: 4),
            Text(
              '${hours}s ${minutes}d',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text('Toplam Uyku', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _SleepTargetSubInfo extends StatelessWidget {
  const _SleepTargetSubInfo({
    required this.targetHours,
    required this.ratio,
  });

  final int targetHours;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final percentage = (ratio * 100).toInt();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MetricText(title: 'Hedef', value: '$targetHours saat'),
        _MetricText(title: 'Ulaşılan', value: '%$percentage'),
      ],
    );
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
