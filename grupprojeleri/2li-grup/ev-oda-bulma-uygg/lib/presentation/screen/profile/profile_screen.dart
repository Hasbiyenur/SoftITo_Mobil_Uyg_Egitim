import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../auth/login_screen.dart';

/// Profilim Ekranı:
/// Kullanıcının kimlik, meslek ve öğrenci durumu bilgilerini görüntüler.
/// Karanlık / Aydınlık tema geçişi, yaşam alışkanlıklarının güncellenmesi,
/// kayıtlı teslimat adreslerinin yönetimi, ödeme kartı güncellemesi, geliştiriciye geri bildirim formu,
/// oturum kapatma ve hesap silme işlevlerini barındırır.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Oturum kapatıldığında veya hesap silindiğinde Giriş ekranına yönlendir
        if (state is UnauthenticatedState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final user = state is AuthenticatedState ? state.user : null;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profilim'),
            actions: [
              // Açık / Koyu Tema Değiştirme Butonu
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isCurrentlyDark = themeMode == ThemeMode.dark;
                  return IconButton(
                    icon: Icon(
                      isCurrentlyDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: primaryColor,
                    ),
                    tooltip: isCurrentlyDark ? 'Açık Tema' : 'Koyu Tema',
                    onPressed: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kullanıcı Profil Özet Kartı
                _buildProfileCard(context, user, primaryColor, isDark),
                const SizedBox(height: 20),
                // 2. Ayarlar & Tercihler Menü Listesi
                _buildOptionTile(
                  icon: Icons.tune_rounded,
                  title: 'Alışkanlıklarım ve Tercihlerim',
                  subtitle: 'Uyku, temizlik, evcil hayvan ve ev tercihi',
                  color: primaryColor,
                  isDark: isDark,
                  onTap: () => _showHabitsModal(context, user, primaryColor),
                ),
                _buildOptionTile(
                  icon: Icons.location_on_outlined,
                  title: 'Adreslerim',
                  subtitle: '${user.savedAddresses.length} kayıtlı adres',
                  color: primaryColor,
                  isDark: isDark,
                  onTap: () => _showAddressesModal(context, user, primaryColor),
                ),
                _buildOptionTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Kayıtlı Ödeme Yöntemi',
                  subtitle: user.savedPaymentCard != null
                      ? 'Kredi Kartı (${user.savedPaymentCard!['cardNumber']})'
                      : 'Kayıtlı kart bulunmuyor',
                  color: primaryColor,
                  isDark: isDark,
                  onTap: () => _showPaymentModal(context, user, primaryColor),
                ),
                _buildOptionTile(
                  icon: Icons.feedback_outlined,
                  title: 'Geliştiriciye Geri Bildirim Gönder',
                  subtitle: 'Uygulama hakkında fikir ve önerilerinizi iletin',
                  color: primaryColor,
                  isDark: isDark,
                  onTap: () => _showFeedbackModal(context, primaryColor),
                ),
                const SizedBox(height: 24),
                // 3. Çıkış Yap ve Hesabımı Sil Butonları
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withAlpha(50),
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Çıkış Yap'),
                  onPressed: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withAlpha(30),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                  ),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Hesabımı Sil'),
                  onPressed: () => _showDeleteAccountDialog(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Profil kartını (Avatar, Ad Soyad, Öğrenci etiketi, Şehir ve Meslek) çizen widget
  Widget _buildProfileCard(
      BuildContext context, UserEntity user, Color primaryColor, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showUserDetailsModal(context, user, primaryColor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 36)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isStudent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Öğrenci',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.district}, ${user.city} • ${user.occupation}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.white54 : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Profil altındaki ayar seçeneklerini gösteren liste öğesi
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }

  /// Kullanıcının tüm profil detaylarını (telefon, yaş vb.) gösteren alt panel
  void _showUserDetailsModal(
      BuildContext context, UserEntity user, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profil Detayları',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow('İsim Soyisim', user.name),
            _buildDetailRow('E-posta', user.email),
            _buildDetailRow('Telefon', user.phone),
            _buildDetailRow('Yaş', user.age.toString()),
            _buildDetailRow('Cinsiyet', user.gender),
            _buildDetailRow('Meslek / Okul', user.occupation),
            _buildDetailRow(
                'Öğrenci Durumu', user.isStudent ? 'Öğrenci' : 'Çalışan'),
            _buildDetailRow('Konum', '${user.district}, ${user.city}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  /// Profil detay satırı yardımcı widget'ı
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Alışkanlıklar (sigara, evcil hayvan, uyku, temizlik, ev tipi) düzenleme paneli
  void _showHabitsModal(
      BuildContext context, UserEntity user, Color primaryColor) {
    bool smoking = user.smoking;
    bool hasPet = user.hasPet;
    String sleep = user.sleepSchedule;
    String cleaning = user.cleaningSensitivity;
    String houseType = user.preferredHouseType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Alışkanlıklarım ve Tercihlerim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Sigara Kullanımı'),
                      value: smoking,
                      activeThumbColor: primaryColor,
                      onChanged: (v) => setModalState(() => smoking = v),
                    ),
                    SwitchListTile(
                      title: const Text('Evcil Hayvan'),
                      value: hasPet,
                      activeThumbColor: primaryColor,
                      onChanged: (v) => setModalState(() => hasPet = v),
                    ),
                    const SizedBox(height: 12),
                    const Text('Uyku Düzeni',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['gece', 'sabah', 'yok'].map((s) {
                        return ChoiceChip(
                          label: Text(s.toUpperCase()),
                          selected: sleep == s,
                          onSelected: (sel) {
                            if (sel) setModalState(() => sleep = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Temizlik Hassasiyeti',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['yok', 'az', 'orta', 'çok'].map((c) {
                        return ChoiceChip(
                          label: Text(c.toUpperCase()),
                          selected: cleaning == c,
                          onSelected: (sel) {
                            if (sel) setModalState(() => cleaning = c);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tercih Edilen Ev Tipi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['1+1 Stüdyo', '2+1 Daire', '3+1 Daire', 'Müstakil Ev']
                              .map((ht) {
                        return ChoiceChip(
                          label: Text(ht),
                          selected: houseType == ht,
                          onSelected: (sel) {
                            if (sel) setModalState(() => houseType = ht);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final updated = user.copyWith(
                    smoking: smoking,
                    hasPet: hasPet,
                    sleepSchedule: sleep,
                    cleaningSensitivity: cleaning,
                    preferredHouseType: houseType,
                  );
                  context
                      .read<AuthBloc>()
                      .add(UpdateProfileEvent(user: updated));
                  Navigator.of(ctx).pop();
                },
                child: const Text('Tercihleri Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kayıtlı adresler ekleme ve silme paneli
  void _showAddressesModal(
      BuildContext context, UserEntity user, Color primaryColor) {
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kayıtlı Adreslerim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: user.savedAddresses.isEmpty
                    ? const Center(child: Text('Henüz kayıtlı adresiniz yok.'))
                    : ListView.builder(
                        itemCount: user.savedAddresses.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(user.savedAddresses[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                final updatedList =
                                    List<String>.from(user.savedAddresses)
                                      ..removeAt(index);
                                context.read<AuthBloc>().add(
                                      UpdateProfileEvent(
                                        user: user.copyWith(
                                            savedAddresses: updatedList),
                                      ),
                                    );
                                setModalState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Adres Ekle',
                  hintText: 'Örn: Kadıköy Moda Cad. No: 42',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (addressController.text.trim().isNotEmpty) {
                    final updatedList = List<String>.from(user.savedAddresses)
                      ..add(addressController.text.trim());
                    context.read<AuthBloc>().add(
                          UpdateProfileEvent(
                            user: user.copyWith(savedAddresses: updatedList),
                          ),
                        );
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Adresi Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kayıtlı ödeme kartı güncelleme paneli
  void _showPaymentModal(
      BuildContext context, UserEntity user, Color primaryColor) {
    final cardNoController = TextEditingController(
      text: user.savedPaymentCard?['cardNumber'] ?? '5421 8900 1234 5678',
    );
    final holderController = TextEditingController(
      text: user.savedPaymentCard?['cardHolder'] ?? user.name,
    );
    final expController = TextEditingController(
      text: user.savedPaymentCard?['expiryDate'] ?? '12/28',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kayıtlı Ödeme Yöntemi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Kredi Kartı Görseli
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.credit_card, color: Colors.white, size: 28),
                      Text(
                        'Roomio Pay',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    cardNoController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        holderController.text.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        expController.text,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: cardNoController,
              decoration: const InputDecoration(labelText: 'Kart Numarası'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: holderController,
                    decoration:
                        const InputDecoration(labelText: 'Kart Sahibi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: expController,
                    decoration: const InputDecoration(labelText: 'SKT (Ay/Yıl)'),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final updated = user.copyWith(
                  savedPaymentCard: {
                    'cardNumber': cardNoController.text.trim(),
                    'cardHolder': holderController.text.trim(),
                    'expiryDate': expController.text.trim(),
                  },
                );
                context
                    .read<AuthBloc>()
                    .add(UpdateProfileEvent(user: updated));
                Navigator.of(ctx).pop();
              },
              child: const Text('Kartı Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  /// Geliştiriciye geri bildirim gönderme paneli
  void _showFeedbackModal(BuildContext context, Color primaryColor) {
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geri Bildirim Kutusu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Uygulama ile ilgili karşılaştığınız sorunları veya önerilerinizi bize iletebilirsiniz.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextFormField(
                controller: feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Görüş ve önerilerinizi buraya yazın...',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Geri bildiriminiz geliştiriciye başarıyla iletildi! Teşekkür ederiz.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Geri Bildirim Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  /// Çıkış yap onay diyalogu
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  /// Hesabı sil onay diyalogu
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabımı Sil'),
        content: const Text(
          'Hesabınızı silmek üzeresiniz. Tüm aktif ilanlarınız ve profil verileriniz kalıcı olarak silinecektir. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(DeleteAccountEvent());
            },
            child: const Text('Evet, Hesabımı Sil'),
          ),
        ],
      ),
    );
  }
}
