import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageServisi{  // Dosya yükleme işlemlerini yöneten servis sınıfını tanımlar.
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UploadTask yuklemeBaslat({  // Dosya yüklemesini başlatır ve takip edilebilen bir UploadTask döndürür.
    required File dosya,
    required String hedefDizin,
    required String dosyaAdi,
  }){
    final Reference ref= _storage.ref().child('$hedefDizin/$dosyaAdi');  // Hedef klasör ve dosya adından Storage dosya referansını oluşturur.
    final metadata= SettableMetadata(  // Dosyayla birlikte saklanacak tür ve özel bilgileri tanımlar.
      contentType: 'image/jpeg',
      customMetadata: {'yukleyen':'Faik Fahri Fuat Furkan tek kişilik dev kadro'},
    );
    return ref.putFile(dosya,metadata);
  }
  task.snapshot.listen((TaskSnapshot snapshot){   // Yükleme durumundaki değişiklikleri snapshotEvents akışı üzerinden dinler.
    final double yuzde= snapshot.bytesTransferred / snapshot.totalBytes;  
    print('Yükleniyor %${(yuzde * 100).toStringAsFixed(1)}');  // Yükleme yüzdesini virgülden sonra bir basamakla konsola yazdırır.
  })
}