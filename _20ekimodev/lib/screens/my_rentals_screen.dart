import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class MyRentalsScreen extends StatelessWidget {
  const MyRentalsScreen({super.key});

  void _onCancelBooking(BuildContext context, AppState appState, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Rezervasyonu İptal Et'),
          ],
        ),
        content: Text(
          '${booking.vehicleTitleSnapshot} için oluşturulan rezervasyonunuzu iptal etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              appState.cancelBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rezervasyonunuz iptal edildi.'),
                ),
              );
            },
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = AppStateScope.of(context);
    final myRentals = appState.myRentals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiralanan Araçlarım'),
      ),
      body: myRentals.isEmpty
          ? const EmptyState(
              icon: Icons.car_rental_outlined,
              title: 'Henüz Kiralama Yapmadınız',
              message:
                  'Ana Sayfa veya Filtreleme ekranından beğendiğiniz bir aracı seçip hemen rezervasyon oluşturabilirsiniz.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: myRentals.length,
              itemBuilder: (context, index) {
                final booking = myRentals[index];

                final isCancelled = booking.isCancelled;
                final isCompleted = !isCancelled && DateTime.now().isAfter(booking.endAt);
                final isActive = !isCancelled && !isCompleted;

                Color statusColor;
                String statusText;
                if (isCancelled) {
                  statusColor = Colors.redAccent;
                  statusText = 'İptal Edildi';
                } else if (isCompleted) {
                  statusColor = Colors.grey;
                  statusText = 'Tamamlandı';
                } else {
                  statusColor = Colors.green;
                  statusText = 'Aktif Rezervasyon';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Başlık & Durum
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.vehicleTitleSnapshot,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Tarihler & Süre
                        _buildRow('Başlangıç:', AppFormatters.formatDateTime24(booking.startAt)),
                        _buildRow('Bitiş:', AppFormatters.formatDateTime24(booking.endAt)),
                        _buildRow('Toplam Süre:', '${booking.durationHours} saat'),
                        _buildRow(
                          'Saatlik Ücret:',
                          AppFormatters.formatCurrency(booking.hourlyPriceSnapshot),
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Alt Kısım: Toplam Tutar ve İptal Butonu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Toplam Tutar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                  ),
                                ),
                                Text(
                                  AppFormatters.formatCurrency(booking.totalPrice),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (isActive)
                              OutlinedButton.icon(
                                onPressed: () => _onCancelBooking(context, appState, booking),
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 16, color: Colors.redAccent),
                                label: const Text(
                                  'İptal Et',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
