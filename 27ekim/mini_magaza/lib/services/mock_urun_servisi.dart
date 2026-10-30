import '../models/kategori.dart';
import '../models/urun.dart';
import 'i_urun_servisi.dart';
import 'api_urun_servisi.dart';

import 'package:proje/models/degerlendirmeler.dart';

class MockUrunServisi implements IUrunServisi {
  final List<Urun> _urunDeposu = const [
    Urun(
      id: 1,
      baslik: 'Macbook M5 Pro Laptop',
      aciklama: "Apple'ın en güçlü işlemcisine sahip yeni nesil Macbook Pro",
      fiyat: 179999.99,
      resimUrl: .parse("https://fakestoreapi.com/img/"),
      kategori: Kategori.elektronik,
      stokAdedi: 5,
      degerlendirme: Degerlendirme(puan: 4.8, onSayisi: 10),
    ),
    Urun(
      id: 2,
      baslik: 'Erkek L Gömlek',
      aciklama: "Yeni sezon Slim Fit Gömlek",
      fiyat: 499.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.erkekgiyim,
      stokAdedi: 14,
      degerlendirme: Degerlendirme(puan: 4.4, onSayisi: 177),
    ),
    Urun(
      id: 3,
      baslik: 'Gümüş Takı Kolye',
      aciklama: "Gümüş Takı Kolye",
      fiyat: 1499.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.taki,
      stokAdedi: 14,
      degerlendirme: Degerlendirme(puan: 4.6, onSayisi: 100),
    ),
    Urun(
      id: 4,
      baslik: 'iPhone Telefon Kılıfı',
      aciklama: "Suya ve Toza Dayanıklı Tüm iPhone Modelleri için Kılıf",
      fiyat: 99.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.taki,
      stokAdedi: 99,
      degerlendirme: Degerlendirme(puan: 4.2, onSayisi: 133),
    ),
    Urun(
      id: 5,
      baslik: 'Macbook Air M2 Kılıf ',
      aciklama:
          "Suya ve Toza Dayanıklı Tüm Macbook Air M2 Modelleri için Kılıf",
      fiyat: 249.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.taki,
      stokAdedi: 24,
      degerlendirme: Degerlendirme(puan: 4.3, onSayisi: 299),
    ),
    Urun(
      id: 6,
      baslik: 'Airpods Pro 3. Nesil',
      aciklama: "Ses Kalitesiyle Öne Çıkan Airpods Pro 3. Nesil",
      fiyat: 7999.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.elektronik,
      stokAdedi: 33,
      degerlendirme: Degerlendirme(puan: 4.7, onSayisi: 345),
    ),
    Urun(
      id: 7,
      baslik: 'Samsung Galaxy Watch 5',
      aciklama: "Samsung'un suya ve toza dayanıklı akıllı saati Samsung Galaxy Watch 5",
      fiyat: 11249.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.elektronik,
      stokAdedi: 44,
      degerlendirme: Degerlendirme(puan: 4.1, onSayisi: 14),
    ),
    Urun(
      id: 8,
      baslik: 'Unisex Kışlık Mont',
      aciklama: "Sıcak Tutuan Unisex Kışlık Mont",
      fiyat: 1499.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.erkekgiyim,
      stokAdedi: 77,
      degerlendirme: Degerlendirme(puan: 4.1, onSayisi: 34),
    ),
    Urun(
      id: 9,
      baslik: 'Kadın Deri Ceket',
      aciklama: "Premium Deri Ceket",
      fiyat: 1299.99,
      resimUrl: "https://fakestoreapi.com/img/",
      kategori: Kategori.kadingiyim,
      stokAdedi: 14,
      degerlendirme: Degerlendirme(puan: 4.1, onSayisi: 34),
    ),
  ];

  @override
  Future<List<Urun>> tumUrunleriGetir() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return List.from(_urunDeposu);
  }

  @override
  Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (kategori == Kategori.hepsi) {
      return List.from(_urunDeposu);
    }
    return _urunDeposu.where((urun) => urun.kategori == kategori).toList();
  }

  @override
  Future<List<Urun>> adaGoreAra(String aramaMetni) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (aramaMetni.trim().isEmpty) {
      return List.from(_urunDeposu);
    }
    return _urunDeposu.where((urun) {
      final baslikKucuk = urun.baslik.toLowerCase();
      final arananKucuk = aramaMetni.toLowerCase();
      return baslikKucuk.contains(arananKucuk);
    }).toList();
  }
}
