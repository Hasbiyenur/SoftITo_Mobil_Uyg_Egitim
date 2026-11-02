enum Kategori {
  hepsi('Tümü', 'H'),
  elektronik('Elektronik', 'E'),
  taki('Takı & Mücevher', 'T'),
  erkekgiyim('Erkek Giyim', 'ER'),
  kadingiyim('Kadın Giyim', 'K');

  final String baslik;
  final String ikon;

  const Kategori(this.baslik, this.ikon);
}

extension KategoriExtension on Kategori {
  String get gorunenAd {
    switch (this) {
      case Kategori.hepsi:
        return "Tümü";
      case Kategori.elektronik:
        return "Elektronik";
      case Kategori taki:
        return "Takı & Mücevher";
      case Kategori.erkekgiyim:
        return "Erkek Giyim";
      case Kategori.kadingiyim:
        return "Kadın Giyim";
    }
  }

  static Kategori apiMetindenUret(String apiMetni) {
    switch (apiMetni.toLowerCase().trim()) {
      case 'electronics':
        return Kategori.elektronik;
      case 'jewelery':
        return Kategori.taki;
      case "men's clothing":
        return Kategori.erkekgiyim;
      case "women's clothing":
        return Kategori.kadingiyim;
      default:
        return Kategori.hepsi;
    }
  }
}
