class Booking {
  final String id;
  final String vehicleId;
  final String vehicleTitleSnapshot;
  final String ownerId;
  final String renterId;
  final String renterFirstName;
  final String renterLastName;
  final DateTime startAt;
  final DateTime endAt;
  final int durationHours;
  final double hourlyPriceSnapshot;
  final double totalPrice;
  final bool isCancelled;

  const Booking({
    required this.id,
    required this.vehicleId,
    required this.vehicleTitleSnapshot,
    required this.ownerId,
    required this.renterId,
    required this.renterFirstName,
    required this.renterLastName,
    required this.startAt,
    required this.endAt,
    required this.durationHours,
    required this.hourlyPriceSnapshot,
    required this.totalPrice,
    this.isCancelled = false,
  });

  String get renterFullName => '$renterFirstName $renterLastName';

  Booking copyWith({
    String? id,
    String? vehicleId,
    String? vehicleTitleSnapshot,
    String? ownerId,
    String? renterId,
    String? renterFirstName,
    String? renterLastName,
    DateTime? startAt,
    DateTime? endAt,
    int? durationHours,
    double? hourlyPriceSnapshot,
    double? totalPrice,
    bool? isCancelled,
  }) {
    return Booking(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleTitleSnapshot: vehicleTitleSnapshot ?? this.vehicleTitleSnapshot,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      renterFirstName: renterFirstName ?? this.renterFirstName,
      renterLastName: renterLastName ?? this.renterLastName,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      durationHours: durationHours ?? this.durationHours,
      hourlyPriceSnapshot: hourlyPriceSnapshot ?? this.hourlyPriceSnapshot,
      totalPrice: totalPrice ?? this.totalPrice,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
