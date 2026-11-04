import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point') //bu tüm classlardan önce sayfanın en üstünde bulunması zorundadır. koda hakim olabilmek için
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Arka Planda Bildirim Geldi: ${message.notification?.title}");
}

class BildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> baslat() async {
    NotificationSettings setting = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      print("Kullanıcı Bildirim İznini Verdi!");
    }
    final token = await _fcm.getToken();
    print('Cihazın FCM Tokenı: $token');
  }
}
