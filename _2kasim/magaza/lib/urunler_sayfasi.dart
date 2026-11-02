import 'package:flutter/material.dart';

import 'tekrar4_katmanli_mimari.dart';

// UrunModel ve CanliApiUrunServisi sınıflarının olduğu dosyayı ekle.
// import 'urun_servisi.dart';

class UrunlerSayfasi extends StatefulWidget {
  const UrunlerSayfasi({super.key});

  @override
  State<UrunlerSayfasi> createState() => _UrunlerSayfasiState();
}

class _UrunlerSayfasiState extends State<UrunlerSayfasi> {
  final IUrunServisi _urunServisi = CanliApiUrunServisi();
  late final Future<List<UrunModel>> _urunler;

  @override
  void initState() {
    super.initState();
    _urunler = _urunServisi.urunleriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünler')),
      body: FutureBuilder<List<UrunModel>>(
        future: _urunler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ürünler yüklenemedi: ${snapshot.error}'),
            );
          }

          final urunler = snapshot.data ?? [];

          if (urunler.isEmpty) {
            return const Center(child: Text('Ürün bulunamadı.'));
          }

          return ListView.builder(
            itemCount: urunler.length,
            itemBuilder: (context, index) {
              final urun = urunler[index];

              return ListTile(
                leading: Image.network(
                  urun.resimUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.broken_image),
                    );
                  },
                ),
                title: Text(urun.baslik),
                subtitle: Text(urun.kategori),
                trailing: Text('\$${urun.fiyat.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
