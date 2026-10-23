import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../motivation_controller.dart';

class MotivationPreferencesPanel extends StatelessWidget {
  const MotivationPreferencesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final motivationCtrl = context.watch<MotivationController>();
    final prefs = motivationCtrl.preferences;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_alt_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Motivasyon Tercihleri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Maskotu Göster / Gizle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Motivasyon Maskotu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Sağ altta sevimli filiz karakterini ve sözlerini göster.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: prefs.mascotEnabled,
              activeTrackColor: colorScheme.primary,
              onChanged: (val) {
                motivationCtrl.updatePreferences(
                  prefs.copyWith(mascotEnabled: val),
                );
              },
            ),
            const Divider(height: 16),

            // 2. Mesaj Aralığı (Yalnızca maskot açıksa aktif)
            if (prefs.mascotEnabled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mesaj Aralığı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Maskotun yeni söz söyleme sıklığı',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<int>(
                    value: prefs.intervalMinutes,
                    underline: const SizedBox(),
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Dakika')),
                      DropdownMenuItem(value: 5, child: Text('5 Dakika')),
                      DropdownMenuItem(value: 10, child: Text('10 Dakika')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        motivationCtrl.updatePreferences(
                          prefs.copyWith(intervalMinutes: val),
                        );
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
            ],

            // 3. Görev Tamamlama Kutlaması Seçimi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Görev Tamamlama Efekti',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Görev tamamlandığında uygulanacak tebrik',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFeedbackChip(
                      context: context,
                      label: 'Üstten Mesaj',
                      icon: Icons.chat_bubble_outline_rounded,
                      mode: 'message',
                      selected: prefs.completionFeedbackMode == 'message',
                      onTap: () {
                        motivationCtrl.updatePreferences(
                          prefs.copyWith(completionFeedbackMode: 'message'),
                        );
                      },
                    ),
                    _buildFeedbackChip(
                      context: context,
                      label: 'Parıltı',
                      icon: Icons.auto_awesome_rounded,
                      mode: 'sparkle',
                      selected: prefs.completionFeedbackMode == 'sparkle',
                      onTap: () {
                        motivationCtrl.updatePreferences(
                          prefs.copyWith(completionFeedbackMode: 'sparkle'),
                        );
                      },
                    ),
                    _buildFeedbackChip(
                      context: context,
                      label: 'Alev',
                      icon: Icons.local_fire_department_rounded,
                      mode: 'flame',
                      selected: prefs.completionFeedbackMode == 'flame',
                      onTap: () {
                        motivationCtrl.updatePreferences(
                          prefs.copyWith(completionFeedbackMode: 'flame'),
                        );
                      },
                    ),
                    _buildFeedbackChip(
                      context: context,
                      label: 'Kapalı',
                      icon: Icons.notifications_off_outlined,
                      mode: 'off',
                      selected: prefs.completionFeedbackMode == 'off',
                      onTap: () {
                        motivationCtrl.updatePreferences(
                          prefs.copyWith(completionFeedbackMode: 'off'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // 4. İsteğe Bağlı Hugging Face / Çevrimiçi Kaynak
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Çevrimiçi Motivasyon Kaynağı',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Herkese açık Türkçe veri setlerinden ilave sözler indir (Hugging Face).',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: prefs.remoteSourceEnabled,
              activeTrackColor: colorScheme.primary,
              onChanged: (val) {
                motivationCtrl.updatePreferences(
                  prefs.copyWith(remoteSourceEnabled: val),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String mode,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      selectedColor: colorScheme.primaryContainer,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
      ),
    );
  }
}
