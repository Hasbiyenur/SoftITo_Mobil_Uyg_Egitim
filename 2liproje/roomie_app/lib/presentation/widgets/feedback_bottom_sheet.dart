import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/user_model.dart';
import '../bloc/feedback_bloc.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class FeedbackBottomSheet extends StatefulWidget {
  final UserModel currentUser;

  const FeedbackBottomSheet({super.key, required this.currentUser});

  static Future<void> show(
    BuildContext context, {
    required UserModel currentUser,
  }) {
    context.read<FeedbackBloc>().add(LoadFeedbacksEvent(currentUser.id));
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (context) => FeedbackBottomSheet(currentUser: currentUser),
    );
  }

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _messageController = TextEditingController();
  String _selectedCategory = 'Genel Görüş';
  int _rating = 5;

  final List<String> _categories = [
    'Genel Görüş',
    'Oda / Ev İlanları',
    'Kiralama Deneyimi',
    'Tasarım ve Kullanılabilirlik',
    'Hata Bildirimi',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geri bildirim mesajınızı yazınız.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<FeedbackBloc>().add(
      SubmitFeedbackEvent(
        user: widget.currentUser,
        category: _selectedCategory,
        message: text,
        rating: _rating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          _messageController.clear();
          setState(() {
            _selectedCategory = 'Genel Görüş';
            _rating = 5;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is FeedbackError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is FeedbackLoading;
        List<dynamic> feedbacks = [];
        if (state is FeedbackLoaded) {
          feedbacks = state.feedbacks;
        } else if (state is FeedbackSuccess) {
          feedbacks = state.feedbacks;
        } else if (state is FeedbackError) {
          feedbacks = state.feedbacks;
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.standard,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.rate_review_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geri Bildirim & Değerlendirme',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.standard),
                    children: [
                      // Category Dropdown
                      const Text(
                        'Konu Başlığı',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Rating Stars
                      const Text(
                        'Uygulama Puanınız',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return IconButton(
                            icon: Icon(
                              starValue <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.secondary,
                              size: 32,
                            ),
                            onPressed: () => setState(() => _rating = starValue),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Message Input
                      CustomTextField(
                        label: 'Görüş ve Önerileriniz',
                        hint: 'Roomio deneyiminizi iyileştirmek için bize fikirlerinizi yazın...',
                        controller: _messageController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Submit Button
                      CustomButton(
                        text: 'Geri Bildirimi Gönder',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submit,
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),

                      // Submitted Feedbacks Section (instant local persistence display)
                      const Text(
                        'Daha Önceki Geri Bildirimleriniz',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (isLoading && feedbacks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (feedbacks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Henüz iletilmiş bir geri bildiriminiz bulunmuyor.',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: feedbacks.map((f) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                borderRadius: AppRadius.cardRadius,
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        f.category.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(
                                          (f.rating as num).toInt(),
                                          (_) => const Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    f.message.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormatter.formatDate(f.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
