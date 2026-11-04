import 'package:firebase_messaging/firebase_messaging.dart';

// Arka plan fonksiyonunu derlemede korur; fonksiyon sınıf dışında olmalıdır
@pragma('vm:entry-point') //bu tüm classlardan önce sayfanın en üstünde bulunması zorundadır. koda hakim olabilmek için
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka plan mesajlarını işlemek için kullanılabilecek üst düzey asenkron fonksiyonu tanımlar.
  print("Arka Planda Bildirim Geldi: ${message.notification?.title}");
}

class BildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance; // Varsayılan Firebase Messaging nesnesini kütüphaneye özel ve yeniden atanamaz bir alanda saklar.
  Future<void> baslat() async {
    NotificationSettings setting = await _fcm.requestPermission(
      // Bildirim izni isteğinin sonucunu setting değişkeninde saklar.
      alert: true,
      badge: true,
      sound: true,
    );
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      // Kullanıcının bildirim iznini tam olarak verip vermediğini kontrol eder.
      print("Kullanıcı Bildirim İznini Verdi!");
    }
    final token = await _fcm.getToken(); // Bu uygulama kurulumuna bildirim göndermek için kullanılabilen FCM tokenini alır.
    print('Cihazın FCM Tokenı: $token');
  }
}
