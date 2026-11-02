import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'store_document.dart';

/// SharedPreferencesAsync kullanarak yerel JSON saklama ve okuma servisi.
/// Tek anahtar ('habit_tracker_store_v1') kullanır, diğer sistem anahtarlarına dokunmaz.
class LocalStore {
  static const String storeKey = 'habit_tracker_store_v1';

  final SharedPreferencesAsync _prefs;
  StoreDocument? _cachedDocument;

  LocalStore({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  /// Depolanmış dokümanı okur, yoksa boş doküman başlatıp kaydeder.
  Future<StoreDocument> load() async {
    try {
      final raw = await _prefs.getString(storeKey);
      if (raw == null || raw.trim().isEmpty) {
        final initial = const StoreDocument();
        _cachedDocument = initial;
        await save(initial);
        return initial;
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final doc = StoreDocument.fromJson(map);
      _cachedDocument = doc;
      return doc;
    } catch (e, st) {
      debugPrint(
        'LocalStore.load hatası, varsayılan doküman dönülüyor: $e\n$st',
      );
      final fallback = const StoreDocument();
      _cachedDocument = fallback;
      return fallback;
    }
  }

  /// Güncel dokümanı yerel depoya kaydeder.
  Future<void> save(StoreDocument doc) async {
    _cachedDocument = doc;
    try {
      final jsonString = jsonEncode(doc.toJson());
      await _prefs.setString(storeKey, jsonString);
    } catch (e, st) {
      debugPrint('LocalStore.save hatası: $e\n$st');
    }
  }

  /// Bellekteki son bilinen doküman
  StoreDocument get cached => _cachedDocument ?? const StoreDocument();
}
