import '../models/kategori.dart';
import '../models/urun.dart';
import 'i_urun_servisi.dart';

class MockUrunServisi implements IUrunServisi {
  final List<Urun> _urunDeposu = const [
    Urun(
      id: 1,
      baslik: 'Macbook M5 Pro Laptop',
      aciklama: "Apple'ın en güçlü işlemcisine sahip yeni nesil Macbook Pro",
      fiyat: 179999.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.elektronik,
      stokAdedi: 5,
    ),
    Urun(
      id: 2,
      baslik: 'Erkek L Gömlek',
      aciklama: "Yeni sezon Slim Fit Gömlek",
      fiyat: 499.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.giyim,
      stokAdedi: 14,
    ),
    Urun(
      id: 3,
      baslik: 'Deri Çizme',
      aciklama: "Kışlık Sıcak Tutuan Çizme",
      fiyat: 1499.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.ayakkabi,
      stokAdedi: 14,
    ),
    Urun(
      id: 4,
      baslik: 'iPhone Telefon Kılıfı',
      aciklama: "Suya ve Toza Dayanıklı Tüm iPhone Modelleri için Kılıf",
      fiyat: 99.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.aksesuar,
      stokAdedi: 99,
    ),
    Urun(
      id: 5,
      baslik: 'Macbook Air M2 Kılıf ',
      aciklama:
          "Suya ve Toza Dayanıklı Tüm Macbook Air M2 Modelleri için Kılıf",
      fiyat: 249.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.aksesuar,
      stokAdedi: 24,
    ),
    Urun(
      id: 6,
      baslik: 'Airpods Pro 3. Nesil',
      aciklama: "Ses Kalitesiyle Öne Çıkan Airpods Pro 3. Nesil",
      fiyat: 7999.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.elektronik,
      stokAdedi: 33,
    ),
    Urun(
      id: 7,
      baslik: 'Samsung Galaxy Watch 5',
      aciklama: "Samsung'un suya ve toza dayanıklı akıllı saati Samsung Galaxy Watch 5",
      fiyat: 11249.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.elektronik,
      stokAdedi: 44,
    ),
    Urun(
      id: 8,
      baslik: 'Unisex Kışlık Mont',
      aciklama: "Sıcak Tutuan Unisex Kışlık Mont",
      fiyat: 1499.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.giyim,
      stokAdedi: 77,
    ),
    Urun(
      id: 9,
      baslik: 'Kadın Deri Ceket',
      aciklama: "Premium Deri Ceket",
      fiyat: 1299.99,
      resimUrl: "https://picsum.photos/400/400",
      kategori: Kategori.giyim,
      stokAdedi: 14,
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
