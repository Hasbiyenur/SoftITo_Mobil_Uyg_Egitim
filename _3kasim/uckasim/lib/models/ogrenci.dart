import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class OgrenciModel {
  final String id;
  final String adSoyad;
  final String projeAdi;
  final int notu;
  final DateTime kayitTarihi;

  const OgrenciModel({
    required this.id,
    required this.adSoyad,
    required this.projeAdi,
    required this.notu,
    required this.kayitTarihi,
  });

  factory OgrenciModel.fromFireStore(DocumentSnapshot doc) {
    final veri = doc.data() as Map<String, dynamic>? ?? {};
    return OgrenciModel(
      id: doc.id,
      adSoyad: veri['adSoyad'] as String? ?? "İsimsiz Öğrenci Hasbiyenur",
      projeAdi:
          veri['projeAdi'] as String? ?? "Henüz Hasbiyenur'un Projesi Yok",
      notu: (veri['notu'] as num?)?.toInt() ?? 0,
      kayitTarihi:
          (veri['kayitTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FirestoreOgrenciServisi {
  final CollectionReference _ogrencilerKoleksiyonu = FirebaseFirestore.instance
      .collection('ogrenciler');

  Future<void> ogrenciEkle({
    required String adSoyad,
    required String projeAdi,
    required int notu,
  }) async {
    try {
      await _ogrencilerKoleksiyonu.add({
        'adSoyad': adSoyad,
        'projeAdi': projeAdi,
        'notu': notu,
        'kayitTarihi': FieldValue.serverTimestamp(),
      });
      print("Öğrenci Başarıyla Kaydedildi");
    } catch (e) {
      print("Öğrenci Ekleme Başarısız: $e");
      rethrow;
    }
  }

  Future<void> ogrenciIdIleKaydet({
    //PUT ve Güncelleme
    required String tcNo,
    required String adSoyad,
    required String projeAdi,
  }) async {
    await _ogrencilerKoleksiyonu.doc(tcNo).set(
      {
        //id (tcNo)ye göre veri çekiyor ve set ile güncelleme ve ekleme işlemini aynı anda yapıyor
        'adSoyad': adSoyad,
        'projeAdi': projeAdi,
        'guncellemeTarihi': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    ); //güncellenen veriler ile eskiler birleşir yoksa diğerlerini yok sayar
  }

  Future<List<OgrenciModel>> tumOgrencileriGetir() async {
    try {
      final QuerySnapshot snapshot = await _ogrencilerKoleksiyonu
          .orderBy('notu', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OgrenciModel.fromFireStore(doc))
          .toList();
    } catch (e) {
      print("Veri Çekme Hatası: $e");
      return [];
    }
  }

  Future<void> ogrenciNotuGuncelle(String documentId, int yeniNot) async {
    await _ogrencilerKoleksiyonu.doc(documentId).update({
      'notu': yeniNot,
      'sonDuzenleme': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ogrenciSil(String documentId) async {
    await _ogrencilerKoleksiyonu.doc(documentId).delete();
    print('$documentId referanslı veri tamamen silindi');
  }
}
