import 'package:equatable/equatable.dart';

class RentalModel extends Equatable {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingImage;
  final String city;
  final String district;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final String tenantId;
  final String tenantName;
  final String tenantGender;
  final String? tenantAvatar;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final int originalDays;
  final double monthlyPrice;
  final double grossAmount;
  final double studentDiscountAmount;
  final double winterDiscountAmount;
  final double totalPaid;
  final bool isStudentDiscountApplied;
  final bool isWinterDiscountApplied;
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime? checkoutDate;
  final int? actualDaysStayed;
  final double? actualChargedAmount;
  final double? refundAmount;
  final String? checkoutPhotoPath;
  final DateTime createdAt;

  const RentalModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingImage,
    required this.city,
    required this.district,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.tenantId,
    required this.tenantName,
    required this.tenantGender,
    this.tenantAvatar,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.originalDays,
    required this.monthlyPrice,
    required this.grossAmount,
    required this.studentDiscountAmount,
    required this.winterDiscountAmount,
    required this.totalPaid,
    this.isStudentDiscountApplied = false,
    this.isWinterDiscountApplied = false,
    this.status = 'active',
    this.checkoutDate,
    this.actualDaysStayed,
    this.actualChargedAmount,
    this.refundAmount,
    this.checkoutPhotoPath,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  int get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  RentalModel copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? listingImage,
    String? city,
    String? district,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? tenantId,
    String? tenantName,
    String? tenantGender,
    String? tenantAvatar,
    DateTime? startDate,
    DateTime? endDate,
    int? guestCount,
    int? originalDays,
    double? monthlyPrice,
    double? grossAmount,
    double? studentDiscountAmount,
    double? winterDiscountAmount,
    double? totalPaid,
    bool? isStudentDiscountApplied,
    bool? isWinterDiscountApplied,
    String? status,
    DateTime? checkoutDate,
    int? actualDaysStayed,
    double? actualChargedAmount,
    double? refundAmount,
    String? checkoutPhotoPath,
    DateTime? createdAt,
  }) {
    return RentalModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImage: listingImage ?? this.listingImage,
      city: city ?? this.city,
      district: district ?? this.district,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantGender: tenantGender ?? this.tenantGender,
      tenantAvatar: tenantAvatar ?? this.tenantAvatar,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      guestCount: guestCount ?? this.guestCount,
      originalDays: originalDays ?? this.originalDays,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      grossAmount: grossAmount ?? this.grossAmount,
      studentDiscountAmount:
          studentDiscountAmount ?? this.studentDiscountAmount,
      winterDiscountAmount: winterDiscountAmount ?? this.winterDiscountAmount,
      totalPaid: totalPaid ?? this.totalPaid,
      isStudentDiscountApplied:
          isStudentDiscountApplied ?? this.isStudentDiscountApplied,
      isWinterDiscountApplied:
          isWinterDiscountApplied ?? this.isWinterDiscountApplied,
      status: status ?? this.status,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      actualDaysStayed: actualDaysStayed ?? this.actualDaysStayed,
      actualChargedAmount: actualChargedAmount ?? this.actualChargedAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      checkoutPhotoPath: checkoutPhotoPath ?? this.checkoutPhotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImage': listingImage,
      'city': city,
      'district': district,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantGender': tenantGender,
      'tenantAvatar': tenantAvatar,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'guestCount': guestCount,
      'originalDays': originalDays,
      'monthlyPrice': monthlyPrice,
      'grossAmount': grossAmount,
      'studentDiscountAmount': studentDiscountAmount,
      'winterDiscountAmount': winterDiscountAmount,
      'totalPaid': totalPaid,
      'isStudentDiscountApplied': isStudentDiscountApplied,
      'isWinterDiscountApplied': isWinterDiscountApplied,
      'status': status,
      'checkoutDate': checkoutDate?.toIso8601String(),
      'actualDaysStayed': actualDaysStayed,
      'actualChargedAmount': actualChargedAmount,
      'refundAmount': refundAmount,
      'checkoutPhotoPath': checkoutPhotoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RentalModel.fromMap(Map<dynamic, dynamic> map) {
    return RentalModel(
      id: map['id'] as String? ?? '',
      listingId: map['listingId'] as String? ?? '',
      listingTitle: map['listingTitle'] as String? ?? '',
      listingImage: map['listingImage'] as String? ?? '',
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhone: map['ownerPhone'] as String? ?? '',
      tenantId: map['tenantId'] as String? ?? '',
      tenantName: map['tenantName'] as String? ?? '',
      tenantGender: map['tenantGender'] as String? ?? '',
      tenantAvatar: map['tenantAvatar'] as String?,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString()) ??
                DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      guestCount: (map['guestCount'] as num?)?.toInt() ?? 1,
      originalDays: (map['originalDays'] as num?)?.toInt() ?? 30,
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (map['grossAmount'] as num?)?.toDouble() ?? 0.0,
      studentDiscountAmount:
          (map['studentDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      winterDiscountAmount:
          (map['winterDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (map['totalPaid'] as num?)?.toDouble() ?? 0.0,
      isStudentDiscountApplied:
          map['isStudentDiscountApplied'] as bool? ?? false,
      isWinterDiscountApplied: map['isWinterDiscountApplied'] as bool? ?? false,
      status: map['status'] as String? ?? 'active',
      checkoutDate: map['checkoutDate'] != null
          ? DateTime.tryParse(map['checkoutDate'].toString())
          : null,
      actualDaysStayed: (map['actualDaysStayed'] as num?)?.toInt(),
      actualChargedAmount: (map['actualChargedAmount'] as num?)?.toDouble(),
      refundAmount: (map['refundAmount'] as num?)?.toDouble(),
      checkoutPhotoPath: map['checkoutPhotoPath'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    listingId,
    listingTitle,
    listingImage,
    city,
    district,
    ownerId,
    ownerName,
    tenantId,
    tenantName,
    startDate,
    endDate,
    guestCount,
    originalDays,
    monthlyPrice,
    grossAmount,
    studentDiscountAmount,
    winterDiscountAmount,
    totalPaid,
    status,
    checkoutDate,
    actualDaysStayed,
    actualChargedAmount,
    refundAmount,
    checkoutPhotoPath,
    createdAt,
  ];
}
