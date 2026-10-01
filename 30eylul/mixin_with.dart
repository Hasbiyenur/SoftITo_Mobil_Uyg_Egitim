//mixin and with

mixin UcmaYetisi{
  int ucusIrtifasiMetre=100;

  void gogeYuksel(){
    print("Uçuş Yetisi: Kanatlarını Açtı ve $ucusIrtifasiMetre metreye Yükseldi ");
  }
}


mixin GorunmezlikYetisi{
  void pelerinOrt(){
    print("Görünmezlik: Düşmanların gözünden tamamen kayboldu!");
  }
}

mixin AtesGucuYetisi {
  void alevSaldirisi(){
    print("Ateş Gücü: Kılıcını alevlendirdi ve alanı yaktı");
  }
}

class TemelKarakter{
  final String ad;
  TemelKarakter({required this.ad});
}

class EfsaneviEjderBinicisi extends TemelKarakter with UcmaYetisi, AtesGucuYetisi{
  final String ejderhaAdi;

  EfsaneviEjderBinicisi({
    required this.ejderhaAdi,
    required super.ad
  });

  void hucumEt(){
    print("$ad ve ejderhası $ejderhaAdi savaşa atılıyor");
    gogeYuksel();
    alevSaldirisi();
  }
}

class GolgeSuikastci extends TemelKarakter with GorunmezlikYetisi{
  GolgeSuikastci({required super.ad});

  void suikastYap() {
    print("$ad hedefe sessizce yaklaşıyor");
    pelerinOrt();
    print("Kritik Darbe Vurdu");
  }
}

void main(){
  print("Süper Güçler Başlatılıyor");
  final birinci = EfsaneviEjderBinicisi(ejderhaAdi: "Büşra", ad: "Akyol");
  birinci.hucumEt();
  final ikinci = GolgeSuikastci(ad: "Kübra");
  ikinci.suikastYap();
}