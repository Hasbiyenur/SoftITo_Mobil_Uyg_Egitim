enum CihazTipi{
  sensor,
  gateway,
  edgeServer,
  router
}

typedef CihazBilgi = ({
  String cihazAdi,
  CihazTipi tip,
  bool alarmDurumu,
});

class IoTCihaz{
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set acikPortlar;
  final bool sslSertifikasiGecerMi;

    const IoTCihaz({
      required this.seriNo,
      required this.cihazAdi,
      required this.tip,
      required this.cpuYukYuzdesi,
      required this.bellekMb,
      required this.acikPortlar,
      required this.sslSertifikasiGecerMi,
    });

  bool get guvenlikAcigiVarMi => !sslSertifikasiGecerMi || acikPortlar.contains("23/TELNET");

  @override
  String toString() => ("$seriNo - $cihazAdi (${tip.name}), CPU: %$cpuYukYuzdesi");
}

String guvenlikIzolasyon(CihazTipi kod){
  return switch(kod){
    CihazTipi.sensor =>"ZONE-S",
    CihazTipi.gateway =>"ZONE-G",
    CihazTipi.edgeServer =>"ZONE-E",
    CihazTipi.router => "ZONE-R"
  };
}   

class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
}


void main(){
  print("IoT Cihazları");

  final List<IoTCihaz> cihazlar = [
    IoTCihaz(
      seriNo: "SRN-01", 
      cihazAdi: "Sıcaklık Sensörü", 
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 24.0, 
      bellekMb: 128, 
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerMi: true),

    IoTCihaz(
      seriNo: "SRN-02", 
      cihazAdi: "Ana Gateway", 
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 62.5, 
      bellekMb: 512, 
      acikPortlar: {"443/HTTPS", "23/TELNET"},
      sslSertifikasiGecerMi: true),

    IoTCihaz(
      seriNo: "SRN-03", 
      cihazAdi: "Kenar Sunucu", 
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 91.0, 
      bellekMb: 4096, 
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerMi: true),
      
    IoTCihaz(
      seriNo: "SRN-04", 
      cihazAdi: "Depo Router", 
      tip: CihazTipi.router,
      cpuYukYuzdesi: 35.0, 
      bellekMb: 256, 
      acikPortlar: {"80/HTTP"},
      sslSertifikasiGecerMi: false),

    IoTCihaz(
      seriNo: "SRN-05", 
      cihazAdi: "Nem Sensörü", 
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 12.0, 
      bellekMb: 64, 
      acikPortlar: <String>{},
      sslSertifikasiGecerMi: true),

    IoTCihaz(
      seriNo: "SRN-06", 
      cihazAdi: "Yedek Gateway", 
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 48.0, 
      bellekMb: 1024, 
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerMi: false)
  ];

  print("------------------------------------------------------");
  final riskliCihazlar=cihazlar.where((s)=>s.acikPortlar.contains("23/TELNET") || s.guvenlikAcigiVarMi || s.cpuYukYuzdesi >= 85.0).toList(); 
  print("Riskli Cihazlar: (${riskliCihazlar.length})");
  riskliCihazlar.forEach((s)=> print("* $s"));

  print("------------------------------------------------------");
  final int toplamBellek=cihazlar.fold(0, (toplam, bellek)=> toplam + bellek.bellekMb);
  print("Toplam Bellek Kullanımı: $toplamBellek MB");

  final List<CihazBilgi>bilgiler = cihazlar.map((e) => (
        cihazAdi: e.cihazAdi,
        tip: e.tip,
        alarmDurumu: e.guvenlikAcigiVarMi || e.cpuYukYuzdesi >= 85.0,)).toList();

  print("------------------------------------------------------");
  print("Cihaz Bilgileri:");
  for (final i in bilgiler) {
    print(
      "${i.cihazAdi} | ${i.tip.name} | Alarm: ${i.alarmDurumu}",
    );
  }
  print("------------------------------------------------------");
  print("Nem Sensörü  : ${guvenlikIzolasyon(CihazTipi.sensor)}");
  print("Kenar Sunucu : ${guvenlikIzolasyon(CihazTipi.edgeServer)}");
  print("Depo Router  : ${guvenlikIzolasyon(CihazTipi.router)}");

  print("------------------------------------------------------");
  final Set<String>kapaliCihazlar = {"SRN-04","SRN-06"};

  print("Cihaz Bağlantıları:");
  for (final a in cihazlar) {
    try {
      if (kapaliCihazlar.contains(a.seriNo)) {
        throw CihazErisilemezException(
          "${a.cihazAdi} (${a.seriNo}) erişime kapalı, cihaza bağlanılamadı.");
      }
      print("${a.cihazAdi} cihazına bağlanıldı.");
    } on CihazErisilemezException catch (hata) {
      print("Cihaz Erişim Hatası: $hata");
    } finally {
      print("${a.seriNo} bağlantı denemesi tamamlandı.");
    }
  }
}

