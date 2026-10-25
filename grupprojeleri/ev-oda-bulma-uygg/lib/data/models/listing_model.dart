import '../../domain/entities/listing_entity.dart';

/// ListingEntity sınıfının serileştirme ve kalıcı veri depolama için kullanılan Data Model karşılığı.
/// İlan sahibini ve aranan ev arkadaşı kriterlerini JSON haritaları halinde kodlar/çözer.
class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.monthlyRent,
    required super.city,
    required super.district,
    required super.owner,
    required super.preferences,
    super.isWinterDiscountEligible,
    required super.createdAt,
    super.isUserCreated,
    super.isActive,
  });

  /// Ham JSON verisini ListingModel nesnesine çevirir.
  /// İç içe geçmiş 'owner' ve 'preferences' haritalarını ayrıştırarak ilgili sınıflara eşler.
  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final ownerMap = json['owner'] as Map<String, dynamic>? ?? {};
    final prefsMap = json['preferences'] as Map<String, dynamic>? ?? {};

    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      owner: OwnerInfo(
        id: ownerMap['id'] as String? ?? '',
        name: ownerMap['name'] as String? ?? 'Ev Sahibi',
        email: ownerMap['email'] as String? ?? '',
        avatarUrl: ownerMap['avatarUrl'] as String? ??
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        gender: ownerMap['gender'] as String? ?? 'Kadın',
        occupation: ownerMap['occupation'] as String? ?? 'Öğrenci',
        isStudent: ownerMap['isStudent'] as bool? ?? false,
      ),
      preferences: ListingPreferences(
        smokingAllowed: prefsMap['smokingAllowed'] as bool? ?? false,
        petAllowed: prefsMap['petAllowed'] as bool? ?? false,
        sleepSchedule: prefsMap['sleepSchedule'] as String? ?? 'farketmez',
        cleaningSensitivity: prefsMap['cleaningSensitivity'] as String? ?? 'orta',
        languages: (prefsMap['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['Türkçe'],
        preferredGender: prefsMap['preferredGender'] as String? ?? 'Farketmez',
        preferredOccupation:
            prefsMap['preferredOccupation'] as String? ?? 'Farketmez',
      ),
      isWinterDiscountEligible:
          json['isWinterDiscountEligible'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isUserCreated: json['isUserCreated'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// İlan nesnesini Hive/JSON depolaması için harita yapısına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'monthlyRent': monthlyRent,
      'city': city,
      'district': district,
      'owner': {
        'id': owner.id,
        'name': owner.name,
        'email': owner.email,
        'avatarUrl': owner.avatarUrl,
        'gender': owner.gender,
        'occupation': owner.occupation,
        'isStudent': owner.isStudent,
      },
      'preferences': {
        'smokingAllowed': preferences.smokingAllowed,
        'petAllowed': preferences.petAllowed,
        'sleepSchedule': preferences.sleepSchedule,
        'cleaningSensitivity': preferences.cleaningSensitivity,
        'languages': preferences.languages,
        'preferredGender': preferences.preferredGender,
        'preferredOccupation': preferences.preferredOccupation,
      },
      'isWinterDiscountEligible': isWinterDiscountEligible,
      'createdAt': createdAt.toIso8601String(),
      'isUserCreated': isUserCreated,
      'isActive': isActive,
    };
  }

  /// Domain ListingEntity nesnesinden ListingModel örneği üretir.
  factory ListingModel.fromEntity(ListingEntity entity) {
    return ListingModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      monthlyRent: entity.monthlyRent,
      city: entity.city,
      district: entity.district,
      owner: entity.owner,
      preferences: entity.preferences,
      isWinterDiscountEligible: entity.isWinterDiscountEligible,
      createdAt: entity.createdAt,
      isUserCreated: entity.isUserCreated,
      isActive: entity.isActive,
    );
  }
}
