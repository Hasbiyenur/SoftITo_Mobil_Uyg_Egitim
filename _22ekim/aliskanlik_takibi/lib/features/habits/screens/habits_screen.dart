import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/date_key.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/auth_controller.dart';
import '../habit_controller.dart';
import '../widgets/habit_card.dart';
import 'habit_form_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _isEditMode = false;
  bool _isDeleteMode = false;
  final Set<String> _selectedHabitIds = {};

  void _exitModes() {
    setState(() {
      _isEditMode = false;
      _isDeleteMode = false;
      _selectedHabitIds.clear();
    });
  }

  void _toggleSelection(String habitId) {
    setState(() {
      if (_selectedHabitIds.contains(habitId)) {
        _selectedHabitIds.remove(habitId);
      } else {
        _selectedHabitIds.add(habitId);
      }
    });
  }

  Future<void> _confirmDelete() async {
    if (_selectedHabitIds.isEmpty) return;

    final count = _selectedHabitIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alışkanlıkları Kaldır'),
        content: Text(
          'Seçtiğin $count alışkanlık listelerinden kaldırılacak. Geçmiş tamamlamaların, rekorların ve kazandığın rozetler korunacak. Devam etmek istiyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthController>();
      final habitCtrl = context.read<HabitController>();
      final user = auth.currentUser;
      if (user != null) {
        final todayKey = DateKey.today().value;
        await habitCtrl.archiveHabits(
          userId: user.id,
          habitIds: _selectedHabitIds.toList(),
          todayKey: todayKey,
        );
      }
      _exitModes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitCtrl = context.watch<HabitController>();
    final activeHabits = habitCtrl.activeHabits;
    final todayKey = DateKey.today().value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
        actions: [
          if (_isEditMode || _isDeleteMode)
            TextButton(onPressed: _exitModes, child: const Text('İptal')),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Üst başlık ve "+ Görev Ekle" butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Görevlerim',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${activeHabits.length} aktif alışkanlık',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (!_isDeleteMode && !_isEditMode)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HabitFormScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Görev Ekle'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                    ],
                  ),
                  if (_isEditMode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Düzenlemek istediğin görevi seç.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            // Alışkanlıklar listesi
            Expanded(
              child: activeHabits.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.spa_outlined,
                              size: 56,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kayıtlı bir alışkanlığın yok.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Yeni bir alışkanlık ekleyerek takibe başla!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: 90,
                      ),
                      itemCount: activeHabits.length,
                      itemBuilder: (context, index) {
                        final habit = activeHabits[index];
                        final streak = habitCtrl.getActiveStreak(
                          habit,
                          todayKey,
                        );
                        final entry = habitCtrl.getEntry(habit.id, todayKey);
                        final isSelected = _selectedHabitIds.contains(habit.id);

                        return HabitCard(
                          habit: habit,
                          entry: entry,
                          streak: streak,
                          dateKey: todayKey,
                          isSelectionMode: _isDeleteMode,
                          isSelected: isSelected,
                          isEditMode: _isEditMode,
                          onTap: () {
                            if (_isDeleteMode) {
                              _toggleSelection(habit.id);
                            } else if (_isEditMode) {
                              _exitModes();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HabitFormScreen(habit: habit),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),

            // Alt eylem alanı (Düzenle ve Kaldır / Seçilenleri Kaldır (n) ve İptal)
            if (activeHabits.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(top: BorderSide(color: colorScheme.outline)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: _isDeleteMode
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              text: 'İptal',
                              isOutlined: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              onPressed: _exitModes,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: PrimaryButton(
                              text:
                                  'Seçilenleri Kaldır (${_selectedHabitIds.length})',
                              backgroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              onPressed: _selectedHabitIds.isNotEmpty
                                  ? _confirmDelete
                                  : null,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: _isEditMode
                                  ? 'Düzenlemeyi Bitir'
                                  : 'Düzenle',
                              isOutlined: true,
                              icon: Icons.edit_outlined,
                              onPressed: () {
                                setState(() {
                                  _isEditMode = !_isEditMode;
                                  _isDeleteMode = false;
                                  _selectedHabitIds.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Kaldır',
                              isOutlined: true,
                              icon: Icons.delete_outline_rounded,
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.error,
                              onPressed: () {
                                setState(() {
                                  _isDeleteMode = true;
                                  _isEditMode = false;
                                  _selectedHabitIds.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
