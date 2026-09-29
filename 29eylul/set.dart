void main(){

  print("Beyaz Liste ve Küme Analizi");

  final Set<String> istanbulVeriMerkeziIpleri={
    "10.0.1.10",
    "10.0.1.11",
    "10.0.1.12",
    "10.0.1.13",
    "10.0.1.10", //Çift kayıt Set burayı anında tek hale getirir
};
  print("İstanbul Ipleri: $istanbulVeriMerkeziIpleri");

  final Set<String> frankfurtVeriMerkezIpleri={
    "10.0.1.13",
    "10.0.1.30",
    "10.0.1.45",
  };
  print("Frankfurt Ipleri: $frankfurtVeriMerkezIpleri");

  final ortakKopruIpler=istanbulVeriMerkeziIpleri.intersection(frankfurtVeriMerkezIpleri);
  print("Ortak Ağ Ipleri (kesişim): $ortakKopruIpler");

  final tumGlobalIpler=istanbulVeriMerkeziIpleri.union(frankfurtVeriMerkezIpleri);
  print("Toplam Global Ipleri (birleşim): $tumGlobalIpler");

  final sadeceIstanbul=istanbulVeriMerkeziIpleri.difference(frankfurtVeriMerkezIpleri);
  print("Sadece Istanbula Ait Ipler: $sadeceIstanbul");
}
