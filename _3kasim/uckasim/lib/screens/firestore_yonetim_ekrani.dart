import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ogrenci.dart';

class FirestoreYonetimEkrani extends StatefulWidget {
  const FirestoreYonetimEkrani({super.key});

  @override
  State<FirestoreYonetimEkrani> createState() => _FirestoreYonetimEkraniState();
}

class _FirestoreYonetimEkraniState extends State<FirestoreYonetimEkrani> {
  final FirestoreOgrenciServisi _servis = FirestoreOgrenciServisi();

  final TextEditingController _adSoyadKontrolcusu = TextEditingController();
  final TextEditingController _projeKontrolcusu = TextEditingController();
  final TextEditingController _notKontrolcusu = TextEditingController();

  @override
  void dispose() {
    _adSoyadKontrolcusu.dispose();
    _projeKontrolcusu.dispose();
    _notKontrolcusu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canlı Firestore Ekranı"),
        backgroundColor: Colors.amber.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _adSoyadKontrolcusu,
                  decoration: const InputDecoration(
                    labelText: "Öğrenci Adı Soyadı",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _projeKontrolcusu,
                        decoration: const InputDecoration(
                          labelText: 'Proje Adı',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _notKontrolcusu,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Not (0-100)",
                          prefixIcon: Icon(Icons.grade),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.brown,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: _yeniOgrenciKaydet,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("Buluta Kaydet"),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ogrenciler')
                  .orderBy('notu', descending: true)
                  .snapshots(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Bulut Hatası: ${snapshot.error}"),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Henüz bulutta kayıtlı öğrenci yoktur."),
                      );
                    }
                    final List<DocumentSnapshot> dokumanlar =
                        snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: dokumanlar.length,
                      itemBuilder: (context, index) {
                        final doc = dokumanlar[index];
                        final ogrenci = OgrenciModel.fromFireStore(doc);
                        return Dismissible(
                          key: Key(ogrenci.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _servis.ogrenciSil(ogrenci.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${ogrenci.adSoyad} buluttan silindi.',
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ogrenci.notu >= 80
                                  ? Colors.green
                                  : (ogrenci.notu >= 50
                                        ? Colors.orange
                                        : Colors.red),
                              child: Text(
                                '${ogrenci.notu}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              ogrenci.adSoyad,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Proje: ${ogrenci.projeAdi}'),
                            trailing: IconButton(
                              onPressed: () => _notGuncelleDialog(ogrenci),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _yeniOgrenciKaydet() async {
    final adSoyad = _adSoyadKontrolcusu.text.trim();
    final proje = _projeKontrolcusu.text.trim();
    final notu = int.tryParse(_notKontrolcusu.text.trim());

    if (adSoyad.isEmpty || proje.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ad soyad ve proje adını giriniz.'),
        ),
      );
      return;
    }
    if (notu == null || notu < 0 || notu > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('0 ile 100 arasında bir tam sayı giriniz.'),
        ),
      );
      return;
    }

    try {
      await _servis.ogrenciEkle(adSoyad: adSoyad, projeAdi: proje, notu: notu);
      if (!mounted) return;
      _adSoyadKontrolcusu.clear();
      _projeKontrolcusu.clear();
      _notKontrolcusu.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Öğrenci kaydedildi.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Öğrenci kaydedilemedi: $e')));
    }
  }

  Future<void> _notGuncelleDialog(OgrenciModel ogrenci) async {
    String yeniNotMetni = ogrenci.notu.toString();
    final yeniNot = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${ogrenci.adSoyad} - Not Güncelle'),
          content: TextFormField(
            initialValue: yeniNotMetni,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Yeni Not (0-100)'),
            onChanged: (deger) => yeniNotMetni = deger,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final not = int.tryParse(yeniNotMetni);
                if (not == null || not < 0 || not > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('0 ile 100 arasında bir not giriniz.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, not);
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
    if (yeniNot != null && mounted) {
      try {
        await _servis.ogrenciNotuGuncelle(ogrenci.id, yeniNot);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Not güncellenemedi: $e')));
      }
    }
  }
}

/*
Yapılacaklar
1 expanded içinde projeadı inputu açılacak
2 _notGuncelleDialog fonksiyonu yazılacak
3 sayfalar parse edilecek ve sistem çalışır hale getirilecek
4 yarın rastgele biri seçilip ekranında sınıfa gösterecek
*/
