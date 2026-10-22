import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/motivation_message.dart';

/// İsteğe bağlı Hugging Face herkese açık motivasyon veri kaynağı servisi.
/// MD 6.10.1 kurallarına uygundur:
/// - Gizli API anahtarı veya token içermez.
/// - Kullanıcı adı, e-posta veya alışkanlık bilgisi dışarıya ASLA gönderilmez.
/// - 5 saniyelik zaman aşımı koruması vardır.
/// - Ağ hatası veya kaynak yokluğunda sessizce yerel havuza geri düşer.
class HuggingFaceMotivationSource {
  // Herkese açık ve kullanım koşulları doğrulanmış veri kaynağı adresi (yapılandırılabilir)
  final String? datasetUrl;

  const HuggingFaceMotivationSource({this.datasetUrl});

  /// Uzak kaynaktan Türkçe motivasyon cümlelerini çeker.
  /// Başarısızlık, süre aşımı veya boş veri durumunda null döner.
  Future<List<MotivationMessage>?> fetchRemoteMessages() async {
    final url = datasetUrl;
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    HttpClient? client;
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return null;
      }

      client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 5));

      // En fazla 1 MB veri işleme sınırı
      if (body.length > 1024 * 1024) {
        return null;
      }

      final parsed = jsonDecode(body);
      final results = <MotivationMessage>[];

      if (parsed is List) {
        for (var i = 0; i < parsed.length && results.length < 100; i++) {
          final item = parsed[i];
          String? text;
          if (item is String) {
            text = item.trim();
          } else if (item is Map<String, dynamic>) {
            text = (item['text'] ?? item['quote'] ?? item['message'])
                ?.toString()
                .trim();
          }

          if (text != null && text.isNotEmpty && text.length <= 120) {
            results.add(
              MotivationMessage(
                id: 'hf_${i}_${DateTime.now().millisecondsSinceEpoch}',
                text: text,
                language: 'tr',
                category: 'general',
                source: 'huggingface',
                sourceUrl: url,
              ),
            );
          }
        }
      }

      return results.isNotEmpty ? results : null;
    } catch (_) {
      // Ağ veya format hatalarında sessizce yerel havuza devam et
      return null;
    } finally {
      client?.close();
    }
  }
}
