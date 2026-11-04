import 'dart:io'; // Cihazdaki dosyaları temsil eden File sınıfını kullanıma açar.

import 'package:image_picker/image_picker.dart';

class MedyaSecicisiServisi {
  // Galeriden ve kameradan görsel alma işlemlerini yöneten sınıfı tanımlar.
  final ImagePicker _picker = ImagePicker();

  Future<File?> galeridenSec() async {
    // Galeriden seçilen görseli File olarak, seçim iptal edilirse null olarak döndürür.
    final XFile? secilen = await _picker.pickImage(
      // Görsel seçiminin tamamlanmasını bekler ve sonucu null olabilen XFile değişkeninde saklar.
      source: ImageSource
          .gallery, // Görsel kaynağı olarak cihazın galerisini kullanır.
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (secilen == null) return null;
    return File(
      secilen.path,
    ); // Seçilen görselin dosya yolundan bir File nesnesi oluşturup döndürür.
  }

  Future<File?> kameradanCek() async {
    // Kamerayla çekilen fotoğrafı File olarak, çekim iptal edilirse null olarak döndürür.
    final XFile? cekilen = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (cekilen == null) return null;
    return File(
      cekilen.path,
    ); // Çekilen fotoğrafın dosya yolundan bir File nesnesi oluşturup döndürür.
  }
}
