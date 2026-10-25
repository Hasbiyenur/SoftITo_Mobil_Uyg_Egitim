import 'package:equatable/equatable.dart';

import '../../core/utils/app_constants.dart';

class ListingOwnerModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? avatar;
  final int age;
  final String gender;
  final String occupation;
  final String phone;
  final double rating;

  const ListingOwnerModel({
    required this.id,
    required this.fullName,
    this.email,
    this.avatar,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.phone,
    this.rating = 4.8,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'phone': phone,
      'rating': rating,
    };
  }

  factory ListingOwnerModel.fromMap(Map<dynamic, dynamic> map) {
    return ListingOwnerModel(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String?,
      avatar: map['avatar'] as String?,
      age: (map['age'] as num?)?.toInt() ?? 24,
      gender: map['gender'] as String? ?? 'Kadın',
      occupation: map['occupation'] as String? ?? 'Öğrenci / Çalışan',
      phone: map['phone'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    avatar,
    age,
    gender,
    occupation,
    phone,
    rating,
  ];
}

class ListingPreferencesModel extends Equatable {
  final bool petFriendly;
  final bool smokingAllowed;
  final String sleepHabit;
  final String cleanliness;
  final List<String> languages;
  final String preferredGender;
  final bool isStudentFriendly;
  final String homeType;

  const ListingPreferencesModel({
    this.petFriendly = true,
    this.smokingAllowed = false,
    this.sleepHabit = 'Fark etmez',
    this.cleanliness = 'Orta',
    this.languages = const ['Türkçe'],
    this.preferredGender = 'Fark etmez',
    this.isStudentFriendly = true,
    this.homeType = 'Ayrı Oda (3+1 Daire)',
  });

  Map<String, dynamic> toMap() {
    return {
      'petFriendly': petFriendly,
      'smokingAllowed': smokingAllowed,
      'sleepHabit': sleepHabit,
      'cleanliness': cleanliness,
      'languages': languages,
      'preferredGender': preferredGender,
      'isStudentFriendly': isStudentFriendly,
      'homeType': homeType,
    };
  }

  factory ListingPreferencesModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const ListingPreferencesModel();
    return ListingPreferencesModel(
      petFriendly: map['petFriendly'] as bool? ?? true,
      smokingAllowed: map['smokingAllowed'] as bool? ?? false,
      sleepHabit: map['sleepHabit'] as String? ?? 'Fark etmez',
      cleanliness: map['cleanliness'] as String? ?? 'Orta',
      languages:
          (map['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Türkçe'],
      preferredGender: map['preferredGender'] as String? ?? 'Fark etmez',
      isStudentFriendly: map['isStudentFriendly'] as bool? ?? true,
      homeType: map['homeType'] as String? ?? 'Ayrı Oda (3+1 Daire)',
    );
  }

  @override
  List<Object?> get props => [
    petFriendly,
    smokingAllowed,
    sleepHabit,
    cleanliness,
    languages,
    preferredGender,
    isStudentFriendly,
    homeType,
  ];
}

class PriceCalculationResult {
  final int days;
  final double dailyRate;
  final double grossAmount;
  final double studentDiscountAmount;
  final double winterDiscountAmount;
  final double totalAmount;

  const PriceCalculationResult({
    required this.days,
    required this.dailyRate,
    required this.grossAmount,
    required this.studentDiscountAmount,
    required this.winterDiscountAmount,
    required this.totalAmount,
  });
}

class ListingModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double monthlyPrice;
  final String city;
  final String district;
  final String neighborhood;
  final List<String> images;
  final ListingOwnerModel owner;
  final ListingPreferencesModel preferences;
  final bool isWinterDiscountEligible;
  final DateTime createdAt;
  final bool isFavorite;
  final bool isMyListing;
  final String status; // 'active', 'rented', 'inactive'

  const ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.monthlyPrice,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.images,
    required this.owner,
    this.preferences = const ListingPreferencesModel(),
    this.isWinterDiscountEligible = false,
    required this.createdAt,
    this.isFavorite = false,
    this.isMyListing = false,
    this.status = 'active',
  });

  bool get isRented => status == 'rented';
  bool get isActive => status == 'active';

  double get dailyPrice => monthlyPrice / 30.0;

  bool get isWinterCityEligible =>
      isWinterDiscountEligible &&
      AppConstants.winterDiscountCities.contains(city);

  PriceCalculationResult calculatePrice({
    required int days,
    required bool isStudent,
  }) {
    final validDays = days < 1 ? 1 : days;
    final daily = dailyPrice;
    final gross = daily * validDays;

    final studentDiscount = isStudent ? (gross * 0.20) : 0.0;
    final winterDiscount = isWinterCityEligible ? (gross * 0.20) : 0.0;
    final total = gross - studentDiscount - winterDiscount;

    return PriceCalculationResult(
      days: validDays,
      dailyRate: daily,
      grossAmount: gross,
      studentDiscountAmount: studentDiscount,
      winterDiscountAmount: winterDiscount,
      totalAmount: total > 0 ? total : 0,
    );
  }

  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? monthlyPrice,
    String? city,
    String? district,
    String? neighborhood,
    List<String>? images,
    ListingOwnerModel? owner,
    ListingPreferencesModel? preferences,
    bool? isWinterDiscountEligible,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isMyListing,
    String? status,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      city: city ?? this.city,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      images: images ?? this.images,
      owner: owner ?? this.owner,
      preferences: preferences ?? this.preferences,
      isWinterDiscountEligible:
          isWinterDiscountEligible ?? this.isWinterDiscountEligible,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isMyListing: isMyListing ?? this.isMyListing,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'city': city,
      'district': district,
      'neighborhood': neighborhood,
      'images': images,
      'owner': owner.toMap(),
      'preferences': preferences.toMap(),
      'isWinterDiscountEligible': isWinterDiscountEligible,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isMyListing': isMyListing,
      'status': status,
    };
  }

  factory ListingModel.fromMap(Map<dynamic, dynamic> map) {
    return ListingModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      city: map['city'] as String? ?? 'İstanbul',
      district: map['district'] as String? ?? 'Kadıköy',
      neighborhood: map['neighborhood'] as String? ?? '',
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      owner: ListingOwnerModel.fromMap(
        map['owner'] as Map<dynamic, dynamic>? ?? {},
      ),
      preferences: ListingPreferencesModel.fromMap(
        map['preferences'] as Map<dynamic, dynamic>?,
      ),
      isWinterDiscountEligible:
          map['isWinterDiscountEligible'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      isMyListing: map['isMyListing'] as bool? ?? false,
      status: map['status'] as String? ?? 'active',
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    monthlyPrice,
    city,
    district,
    neighborhood,
    images,
    owner,
    preferences,
    isWinterDiscountEligible,
    createdAt,
    isFavorite,
    isMyListing,
    status,
  ];
}
