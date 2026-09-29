//1. Enumları (derleme Zamanı Güvenliği)

enum HizmetKategorisi{  // enum, bir değişkenin alabileceği hizmet kategorilerini önceden belirlenmiş seçeneklerle sınırlar.
  ciltYenileme,     // Cilt yenileme kategorisinin enum değeridir; sayı veya serbest metin yerine bu ad kullanılır.
  medikalEstetik,
  lazerEpilasyon,
  Lipo,
}

enum SeansDurumu{
  bekliyor,
  odadaIslemde,
  tamamlandi,
  iptalEdildi,
}

enum OdemeYontemi{
  krediKarti,
  havaleEft,
  nakit,
  klinikPaketKredisi,
}

//Danışan (müşteri) Modeli
class Danisan{    // class, danışan bilgilerini ve bu bilgilerle ilgili işlemleri aynı modelde toplar.
  final String id;    // String metin tipidir; final bu kimliğin nesne oluşturulduktan sonra yeniden atanamayacağını söyler.
  final String adSoyad;   // Danışanın ad ve soyadını saklayan, sonradan yeniden atanamayan metin alanı.
  final String telefon;   
  final bool vipUyeMi;    // bool yalnızca true veya false alır; burada VIP üyeliğini gösterir.
  final List<String> alerjiler; //boş olabilir ama null olamaz  // List<String> metinlerden oluşan listedir;  
  final String? ozelCiltNotu; //Opsiyonel Null olabilir   // String? ifadesindeki ? bu alanın metin ya da null olabileceğini belirtir.

  const Danisan({     // const kurucu, bütün alanlar uygun olduğunda sabit bir Danisan nesnesi oluşturmayı sağlar; { } adlandırılmış parametrelerdir.
    required this.id,   // required ZORUNLU parametre demektir; this.id gelen değeri nesnenin id alanına koyar.
    required this.adSoyad,   
    required this.telefon,
    this.vipUyeMi=false,    // vipUyeMi verilmezse varsayılan değer false olur.
    this.alerjiler=const [],  // alerjiler verilmezse varsayılan değer boş ve sabit bir listedir.
    this.ozelCiltNotu,    // ozelCiltNotu isteğe bağlıdır; verilmezse null olur.
  });

  bool get hassasCiltMi=>alerjiler.isNotEmpty;  // get, parantezsiz okunabilen hesaplanmış özelliktir; isNotEmpty liste boş değilse true döndürür.

  //Bilgi özet kartı
  String get bilgiOzeti{    // bilgiOzeti, çağrıldığında danışanın kısa tanıtım metnini hesaplayan String getter'dır.
    final String alerjiBilgisi=alerjiler.isEmpty ? "Kayıtlı Alerji Yok": "Alerjiler: ${alerjiler.join(', ')}";    // Üçlü koşul ? : ile liste boşsa sabit yazı seçer; değilse join ile alerjileri virgülle birleştirir.
    final String notBilgisi=ozelCiltNotu ?? "Özel medikal not girilmemiş";    // ?? soldaki not null değilse onu, null ise sağdaki varsayılan metni seçer.
    final String vipRozeti= vipUyeMi ? "VIP" : "Standart";    // VIP koşuluna göre iki yazıdan birini seçer; final değer bir kez atanır.
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";    // return hesaplanan metni döndürür; $ değişkenleri metnin içine yerleştirir.
  }
}
  // Seans (randevu) Modeli

  class SeansKaydi{   // SeansKaydi sınıfı bir randevunun tüm bilgilerini ve hesaplarını bir arada tutar.
    final String seansKodu;   // Her seans için kullanılan kod; final olduğundan sonradan değiştirilemez.
    final Danisan danisan;    // Danisan tipindeki alan, bu seansın hangi danışana ait olduğunu gösterir.
    final HizmetKategorisi kategori;
    final String islemAdi;
    final double birimFiyat;    // Tek seansın TL cinsinden ücretini ondalıklı sayı olarak saklar.
    final int seansSayisi;    // Satın alınan veya planlanan seans adedini tam sayı olarak saklar.
    final double indirimOrani;
    final String? sorumluUzman;
    SeansDurumu durum;    // final yoktur; seans ilerledikçe durum değiştirilebilir.
    OdemeYontemi? odemeTipi;    // Ödeme henüz yapılmadıysa null olabilir; sonra ödeme yöntemi atanabilir.

    SeansKaydi({    // SeansKaydi kurucusu adlandırılmış parametrelerle yeni bir kayıt oluşturur.
      required this.seansKodu,    // Seans kodu zorunludur ve bu nesnenin seansKodu alanına atanır.
      required this.danisan,     // Hangi danışana ait olduğu zorunludur.
      required this.kategori, 
      required this.islemAdi,
      required this.birimFiyat,
      this.seansSayisi=1,   // Adet verilmezse bir seans varsayılır.
      this.indirimOrani=0.0,    // İndirim verilmezse yüzde sıfır varsayılır.
      this.sorumluUzman,    // Uzman verilmezse sorumluUzman null kalır.
      this.durum=SeansDurumu.bekliyor,    // Durum verilmezse seans bekliyor olarak başlar.
      this.odemeTipi,
    });

    double get brutTutar=>birimFiyat*seansSayisi;   // Brüt toplamı birim fiyat × seans sayısı olarak her okunduğunda hesaplar; => kısa dönüş yazımıdır.
    double get indirimTutari{     // İndirim tutarını hesaplayan getter başlar; sonuç double tipindedir.
    double toplamOran=indirimOrani;   // Başlangıçtaki toplam indirim oranını seansın kendi oranından alır.

    if(danisan.vipUyeMi){     // Danışan VIP ise koşulun içindeki ek indirim uygulanır.
      toplamOran+=10.0;   // VIP indirimine 10 yüzde puan ekler; += mevcut değerin üzerine ekleme yapar.
    }
      return brutTutar * (toplamOran / 100.0);    // Brüt tutarın toplam indirim oranına karşılık gelen para miktarını döndürür; 100'e bölme yüzdeyi dönüştürür.
    }

    double get netTutar=> brutTutar - indirimTutari;    // Net ödenecek tutarı brüt tutardan indirim tutarını çıkararak hesaplar.

  }

  class KlinikYoneticisi{
    final String subeAdi;   // Şube adını tutar; final olduğu için kurulduktan sonra başka değere atanmaz.
    final List<SeansKaydi> _seanslar=[];    // SeansKaydi nesnelerinden oluşan boş liste; baştaki _ bu adı kütüphane içinde özel yapar.
    final Map<String,Danisan> _danisanRehberi={};   // Map anahtar-değer yapısıdır; danışan id'sini Danisan nesnesiyle eşleştirir.

    KlinikYoneticisi({ required this.subeAdi});

    //Danışan kaydetme
    void danisanKaydet(Danisan danisan){    // void sonuç döndürmeyen metottur; parametre olarak bir Danisan alır.
      _danisanRehberi[danisan.id]=danisan;    // Danışanı id anahtarı altında rehbere ekler; aynı id varsa eski kayıt üzerine yazılır.
      print("Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VIP" : "Standart"})");  // print konsola bilgi yazar; ${...} ifadeleri danışanın alanlarını ve VIP koşulunu metne yerleştirir.
    }

    void randevuOlustur(SeansKaydi seans){    // Bir SeansKaydi alıp kaydetmek için randevuOlustur metodu başlar.
      _seanslar.add(seans); // add, seans nesnesini _seanslar listesinin sonuna ekler.
      print("Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}->${seans.islemAdi}",   // Randevunun kodunu, danışanını ve işlem adını yazdıran print çağrısı başlar.
      );
    }

    void seansiTamamla({    // seansiTamamla metodu adlandırılmış iki parametre alır ve değer döndürmez.
      required String seansKodu,    // Aranacak seans kodunu vermek zorunludur.
      required OdemeYontemi odeme,    // Ödeme yöntemi OdemeYontemi enum değerlerinden biri olarak zorunludur.
    }){
      for (var seans in _seanslar){   // for-in döngüsü listedeki her seansı sırayla seans değişkenine koyar.
        if(seans.seansKodu==seansKodu){   // == iki kodun aynı olup olmadığını kontrol eder.
          seans.durum=SeansDurumu.tamamlandi;   // Eşleşen seansın durumunu tamamlandı olarak değiştirir.
          seans.odemeTipi=odeme;    // Bu seansa seçilen ödeme yöntemini kaydeder.
          print("Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",   // Seans kodunu, iki ondalıklı net tutarı ve odeme.name değerini yazdırır.
          );
          return;   // return metottan hemen çıkar; böylece alttaki bulunamadı mesajı çalışmaz.
        }
      }
        print("Hata [$seansKodu] kodlu seans bulunamadı");    // Hiçbir eşleşme bulunmadıysa hata mesajı yazdırılır.
      }
    void seansiIptalEt(String seansKodu,{String? iptalNedeni}){ // İptal metodunda seans kodu zorunlu; {String? iptalNedeni} isteğe bağlı adlandırılmış parametredir.
      for(var seans in _seanslar){    // Kayıtlı seansların her birini dolaşır.
        if (seans.seansKodu==seansKodu){    // İptal edilmek istenen kod ile listedeki kodu karşılaştırır.
          seans.durum=SeansDurumu.iptalEdildi;    // Eşleşen seansın durumunu iptalEdildi yapar.
          print(  
            "Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",    // ?? sayesinde neden verilmemişse Gerekçe Belirtilmedi yazılır.
          );
          return;
        }
      }
    }

    //Finansal Rapor Metotları(fonksiyonel Dart)
    double get toplamTahsilEdilenCiro => _seanslar.where((s) => s.durum==SeansDurumu.tamamlandi).fold(0.0, (toplam,s) => toplam + s.netTutar);    // get olarak ciroyu hesaplar; where yalnızca tamamlananları seçer, fold 0.0'dan başlayıp net tutarları toplar.
    double get beklenenPotansiyelCiro => _seanslar.where((s) => s.durum==SeansDurumu.bekliyor || s.durum == SeansDurumu.odadaIslemde).fold(0.0, (toplam, s) => toplam + s.netTutar);    // where bekleyen veya işlemde olanları seçer; fold bunların net tutarlarını toplayarak potansiyel ciroyu verir.

    //kategori bazlı seans sayıları
    Map<HizmetKategorisi,int> kategoriBazliSeansDagilimi (){    // Map döndüren metot; her HizmetKategorisi için seans sayısını hesaplar.
      final Map<HizmetKategorisi,int> dagilim={};   // Kategori anahtarı ve int sayaç değeri tutacak boş haritayı oluşturur.
      for (var kat in HizmetKategorisi.values){   // Enumdaki bütün kategorileri values üzerinden tek tek dolaşır.
        dagilim[kat]=0;   // Her kategorinin başlangıç sayacını sıfır yapar.
      }
      for(var s in _seanslar){    // Kaydedilmiş her seansı dolaşır.
        dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;  // Seansın kategori sayacını bir artırır; ?? 0 varsa olmayan anahtarda sıfırdan başlar.
      }
      return dagilim; // Doldurulan kategori-sayı haritasını döndürür.
    }

    Set<String> gorevliUzmanKadrosu(){    // Set<String> benzersiz uzman adları kümesidir; metot bu kümeyi döndürür.
      return _seanslar.map((s)=>s.sorumluUzman).whereType<String>().toSet();    // map uzmanları seçer, whereType<String> null değerleri çıkarır, toSet tekrarları kaldırır.
    }

    //Uzmansız kalan seanslar
    List<SeansKaydi> uzmansizSeanslariGetir(){    // Uzmanı null olan seansları List<SeansKaydi> olarak döndüren metot başlar.
      return _seanslar.where((s)=> s.sorumluUzman == null).toList();    // where uzmanı olmayanları filtreler; toList sonucu listeye çevirir; durum kontrolü yapmaz.
    }

    void gunSonuRaporuYazdir() {    // Gün sonu raporunu konsola yazdıran, sonuç döndürmeyen metot başlar.
    print("Günlük Seans ve İşlem Çizelgesi");
    print("----------------------------------------------------");
    print(
      "${'Kod'.padRight(10)} | "    // Kod başlığını padRight(10) ile 10 karakter genişliğe tamamlar.
      "${'Danışan'.padRight(16)} | "    // Danışan başlığını 16 karakter genişliğe tamamlar.
      "${'İşlem'.padRight(20)} | "     // İşlem başlığını 20 karakter genişliğe tamamlar.
      "${'Uzman'.padRight(18)} | "    // Uzman başlığını 18 karakter genişliğe tamamlar.
      "${'Tutar'.padRight(10)} | "    // Tutar başlığını 10 karakter genişliğe tamamlar.
      "${'Durum'} | ",    // Son sütunun Durum başlığını ekler; bitişik metinler Dart'ta yan yana birleşir.
    );
    print("----------------------------------------------------");

    for(var s in _seanslar){  // Rapor için her seans kaydını sırayla s değişkenine alır.
      final String uzman = s.sorumluUzman ?? "Nöbetçi Bekliyor";    // ?? ile uzman varsa adını, yoksa Nöbetçi Bekliyor metnini seçer.
      final String durumRozet = switch (s.durum){   // switch ifadesi, seans durumuna göre gösterilecek yazıyı üretir.
        SeansDurumu.tamamlandi => "Tamamlandı",   // Durum tamamlandıysa Tamamlandı metnini seçer.
        SeansDurumu.odadaIslemde => "İşlemde",   
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal Edildi",
      };

      print(
        "${s.seansKodu.padRight(10)} | "    // Seans kodunu 10 karakter genişliğe getirip | ayıracını ekler.
        "${s.danisan.adSoyad.padRight(10)} | "    // Danışan adını 10 karaktere tamamlar; 16 karakterlik başlıkla genişliği farklıdır.
        "${s.islemAdi.padRight(10)} | "   // İşlem adını 10 karaktere tamamlar; 20 karakterlik başlıkla genişliği farklıdır.
        "${uzman.padRight(10)} | "    // Uzman adını 10 karaktere tamamlar; 18 karakterlik başlıkla genişliği farklıdır.
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "    // Net tutarı iki ondalıklı metne çevirip 10 karaktere tamamlar.
        "$durumRozet",
      );
    }   
      print("----------------------------------------------------");
      print("Finansal Özet:");
      print(" * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}");   // Tamamlanmış seanslardan gelen net ciroyu iki ondalıkla yazdırır.
      print(" * Bekleyen Potansiyel Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}");    // _seanslar.length liste elemanı sayısını, yani toplam randevu adedini verir.
      print(" * Toplam Seans : ${_seanslar.length} Randevu");
      print("----------------------------------------------------");
      print("Aktif Uzmanlar");

      final uzmanlar = gorevliUzmanKadrosu();   // gorevliUzmanKadrosu sonucundaki benzersiz isimleri uzmanlar değişkenine alır.
      if (uzmanlar.isEmpty){    // isEmpty kümede hiç uzman adı yoksa true olur.
        print("Kayıtlı Uzman Bulunamadı");    
      } else {
        print(" ${uzmanlar.join(', ')}");   // join(', ') isimleri aralarına virgül ve boşluk koyarak tek metne dönüştürür.
      }

      final uzmansizlar = uzmansizSeanslariGetir();
      if (uzmansizlar.isNotEmpty){   // isNotEmpty listede en az bir uzmansız seans varsa true olur.
        print(
          "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",
        );
        for (var u in uzmansizlar) {
          print("-> [${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");  // Her uzmansız seansın kodunu, danışanını ve işlem adını yazdırır.
        }
      }
      print("---------------------------------------");
    }
  }

  void main() {   // main programın başlangıç noktasıdır; dosya çalıştırılınca ilk bu fonksiyon çağrılır.
    print("Klinik yönetim sistemi başlatılıyor....");
    final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi");     // subeAdi vererek yeni KlinikYoneticisi nesnesi kurar; final değişkeni bir kez atanır.

    //danışanları oluşturalım
    final d1 = Danisan( // İlk Danisan nesnesini oluşturur ve d1 değişkenine atar.
      id: "DAN-101",
      adSoyad: "Ahmet Yılmaz",
      telefon: "0555 555 55 55",
      vipUyeMi: true,       // VIP üyelik bilgisini true veya false olarak verir; true ise indirim hesabına 10 puan eklenir.
      alerjiler: ["Retinol,Aspirin"],
      ozelCiltNotu: "Cilt bariyeri hassas",
    );
    final d2 = Danisan(
      id: "DAN-102",
      adSoyad: "Ahmet Yılan",
      telefon: "0555 555 55 55",
      vipUyeMi: false,
      alerjiler: [],    // Boş liste, bu danışan için kayıtlı alerji olmadığını belirtir.
    );
    final d3 = Danisan(
      id: "DAN-103",
      adSoyad: "Hasan Hüseyin",
      telefon: "0555 555 55 55",
      vipUyeMi: true,
      alerjiler: ["Retinol,Aspirin"],   // Bu tek String öğesidir; iki ayrı alerji isteniyorsa ["Retinol", "Aspirin"] yazılmalı.
    );
    final d4 = Danisan(
      id: "DAN-104",
      adSoyad: "Ebubekir Sıddık",
      telefon: "0555 555 55 55",
      vipUyeMi: true,
      alerjiler: [],
      ozelCiltNotu: "Cilt bariyeri hassas",
    );

    yonetici.danisanKaydet(d1);   // d1 nesnesini yöneticinin id ile erişilen danışan rehberine kaydeder.
    yonetici.danisanKaydet(d2);
    yonetici.danisanKaydet(d3);
    yonetici.danisanKaydet(d4);

    print("Danışan güvenlik kontrolü");
    print(d1.bilgiOzeti);   // d1'in bilgiOzeti getter'ını okuyup sonucu yazdırır.
    print(d2.bilgiOzeti);   // d2'nin bilgiOzeti getter'ını okuyup sonucu yazdırır.
    print("----------------------------------");

    // randevular oluşturuluyor
    final seans1 = SeansKaydi(    // Birinci SeansKaydi nesnesini oluşturup seans1 değişkenine atar.
      seansKodu: "SNS-2026-1",
      danisan: d1,
      kategori: HizmetKategorisi.Lipo,    // HizmetKategorisi enumundan bu işlemin kategorisini seçer.
      islemAdi: "Lipo gerisini bilmiyorum",
      birimFiyat: 6500.0,
      seansSayisi: 2,
      indirimOrani: 5.0,
      sorumluUzman: "Osman Gültekin",
    );
    final seans2 = SeansKaydi(
      seansKodu: "SNS-2026-2",
      danisan: d2,
      kategori: HizmetKategorisi.ciltYenileme,
      islemAdi: "Siverex ile yüz temizleme",
      birimFiyat: 2500.0,
      seansSayisi: 5,
      indirimOrani: 15.0,
      sorumluUzman: null,   // Seansın uzman adını verir; null henüz uzman atanmadığı anlamına gelir.
    );
    final seans3 = SeansKaydi(
      seansKodu: "SNS-2026-3",
      danisan: d3,
      kategori: HizmetKategorisi.lazerEpilasyon,
      islemAdi: "Tüm Vücut",
      birimFiyat: 25000.0,
      seansSayisi: 15,
      indirimOrani: 0.0,
      sorumluUzman: "Hasbiyenur Çoban",
    );
    final seans4 = SeansKaydi(
      seansKodu: "SNS-2026-4",
      danisan: d4,
      kategori: HizmetKategorisi.medikalEstetik,
      islemAdi: "Burun Estetiği",
      birimFiyat: 1500.0,
      seansSayisi: 3,
      sorumluUzman: "Fatma Gül",
    );

    yonetici.randevuOlustur(seans1);  // Birinci seansı yönetici içindeki _seanslar listesine ekler.
    yonetici.randevuOlustur(seans2);
    yonetici.randevuOlustur(seans3);
    yonetici.randevuOlustur(seans4);
    print("Seanslar Gönderiliyor");

    yonetici.seansiTamamla(   // Birinci seansı tamamlayıp ödeme yöntemini kaydetmek için metodu çağırır.
      seansKodu: "SNS-2026-1",    // Tamamlanacak seansı koduyla seçer.
      odeme: OdemeYontemi.krediKarti, // Ödeme yöntemini kredi kartı enum değeri olarak verir.
    );

    //seans 2 başarıyla tamamlanıyor (nakit ödeme);
    yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);   // İkinci seansı nakit ödeme ile tamamlamak için aynı metodu çağırır.

    //seans 4 iptal ediliyor
    yonetici.seansiIptalEt(   // Bir seansı iptal etmek için yöneticinin seansiIptalEt metodunu çağırır.
      "SNS-2026-04",    
      iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
    );
    yonetici.gunSonuRaporuYazdir();   // Gün sonu raporunu hesaplayıp konsola yazdırır.
  }