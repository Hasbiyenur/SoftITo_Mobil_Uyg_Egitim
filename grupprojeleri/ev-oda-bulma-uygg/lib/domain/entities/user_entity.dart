/// Uygulama genelinde kullanıcı profilini ve yaşam tarzı tercihlerini temsil eden Domain Entity sınıfı.
/// Clean Architecture prensiplerine uygun olarak harici paketlerden bağımsızdır.
class UserEntity {
  /// Kullanıcının benzersiz kimlik numarası (UUID / String)
  final String id;

  /// Kullanıcının adı ve soyadı
  final String name;

  /// Kullanıcının e-posta adresi (Giriş için kullanılır)
  final String email;

  /// Kullanıcının telefon numarası
  final String phone;

  /// Kullanıcının şifresi (Simülasyon/yerel depolama için saklanır)
  final String password;

  /// Profil fotoğrafı bağlantısı (URL veya yerel asset yolu)
  final String? avatarUrl;

  /// Kullanıcının yaşı
  final int age;

  /// Kullanıcının cinsiyeti (Örn: 'Kadın', 'Erkek')
  final String gender;

  /// Kullanıcının mesleği veya okuduğu bölüm/üniversite
  final String occupation;

  /// Kullanıcının öğrenci olup olmadığı (İndirim ve ev arkadaşı kriterleri için kritik)
  final bool isStudent;

  // ================= YAŞAM ALIŞKANLIKLARI (HABITS) =================
  /// Sigara kullanımı (true: içiyor, false: içmiyor)
  final bool smoking;

  /// Evcil hayvan sahipliği (true: evcil hayvanı var, false: yok)
  final bool hasPet;

  /// Uyku düzeni (Örn: 'gece', 'sabah', 'farketmez')
  final String sleepSchedule;

  /// Temizlik hassasiyeti seviyesi (Örn: 'yok', 'az', 'orta', 'çok')
  final String cleaningSensitivity;

  /// Konuşabildiği dillerin listesi (Örn: ['Türkçe', 'İngilizce'])
  final List<String> languages;

  // ================= KONUM BİLGİLERİ (LOCATION) =================
  /// Yaşadığı veya arama yaptığı şehir (Örn: 'İstanbul')
  final String city;

  /// Yaşadığı veya arama yaptığı ilçe (Örn: 'Kadıköy')
  final String district;

  // ================= EK TERCİHLER VE PROFİL DETAYLARI =================
  /// Tercih edilen konut tipi (Örn: '2+1 Daire', 'Müstakil Ev', 'Stüdyo')
  final String preferredHouseType;

  /// Kullanıcının kayıtlı teslimat / fatura adresleri listesi
  final List<String> savedAddresses;

  /// Kayıtlı ödeme kartı bilgileri (Örn: kart numarası maskeli, son kullanma vb.)
  final Map<String, String>? savedPaymentCard;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.avatarUrl,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.isStudent,
    required this.smoking,
    required this.hasPet,
    required this.sleepSchedule,
    required this.cleaningSensitivity,
    required this.languages,
    required this.city,
    required this.district,
    this.preferredHouseType = '2+1 Daire',
    this.savedAddresses = const [],
    this.savedPaymentCard,
  });

  /// Kullanıcı nesnesinin belirli alanlarını güncelleyerek yeni bir kopya oluşturur (Immutability deseni).
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? avatarUrl,
    int? age,
    String? gender,
    String? occupation,
    bool? isStudent,
    bool? smoking,
    bool? hasPet,
    String? sleepSchedule,
    String? cleaningSensitivity,
    List<String>? languages,
    String? city,
    String? district,
    String? preferredHouseType,
    List<String>? savedAddresses,
    Map<String, String>? savedPaymentCard,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      isStudent: isStudent ?? this.isStudent,
      smoking: smoking ?? this.smoking,
      hasPet: hasPet ?? this.hasPet,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      cleaningSensitivity: cleaningSensitivity ?? this.cleaningSensitivity,
      languages: languages ?? this.languages,
      city: city ?? this.city,
      district: district ?? this.district,
      preferredHouseType: preferredHouseType ?? this.preferredHouseType,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedPaymentCard: savedPaymentCard ?? this.savedPaymentCard,
    );
  }
}
