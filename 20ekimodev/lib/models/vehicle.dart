class Vehicle {
  final String id;
  final String ownerId;
  final String ownerFirstName;
  final String ownerLastName;
  final String type; // e.g. Sedan, SUV, Hatchback, Spor, Elektrikli, Ticari
  final String brand;
  final String model;
  final String color;
  final String location;
  final double hourlyPrice;
  final int kilometers;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.ownerFirstName,
    required this.ownerLastName,
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.location,
    required this.hourlyPrice,
    required this.kilometers,
  });

  String get title => '$brand $model';
  String get ownerFullName => '$ownerFirstName $ownerLastName';

  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? ownerFirstName,
    String? ownerLastName,
    String? type,
    String? brand,
    String? model,
    String? color,
    String? location,
    double? hourlyPrice,
    int? kilometers,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerFirstName: ownerFirstName ?? this.ownerFirstName,
      ownerLastName: ownerLastName ?? this.ownerLastName,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      location: location ?? this.location,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      kilometers: kilometers ?? this.kilometers,
    );
  }
}
