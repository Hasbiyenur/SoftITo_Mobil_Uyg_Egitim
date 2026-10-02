class Kahraman{
  final String ad;
  final String sinif;
  int seviye;
  double saldiriciGucu;
  bool hayattaMi;

  Kahraman({
    required this.ad,
    required this.sinif,
    this.seviye = 1,
    this.saldiriciGucu = 50.0,
    this.hayattaMi = true
  });

  Kahraman.acemi({required this.ad,}) 
  : sinif = "Çırak Savaşçı",
    seviye= 1,
    saldiriciGucu = 25.0,
    hayattaMi = true;

    factory Kahraman.fromSaveJson(Map<String, dynamic>json){
      return Kahraman(
      ad: json["ad"] as String, 
      sinif: json["sinif"] as String,
      seviye: json["seviye"] as int,
      saldiriciGucu: (json["hasar"] as num).toDouble(),
      hayattaMi: json["hayatta"] as bool
      );
    }
    void kartYazdir(){
      print("[$sinif] $ad | Seviye $seviye | Güç: $saldiriciGucu | Durum: ${hayattaMi ? 'Canlı' : 'Ruh Halinde'}");
    }
 }

    void main(){
      print("Karakter Üretimi");
      final sampiyon=Kahraman(
        ad: "Hasbiyenur Çoban", 
        sinif: "Şövalye",
        seviye: 10,
        saldiriciGucu: 120.0
      );

      sampiyon.kartYazdir();

      final caylak=Kahraman.acemi(ad: "Furkan Doğan");
      caylak.kartYazdir();

      final Map<String, dynamic> jsondanGelenKarakter={
        "ad": "Büşra",
        "sinif": "Ak Büyücü",
        "seviye": 50,
        "hasar": 350.5,
        "hayatta": true
      };
      final efsane = Kahraman.fromSaveJson(jsondanGelenKarakter);
      efsane.kartYazdir();
    }