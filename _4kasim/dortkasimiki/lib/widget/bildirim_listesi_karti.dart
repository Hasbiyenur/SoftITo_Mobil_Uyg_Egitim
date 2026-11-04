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
                      color: Color(0xFFF172A),
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
                      color: Color.fromARGB(255, 26, 40, 52),
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
                    // Listenin yüksekliğini içeriğinin gerektirdiği kadar tutar.
                    shrinkWrap: true, // Listenin yüksekliğini içeriğinin gerektirdiği kadar tutar.
                    physics: const NeverScrollableScrollPhysics(), // Listenin kendi içinde kaydırılmasını engeller.
                    itemCount: bildirimler.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                    ), // Öğeler arasına 1 birim yüksekliğinde ayırıcı ekler.
                    itemBuilder: (context, index) {},
                  ),
          ],
        ),
      ),
    );
  }
}
