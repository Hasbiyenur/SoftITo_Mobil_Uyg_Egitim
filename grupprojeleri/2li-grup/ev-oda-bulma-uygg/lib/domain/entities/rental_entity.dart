/// Gerçekleşen veya devam eden bir ev/oda kiralama ve konaklama kaydını temsil eden Domain Entity sınıfı.
/// Ev sahibi, kiracı, konaklama tarihleri ve maliyet dökümlerini içerir.
class RentalEntity {
  /// Kiralama işleminin benzersiz kimlik numarası
  final String id;

  /// Kiralanan ilanın kimlik numarası
  final String listingId;

  /// Kiralanan ilanın başlığı
  final String listingTitle;

  /// Kiralanan ilanın fotoğraf URL'si
  final String listingImageUrl;

  /// İlanın şehri
  final String city;

  /// İlanın ilçesi
  final String district;

  /// İlanın aylık taban kira bedeli
  final double monthlyRent;

  // ================= EV SAHİBİ BİLGİLERİ (HOST) =================
  /// Ev sahibinin kullanıcı kimliği
  final String hostId;

  /// Ev sahibinin adı ve soyadı
  final String hostName;

  /// Ev sahibinin profil görseli
  final String hostAvatarUrl;

  // ================= KİRACI / MİSAFİR BİLGİLERİ (TENANT) =================
  /// Kiracının kullanıcı kimliği
  final String tenantId;

  /// Kiracının adı ve soyadı
  final String tenantName;

  /// Kiracının cinsiyeti
  final String tenantGender;

  /// Kiracının profil fotoğrafı
  final String tenantAvatarUrl;

  /// Kiracının mesleği / okulu
  final String tenantOccupation;

  // ================= REZERVASYON VE ÜCRET DETAYLARI =================
  /// Giriş (Check-in) tarihi
  final DateTime checkInDate;

  /// Çıkış (Check-out) tarihi
  final DateTime checkOutDate;

  /// Toplam konaklanan / kiralanan gün sayısı
  final int daysStayed;

  /// Konaklayacak kişi / misafir sayısı
  final int guestCount;

  /// Günlük ücret üzerinden hesaplanan ham baz tutar (TL)
  final double baseAmount;

  /// Uygulanan indirim tutarı (Öğrenci veya kış indirimi) (TL)
  final double discountAmount;

  /// İndirim sonrası ödenen / ödenecek nihai toplam tutar (TL)
  final double totalAmount;

  /// İndirimin açıklama metni
  final String? discountReason;

  /// Konaklamanın tamamlanıp tamamlanmadığı (Check-out yapıldı mı?)
  final bool isCompleted;

  /// Rezervasyonun oluşturulma zamanı
  final DateTime createdAt;

  const RentalEntity({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingImageUrl,
    required this.city,
    required this.district,
    required this.monthlyRent,
    required this.hostId,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.tenantId,
    required this.tenantName,
    required this.tenantGender,
    required this.tenantAvatarUrl,
    required this.tenantOccupation,
    required this.checkInDate,
    required this.checkOutDate,
    required this.daysStayed,
    required this.guestCount,
    required this.baseAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.discountReason,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Çıkış tarihine kadar kalan gün sayısını dinamik olarak hesaplar.
  /// Çıkış tarihi geçmişse 0 döner.
  int get remainingDays {
    final now = DateTime.now();
    if (checkOutDate.isBefore(now)) return 0;
    return checkOutDate.difference(now).inDays + 1;
  }

  /// Kiralama nesnesinin belirli alanlarını güncelleyerek yeni bir kopya oluşturur.
  RentalEntity copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
    String? city,
    String? district,
    double? monthlyRent,
    String? hostId,
    String? hostName,
    String? hostAvatarUrl,
    String? tenantId,
    String? tenantName,
    String? tenantGender,
    String? tenantAvatarUrl,
    String? tenantOccupation,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? daysStayed,
    int? guestCount,
    double? baseAmount,
    double? discountAmount,
    double? totalAmount,
    String? discountReason,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return RentalEntity(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImageUrl: listingImageUrl ?? this.listingImageUrl,
      city: city ?? this.city,
      district: district ?? this.district,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantGender: tenantGender ?? this.tenantGender,
      tenantAvatarUrl: tenantAvatarUrl ?? this.tenantAvatarUrl,
      tenantOccupation: tenantOccupation ?? this.tenantOccupation,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      daysStayed: daysStayed ?? this.daysStayed,
      guestCount: guestCount ?? this.guestCount,
      baseAmount: baseAmount ?? this.baseAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      discountReason: discountReason ?? this.discountReason,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
