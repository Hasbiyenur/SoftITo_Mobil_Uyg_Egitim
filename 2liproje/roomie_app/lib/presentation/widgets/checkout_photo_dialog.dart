import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/rental_model.dart';
import 'custom_button.dart';

class CheckoutPhotoDialog extends StatefulWidget {
  final RentalModel rental;
  final bool isEarlyExit;
  final int daysStayed;
  final double chargedAmount;
  final double refundAmount;
  final void Function(String photoPath) onConfirmed;

  const CheckoutPhotoDialog({
    super.key,
    required this.rental,
    required this.isEarlyExit,
    required this.daysStayed,
    required this.chargedAmount,
    required this.refundAmount,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required RentalModel rental,
    required bool isEarlyExit,
    required int daysStayed,
    required double chargedAmount,
    required double refundAmount,
    required void Function(String photoPath) onConfirmed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckoutPhotoDialog(
        rental: rental,
        isEarlyExit: isEarlyExit,
        daysStayed: daysStayed,
        chargedAmount: chargedAmount,
        refundAmount: refundAmount,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<CheckoutPhotoDialog> createState() => _CheckoutPhotoDialogState();
}

class _CheckoutPhotoDialogState extends State<CheckoutPhotoDialog> {
  String? _pickedPhotoPath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (xFile != null) {
        setState(() {
          _pickedPhotoPath = xFile.path;
        });
      }
    } catch (e) {
      // In case emulator/desktop camera is unavailable, offer sample checkout preset
      _useSampleCheckoutPreset();
    }
  }

  void _useSampleCheckoutPreset() {
    setState(() {
      _pickedPhotoPath = 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=800&q=80';
    });
  }

  void _submit() {
    if (_pickedPhotoPath == null || _pickedPhotoPath!.isEmpty) return;
    setState(() => _isLoading = true);
    widget.onConfirmed(_pickedPhotoPath!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.standard),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.meeting_room_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isEarlyExit
                          ? 'Erken Çıkış & Teslimat'
                          : 'Evden Çıkış İşlemi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Early Exit Notice
              if (widget.isEarlyExit) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: AppRadius.inputRadius,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Erken Çıkış İade Hesabı',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Planlanan süreden önce çıkış yapıyorsunuz. Yalnızca fiilen kaldığınız ${widget.daysStayed} gün ücretlendirilecektir.',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kalış Ücreti:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.chargedAmount),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hesabınıza Demo İade:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.refundAmount),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Mandatory Photo Requirement
              const Text(
                'Zorunlu Çıkış Fotoğrafı',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Ev sahibi güvencesi için odanın/evin son halini gösteren fotoğraf yüklemeniz zorunludur.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 10),

              // Photo Container / Preview
              if (_pickedPhotoPath != null) ...[
                ClipRRect(
                  borderRadius: AppRadius.inputRadius,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: _pickedPhotoPath!.startsWith('http')
                            ? Image.network(
                                _pickedPhotoPath!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_pickedPhotoPath!),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Fotoğraf Seçildi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Pick Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text(
                        'Kamera',
                        style: TextStyle(fontSize: 13),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text(
                        'Galeri',
                        style: TextStyle(fontSize: 13),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: _useSampleCheckoutPreset,
                  child: const Text(
                    'Örnek Temiz Oda Fotoğrafı Ekle (Demo)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.standard),

              // Action button
              CustomButton(
                text: _pickedPhotoPath != null
                    ? 'Çıkışı Tamamla ve Arşivle'
                    : 'Lütfen Önce Fotoğraf Yükleyin',
                isLoading: _isLoading,
                onPressed: _pickedPhotoPath != null ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
