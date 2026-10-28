import '../../domain/entities/rental_entity.dart';

/// RentalEntity sınıfının JSON serileştirme ve kalıcı yerel depolama için kullanılan Data Model karşılığı.
/// Tarih alanlarını ISO 8601 formatında saklar ve okur.
class RentalModel extends RentalEntity {
  const RentalModel({
    required super.id,
    required super.listingId,
    required super.listingTitle,
    required super.listingImageUrl,
    required super.city,
    required super.district,
    required super.monthlyRent,
    required super.hostId,
    required super.hostName,
    required super.hostAvatarUrl,
    required super.tenantId,
    required super.tenantName,
    required super.tenantGender,
    required super.tenantAvatarUrl,
    required super.tenantOccupation,
    required super.checkInDate,
    required super.checkOutDate,
    required super.daysStayed,
    required super.guestCount,
    required super.baseAmount,
    required super.discountAmount,
    required super.totalAmount,
    super.discountReason,
    super.isCompleted,
    required super.createdAt,
  });

  /// JSON formatındaki rezervasyon kaydını çözümler ve RentalModel örneğine dönüştürür.
  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      listingTitle: json['listingTitle'] as String,
      listingImageUrl: json['listingImageUrl'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      hostAvatarUrl: json['hostAvatarUrl'] as String? ?? '',
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String,
      tenantGender: json['tenantGender'] as String? ?? 'Kadın',
      tenantAvatarUrl: json['tenantAvatarUrl'] as String? ?? '',
      tenantOccupation: json['tenantOccupation'] as String? ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      daysStayed: (json['daysStayed'] as num).toInt(),
      guestCount: (json['guestCount'] as num).toInt(),
      baseAmount: (json['baseAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountReason: json['discountReason'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// RentalModel nesnesini Hive veritabanında saklamak için JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
      'city': city,
      'district': district,
      'monthlyRent': monthlyRent,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatarUrl': hostAvatarUrl,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantGender': tenantGender,
      'tenantAvatarUrl': tenantAvatarUrl,
      'tenantOccupation': tenantOccupation,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'daysStayed': daysStayed,
      'guestCount': guestCount,
      'baseAmount': baseAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'discountReason': discountReason,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Domain RentalEntity nesnesinden RentalModel oluşturur.
  factory RentalModel.fromEntity(RentalEntity entity) {
    return RentalModel(
      id: entity.id,
      listingId: entity.listingId,
      listingTitle: entity.listingTitle,
      listingImageUrl: entity.listingImageUrl,
      city: entity.city,
      district: entity.district,
      monthlyRent: entity.monthlyRent,
      hostId: entity.hostId,
      hostName: entity.hostName,
      hostAvatarUrl: entity.hostAvatarUrl,
      tenantId: entity.tenantId,
      tenantName: entity.tenantName,
      tenantGender: entity.tenantGender,
      tenantAvatarUrl: entity.tenantAvatarUrl,
      tenantOccupation: entity.tenantOccupation,
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      daysStayed: entity.daysStayed,
      guestCount: entity.guestCount,
      baseAmount: entity.baseAmount,
      discountAmount: entity.discountAmount,
      totalAmount: entity.totalAmount,
      discountReason: entity.discountReason,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }
}
