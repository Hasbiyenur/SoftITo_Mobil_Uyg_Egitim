/*void main(){
/*
  //Jsdeki gibi let x=""Hasbiyenur; x=42;
  // print("İlk dersimiz - Dart SDK aktif olmalı");
  //1.Açık belirtilen veri tipleri
  int seansSuresiDakika=45;
  double seansUnretiTl=2750.50;
  String uzmanAdi="Dr Hasbiyenur Çoban";
  bool aktifMi=true;

  //2.String interpolation
  //Jsdeki `${}` bunun yerine sadece $değişken, işlem varsa ${degisken*2} kullanılır
  print("Uzman:$uzmanAdi | Süre: $seansSuresiDakika dk | Ücret: $seansUnretiTl ₺");
  print("KDV dahil (½20) ${seansUnretiTl*1.20} ₺"); 

  //3. var ile tip çıkarımı
  var tedaviAdi="Kahve ile Peeling";
  // tedaviAdi=99; //izin vermez
  print(tedaviAdi);

  //4. dynamic veri tipini bağımsız kullanabiliriz ancak flutterda önerilmez
  dynamic serbestKutu="Lazer Epilasyon";
  serbestKutu=1000 ;//izin verilir ama veri tip güvenliğini yok eder

*/
/*
   //const: Derleme anında değeri belli olan veriler, bellekte tek bir yerde saklanır
   const String KLINIK_ADI="SoftITo Güzellik Merkezi";
   const double KDV_ORANI=0.20;

   //const DateTime suankiZaman=DateTime.now(): //Hata derleme anında bunu bilemeyiz.

  //final: Çalışma anında hesaplanır, bir kere atandıktan sonra değişmez
  final DateTime randevuZamani=DateTime.now();
  final String takipKodu="SOFT-" + randevuZamani.microsecondsSinceEpoch.toString();

  print("Klinik adı: $KLINIK_ADI");
  print("oluşturulma tarihi: $randevuZamani | Kod: $takipKodu");

*/
/*
  //Dartts değişken varsayılan olarak null olamaz bunun yerine null safety operatörleri kullanırız(?,??,!)

  String zorunluDanisanAdi="Hasbiyenur Çoban";
  String? danisanAlerjiNotu;
  print("alerji notu: $danisanAlerjiNotu");

  //ifNull operatörü-null ise varsayılan değer atama
  String goruntulenecekNot=danisanAlerjiNotu ?? "Bilinen bir alerjisi yok";
  print ("Rapor: $goruntulenecekNot");


  //null aware
  print("alerji metin uzunluğu: ${danisanAlerjiNotu?.length}");


  //klasik sıralı fonksiyon
  double topla(double a, double b)=>a + b;
*/
*/
  //Modern Dart / Flutter standartları: Named parameters({})

  void seansKaydiOlustur({
      required String danisan,
      required String tedavi,
      required double birimFiyat,
      int seansSayisi=1,  //default değer
      double indirimOrani=0.0,  //default değer
      String? uzmanHekim, //null olabilir
  }){
  final double brutTutar=birimFiyat*seansSayisi;
  final double indirimTutari=brutTutar*(indirimOrani/100);
  final double netTutar=brutTutar-indirimTutari;

print("""

===========================================================

SoftITo Seans Sözleşmesi

-----------------------------------------------------------

Danışan         :   $danisan
Tedavi           :  $tedavi (x$seansSayisi Seans)
Uzman Hekim     :   ${uzmanHekim ?? "Nöbetçi Estetisyen"}
Brüt Tutar      :   $brutTutar
İndirim         :   -$indirimTutari ₺ ($indirimOrani)
Ödenecek Tutar  :   $netTutar ₺

===========================================================

""");
}

  void main(){
    seansKaydiOlustur(
      danisan: "Hasbiyenur Çoban",
      tedavi: "Medikal Cilt Yenileme",
      birimFiyat: 4500.0,
      seansSayisi: 3,
      indirimOrani: 15.0,
      uzmanHekim: "Dr. Hasbiyenur"
    );
  }
