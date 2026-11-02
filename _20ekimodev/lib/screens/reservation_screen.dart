import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sample_data.dart';
import '../models/booking.dart';
import '../models/vehicle.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_text_field.dart';

enum ReservationMode { byBudget, byDuration }

class ReservationScreen extends StatefulWidget {
  final Vehicle vehicle;

  const ReservationScreen({super.key, required this.vehicle});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  ReservationMode _mode = ReservationMode.byDuration;

  DateTime _startDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    // Bir sonraki tam saat başlangıç olsun
    final now = DateTime.now();
    final nextHour = now.hour + 1;
    if (nextHour >= 24) {
      _startDate = DateTime(now.year, now.month, now.day + 1, 10, 0);
      _startTime = const TimeOfDay(hour: 10, minute: 0);
    } else {
      _startDate = DateTime(now.year, now.month, now.day, nextHour, 0);
      _startTime = TimeOfDay(hour: nextHour, minute: 0);
    }

    _firstNameController = TextEditingController(text: demoUserFirstName);
    _lastNameController = TextEditingController(text: demoUserLastName);

    // Varsayılan süre 2 saat
    _durationController.text = '2';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  DateTime get _startDateTime {
    return DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
  }

  int get _calculatedHours {
    if (_mode == ReservationMode.byDuration) {
      final text = _durationController.text.trim();
      final hours = int.tryParse(text);
      return (hours != null && hours > 0) ? hours : 0;
    } else {
      final text = _budgetController.text.trim();
      final budget = double.tryParse(text);
      if (budget == null || budget <= 0) return 0;
      final hours = (budget / widget.vehicle.hourlyPrice).floor();
      return hours;
    }
  }

  double get _calculatedTotalPrice {
    return _calculatedHours * widget.vehicle.hourlyPrice;
  }

  double? get _calculatedRemainingBudget {
    if (_mode != ReservationMode.byBudget) return null;
    final text = _budgetController.text.trim();
    final budget = double.tryParse(text);
    if (budget == null) return null;
    final remaining = budget - _calculatedTotalPrice;
    return remaining >= 0 ? remaining : 0;
  }

  DateTime get _endDateTime {
    return _startDateTime.add(Duration(hours: _calculatedHours));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(now) ? now : _startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('tr', 'TR'),
      helpText: 'Başlangıç Tarihi Seçin',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Başlangıç Saati Seçin (24 Saat)',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _onModeChanged(ReservationMode newMode) {
    if (_mode == newMode) return;
    setState(() {
      _mode = newMode;
      if (_mode == ReservationMode.byDuration) {
        _durationController.text = '2';
        _budgetController.clear();
      } else {
        // En az 1 saatlik fiyat ile başlat
        final defaultBudget = (widget.vehicle.hourlyPrice * 2).toInt();
        _budgetController.text = defaultBudget.toString();
        _durationController.clear();
      }
    });
  }

  void _submit() {
    final appState = AppStateScope.of(context);

    // Kendi aracını kiralama engeli
    if (widget.vehicle.ownerId == appState.currentUserId) {
      _showErrorDialog(
        title: 'Geçersiz İşlem',
        message: 'Kendi eklediğiniz araca rezervasyon yapamazsınız.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Tarih geçmişte mi kontrolü
    final now = DateTime.now();
    if (_startDateTime.isBefore(now)) {
      _showErrorDialog(
        title: 'Geçersiz Başlangıç Zamanı',
        message: 'Rezervasyon başlangıç tarihi ve saati geçmişte olamaz.',
      );
      return;
    }

    final hours = _calculatedHours;
    if (hours < 1) {
      _showErrorDialog(
        title: 'Geçersiz Süre',
        message: _mode == ReservationMode.byBudget
            ? 'Girilen bütçe ile en az 1 saatlik kiralama yapılmalıdır (Minimum bütçe: ${AppFormatters.formatCurrency(widget.vehicle.hourlyPrice)}).'
            : 'Kiralama süresi en az 1 saat olmalıdır.',
      );
      return;
    }

    final start = _startDateTime;
    final end = _endDateTime;

    // Çakışma kontrolü
    // yeniBaşlangıç < mevcutBitiş && yeniBitiş > mevcutBaşlangıç
    final hasConflict = appState.hasBookingConflict(widget.vehicle.id, start, end);
    if (hasConflict) {
      _showErrorDialog(
        title: 'Zaman Çakışması',
        message:
            'Seçtiğiniz tarih ve saat aralığında bu araç için başka bir aktif rezervasyon bulunmaktadır. Lütfen farklı bir zaman aralığı seçiniz.',
      );
      return;
    }

    // Özet Onay Diyaloğu
    _showSummaryDialog(start, end, hours);
  }

  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(DateTime start, DateTime end, int hours) {
    final totalPrice = _calculatedTotalPrice;
    final renterName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Rezervasyon Özeti'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Araç:', widget.vehicle.title),
              _buildSummaryRow('Konum:', widget.vehicle.location),
              _buildSummaryRow('Kiralayan:', renterName),
              const Divider(height: 16),
              _buildSummaryRow(
                'Başlangıç:',
                AppFormatters.formatDateTime24(start),
              ),
              _buildSummaryRow(
                'Bitiş:',
                AppFormatters.formatDateTime24(end),
              ),
              _buildSummaryRow('Kiralama Süresi:', '$hours saat'),
              _buildSummaryRow(
                'Saatlik Ücret:',
                AppFormatters.formatCurrency(widget.vehicle.hourlyPrice),
              ),
              if (_mode == ReservationMode.byBudget && _calculatedRemainingBudget != null)
                _buildSummaryRow(
                  'Kalan Bütçe:',
                  AppFormatters.formatCurrency(_calculatedRemainingBudget!),
                ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Toplam Tutar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    AppFormatters.formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Diyaloğu kapat
              _confirmBooking(start, end, hours, totalPrice);
            },
            child: const Text('Rezervasyonu Onayla'),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(DateTime start, DateTime end, int hours, double totalPrice) {
    final appState = AppStateScope.of(context);

    final newBooking = Booking(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: widget.vehicle.id,
      vehicleTitleSnapshot: widget.vehicle.title,
      ownerId: widget.vehicle.ownerId,
      renterId: appState.currentUserId,
      renterFirstName: _firstNameController.text.trim(),
      renterLastName: _lastNameController.text.trim(),
      startAt: start,
      endAt: end,
      durationHours: hours,
      hourlyPriceSnapshot: widget.vehicle.hourlyPrice,
      totalPrice: totalPrice,
      isCancelled: false,
    );

    appState.addBooking(newBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[700],
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rezervasyonunuz başarıyla oluşturuldu! Profil > Kiralanan Araçlarım bölümünden görüntüleyebilirsiniz.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.of(context).pop();
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
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
    final isOwner = widget.vehicle.ownerId == appState.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Yap'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Seçilen Aracın Özeti
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_car_filled_rounded,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.vehicle.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.vehicle.type} • ${widget.vehicle.color} • ${widget.vehicle.location}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saatlik Kiralama Ücreti:',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${AppFormatters.formatCurrency(widget.vehicle.hourlyPrice)} / saat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (isOwner) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bu araç sizin kendi ilanınızdır. Kendi aracınızı kiralayamazsınız.',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Kiralayan Bilgileri (Ad, Soyad)
                Text(
                  'Kiralayan Bilgileri',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: _firstNameController,
                        labelText: 'Adınız',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ad boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonTextField(
                        controller: _lastNameController,
                        labelText: 'Soyadınız',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Soyad boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. Başlangıç Tarihi ve Saati
                Text(
                  'Başlangıç Tarihi ve Saati',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                AppFormatters.formatDateOnly(_startDate),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                AppFormatters.formatTimeOnly(_startDateTime),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Kiralama Hesaplama Modu
                Text(
                  'Hesaplama Yöntemi',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ReservationMode>(
                    segments: const [
                      ButtonSegment<ReservationMode>(
                        value: ReservationMode.byDuration,
                        label: Text('Süreye Göre'),
                        icon: Icon(Icons.timer_outlined),
                      ),
                      ButtonSegment<ReservationMode>(
                        value: ReservationMode.byBudget,
                        label: Text('Bütçeme Göre'),
                        icon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (Set<ReservationMode> newSelection) {
                      _onModeChanged(newSelection.first);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Mod Girdisi
                if (_mode == ReservationMode.byDuration) ...[
                  CommonTextField(
                    controller: _durationController,
                    labelText: 'Kiralama Süresi (Saat)',
                    hintText: 'Örn: 2, 4, 24',
                    prefixIcon: Icons.hourglass_top_rounded,
                    suffixText: 'Saat',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (_mode != ReservationMode.byDuration) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen saat cinsinden süre girin';
                      }
                      final hours = int.tryParse(value.trim());
                      if (hours == null || hours < 1) {
                        return 'Süre en az 1 saat olmalıdır';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  CommonTextField(
                    controller: _budgetController,
                    labelText: 'Bütçeniz (TL)',
                    hintText: 'Örn: 1000',
                    prefixIcon: Icons.payments_outlined,
                    suffixText: 'TL',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (_mode != ReservationMode.byBudget) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bütçenizi girin';
                      }
                      final budget = double.tryParse(value.trim());
                      if (budget == null || budget <= 0) {
                        return 'Geçerli bir bütçe tutarı girin';
                      }
                      if (budget < widget.vehicle.hourlyPrice) {
                        return 'Bütçe en az 1 saatlik kiralama tutarı (${AppFormatters.formatCurrency(widget.vehicle.hourlyPrice)}) olmalıdır';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Canlı Hesaplama Önizleme Kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate_outlined,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Kiralama Hesaplama Özeti',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hesaplanan Süre:'),
                          Text(
                            '$_calculatedHours saat',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bitiş Zamanı:'),
                          Text(
                            AppFormatters.formatDateTime24(_endDateTime),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_mode == ReservationMode.byBudget &&
                          _calculatedRemainingBudget != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kalan Bütçe:'),
                            Text(
                              AppFormatters.formatCurrency(_calculatedRemainingBudget!),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ödenecek Tutar:',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          Text(
                            AppFormatters.formatCurrency(_calculatedTotalPrice),
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

                const SizedBox(height: 30),

                // Onayla Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isOwner ? null : _submit,
                    child: const Text(
                      'Rezervasyonu Onayla',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
