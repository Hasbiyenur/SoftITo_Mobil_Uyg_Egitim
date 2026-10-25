import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/rental_bloc.dart';
import '../bloc/theme_cubit.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/feedback_bottom_sheet.dart';
import 'login_screen.dart';
import 'rental_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilim',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.read<RentalBloc>().add(const ClearRentalsEvent());
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 10: Kullanıcı Profil Kartı
                _buildProfileHeaderCard(context, user, theme),
                const SizedBox(height: AppSpacing.standard),

                // Section 10: Menü Seçenekleri
                _buildMenuSection(context, user, theme, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Çıkış Yap & Hesabımı Sil Butonları
                _buildAccountActions(context, theme),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. Profil Kartı (tıklandığında detayları gösteren)
  Widget _buildProfileHeaderCard(
    BuildContext context,
    UserModel user,
    ThemeData theme,
  ) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: () => _showUserDetailsDialog(context, user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 34,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                backgroundImage: user.avatar != null
                    ? (user.avatar!.startsWith('http')
                          ? NetworkImage(user.avatar!) as ImageProvider
                          : FileImage(File(user.avatar!)))
                    : null,
                child: user.avatar == null
                    ? Text(
                        user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Student Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: user.isStudent
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.isStudent
                            ? '🎓 Öğrenci (%20 İndirim Tanımlı)'
                            : '💼 Çalışan Birey',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: user.isStudent
                              ? AppColors.secondary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Menü Seçenekleri
  Widget _buildMenuSection(
    BuildContext context,
    UserModel user,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: Column(
        children: [
          // Alışkanlıklarım ve Tercihlerim
          _buildMenuItem(
            icon: Icons.tune_rounded,
            title: 'Alışkanlıklarım ve Tercihlerim',
            subtitle: 'Sigara, evcil hayvan, uyku düzeni ve diller',
            onTap: () => _showHabitsBottomSheet(context, user),
          ),
          const Divider(height: 1, indent: 56),

          // Adreslerim
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Adreslerim',
            subtitle: '${user.addresses.length} kayıtlı adres',
            onTap: () => _showAddressesBottomSheet(context, user),
          ),
          const Divider(height: 1, indent: 56),

          // Kayıtlı Ödeme Yöntemi
          _buildMenuItem(
            icon: Icons.credit_card_rounded,
            title: 'Kayıtlı Ödeme Yöntemi',
            subtitle: '${user.savedCards.length} kayıtlı demo kart',
            onTap: () => _showCardsBottomSheet(context, user),
          ),
          const Divider(height: 1, indent: 56),

          // Daha Önce Kiralananlar
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'Daha Önce Kiraladıklarım',
            subtitle: 'Geçmiş kiralama ve teslim fotoğrafları',
            onTap: () {
              context.read<RentalBloc>().add(LoadRentalsEvent(user.id));
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RentalHistoryScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 56),

          // Feedback Kutusu
          _buildMenuItem(
            icon: Icons.rate_review_outlined,
            title: 'Geri Bildirim Gönder',
            subtitle: 'Uygulama geliştiricisine öneri ilet',
            onTap: () => FeedbackBottomSheet.show(context, currentUser: user),
          ),
          const Divider(height: 1, indent: 56),

          // Tema Değiştir
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Koyu Tema',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              isDark ? 'Koyu tema aktif' : 'Açık tema aktif',
              style: const TextStyle(fontSize: 12),
            ),
            value: isDark,
            activeThumbColor: AppColors.primary,
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  // 3. Hesap Aksiyonları (Çıkış & Sil)
  Widget _buildAccountActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Çıkış Yap
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Oturumu Kapat'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutEvent());
          },
        ),
        const SizedBox(height: 12),

        // Hesabımı Sil
        TextButton.icon(
          icon: const Icon(
            Icons.delete_forever_rounded,
            color: AppColors.error,
            size: 18,
          ),
          label: const Text(
            'Hesabımı ve Verilerimi Sil',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hesabınızı Silmek İstiyor Musunuz?'),
                content: const Text(
                  'Bu işlem geri alınamaz. Kayıtlı tüm profil bilgileriniz, adresleriniz ve ayarlarınız yerel depolamadan tamamen silinecektir.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.read<AuthBloc>().add(DeleteAccountEvent());
                    },
                    child: const Text('Evet, Sil'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Profil Detay Dialogu (Section 10)
  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('E-posta', user.email),
            _buildDetailItem('Telefon', user.phone),
            _buildDetailItem(
              'Yaş / Cinsiyet',
              '${user.age} yaş / ${user.gender}',
            ),
            _buildDetailItem('Meslek / Okul', user.occupation),
            _buildDetailItem('Konum', '${user.district}, ${user.city}'),
            _buildDetailItem(
              'Adli Sicil Belgesi',
              user.hasCriminalRecordDoc ? 'Doğrulandı ✅' : 'Eksik ❌',
            ),
            _buildDetailItem(
              'Öğrenci Belgesi',
              user.hasStudentDoc ? 'Doğrulandı ✅' : 'Yok',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailItem(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Flexible(child: Text(val, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // Alışkanlıklar BottomSheet (Düzenlenebilir)
  void _showHabitsBottomSheet(BuildContext context, UserModel user) {
    bool smoking = user.habits.smoking;
    bool hasPets = user.habits.hasPets;
    String sleepHabit = user.habits.sleepHabit;
    String cleanliness = user.habits.cleanliness;
    List<String> languages = List.from(user.habits.languages);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Alışkanlıklarımı Düzenle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text(
                      'Sigara Kullanıyorum',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: smoking,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setSheetState(() => smoking = v),
                  ),

                  SwitchListTile(
                    title: const Text(
                      'Evcil Hayvanım Var',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: hasPets,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setSheetState(() => hasPets = v),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Uyku Düzeni',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.sleepHabits.map((h) {
                      return ChoiceChip(
                        label: Text(h),
                        selected: sleepHabit == h,
                        onSelected: (_) => setSheetState(() => sleepHabit = h),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Temizlik Hassasiyeti',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['Yok', 'Az', 'Orta', 'Çok'].map((c) {
                      return ChoiceChip(
                        label: Text(c),
                        selected: cleanliness == c,
                        onSelected: (_) => setSheetState(() => cleanliness = c),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Konuştuğum Diller',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.availableLanguages.map((l) {
                      final sel = languages.contains(l);
                      return FilterChip(
                        label: Text(l),
                        selected: sel,
                        onSelected: (v) {
                          setSheetState(() {
                            if (v) {
                              languages.add(l);
                            } else if (languages.length > 1) {
                              languages.remove(l);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Değişiklikleri Kaydet',
                    onPressed: () {
                      final newHabits = user.habits.copyWith(
                        smoking: smoking,
                        hasPets: hasPets,
                        sleepHabit: sleepHabit,
                        cleanliness: cleanliness,
                        languages: languages,
                      );
                      context.read<AuthBloc>().add(
                        UpdateHabitsEvent(newHabits),
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Alışkanlıklarınız başarıyla güncellendi.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Adreslerim BottomSheet (Section 10)
  void _showAddressesBottomSheet(BuildContext context, UserModel user) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    String city = user.city;
    String district = user.district;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final addresses = user.addresses;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kayıtlı Adreslerim',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  if (addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Kayıtlı adres bulunamadı.'),
                    )
                  else
                    ...addresses.map(
                      (addr) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          addr.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${addr.district}, ${addr.city} • ${addr.addressDetail}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              RemoveAddressEvent(addr.id),
                            );
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ),
                    ),

                  const Divider(),
                  const Text(
                    'Yeni Adres Ekle',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    label: 'Adres Başlığı',
                    hint: 'Örn: Ev, Okul',
                    controller: titleController,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Detaylı Adres',
                    hint: 'Cadde, Mahalle, Kapı No',
                    controller: detailController,
                  ),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Adresi Kaydet',
                    onPressed: () {
                      if (titleController.text.trim().isEmpty ||
                          detailController.text.trim().isEmpty) {
                        return;
                      }
                      final newAddr = AddressModel(
                        id: const Uuid().v4(),
                        title: titleController.text.trim(),
                        city: city,
                        district: district,
                        addressDetail: detailController.text.trim(),
                      );
                      context.read<AuthBloc>().add(AddAddressEvent(newAddr));
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Kayıtlı Kartlarım BottomSheet (Section 10)
  void _showCardsBottomSheet(BuildContext context, UserModel user) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kayıtlı Demo Ödeme Kartlarım',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              ...user.savedCards.map(
                (card) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                    ),
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.cardHolder,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.maskedNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SKT: ${card.expiry}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            RemoveCardEvent(card.id),
                          );
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              const Text(
                'Yeni Demo Kart Tanımla',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Kart Sahibi',
                hint: 'AD SOYAD',
                controller: holderController,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Kart Numarası',
                hint: '•••• •••• •••• 1234',
                controller: numberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Son Kullanma Tarihi',
                hint: '12/28',
                controller: expiryController,
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Kartı Kaydet',
                onPressed: () {
                  if (holderController.text.trim().isEmpty ||
                      numberController.text.trim().isEmpty) {
                    return;
                  }
                  final rawNum = numberController.text.trim();
                  final masked = rawNum.length >= 4
                      ? '•••• •••• •••• ${rawNum.substring(rawNum.length - 4)}'
                      : '•••• •••• •••• 9999';
                  final newCard = SavedCardModel(
                    id: const Uuid().v4(),
                    cardHolder: holderController.text.trim().toUpperCase(),
                    maskedNumber: masked,
                    expiry: expiryController.text.trim().isNotEmpty
                        ? expiryController.text.trim()
                        : '12/28',
                  );
                  context.read<AuthBloc>().add(SaveCardEvent(newCard));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
