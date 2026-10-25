import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/rental_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/rental_bloc.dart';
import '../widgets/empty_view.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<RentalBloc>().add(LoadRentalsEvent(authState.user.id));
    }
  }

  void _showDetailModal(BuildContext context, RentalModel rental) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kiralama ve Çıkış Detayı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),

                // Listing Title & Dates
                Text(
                  rental.listingTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rental.district}, ${rental.city}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Column(
                    children: [
                      _buildRow(
                        'Ev Sahibi',
                        '${rental.ownerName} (${rental.ownerPhone})',
                      ),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Giriş Tarihi',
                        DateFormatter.formatShortDate(rental.startDate),
                      ),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Çıkış Tarihi',
                        rental.checkoutDate != null
                            ? DateFormatter.formatShortDate(
                                rental.checkoutDate!,
                              )
                            : 'Belirtilmedi',
                      ),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Fiili Kalış Süresi',
                        '${rental.actualDaysStayed ?? rental.originalDays} gün',
                      ),
                      const SizedBox(height: 6),
                      _buildRow(
                        'Ödenen Net Ücret',
                        CurrencyFormatter.format(
                          rental.actualChargedAmount ?? rental.totalPaid,
                        ),
                        isBold: true,
                      ),
                      if (rental.refundAmount != null &&
                          rental.refundAmount! > 0) ...[
                        const SizedBox(height: 6),
                        _buildRow(
                          'Erken Çıkış İadesi',
                          CurrencyFormatter.format(rental.refundAmount!),
                          color: AppColors.success,
                          isBold: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.standard),

                // Section 11: "kullanıcının evden çıkarken yüklediği fotoğraf"
                const Text(
                  'Evden Çıkarken Yüklenen Teslimat Fotoğrafı',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),

                if (rental.checkoutPhotoPath != null &&
                    rental.checkoutPhotoPath!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: AppRadius.cardRadius,
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: rental.checkoutPhotoPath!.startsWith('http')
                          ? Image.network(
                              rental.checkoutPhotoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.shimmerBase,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            )
                          : Image.file(
                              File(rental.checkoutPhotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.shimmerBase,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppRadius.cardRadius,
                    ),
                    child: const Center(
                      child: Text(
                        'Çıkış fotoğrafı kaydedilmemiş.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(
    String title,
    String val, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13)),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildListingImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.shimmerBase,
        child: const Icon(Icons.home, color: Colors.black38),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.shimmerBase,
          child: const Icon(Icons.home, color: Colors.black38),
        ),
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.shimmerBase,
          child: const Icon(Icons.home, color: Colors.black38),
        ),
      );
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.shimmerBase,
          child: const Icon(Icons.home, color: Colors.black38),
        ),
      );
    }
    return Container(
      color: AppColors.shimmerBase,
      child: const Icon(Icons.home, color: Colors.black38),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daha Önce Kiraladıklarım',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<RentalBloc, RentalState>(
        builder: (context, state) {
          if (state is RentalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = state is RentalLoaded
              ? (currentUserId != null
                  ? state.rentalHistory
                      .where((r) => r.tenantId == currentUserId)
                      .toList()
                  : state.rentalHistory)
              : <RentalModel>[];

          if (history.isEmpty) {
            final hasActive =
                state is RentalLoaded &&
                state.activeRental != null &&
                state.activeRental!.isActive &&
                (currentUserId == null ||
                    state.activeRental!.tenantId == currentUserId);

            return EmptyView(
              icon: Icons.history_rounded,
              title: 'Geçmiş Kiralama Bulunamadı',
              subtitle: hasActive
                  ? 'Şu anda aktif bir kiralamanız bulunmaktadır. Aktif kiralık evinizi "Kiralamalar" sekmesinden görüntüleyebilir; evden çıkış yapıp teslim fotoğrafını yüklediğinizde geçmişiniz burada arşivlenecektir.'
                  : 'Daha önce kiralayıp çıkış yaptığınız tüm ev ve odalar burada arşivlenecektir.',
              buttonText: hasActive ? 'Geri Dön' : null,
              onButtonPressed:
                  hasActive ? () => Navigator.of(context).pop() : null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius,
                ),
                child: InkWell(
                  borderRadius: AppRadius.cardRadius,
                  onTap: () => _showDetailModal(context, item),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 11: "Ev/oda fotoğrafı (sol üstte)"
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: _buildListingImage(item.listingImage),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Section 11: "Ev/oda başlığı, Ev/oda sahibi bilgileri, Ev/oda konumu, Ev/oda ödeme bilgileri, Ev/oda çıkış bilgileri"
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.listingTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.ownerName} • ${item.ownerPhone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.district}, ${item.city}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(
                                      item.actualChargedAmount ??
                                          item.totalPaid,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${item.actualDaysStayed ?? item.originalDays} gün kalındı',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
