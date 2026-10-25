import '../../domain/entities/user_entity.dart';

/// UserEntity sınıfının JSON serileştirme ve yerel veritabanı (Hive) uyumlu Data Model karşılığı.
/// JSON verilerini nesneye çevirme (deserialization) ve nesneyi JSON haritasına dönüştürme (serialization) işlevlerini üstlenir.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.password,
    super.avatarUrl,
    required super.age,
    required super.gender,
    required super.occupation,
    required super.isStudent,
    required super.smoking,
    required super.hasPet,
    required super.sleepSchedule,
    required super.cleaningSensitivity,
    required super.languages,
    required super.city,
    required super.district,
    super.preferredHouseType,
    super.savedAddresses,
    super.savedPaymentCard,
  });

  /// JSON (`Map<String, dynamic>`) formatındaki veriyi UserModel nesnesine dönüştüren fabrika kurucu metot.
  /// Eksik veya null alanlar için güvenli varsayılan değerler atar.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      age: (json['age'] as num?)?.toInt() ?? 20,
      gender: json['gender'] as String? ?? 'Kadın',
      occupation: json['occupation'] as String? ?? '',
      isStudent: json['isStudent'] as bool? ?? false,
      smoking: json['smoking'] as bool? ?? false,
      hasPet: json['hasPet'] as bool? ?? false,
      sleepSchedule: json['sleepSchedule'] as String? ?? 'gece',
      cleaningSensitivity: json['cleaningSensitivity'] as String? ?? 'orta',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Türkçe'],
      city: json['city'] as String? ?? 'İstanbul',
      district: json['district'] as String? ?? 'Kadıköy',
      preferredHouseType: json['preferredHouseType'] as String? ?? '2+1 Daire',
      savedAddresses: (json['savedAddresses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      savedPaymentCard: json['savedPaymentCard'] != null
          ? Map<String, String>.from(json['savedPaymentCard'] as Map)
          : null,
    );
  }

  /// UserModel nesnesini veritabanında saklanabilir bir JSON / Map nesnesine dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'avatarUrl': avatarUrl,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'isStudent': isStudent,
      'smoking': smoking,
      'hasPet': hasPet,
      'sleepSchedule': sleepSchedule,
      'cleaningSensitivity': cleaningSensitivity,
      'languages': languages,
      'city': city,
      'district': district,
      'preferredHouseType': preferredHouseType,
      'savedAddresses': savedAddresses,
      'savedPaymentCard': savedPaymentCard,
    };
  }

  /// Domain katmanındaki UserEntity nesnesinden UserModel türetir.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      password: entity.password,
      avatarUrl: entity.avatarUrl,
      age: entity.age,
      gender: entity.gender,
      occupation: entity.occupation,
      isStudent: entity.isStudent,
      smoking: entity.smoking,
      hasPet: entity.hasPet,
      sleepSchedule: entity.sleepSchedule,
      cleaningSensitivity: entity.cleaningSensitivity,
      languages: entity.languages,
      city: entity.city,
      district: entity.district,
      preferredHouseType: entity.preferredHouseType,
      savedAddresses: entity.savedAddresses,
      savedPaymentCard: entity.savedPaymentCard,
    );
  }
}
