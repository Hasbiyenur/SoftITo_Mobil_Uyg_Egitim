import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/avatar_option.dart';
import '../../auth/auth_controller.dart';
import '../../motivation/widgets/motivation_preferences_panel.dart';
import '../settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Şifre Değiştirme Formu Kontrolcüleri
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordLoading = false;
  String? _passwordErrorMessage;
  String? _passwordSuccessMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _passwordErrorMessage = null;
      _passwordSuccessMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cur = _currentPasswordController.text;
    final neu = _newPasswordController.text;
    final conf = _confirmPasswordController.text;

    if (neu != conf) {
      setState(() {
        _passwordErrorMessage = 'Yeni şifreler birbiriyle eşleşmiyor.';
      });
      return;
    }

    if (cur == neu) {
      setState(() {
        _passwordErrorMessage = 'Yeni şifre mevcut şifreniz ile aynı olamaz.';
      });
      return;
    }

    setState(() {
      _isPasswordLoading = true;
    });

    try {
      final auth = context.read<AuthController>();
      final ok = await auth.changePassword(
        currentPassword: cur,
        newPassword: neu,
      );

      if (ok) {
        setState(() {
          _passwordSuccessMessage = 'Şifreniz başarıyla güncellendi.';
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Şifreniz başarıyla güncellendi.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _passwordErrorMessage =
              auth.errorMessage ?? 'Şifre güncellenirken bir hata oluştu.';
        });
      }
    } catch (e) {
      setState(() {
        _passwordErrorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPasswordLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final settingsCtrl = context.watch<SettingsController>();
    final user = auth.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final currentAvatarId = user?.avatarId ?? 'fox';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // 1. BÖLÜM: PROFİL FOTOĞRAFI
              // ==========================================
              _buildSectionHeader(
                icon: Icons.account_circle_outlined,
                title: 'Profil Fotoğrafı',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              Material(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Önizleme
                      Row(
                        children: [
                          AppAvatar(
                            avatarId: currentAvatarId,
                            size: 64,
                            showBorder: true,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Kullanıcı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Aşağıdaki 8 hazır insan ve hayvan avatarından birini seçebilirsin.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // 8 Hazır Avatar Izgarası (4 insan, 4 hayvan)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: AvatarOption.all.length,
                        itemBuilder: (context, index) {
                          final option = AvatarOption.all[index];
                          final isSelected = option.id == currentAvatarId;

                          return InkWell(
                            onTap: () async {
                              if (!isSelected) {
                                await auth.updateAvatar(option.id);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppAvatar(
                                  avatarId: option.id,
                                  size: 52,
                                  isSelected: isSelected,
                                  showBorder: !isSelected,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 2. BÖLÜM: GÖRÜNÜM (TEMA)
              // ==========================================
              _buildSectionHeader(
                icon: Icons.palette_outlined,
                title: 'Görünüm',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              Material(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uygulama Teması',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Göz yormayan soft adaçayı açık tema veya dinlendirici koyu tema.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThemeOptionCard(
                              context: context,
                              title: 'Açık Tema',
                              icon: Icons.wb_sunny_rounded,
                              isSelected: !settingsCtrl.isDarkMode,
                              onTap: () {
                                if (user != null) {
                                  settingsCtrl.setThemeMode(
                                    user.id,
                                    ThemeMode.light,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildThemeOptionCard(
                              context: context,
                              title: 'Koyu Tema',
                              icon: Icons.nightlight_round,
                              isSelected: settingsCtrl.isDarkMode,
                              onTap: () {
                                if (user != null) {
                                  settingsCtrl.setThemeMode(
                                    user.id,
                                    ThemeMode.dark,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 3. BÖLÜM: ŞİFRE DEĞİŞTİR
              // ==========================================
              _buildSectionHeader(
                icon: Icons.lock_outline_rounded,
                title: 'Şifre Değiştir',
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              Material(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _currentPasswordController,
                          label: 'Mevcut Şifre',
                          hint: 'Şu an kullandığınız şifre',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Mevcut şifrenizi giriniz.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _newPasswordController,
                          label: 'Yeni Şifre',
                          hint: 'En az 8 karakter',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Yeni şifrenizi giriniz.';
                            }
                            if (val.length < 8) {
                              return 'Yeni şifre en az 8 karakter olmalıdır.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Yeni Şifre Tekrar',
                          hint: 'Yeni şifrenizi tekrar giriniz',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.check_circle_outline),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Şifre tekrarını giriniz.';
                            }
                            return null;
                          },
                        ),
                        if (_passwordErrorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _passwordErrorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkError
                                  : AppColors.error,
                            ),
                          ),
                        ],
                        if (_passwordSuccessMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _passwordSuccessMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Şifreyi Güncelle',
                          isLoading: _isPasswordLoading,
                          onPressed: () {
                            _handleChangePassword();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 4. BÖLÜM: MOTİVASYON TERCİHLERİ
              // ==========================================
              const MotivationPreferencesPanel(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
