import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/price_calculator.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/rental_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/rental/rental_event.dart';

/// İlan detayından veya kartından 'Kirala' butonuna tıklandığında açılan
/// tarih aralığı seçimi, konaklama gün sayısı hesabı, indirim uygulaması, kart bilgisi girişi
/// ve ödeme işlemini gerçekleştiren modal alt panel (BottomSheet).
class RentalBookingBottomSheet extends StatefulWidget {
  final ListingEntity listing;

  const RentalBookingBottomSheet({super.key, required this.listing});

  /// Rezervasyon ve ödeme alt panelini açan yardımcı metot.
  static Future<void> show(BuildContext context, ListingEntity listing) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RentalBookingBottomSheet(listing: listing),
    );
  }

  @override
  State<RentalBookingBottomSheet> createState() =>
      _RentalBookingBottomSheetState();
}

class _RentalBookingBottomSheetState extends State<RentalBookingBottomSheet> {
  // Varsayılan rezervasyon tarihleri: Yarın giriş, 30 gün sonra çıkış
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 31));
  int _guestCount = 1;

  // Demo ödeme kartı formu kontrolcüleri
  final _cardNumberController =
      TextEditingController(text: '4543 2109 8765 4321');
  final _cardHolderController = TextEditingController(text: 'Betül Yılmaz');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '888');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  /// Seçili iki tarih arasındaki toplam konaklama gün sayısını hesaplar.
  int get _stayDays {
    final diff = _checkOutDate.difference(_checkInDate).inDays;
    return diff > 0 ? diff : 1;
  }

  /// Tarihi Türkçe '12 Kas 2026' formatında biçimlendirir.
  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy').format(date);
      } catch (_) {
        return '${date.day}.${date.month}.${date.year}';
      }
    }
  }

  /// Kullanıcıya tarih aralığı seçtirici (DateRangePicker) penceresini açar.
  Future<void> _selectDateRange() async {
    final initialRange = DateTimeRange(
      start: _checkInDate,
      end: _checkOutDate,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialRange,
      helpText: 'Giriş ve Çıkış Tarihi Seçin',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;
    final isStudent = user?.isStudent ?? false;

    // PriceCalculator ile iş mantığı kurallarını işlet: Günlük oran x Gün, Öğrenci veya Kış indirimi
    final priceResult = PriceCalculator.calculate(
      monthlyRent: widget.listing.monthlyRent,
      days: _stayDays,
      isStudent: isStudent,
      city: widget.listing.city,
      bookingDate: _checkInDate,
    );

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Sürükleme tutamacı
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Başlık ve Kapatma Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oda Kiralama ve Ödeme',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form ve İçerik Alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Tarih Seçimi
                    const Text(
                      '1. Konaklama Tarihleri',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withAlpha(80)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                color: primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_formatDate(_checkInDate)} — ${_formatDate(_checkOutDate)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_stayDays Gün',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 2. Kişi Sayısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2. Kişi Sayısı',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _guestCount > 1
                                  ? () => setState(() => _guestCount--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_guestCount Kişi',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: _guestCount < 4
                                  ? () => setState(() => _guestCount++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    // 3. Fiyat Özeti
                    const Text(
                      '3. Fiyat Dökümü',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.accentBeige.withAlpha(120),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Aylık Kira Bedeli:'),
                              Text(currencyFormat.format(widget.listing.monthlyRent)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Gün Sayısı:'),
                              Text('$_stayDays Gün'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Taban Ücret (Aylık/30 * $_stayDays):'),
                              Text(currencyFormat.format(priceResult.basePrice)),
                            ],
                          ),
                          if (priceResult.discountReason != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.discount_rounded,
                                        size: 16, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(
                                      priceResult.discountReason!,
                                      style: const TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Text(
                                  '- ${currencyFormat.format(priceResult.discountAmount)}',
                                  style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Toplam Tutar:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                currencyFormat.format(priceResult.finalPrice),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 4. Kart Bilgileri Formu
                    const Text(
                      '4. Ödeme Yöntemi (Kart Bilgileri)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kart Numarası',
                        prefixIcon: Icon(Icons.credit_card_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: const InputDecoration(
                        labelText: 'Kart Üzerindeki İsim',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'SKT (Ay/Yıl)',
                              hintText: '12/28',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Gerekli' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: '888',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Gerekli' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Ödeme ve Kiralama Butonu
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final currentUserId = user?.id ?? 'user-demo-1';
                          // Yeni kiralama varlığı oluştur
                          final rental = RentalEntity(
                            id: 'rental-${DateTime.now().millisecondsSinceEpoch}',
                            listingId: widget.listing.id,
                            listingTitle: widget.listing.title,
                            listingImageUrl: widget.listing.imageUrl,
                            city: widget.listing.city,
                            district: widget.listing.district,
                            monthlyRent: widget.listing.monthlyRent,
                            hostId: widget.listing.owner.id,
                            hostName: widget.listing.owner.name,
                            hostAvatarUrl: widget.listing.owner.avatarUrl,
                            tenantId: currentUserId,
                            tenantName: user?.name ?? 'Betül Yılmaz',
                            tenantGender: user?.gender ?? 'Kadın',
                            tenantAvatarUrl: user?.avatarUrl ?? '',
                            tenantOccupation:
                                user?.occupation ?? 'Yazılım Mühendisi',
                            checkInDate: _checkInDate,
                            checkOutDate: _checkOutDate,
                            daysStayed: _stayDays,
                            guestCount: _guestCount,
                            baseAmount: priceResult.basePrice,
                            discountAmount: priceResult.discountAmount,
                            totalAmount: priceResult.finalPrice,
                            discountReason: priceResult.discountReason,
                            isCompleted: false,
                            createdAt: DateTime.now(),
                          );

                          // BLoC'a kiralama oluşturma olayını gönder
                          context
                              .read<RentalBloc>()
                              .add(CreateRentalBookingEvent(rental));
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Kiralama işleminiz başarıyla tamamlandı!'),
                              backgroundColor: primaryColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Text(
                        '${currencyFormat.format(priceResult.finalPrice)} Öde ve Kirala',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
