import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageServisi {
  // Görsel seçme, yükleme, bağlantı alma ve silme işlemlerini yöneten sınıfı tanımlar.
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> gorselSec({bool kameradan = false}) async {
    // Kamera veya galeriden görsel seçer ve seçim iptal edilirse null döndürür
    final XFile? xFile = await _picker.pickImage(
      // Görsel seçme işlemini bekler ve sonucu XFile türünde saklar.
      source: kameradan ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile == null) return null;
    return File(
      xFile.path,
    ); // Seçilen görselin yolundan bir File nesnesi oluşturup döndürür.
  }

  UploadTask yuklemeBaslat({
    // Dosya yüklemesini başlatır ve ilerlemesi takip edilebilen bir UploadTask döndürür.
    required File dosya,
    required String dosyaAdi,
    String klasor =
        'yuklenmeler', // Klasör belirtilmezse yuklenmeler klasörünü kullanır.
  }) {
    final Reference ref = _storage.ref().child('$klasor/$dosyaAdi');
    final metadata = SettableMetadata(
      contentType: 'image/png', // Dosyayı PNG olarak etiketler ancak dosyanın biçimini dönüştürmez.
      customMetadata: {'ekleyen': 'Hasbiyenur'},
    );
    return ref.putFile(
      dosya,
      metadata,
    ); // Dosyayı ek bilgileriyle yüklemeye başlar ve yükleme görevini döndürür.
  }

  Future<String> urlGetir(Reference ref) async {
    // Verilen Storage referansına ait indirme bağlantısını döndüren metodu tanımlar.
    return await ref.getDownloadURL();
  }

  Future<void> dosyaSil(String dosyaYolu) async {
    final Reference ref = _storage.ref().child(
      dosyaYolu,
    ); // Silinecek dosyanın Storage referansını oluşturur.
    await ref.delete();
  }
}
