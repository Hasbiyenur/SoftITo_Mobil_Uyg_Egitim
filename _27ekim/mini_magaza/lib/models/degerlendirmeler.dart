class Degerlendirme {
  final double puan;
  final int onSayisi;

  const Degerlendirme({required this.puan, required this.onSayisi});

  factory Degerlendirme.fromJson(Map<String, dynamic> json) {
    return Degerlendirme(
      puan: (json['rate'] as num?)?.toDouble() ?? 0.0,
      onSayisi: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}


