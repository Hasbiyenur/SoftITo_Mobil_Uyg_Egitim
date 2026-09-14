class Urun {
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);

  double kargoUcretiHesapla() {
    return 29.90;
  }
}

class DijitalUrun extends Urun {
  DijitalUrun(String id, String ad, double fiyat, int stok)
      : super(id, ad, fiyat, stok, "DIJITAL");

  @override
  double kargoUcretiHesapla() {
    return 0.0;
  }
}

abstract class ISiparisKaydedici {
  void siparisKaydet(String orderId, double tutar);
}

abstract class IOdemeYapici {
  void odemeYap(String tip, double tutar);
}

abstract class IKargoGonderici {
  void kargoGonder(String orderId, String adres);
}

abstract class IMailGonderici {
  void mailGonder(String email, String mesaj);
}

abstract class ISmsGonderici {
  void smsGonder(String tel, String mesaj);
}

abstract class IFaturaYazdirici {
  void faturaYazdir(String orderId);
}

abstract class ISiparisIslemleri
    implements
        ISiparisKaydedici,
        IOdemeYapici,
        IKargoGonderici,
        IMailGonderici,
        ISmsGonderici,
        IFaturaYazdirici {}

abstract class IVeritabaniServisi {
  void kaydet(String sql);
}

class SqliteVeritabani implements IVeritabaniServisi {
  @override
  void kaydet(String sql) {
    print("DB calistirildi: " + sql);
  }
}

abstract class IMailServisi {
  void mailAt(String to, String body);
}

class SmtpMailServisi implements IMailServisi {
  @override
  void mailAt(String to, String body) {
    print("SMTP Mail gonderildi: " + to);
  }
}

abstract class ISmsServisi {
  void smsYolla(String gsm, String text);
}

class NetgsmSmsServisi implements ISmsServisi {
  @override
  void smsYolla(String gsm, String text) {
    print("SMS iletildi: " + gsm);
  }
}

abstract class IOdemeStratejisi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements IOdemeStratejisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kredi kartindan POS ile cekildi.");
  }
}

class HavaleOdeme implements IOdemeStratejisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Havale kontrol edildi.");
  }
}

class KapidaOdeme implements IOdemeStratejisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kapida odeme tahsil edilecek (Komisyon +15 TL).");
  }
}

class CryptoOdeme implements IOdemeStratejisi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL USDT transferi onaylandi.");
  }
}

class OdemeStratejiSaglayici {
  final Map<String, IOdemeStratejisi> _stratejiler = {
    "KREDI_KARTI": KrediKartiOdeme(),
    "HAVALE": HavaleOdeme(),
    "KAPIDA_ODEME": KapidaOdeme(),
    "CRYPTO": CryptoOdeme(),
  };

  IOdemeStratejisi? stratejiGetir(String tip) => _stratejiler[tip];
}

abstract class IKuponStratejisi {
  double uygula(double tutar);
}

class Indirim10Kuponu implements IKuponStratejisi {
  @override
  double uygula(double tutar) => tutar * 0.90;
}

class Yaz20Kuponu implements IKuponStratejisi {
  @override
  double uygula(double tutar) => tutar * 0.80;
}

class Sepette50Kuponu implements IKuponStratejisi {
  @override
  double uygula(double tutar) => tutar - 50;
}

class KuponStratejiSaglayici {
  final Map<String, IKuponStratejisi> _kuponlar = {
    "INDIRIM10": Indirim10Kuponu(),
    "YAZ20": Yaz20Kuponu(),
    "SEPETTE50": Sepette50Kuponu(),
  };

  IKuponStratejisi? stratejiGetir(String kuponKodu) => _kuponlar[kuponKodu];
}

class SiparisYoneticisi implements ISiparisIslemleri {
  final IVeritabaniServisi db;
  final IMailServisi mailci;
  final ISmsServisi smsci;
  final OdemeStratejiSaglayici odemeStratejiSaglayici;
  final KuponStratejiSaglayici kuponStratejiSaglayici;

  SiparisYoneticisi({
    IVeritabaniServisi? db,
    IMailServisi? mailci,
    ISmsServisi? smsci,
    OdemeStratejiSaglayici? odemeStratejiSaglayici,
    KuponStratejiSaglayici? kuponStratejiSaglayici,
  })  : db = db ?? SqliteVeritabani(),
        mailci = mailci ?? SmtpMailServisi(),
        smsci = smsci ?? NetgsmSmsServisi(),
        odemeStratejiSaglayici =
            odemeStratejiSaglayici ?? OdemeStratejiSaglayici(),
        kuponStratejiSaglayici =
            kuponStratejiSaglayici ?? KuponStratejiSaglayici();

  @override
  void siparisKaydet(String orderId, double tutar) {
    db.kaydet("INSERT INTO siparisler VALUES ('$orderId', $tutar)");
  }

  @override
  void odemeYap(String tip, double tutar) {
    var strateji = odemeStratejiSaglayici.stratejiGetir(tip);
    if (strateji != null) {
      strateji.odemeYap(tutar);
    } else {
      print("Gecersiz odeme yontemi");
    }
  }

  @override
  void kargoGonder(String orderId, String adres) {
    print("MNG Kargo takip fis basildi: $adres");
  }

  @override
  void mailGonder(String email, String mesaj) {
    mailci.mailAt(email, mesaj);
  }

  @override
  void smsGonder(String tel, String mesaj) {
    smsci.smsYolla(tel, mesaj);
  }

  @override
  void faturaYazdir(String orderId) {
    print("Fatura PDF cikarildi: $orderId");
  }

  void siparisTamamla(
      String orderId,
      List<Urun> sepet,
      String odemeTipi,
      String musteriAdi,
      String email,
      String tel,
      String adres,
      String kuponKodu) {
    double? toplam = _sepetToplamiHesapla(sepet);
    if (toplam == null) {
      return;
    }

    toplam = _kuponUygula(toplam, kuponKodu);

    double kdv = toplam * 0.20;
    double sonTutar = toplam + kdv;

    odemeYap(odemeTipi, sonTutar);
    siparisKaydet(orderId, sonTutar);
    faturaYazdir(orderId);
    mailGonder(
        email, "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL");
    smsGonder(tel, "Siparisiniz onaylandi: $orderId");
    kargoGonder(orderId, adres);
  }

  double? _sepetToplamiHesapla(List<Urun> sepet) {
    double toplam = 0;
    for (var i = 0; i < sepet.length; i++) {
      if (sepet[i].stok <= 0) {
        print("Hata: " + sepet[i].ad + " tukenmis!");
        return null;
      }
      toplam += sepet[i].fiyat;
      toplam += sepet[i].kargoUcretiHesapla();
      sepet[i].stok--;
    }
    return toplam;
  }

  double _kuponUygula(double toplam, String kuponKodu) {
    var strateji = kuponStratejiSaglayici.stratejiGetir(kuponKodu);
    if (strateji != null) {
      return strateji.uygula(toplam);
    }
    return toplam;
  }
}

void main() {
  var siparisci = SiparisYoneticisi();

  var urun1 = Urun("1", "Kablosuz Mouse", 450.0, 5, "FIZIKSEL");
  var urun2 = DijitalUrun("2", "Flutter Kursu E-Kitap", 150.0, 100);

  var sepet = <Urun>[urun1, urun2];

  siparisci.siparisTamamla(
    "SP-9921",
    sepet,
    "KREDI_KARTI",
    "Selahaddin",
    "selahaddin@kodvance.com",
    "05551112233",
    "Kadikoy / Istanbul",
    "INDIRIM10",
  );
}