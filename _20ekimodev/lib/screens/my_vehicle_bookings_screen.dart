import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class MyVehicleBookingsScreen extends StatelessWidget {
  const MyVehicleBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = AppStateScope.of(context);
    final bookings = appState.myVehicleBookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlarımın Kiralamaları'),
      ),
      body: bookings.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Henüz Rezervasyon Yok',
              message:
                  'Eklediğiniz araçlara başkaları tarafından rezervasyon yapıldığında bu ekranda kiralayan bilgileri ve gelir detaylarıyla listelenecektir.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                final isCancelled = booking.isCancelled;
                final isCompleted = !isCancelled && DateTime.now().isAfter(booking.endAt);

                Color statusColor;
                String statusText;
                if (isCancelled) {
                  statusColor = Colors.redAccent;
                  statusText = 'İptal Edildi';
                } else if (isCompleted) {
                  statusColor = Colors.grey;
                  statusText = 'Tamamlandı';
                } else {
                  statusColor = Colors.teal;
                  statusText = 'Aktif Kiralama';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık ve Durum
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

                        // Kiralayan Kişi Bilgisi
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                child: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kiralayan Müşteri',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    booking.renterFullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tarihler ve Süre
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

                        // Toplam Gelir
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kazanılan / Beklenen Gelir:',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(booking.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.teal,
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
