/// İlan sahibinin temel profil bilgilerini temsil eden yardımcı varlık sınıfı.
class OwnerInfo {
  /// Ev sahibinin kullanıcı kimliği
  final String id;

  /// Ev sahibinin adı soyadı
  final String name;

  /// Ev sahibinin e-posta adresi
  final String email;

  /// Ev sahibinin profil fotoğrafı URL'si
  final String avatarUrl;

  /// Ev sahibinin cinsiyeti
  final String gender;

  /// Ev sahibinin mesleği
  final String occupation;

  /// Ev sahibinin öğrenci olup olmadığı
  final bool isStudent;

  const OwnerInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.gender,
    required this.occupation,
    required this.isStudent,
  });
}

/// İlan için aranan ev arkadaşı kriterleri ve ev kurallarını temsil eden varlık sınıfı.
class ListingPreferences {
  /// İlanda sigara kullanımına izin verilip verilmediği
  final bool smokingAllowed;

  /// Evcil hayvana izin verilip verilmediği
  final bool petAllowed;

  /// Tercih edilen uyku düzeni (gece, sabah, farketmez)
  final String sleepSchedule;

  /// Beklenen temizlik hassasiyeti seviyesi (yok, az, orta, çok)
  final String cleaningSensitivity;

  /// Evde konuşulan / tercih edilen diller
  final List<String> languages;

  /// Tercih edilen ev arkadaşı cinsiyeti (Kadın, Erkek, Farketmez)
  final String preferredGender;

  /// Tercih edilen meslek grubu (Öğrenci, Çalışan, Farketmez)
  final String preferredOccupation;

  const ListingPreferences({
    required this.smokingAllowed,
    required this.petAllowed,
    required this.sleepSchedule,
    required this.cleaningSensitivity,
    required this.languages,
    required this.preferredGender,
    required this.preferredOccupation,
  });
}

/// Ev / Oda ilanını temsil eden ana Domain Entity sınıfı.
/// İlanın konumu, kira bedeli, kış indirimi uygunluğu ve ev kurallarını barındırır.
class ListingEntity {
  /// İlanın benzersiz kimlik numarası
  final String id;

  /// İlan başlığı
  final String title;

  /// İlanın detaylı açıklaması
  final String description;

  /// İlan görseli URL'si
  final String imageUrl;

  /// Aylık kiralama bedeli (TL)
  final double monthlyRent;

  /// İlanın bulunduğu şehir
  final String city;

  /// İlanın bulunduğu ilçe
  final String district;

  /// İlan sahibinin bilgileri
  final OwnerInfo owner;

  /// Ev arkadaşı kriterleri ve kuralları
  final ListingPreferences preferences;

  /// Kış sezonu indirimine uygun olup olmadığı
  final bool isWinterDiscountEligible;

  /// İlanın sisteme eklenme tarihi
  final DateTime createdAt;

  /// Giriş yapan kullanıcı tarafından oluşturulup oluşturulmadığı
  final bool isUserCreated;

  /// İlanın yayında (aktif) olup olmadığı
  final bool isActive;

  const ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.monthlyRent,
    required this.city,
    required this.district,
    required this.owner,
    required this.preferences,
    this.isWinterDiscountEligible = false,
    required this.createdAt,
    this.isUserCreated = false,
    this.isActive = true,
  });

  /// İlan nesnesinin belirli alanlarını güncelleyerek yeni bir kopya oluşturur.
  ListingEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? monthlyRent,
    String? city,
    String? district,
    OwnerInfo? owner,
    ListingPreferences? preferences,
    bool? isWinterDiscountEligible,
    DateTime? createdAt,
    bool? isUserCreated,
    bool? isActive,
  }) {
    return ListingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      city: city ?? this.city,
      district: district ?? this.district,
      owner: owner ?? this.owner,
      preferences: preferences ?? this.preferences,
      isWinterDiscountEligible:
          isWinterDiscountEligible ?? this.isWinterDiscountEligible,
      createdAt: createdAt ?? this.createdAt,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      isActive: isActive ?? this.isActive,
    );
  }
}
