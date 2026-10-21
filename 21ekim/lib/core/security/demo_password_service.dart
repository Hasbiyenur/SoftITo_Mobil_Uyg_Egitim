import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// PBKDF2 tabanlı yerel demo parola hash ve doğrulama servisi.
/// Açık metin parolaları asla JSON dokümanında, loglarda veya bellekte saklamaz.
class DemoPasswordService {
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 10000,
    bits: 256,
  );

  /// Rastgele 16 baytlık tuz (salt) üretir ve hex string döner.
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verilen parola ve tuz ile PBKDF2-HMAC-SHA256 türetilmiş anahtarını (hex) hesaplar.
  Future<String> hashPassword(String password, String saltHex) async {
    final saltBytes = _hexToBytes(saltHex);
    final secretKey = SecretKey(utf8.encode(password));
    final derived = await _pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: saltBytes,
    );
    final bytes = await derived.extractBytes();
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Parola doğrulaması
  Future<bool> verifyPassword({
    required String password,
    required String saltHex,
    required String expectedHashHex,
  }) async {
    final calculatedHash = await hashPassword(password, saltHex);
    return _constantTimeEquals(calculatedHash, expectedHashHex);
  }

  List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final part = hex.substring(i, i + 2);
      result.add(int.parse(part, radix: 16));
    }
    return result;
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
