import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/rental/rental_bloc.dart';
import '../../bloc/rental/rental_event.dart';
import '../../bloc/rental/rental_state.dart';
import '../chat/chat_conversation_screen.dart';

/// Kiralamalarım (Konaklama Takip) Ekranı:
/// Kullanıcının şu anda aktif olarak konakladığı odayı/evi, çıkış tarihine kalan gün sayacını,
/// ev sahibini, ödenen toplam tutarı gösterir ve 'Evden/Odadan Çıkış Yap' (Check-out) imkanı tanır.
class ActiveRentalsScreen extends StatefulWidget {
  const ActiveRentalsScreen({super.key});

  @override
  State<ActiveRentalsScreen> createState() => _ActiveRentalsScreenState();
}

class _ActiveRentalsScreenState extends State<ActiveRentalsScreen> {
  @override
  void initState() {
    super.initState();
    // Kullanıcının aktif kiralamalarını yüklemek için olay tetiklenir
    final authState = context.read<AuthBloc>().state;
    final userId =
        authState is AuthenticatedState ? authState.user.id : 'user-demo-1';
    context.read<RentalBloc>().add(LoadRentalsEvent(userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final authState = context.watch<AuthBloc>().state;
    final currentUser =
        authState is AuthenticatedState ? authState.user : null;
    final currentUserId = currentUser?.id ?? 'user-demo-1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiralamalarım'),
      ),
      body: BlocConsumer<RentalBloc, RentalState>(
        listener: (context, state) {
          // Başarılı kiralama veya check-out bildirimi
          if (state is RentalLoadedState && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is RentalErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RentalLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeStay =
              state is RentalLoadedState ? state.activeStay : null;

          // Aktif konaklama yoksa bilgilendirici boş ekran göster
          if (activeStay == null || activeStay.isCompleted) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.night_shelter_outlined,
                          size: 64, color: primaryColor),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Şu Anda Kiralanan İlan Yok',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keşfet sayfasındaki ilanlardan "Kirala" butonuna tıklayarak kiralama yaptığınızda burada görüntülenecektir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final currencyFormat =
              NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
          final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
          final remainingDays = activeStay.remainingDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kalan Gün Sayacı ve Bitiş Tarihi Kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, AppColors.secondaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded,
                          size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$remainingDays Gün Kaldı',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Çıkış Tarihi: ${dateFormat.format(activeStay.checkOutDate)}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Aktif Kiralama',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Kiralanan İlanın Detay Kartı
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.black.withAlpha(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: activeStay.listingImageUrl.isNotEmpty
                            ? Image.network(
                                activeStay.listingImageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 180,
                                  color: Colors.grey.withAlpha(50),
                                  child: const Center(
                                      child: Icon(Icons.home_work_rounded)),
                                ),
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey.withAlpha(50),
                                child: const Center(
                                    child: Icon(Icons.home_work_rounded)),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 14, color: primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${activeStay.district}, ${activeStay.city}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeStay.listingTitle,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            // Ev Sahibi Profil Bilgisi ve Mesajlaşma Butonu
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      activeStay.hostAvatarUrl.isNotEmpty
                                          ? NetworkImage(activeStay.hostAvatarUrl)
                                          : null,
                                  child: activeStay.hostAvatarUrl.isEmpty
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeStay.hostName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        'Ev / Oda Sahibi',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    textStyle: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  icon: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 16),
                                  label: const Text('İletişime Geç'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChatConversationScreen(
                                          peerId: activeStay.hostId,
                                          peerName: activeStay.hostName,
                                          peerAvatarUrl:
                                              activeStay.hostAvatarUrl,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Konaklama Tarihleri ve Ödeme Özeti
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Giriş Tarihi:',
                                    style: TextStyle(color: Colors.grey)),
                                Text(dateFormat.format(activeStay.checkInDate)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Çıkış Tarihi:',
                                    style: TextStyle(color: Colors.grey)),
                                Text(dateFormat
                                    .format(activeStay.checkOutDate)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Konaklama Süresi:',
                                    style: TextStyle(color: Colors.grey)),
                                Text('${activeStay.daysStayed} Gün'),
                              ],
                            ),
                            if (activeStay.discountReason != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    activeStay.discountReason!,
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '- ${currencyFormat.format(activeStay.discountAmount)}',
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ödenen Toplam Miktar:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  currencyFormat
                                      .format(activeStay.totalAmount),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Evden / Odadan Çıkış Yap Butonu
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Evden / Odadan Çıkış Yap'),
                              onPressed: () {
                                _showCheckoutConfirmDialog(
                                    context, activeStay.id, currentUserId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Çıkış yapmadan önce kullanıcıdan onay isteyen onay penceresi
  void _showCheckoutConfirmDialog(
      BuildContext context, String rentalId, String userId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Çıkış Yapılsın mı?'),
        content: const Text(
          'Bu odadan/evden çıkış yapmak üzeresiniz. Çıkış sonrasında yeni kiralama yapabilir ve geçmiş konaklamanızı tamamlamış olursunuz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<RentalBloc>().add(
                    CheckoutActiveRentalEvent(
                      rentalId: rentalId,
                      userId: userId,
                    ),
                  );
            },
            child: const Text('Evet, Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
