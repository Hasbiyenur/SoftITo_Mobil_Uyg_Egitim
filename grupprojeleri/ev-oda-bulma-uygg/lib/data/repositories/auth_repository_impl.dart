import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// AuthRepository arayüzünün Hive yerel veritabanı ile çalışan somut uygulaması.
/// Kullanıcı oturum yönetimini, giriş/kayıt işlemlerini ve varsayılan demo kullanıcıyı yönetir.
class AuthRepositoryImpl implements AuthRepository {
  /// Hive veritabanındaki oturum ve kullanıcı kutusu adı
  static const String _boxName = 'auth_box';

  /// Aktif oturum bilgisinin saklandığı anahtar
  static const String _sessionKey = 'current_user_session';

  /// Kullanıcı kayıtlarının ayrıştırılması için anahtar ön eki
  static const String _usersPrefix = 'user_';

  /// Hive kutusuna erişim sağlayan yardımcı getter
  Box get _box => Hive.box(_boxName);

  /// Aktif oturum açmış kullanıcıyı yerel depolamadan getirir.
  @override
  Future<UserEntity?> getCurrentUser() async {
    _ensureDefaultUser(); // İlk çalıştırmada demo kullanıcıyı oluştur
    final String? sessionJson = _box.get(_sessionKey) as String?;
    if (sessionJson == null) {
      return null;
    }
    try {
      final map = jsonDecode(sessionJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// İlk kurulumda test ve inceleme amaçlı varsayılan demo kullanıcıyı (Betül Yılmaz) oluşturur.
  void _ensureDefaultUser() {
    const defaultUser = UserModel(
      id: 'user-demo-1',
      name: 'Betül Yılmaz',
      email: 'betul@example.com',
      phone: '05551234567',
      password: 'password123',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      age: 21,
      gender: 'Kadın',
      occupation: 'Yazılım Mühendisliği Öğrencisi',
      isStudent: true,
      smoking: false,
      hasPet: true,
      sleepSchedule: 'gece',
      cleaningSensitivity: 'çok',
      languages: ['Türkçe', 'İngilizce'],
      city: 'İstanbul',
      district: 'Kadıköy',
      preferredHouseType: '2+1 Daire',
      savedAddresses: ['Moda Cad. No: 42 D: 5 Kadıköy/İstanbul'],
      savedPaymentCard: {
        'cardNumber': '**** **** **** 4242',
        'cardHolder': 'Betül Yılmaz',
        'expiryDate': '12/28',
      },
    );

    final jsonStr = jsonEncode(defaultUser.toJson());
    // Kolay giriş yapabilmek için hem e-posta, hem isim anahtarlarıyla indekslenir
    _box.put('$_usersPrefix${defaultUser.email.toLowerCase()}', jsonStr);
    _box.put('$_usersPrefix${defaultUser.name.toLowerCase()}', jsonStr);
    _box.put('${_usersPrefix}betul', jsonStr);
  }

  /// Kullanıcı girişi: E-posta veya ad soyad ile eşleşen kullanıcıyı arar ve şifresini doğrular.
  @override
  Future<UserEntity> login(String emailOrUsername, String password) async {
    _ensureDefaultUser();
    final trimmed = emailOrUsername.trim().toLowerCase();

    // 1. Doğrudan anahtar bazlı arama
    String? userJson = _box.get('$_usersPrefix$trimmed') as String?;

    // 2. Kutu içerisindeki tüm kullanıcılar arasında tarama
    if (userJson == null) {
      for (var key in _box.keys) {
        if (key.toString().startsWith(_usersPrefix)) {
          final item = _box.get(key) as String?;
          if (item != null) {
            try {
              final map = jsonDecode(item) as Map<String, dynamic>;
              final email = (map['email'] as String? ?? '').toLowerCase();
              final name = (map['name'] as String? ?? '').toLowerCase();
              if (email == trimmed || name == trimmed) {
                userJson = item;
                break;
              }
            } catch (_) {}
          }
        }
      }
    }

    // Kullanıcı bulunduysa şifre kontrolü yapılır
    if (userJson != null) {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(map);
      if (user.password == password) {
        // Oturumu kalıcı olarak kaydet
        await _box.put(_sessionKey, jsonEncode(user.toJson()));
        return user;
      } else {
        throw Exception('Hatalı şifre girdiniz.');
      }
    }

    throw Exception('Kullanıcı bulunamadı. Lütfen kayıt olun.');
  }

  /// Yeni kullanıcı kaydını oluşturur ve oturumunu başlatır.
  @override
  Future<UserEntity> register(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    final userJson = jsonEncode(userModel.toJson());
    // E-posta ile indekslenerek kaydedilir
    await _box.put('$_usersPrefix${user.email.trim().toLowerCase()}', userJson);
    // Aktif oturum olarak ayarlanır
    await _box.put(_sessionKey, userJson);
    return userModel;
  }

  /// Kullanıcı profil bilgilerini günceller ve oturum bilgisini tazeler.
  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    final userJson = jsonEncode(userModel.toJson());
    await _box.put('$_usersPrefix${user.email.trim().toLowerCase()}', userJson);
    await _box.put(_sessionKey, userJson);
    return userModel;
  }

  /// Kullanıcı oturumunu kapatır (session kaydını siler).
  @override
  Future<void> logout() async {
    await _box.delete(_sessionKey);
  }

  /// Kullanıcının oturumunu ve veritabanındaki kaydını siler.
  @override
  Future<void> deleteAccount() async {
    final String? sessionJson = _box.get(_sessionKey) as String?;
    if (sessionJson != null) {
      final map = jsonDecode(sessionJson) as Map<String, dynamic>;
      final email = map['email'] as String? ?? '';
      await _box.delete('$_usersPrefix${email.toLowerCase()}');
    }
    await _box.delete(_sessionKey);
  }
}
