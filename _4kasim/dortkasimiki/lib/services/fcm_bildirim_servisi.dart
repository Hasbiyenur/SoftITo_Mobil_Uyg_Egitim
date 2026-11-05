import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; //gerekli kütüphaneler yükleniyor

// Firebase Cloud Messaging (FCM) paketini projeye dahil eder.

@pragma(
  'vm:entry-point',
) // Arka plan fonksiyonunun derleme sırasında kaldırılmasını engeller.
Future<void> fcmBackgroundHandler(RemoteMessage message) async {}

class FcmBildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> baslat({
    // Bildirim izinlerini, ayarlarını ve mesaj dinleyicilerini hazırlar.
    required Function(RemoteMessage message) onMesajGeldi,
  }) async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    ); // Kullanıcıdan görsel bildirim, rozet ve ses izni ister.

    const androidSettings = AndroidInitializationSettings(
      // Android bildirimlerinde kullanılacak varsayılan simgeyi ayarlar.
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localPlugin.initialize(initSettings);
    FirebaseMessaging.onMessage.listen((message) {
      _yerelBildirimGoster(message);
      onMesajGeldi(message);
    });
    FirebaseMessaging.onBackgroundMessage(
      fcmBackgroundHandler,
    ); // Arka plan mesajlarını karşılayacak fonksiyonu kaydeder.
  }

  Future<String?> tokenAl() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> konuyaAboneOl(String konu) async {
    await _fcm.subscribeToTopic(konu);
  }

  Future<void> konudanAyril(String konu) async {
    await _fcm.unsubscribeFromTopic(konu);
  }

  Future<void> _yerelBildirimGoster(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      // Android bildirim kanalını ve bildirim ayarlarını tanımlar.
      'softito_fcm_channel_id',
      'Softito bildirimleri',
      channelDescription: 'FCM Push Bildirimleri',
      importance: Importance.max, // Kanalın önem seviyesini en yükseğe ayarlar.
      priority: Priority.high, // Bildirimin önceliğini yüksek olarak ayarlar.
    );

    const details = NotificationDetails(
      // Android ve iOS için bildirim ayrıntılarını birleştirir.
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _localPlugin.show(
      // Belirtilen kimlik, başlık, içerik ve ayarlarla yerel bildirimi gösterir.
      message.hashCode,
      message.notification?.title ?? 'Yeni Bildirim',
      message.notification?.body ?? '',
      details,
    );
  }
}
