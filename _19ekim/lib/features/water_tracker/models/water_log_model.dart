class WaterLogModel {
  const WaterLogModel({
    required this.id,
    required this.amountInMl,
    required this.timestamp,
    this.containerName = 'Bardak',
  });

  final String id;
  final int amountInMl;
  final DateTime timestamp;
  final String containerName;
}
