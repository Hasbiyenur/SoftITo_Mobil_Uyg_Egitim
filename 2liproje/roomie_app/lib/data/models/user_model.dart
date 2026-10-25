import 'package:equatable/equatable.dart';

class HabitsModel extends Equatable {
  final bool smoking;
  final bool hasPets;
  final String sleepHabit;
  final String cleanliness;
  final List<String> languages;

  const HabitsModel({
    this.smoking = false,
    this.hasPets = false,
    this.sleepHabit = 'Fark etmez',
    this.cleanliness = 'Orta',
    this.languages = const ['Türkçe'],
  });

  HabitsModel copyWith({
    bool? smoking,
    bool? hasPets,
    String? sleepHabit,
    String? cleanliness,
    List<String>? languages,
  }) {
    return HabitsModel(
      smoking: smoking ?? this.smoking,
      hasPets: hasPets ?? this.hasPets,
      sleepHabit: sleepHabit ?? this.sleepHabit,
      cleanliness: cleanliness ?? this.cleanliness,
      languages: languages ?? this.languages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'smoking': smoking,
      'hasPets': hasPets,
      'sleepHabit': sleepHabit,
      'cleanliness': cleanliness,
      'languages': languages,
    };
  }

  factory HabitsModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const HabitsModel();
    return HabitsModel(
      smoking: map['smoking'] as bool? ?? false,
      hasPets: map['hasPets'] as bool? ?? false,
      sleepHabit: map['sleepHabit'] as String? ?? 'Fark etmez',
      cleanliness: map['cleanliness'] as String? ?? 'Orta',
      languages:
          (map['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Türkçe'],
    );
  }

  @override
  List<Object?> get props => [
    smoking,
    hasPets,
    sleepHabit,
    cleanliness,
    languages,
  ];
}

class AddressModel extends Equatable {
  final String id;
  final String title;
  final String city;
  final String district;
  final String addressDetail;

  const AddressModel({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.addressDetail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'district': district,
      'addressDetail': addressDetail,
    };
  }

  factory AddressModel.fromMap(Map<dynamic, dynamic> map) {
    return AddressModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      addressDetail: map['addressDetail'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, city, district, addressDetail];
}

class SavedCardModel extends Equatable {
  final String id;
  final String cardHolder;
  final String maskedNumber;
  final String expiry;
  final String cardType;

  const SavedCardModel({
    required this.id,
    required this.cardHolder,
    required this.maskedNumber,
    required this.expiry,
    this.cardType = 'Mastercard',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardHolder': cardHolder,
      'maskedNumber': maskedNumber,
      'expiry': expiry,
      'cardType': cardType,
    };
  }

  factory SavedCardModel.fromMap(Map<dynamic, dynamic> map) {
    return SavedCardModel(
      id: map['id'] as String? ?? '',
      cardHolder: map['cardHolder'] as String? ?? '',
      maskedNumber: map['maskedNumber'] as String? ?? '•••• •••• •••• 4242',
      expiry: map['expiry'] as String? ?? '12/28',
      cardType: map['cardType'] as String? ?? 'Mastercard',
    );
  }

  @override
  List<Object?> get props => [id, cardHolder, maskedNumber, expiry, cardType];
}

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String? avatar;
  final int age;
  final String gender;
  final String occupation;
  final bool isStudent;
  final HabitsModel habits;
  final String city;
  final String district;
  final bool hasCriminalRecordDoc;
  final bool hasStudentDoc;
  final List<AddressModel> addresses;
  final List<SavedCardModel> savedCards;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    this.avatar,
    required this.age,
    required this.gender,
    required this.occupation,
    this.isStudent = false,
    this.habits = const HabitsModel(),
    required this.city,
    required this.district,
    this.hasCriminalRecordDoc = true,
    this.hasStudentDoc = false,
    this.addresses = const [],
    this.savedCards = const [],
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? phone,
    String? avatar,
    int? age,
    String? gender,
    String? occupation,
    bool? isStudent,
    HabitsModel? habits,
    String? city,
    String? district,
    bool? hasCriminalRecordDoc,
    bool? hasStudentDoc,
    List<AddressModel>? addresses,
    List<SavedCardModel>? savedCards,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      isStudent: isStudent ?? this.isStudent,
      habits: habits ?? this.habits,
      city: city ?? this.city,
      district: district ?? this.district,
      hasCriminalRecordDoc: hasCriminalRecordDoc ?? this.hasCriminalRecordDoc,
      hasStudentDoc: hasStudentDoc ?? this.hasStudentDoc,
      addresses: addresses ?? this.addresses,
      savedCards: savedCards ?? this.savedCards,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'avatar': avatar,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'isStudent': isStudent,
      'habits': habits.toMap(),
      'city': city,
      'district': district,
      'hasCriminalRecordDoc': hasCriminalRecordDoc,
      'hasStudentDoc': hasStudentDoc,
      'addresses': addresses.map((e) => e.toMap()).toList(),
      'savedCards': savedCards.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatar: map['avatar'] as String?,
      age: (map['age'] as num?)?.toInt() ?? 22,
      gender: map['gender'] as String? ?? 'Kadın',
      occupation: map['occupation'] as String? ?? '',
      isStudent: map['isStudent'] as bool? ?? false,
      habits: HabitsModel.fromMap(map['habits'] as Map<dynamic, dynamic>?),
      city: map['city'] as String? ?? 'İstanbul',
      district: map['district'] as String? ?? 'Kadıköy',
      hasCriminalRecordDoc: map['hasCriminalRecordDoc'] as bool? ?? true,
      hasStudentDoc: map['hasStudentDoc'] as bool? ?? false,
      addresses:
          (map['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      savedCards:
          (map['savedCards'] as List<dynamic>?)
              ?.map((e) => SavedCardModel.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    avatar,
    age,
    gender,
    occupation,
    isStudent,
    habits,
    city,
    district,
    hasCriminalRecordDoc,
    hasStudentDoc,
    addresses,
    savedCards,
    createdAt,
  ];
}
