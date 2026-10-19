import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    super.key,
    required this.consumedMl,
    required this.goalMl,
    required this.progressRatio,
  });

  final int consumedMl;
  final int goalMl;
  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            _ProgressRing(ratio: progressRatio, consumed: consumedMl),
            const SizedBox(height: 18),
            _TargetSubInfo(consumed: consumedMl, goal: goalMl),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.ratio, required this.consumed});

  final double ratio;
  final int consumed;

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
            color: AppColor.neonCyan,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop_rounded,
                color: AppColor.neonCyan, size: 30),
            const SizedBox(height: 4),
            Text(
              '$consumed',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text('ml', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _TargetSubInfo extends StatelessWidget {
  const _TargetSubInfo({required this.consumed, required this.goal});

  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final percentage = (goal > 0 ? (consumed / goal * 100) : 0).toInt();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MetricText(title: 'Hedef', value: '$goal ml'),
        _MetricText(title: 'Yüzde', value: '%$percentage'),
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
