/// Fiyat hesaplama sonucunu temsil eden veri modeli.
/// İndirimsiz ham tutar, uygulanan indirim miktarı, nihai ödenecek tutar ve indirim gerekçesini tutar.
class PriceCalculationResult {
  /// İndirimsiz baz tutar (Günlük ücret x Gün sayısı)
  final double basePrice;

  /// Toplam düşülen indirim tutarı (TL)
  final double discountAmount;

  /// İndirim sonrası ödenecek son net tutar
  final double finalPrice;

  /// Uygulanan indirimin adı veya açıklaması (Örn: Öğrenci İndirimi (%20))
  final String? discountReason;

  /// Hesaba katılan toplam konaklama gün sayısı
  final int days;

  PriceCalculationResult({
    required this.basePrice,
    required this.discountAmount,
    required this.finalPrice,
    this.discountReason,
    required this.days,
  });
}

/// Rezervasyon ve kiralama ücretlerini hesaplayan yardımcı iş mantığı sınıfı.
/// Günlük kura çevirme, öğrenci indirimi ve büyük şehir kış sezonu indirim kurallarını uygular.
class PriceCalculator {
  /// Verilen aylık kira, gün sayısı, öğrenci durumu, şehir ve rezervasyon tarihine göre
  /// toplam tutarı ve hak edilen indirimleri hesaplar.
  ///
  /// Kurallar:
  /// 1. Günlük ücret = Aylık Kira / 30 gün
  /// 2. Öğrencilere koşulsuz %20 indirim uygulanır.
  /// 3. Öğrenci olmayanlar için: Eğer rezervasyon kış aylarında (Kasım, Aralık, Ocak)
  ///    ve büyük şehirlerde (İstanbul, Ankara, İzmir) ise %20 kış sezonu indirimi uygulanır.
  static PriceCalculationResult calculate({
    required double monthlyRent,
    required int days,
    required bool isStudent,
    required String city,
    required DateTime bookingDate,
  }) {
    // Geçersiz gün sayısı durumunda sıfır değerler döndürülür
    if (days <= 0) {
      return PriceCalculationResult(
        basePrice: 0,
        discountAmount: 0,
        finalPrice: 0,
        days: 0,
      );
    }

    // Aylık kira 30 güne bölünerek 1 günlük standart ücret bulunur
    final double dailyRate = monthlyRent / 30.0;
    // Günlük ücret ile konaklanacak gün sayısı çarpılarak baz fiyat elde edilir
    final double basePrice = dailyRate * days;

    double discountRate = 0.0;
    String? discountReason;

    // 1. Kural: Öğrenci indirimi kontrolü (%20)
    if (isStudent) {
      discountRate = 0.20;
      discountReason = 'Öğrenci İndirimi (%20)';
    } else {
      // 2. Kural: Kış sezonu ve büyük şehir indirimi kontrolü
      // Kasım (11), Aralık (12), Ocak (1) ayları kış sezonu kabul edilir
      final int month = bookingDate.month;
      final bool isWinterMonth = (month == 11 || month == 12 || month == 1);
      final List<String> bigCities = ['İstanbul', 'Ankara', 'İzmir'];
      
      // Şehir ismini küçük harfe çevirerek eşleştirme yapılır
      final bool isTargetCity = bigCities.any(
        (c) => c.toLowerCase() == city.trim().toLowerCase(),
      );

      // Kış ayı ve hedef şehirlerden biriyse %20 indirim uygulanır
      if (isWinterMonth && isTargetCity) {
        discountRate = 0.20;
        discountReason = 'Kış Sezonu İndirimi (%20)';
      }
    }

    // İndirim tutarı ve indirimli son fiyat hesaplaması
    final double discountAmount = basePrice * discountRate;
    final double finalPrice = basePrice - discountAmount;

    return PriceCalculationResult(
      basePrice: basePrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      discountReason: discountReason,
      days: days,
    );
  }
}
