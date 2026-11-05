import 'package:flutter/material.dart';

import '../models/bildirim_modeli.dart';

class BildirimListesiKarti extends StatelessWidget {
  // Kendi içinde değişken durum tutmayan bir bildirim kartı bileşeni tanımlar
  final List<BildirimModeli> bildirimler;
  final String? token;
  final bool konuyaAboneMi;
  final ValueChanged<bool> onAboneDegisti;

  const BildirimListesiKarti({
    // Kart oluşturulurken gerekli verileri ve fonksiyonu alır.
    super.key,
    required this.bildirimler,
    required this.token,
    required this.konuyaAboneMi,
    required this.onAboneDegisti,
  });

  @override // Üst sınıftaki build metodunun yeniden tanımlandığını belirtir.
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Kartın yükselti gölgesini kaldırır.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ), // Kart içeriğinin her tarafına 16 birim boşluk ekler.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Çocukları yatayda kullanılabilir genişliğe yayar.
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined, // Çizgili aktif bildirim simgesini seçer.
                  color: Color(0xFF006C4A),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  // Başlığın satırdaki kalan yatay alanı kaplamasını sağlar.
                  child: Text(
                    'FCM Bildirim Merkezi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(17, 4, 50, 20),
                    ),
                  ),
                ),
                Switch(
                  value: konuyaAboneMi, // Anahtarın açık veya kapalı görünmesini belirler.
                  onChanged: onAboneDegisti,
                  activeColor: const Color.fromARGB(15, 160, 40, 50),
                ),
              ],
            ),
            Text(
              konuyaAboneMi ? 'üm sınıf yayını aktif' : 'Yayın Kapalı', // Abonelik açıksa ilk, kapalıysa ikinci metni gösterir.
              style: TextStyle(
                fontSize: 12,
                color: konuyaAboneMi
                    ? const Color.fromARGB(15, 24, 59, 17)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              // FCM tokenini göstermek için bir kutu oluşturur.
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // İçeriği yatay eksenin başlangıcına hizalar.
                children: [
                  const Text(
                    "Cihazın FCM Tokeni",
                    style: TextStyle(
                      color: Color.fromARGB(255, 98, 153, 201),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    token ?? 'token alınıyor',
                    style: const TextStyle(
                      color: Color(0xFF388888),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              // Gelen bildirimlerin sayısını başlıkta gösterir.
              'Gelen Bildirimler (${bildirimler.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromARGB(0, 5, 249, 253),
              ),
            ),
            const SizedBox(height: 8),
            bildirimler
                    .isEmpty // Liste boşsa bilgilendirme kutusunu, doluysa bildirim listesini gösterir.
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Henüz gelen bildirim yok',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : ListView.separated(
                    // liste doluysa aralarına ayırıcı koyarak elemanları listeler
                    shrinkWrap:
                        true, // listenin yüksekliğini içeriğine göre ayarlar
                    physics: const NeverScrollableScrollPhysics(), // listenin kendi içinde kaydırılmasını engeller
                    itemCount: bildirimler.length, // oluşturulacak liste elemanı sayısını belirler
                    separatorBuilder: (_, _) => const Divider(height: 1), // elemanların arasına 1 piksel yüksekliğinde ayırıcı ekler
                    itemBuilder: (context, index) {
                      // her bildirim için liste elemanı oluşturan fonksiyon
                      final b = bildirimler[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color.fromARGB(0, 123, 238, 230),
                          child: Icon(
                            Icons.mark_email_unread_outlined,
                            color: Color.fromARGB(150, 165, 19, 19),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          b.baslik,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(b.icerik),
                        trailing: Text(
                          '${b.tarih.hour.toString().padLeft(2, '0')} : ${b.tarih.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500, //uygulama çalışırken güncelleme yapılacağı için const kullanmıyorum aterial kütüphanesinin sözleşmelernde uyma konusu da var ??
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
