import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/rental_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/rental_bloc.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class RentalBookingBottomSheet extends StatefulWidget {
  final ListingModel listing;
  final UserModel currentUser;

  const RentalBookingBottomSheet({
    super.key,
    required this.listing,
    required this.currentUser,
  });

  static Future<void> show(
    BuildContext context, {
    required ListingModel listing,
    required UserModel currentUser,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (context) =>
          RentalBookingBottomSheet(listing: listing, currentUser: currentUser),
    );
  }

  @override
  State<RentalBookingBottomSheet> createState() =>
      _RentalBookingBottomSheetState();
}

class _RentalBookingBottomSheetState extends State<RentalBookingBottomSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  int _guestCount = 1;
  SavedCardModel? _selectedSavedCard;
  bool _useNewCard = false;

  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 30));

    if (widget.currentUser.savedCards.isNotEmpty) {
      _selectedSavedCard = widget.currentUser.savedCards.first;
    } else {
      _useNewCard = true;
      _cardHolderController.text = widget.currentUser.fullName.toUpperCase();
      _cardNumberController.text = '5421 8899 4432 1234';
      _expiryController.text = '12/28';
      _cvvController.text = '321';
    }
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  int get _daysCount {
    final diff = _endDate.difference(_startDate).inDays;
    return diff < 1 ? 1 : diff;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _onBook() {
    if (_isSubmitting) return;

    if (_endDate.isBefore(_startDate) ||
        _endDate.isAtSameMomentAs(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir tarih aralığı seçiniz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_useNewCard) {
      if (_cardHolderController.text.trim().isEmpty ||
          _cardNumberController.text.trim().isEmpty ||
          _expiryController.text.trim().isEmpty ||
          _cvvController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen demo kart bilgilerini eksiksiz doldurunuz.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final calculation = widget.listing.calculatePrice(
      days: _daysCount,
      isStudent: widget.currentUser.isStudent,
    );

    final rental = RentalModel(
      id: '',
      listingId: widget.listing.id,
      listingTitle: widget.listing.title,
      listingImage: widget.listing.images.isNotEmpty
          ? widget.listing.images.first
          : '',
      city: widget.listing.city,
      district: widget.listing.district,
      ownerId: widget.listing.owner.id,
      ownerName: widget.listing.owner.fullName,
      ownerPhone: widget.listing.owner.phone,
      tenantId: widget.currentUser.id,
      tenantName: widget.currentUser.fullName,
      tenantGender: widget.currentUser.gender,
      tenantAvatar: widget.currentUser.avatar,
      startDate: _startDate,
      endDate: _endDate,
      guestCount: _guestCount,
      originalDays: _daysCount,
      monthlyPrice: widget.listing.monthlyPrice,
      grossAmount: calculation.grossAmount,
      studentDiscountAmount: calculation.studentDiscountAmount,
      winterDiscountAmount: calculation.winterDiscountAmount,
      totalPaid: calculation.totalAmount,
      isStudentDiscountApplied: calculation.studentDiscountAmount > 0,
      isWinterDiscountApplied: calculation.winterDiscountAmount > 0,
      status: 'active',
      createdAt: DateTime.now(),
    );

    setState(() => _isSubmitting = true);
    context.read<RentalBloc>().add(BookRentalEvent(rental));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rentalState = context.watch<RentalBloc>().state;
    final hasActiveRental =
        rentalState is RentalLoaded && rentalState.hasActiveRental;

    final calculation = widget.listing.calculatePrice(
      days: _daysCount,
      isStudent: widget.currentUser.isStudent,
    );

    return BlocListener<RentalBloc, RentalState>(
      listener: (context, state) {
        if (state is RentalActionSuccess) {
          setState(() => _isSubmitting = false);
          context.read<ListingBloc>().add(LoadListingsEvent());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is RentalActionError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
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

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.standard,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kiralama & Demo Ödeme',
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

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.standard),
                  children: [
                    // Active rental warning banner if user already has an active rental
                    if (hasActiveRental) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: AppRadius.inputRadius,
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Zaten aktif bir kiralamanız bulunmaktadır. Yeni kiralama yapabilmek için önce mevcut evinizden çıkış yapmanız gerekir.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Room Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: AppRadius.cardRadius,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: widget.listing.images.isNotEmpty
                                  ? Image.network(
                                      widget.listing.images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) => const Icon(Icons.home),
                                    )
                                  : const Icon(Icons.home),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.listing.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.listing.district}, ${widget.listing.city}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatMonthly(
                                    widget.listing.monthlyPrice,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.standard),

                    // Tarih Seçimi
                    const Text(
                      'Kalış Tarihleri (Giriş - Çıkış)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: AppRadius.inputRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: AppRadius.inputRadius,
                          color: theme.colorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormatter.formatRange(
                                      _startDate,
                                      _endDate,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$_daysCount gün kalış',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Kişi Sayısı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kişi Sayısı',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _guestCount > 1
                                  ? () => setState(() => _guestCount--)
                                  : null,
                            ),
                            Text(
                              '$_guestCount Kişi',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _guestCount < 4
                                  ? () => setState(() => _guestCount++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Fiyat ve İndirim Dökümü
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ücret ve İndirim Dökümü',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildPriceLine('Gün Sayısı', '$_daysCount gün'),
                          _buildPriceLine(
                            'Günlük Eşdeğer Kira',
                            CurrencyFormatter.formatDaily(
                              widget.listing.dailyPrice,
                            ),
                          ),
                          _buildPriceLine(
                            'Brüt Konaklama Bedeli',
                            CurrencyFormatter.format(calculation.grossAmount),
                          ),

                          if (calculation.studentDiscountAmount > 0) ...[
                            _buildPriceLine(
                              'Öğrenci Desteği (%20 İndirim)',
                              '-${CurrencyFormatter.format(calculation.studentDiscountAmount)}',
                              color: AppColors.success,
                            ),
                          ],

                          if (calculation.winterDiscountAmount > 0) ...[
                            _buildPriceLine(
                              'Kış Sezonu Kampanyası (%20 İndirim)',
                              '-${CurrencyFormatter.format(calculation.winterDiscountAmount)}',
                              color: const Color(0xFF16A085),
                            ),
                          ],

                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Toplam Ödenecek',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(
                                  calculation.totalAmount,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Demo Kart Bilgileri
                    const Row(
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Demo Ödeme Yöntemi',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Güvenlik gereği gerçek kart bilgisi girmeyiniz. Sistem demo simülasyonu çalıştırır.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Saved card selection if available
                    if (widget.currentUser.savedCards.isNotEmpty)
                      RadioGroup<String>(
                        groupValue: _useNewCard
                            ? 'new'
                            : _selectedSavedCard?.id,
                        onChanged: (val) {
                          if (val == 'new') {
                            setState(() {
                              _useNewCard = true;
                            });
                          } else if (val != null) {
                            final card = widget.currentUser.savedCards
                                .firstWhere((c) => c.id == val);
                            setState(() {
                              _useNewCard = false;
                              _selectedSavedCard = card;
                            });
                          }
                        },
                        child: Column(
                          children: [
                            ...widget.currentUser.savedCards.map((card) {
                              return RadioListTile<String>(
                                value: card.id,
                                title: Text(
                                  card.maskedNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${card.cardHolder} (${card.expiry})',
                                ),
                                secondary: const Icon(Icons.credit_card),
                              );
                            }),
                            const RadioListTile<String>(
                              value: 'new',
                              title: Text('Farklı Bir Demo Kart Kullan'),
                            ),
                          ],
                        ),
                      ),

                    if (_useNewCard) ...[
                      const SizedBox(height: 8),
                      CustomTextField(
                        label: 'Kart Üzerindeki İsim',
                        controller: _cardHolderController,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Kart Numarası',
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Son Kullanma (AA/YY)',
                              controller: _expiryController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'CVV',
                              controller: _cvvController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(AppSpacing.standard),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: hasActiveRental
                      ? 'Aktif Kiralamanız Bulunuyor'
                      : 'Ödemeyi Tamamla (${CurrencyFormatter.format(calculation.totalAmount)})',
                  isLoading: _isSubmitting,
                  onPressed: (hasActiveRental || _isSubmitting) ? null : _onBook,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
