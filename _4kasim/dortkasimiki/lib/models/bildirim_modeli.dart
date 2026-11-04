class BildirimModeli {
  // Bir bildirimin hangi bilgileri taşıyacağını tanımlayan sınıf.
  final String id;
  final String baslik;
  final String icerik;
  final DateTime tarih;
  final bool okunduMu;

  const BildirimModeli({
    // Bildirimmodeli nesnesi oluşturulurken çalışır.
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.tarih,
    this.okunduMu = false,
  });

  BildirimModeli copyWith({
    // asıl nesneyi değiştirmeden mevcut bildirimi temel alarak yeni bir bildirim nesnesi oluşturur.
    String? id,
    String? baslik,
    String? icerik,
    DateTime? tarih,
    bool? okunduMu,
  }) {
    return BildirimModeli(
      // Yeni bir BildirimModeli nesnesi oluşturup döndürür.
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      icerik: icerik ?? this.icerik,
      tarih: tarih ?? this.tarih,
      okunduMu: okunduMu ?? this.okunduMu,
    );
  }
}
