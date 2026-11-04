import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class YerelBildirimYoneticisi {
  static final FlutterLocalNotificationsPlugin _yerelBildirim =
      FlutterLocalNotificationsPlugin();

  static Future<void> kurulum() async {
    // Sınıf üzerinden çağrılabilen asenkron bildirim kurulum metodunu tanımlar.
    const androidAyarlar = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // Android bildirimlerinde kullanılacak varsayılan simgeyi belirler.
    const iosAyarlar = DarwinInitializationSettings();
    const ayarlar = InitializationSettings(
      // Platformların başlangıç ayarlarını tek nesnede toplar.
      android: androidAyarlar,
      iOS: iosAyarlar,
    );
    await _yerelBildirim.initialize(settings: ayarlar); // Bildirim eklentisini belirtilen ayarlarla başlatır ve tamamlanmasını bekler.
  }

  static Future<void> bildirimGoster(RemoteMessage message) async {
    // Verilen Firebase mesajından yerel bildirim oluşturan asenkron metodu tanımlar.
    const androidDetay = AndroidNotificationDetails(
      // Android bildirim kanalını ve gösterim özelliklerini tanımlar.
      'softito_kanal_id',
      'Softito Bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const detaylar = NotificationDetails(
      android: androidDetay,
    ); // Gösterilecek bildirimin Android ayrıntılarını bir araya getirir.
    await _yerelBildirim.show(
      // Yerel bildirimi gösterir ve gösterme işleminin tamamlanmasını bekler.
      id: message.hashCode,
      title: message.notification?.title ?? 'Yeni Bildirim',
      body: message.notification?.body ?? '',
      notificationDetails: detaylar,
    );
  }
}
