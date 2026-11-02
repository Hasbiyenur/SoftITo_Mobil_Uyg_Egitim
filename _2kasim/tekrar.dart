//Mülakat için önemli: Sealed sınıflar dışarıdan extend edilmez. Switch içinde tüm alt sınıflar tüketilmek zorundadır.
sealed class OdemeDurumu {} //sealed ile ödeme sınıfı bu dosya dışında başka dosyada kullanılamaz, sadece bu dosya içerisinde kullanılabilir.

class OdemeBasarili extends OdemeDurumu {
  //Odemedurumu extends ile miras alınır
  final ({String referansKodu, double tutar}) veri;
  OdemeBasarili(this.veri); //oluşturulurken verilen bilgiyi veri alanına koyar.
}

class OdemeBasarisiz extends OdemeDurumu {
  final String hataNedeni;
  OdemeBasarisiz(this.hataNedeni); //yukarıdaki durumun aynısı
}

abstract class IBankaServisi {
  //başka sınıflarda bulunması gereken işlemi tarif eder.
  Future<OdemeDurumu> odeme({
    required double miktar,
  }); //istenilen miktar bilgisini zorunlu olarak ister. boş geçilemez
}

mixin GuvenlikDenetimiMixin {
  //başka bir sınıflarda kullanılabilmesi için oluşturulan bir yapıdır.
  bool tokenGecerliMi(String token) {
    return token.isNotEmpty &&
        token.length >= 32; //token verisi boş ve 32den az olmamalı
  }
}

mixin AuditLogMixin {
  void islemKaydet(String mesaj) {
    // yukarıdaki durumla aynı
    final zaman = DateTime.now().toIso8601String(); //işlem yapılan sistemden saati alır ve aşağıdaki print ile yazdırılır
    print('Log - $zaman: $mesaj');
  }
}

class GarantiBankasiServisi //mixin kullanılan işlemler aynen garantibankasıservisinde kullanılsın.
    with GuvenlikDenetimiMixin, AuditLogMixin
    implements IBankaServisi {
  //,GarantibankasıServisi, IBankaServisindeki işlemi kullanacak fakat kendisine göre dolduracak (sözleşme yapar) ve bunu @override ile yapmalı yoksa dart hata verir
  final String apiAnahtari;

  GarantiBankasiServisi({required this.apiAnahtari});

  @override //implements edilen işlemi sağlamak için üzerine yazılması gerek.
  Future<OdemeDurumu> odeme({required double miktar}) async {
    //gelecekte işlemin gerçekleşmesi sağlanılır. ODemedurumunun tipine göre işlem yapılır. miktar virgüllü kullanılıp zorunlu tutulmuştur
    if (!tokenGecerliMi(apiAnahtari)) {
      islemKaydet('Ödeme Reddedildi. Geçersiz Api Anahtarı');
      return OdemeBasarisiz('Yetkilendirme hatası: Geçersiz token');
    }

    await Future.delayed(
      const Duration(milliseconds: 1000),
    ); //1000 milisaniye bekleme işlemi yapılıyor

    islemKaydet(
      '$miktar tutarındaki ödeme Garanti Bankası tarafından ONAYLANDI!',
    );
    return OdemeBasarili((
      referansKodu: 'GRNT-${DateTime.now().millisecondsSinceEpoch}',
      tutar: miktar,
    ));
  }
}

void odemeSonucuEkranaBas(OdemeDurumu durum) {
  //ekrana yazdırma fonksiyonudur. sealed classtan aldığı verileri ekrana yazdırır.
  final mesaj = switch (durum) {
    //switch içindeki durum değerini string olarak seçip mesaj değişkeninin içine atar.
    OdemeBasarili b =>
      'Ödeme Başarılı. Ref: ${b.veri.referansKodu}, Tutar: ${b.veri.tutar} ₺',
    OdemeBasarisiz h => 'Ödeme Başarısız. Gerekçe: ${h.hataNedeni}',
  };
  print(mesaj);
}

void main() async {
  //uygulamanın çalışmasını sağlar
  final kullanici = GarantiBankasiServisi(
    apiAnahtari: 'abcdefgh1234567891234567890123456',
  );
  final durum = await kullanici.odeme(miktar: 1000.14);
  odemeSonucuEkranaBas(durum);
}
