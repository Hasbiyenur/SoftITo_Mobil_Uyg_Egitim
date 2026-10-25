import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../datasources/hive_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final HiveStorageService _storage;
  static const _uuid = Uuid();
  static const String _currentUserKey = 'current_user';
  static const String _usersListKey = 'all_registered_users';
  static const String _demoSeededKey = 'is_demo_user_seeded_v1';

  AuthRepository({HiveStorageService? storage})
    : _storage = storage ?? HiveStorageService.instance;

  /// Seeds default demo user only on first app run if not seeded yet.
  /// If the demo account was subsequently deleted by user, it will never be re-seeded.
  Future<void> initDefaultDemoUserIfNeeded() async {
    final isSeeded =
        _storage.settingsBox.get(_demoSeededKey, defaultValue: false) as bool;
    if (isSeeded) return;

    final usersListRaw = _storage.userBox.get(_usersListKey);
    final bool hasUsers = usersListRaw is List && usersListRaw.isNotEmpty;
    if (!hasUsers) {
      final defaultDemo = createDemoUser();
      final users = [defaultDemo.toMap()];
      await _storage.userBox.put(_usersListKey, users);
    }
    await _storage.settingsBox.put(_demoSeededKey, true);
  }

  List<UserModel> getAllRegisteredUsers() {
    final usersListRaw = _storage.userBox.get(_usersListKey);
    if (usersListRaw is List) {
      return usersListRaw
          .whereType<Map>()
          .map((u) => UserModel.fromMap(Map<dynamic, dynamic>.from(u)))
          .toList();
    }
    return [];
  }

  UserModel? getCurrentUser() {
    final data = _storage.userBox.get(_currentUserKey);
    if (data == null) return null;
    return UserModel.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const AuthFailure('Lütfen e-posta ve şifrenizi giriniz.');
    }

    final users = getAllRegisteredUsers();

    // Look for matching user strictly by registered email
    UserModel? matchingUser;
    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) {
        matchingUser = user;
        break;
      }
    }

    if (matchingUser == null) {
      throw const AuthFailure(
        'Kayıtlı hesap bulunamadı. Lütfen bilgilerinizi kontrol ediniz veya kayıt olunuz.',
      );
    }

    if (matchingUser.password != trimmedPassword) {
      throw const AuthFailure('Hatalı şifre. Lütfen tekrar deneyiniz.');
    }

    await _storage.userBox.put(_currentUserKey, matchingUser.toMap());
    return matchingUser;
  }

  Future<UserModel> register(UserModel user) async {
    final usersListRaw = _storage.userBox.get(_usersListKey);
    List<Map<dynamic, dynamic>> users = [];
    if (usersListRaw is List) {
      users = List<Map<dynamic, dynamic>>.from(usersListRaw);
    }

    // Check if email already registered, replace or append
    users.removeWhere(
      (u) => (u['email'] as String?)?.toLowerCase() == user.email.toLowerCase(),
    );
    users.add(user.toMap());

    await _storage.userBox.put(_usersListKey, users);
    await _storage.userBox.put(_currentUserKey, user.toMap());
    return user;
  }

  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await register(updatedUser);
    return updatedUser;
  }

  Future<UserModel> updateHabits(HabitsModel habits) async {
    final current = getCurrentUser();
    if (current == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');
    final updated = current.copyWith(habits: habits);
    return await updateProfile(updated);
  }

  Future<UserModel> addAddress(AddressModel address) async {
    final current = getCurrentUser();
    if (current == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');
    final list = List<AddressModel>.from(current.addresses)..add(address);
    final updated = current.copyWith(addresses: list);
    return await updateProfile(updated);
  }

  Future<UserModel> removeAddress(String addressId) async {
    final current = getCurrentUser();
    if (current == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');
    final list = List<AddressModel>.from(current.addresses)
      ..removeWhere((a) => a.id == addressId);
    final updated = current.copyWith(addresses: list);
    return await updateProfile(updated);
  }

  Future<UserModel> saveCard(SavedCardModel card) async {
    final current = getCurrentUser();
    if (current == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');
    final list = List<SavedCardModel>.from(current.savedCards)
      ..removeWhere((c) => c.maskedNumber == card.maskedNumber)
      ..add(card);
    final updated = current.copyWith(savedCards: list);
    return await updateProfile(updated);
  }

  Future<UserModel> removeCard(String cardId) async {
    final current = getCurrentUser();
    if (current == null) throw Exception('Oturum açmış kullanıcı bulunamadı.');
    final list = List<SavedCardModel>.from(current.savedCards)
      ..removeWhere((c) => c.id == cardId);
    final updated = current.copyWith(savedCards: list);
    return await updateProfile(updated);
  }

  Future<void> logout() async {
    await _storage.userBox.delete(_currentUserKey);
  }

  Future<void> deleteAccount() async {
    final current = getCurrentUser();
    if (current != null) {
      final usersListRaw = _storage.userBox.get(_usersListKey);
      if (usersListRaw is List) {
        final users = List<Map<dynamic, dynamic>>.from(usersListRaw);
        users.removeWhere((u) {
          final idMatch = u['id'] != null && u['id'] == current.id;
          final emailMatch = (u['email'] as String?)?.trim().toLowerCase() ==
              current.email.trim().toLowerCase();
          return idMatch || emailMatch;
        });
        await _storage.userBox.put(_usersListKey, users);
      }

      // If this user had an active rental, clear active rental id
      final activeRentalId =
          _storage.settingsBox.get('active_rental_id') as String?;
      if (activeRentalId != null) {
        final rentalData = _storage.rentalsBox.get(activeRentalId);
        if (rentalData is Map && rentalData['tenantId'] == current.id) {
          await _storage.settingsBox.delete('active_rental_id');
        }
      }
    }
    await _storage.userBox.delete(_currentUserKey);
  }

  static UserModel createDemoUser({
    String? email,
    String? fullName,
    String? password,
    bool isStudent = true,
  }) {
    return UserModel(
      id: _uuid.v4(),
      fullName: fullName ?? 'Deniz Kaya',
      email: email ?? 'deniz.kaya@roomio.demo',
      password: password ?? '123456',
      phone: '+90 544 123 45 67',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      age: 22,
      gender: 'Erkek',
      occupation: 'Yazılım Mühendisliği Öğrencisi',
      isStudent: isStudent,
      city: 'İstanbul',
      district: 'Kadıköy',
      hasCriminalRecordDoc: true,
      hasStudentDoc: true,
      habits: const HabitsModel(
        smoking: false,
        hasPets: true,
        sleepHabit: 'Gece',
        cleanliness: 'Çok',
        languages: ['Türkçe', 'İngilizce'],
      ),
      addresses: const [
        AddressModel(
          id: 'addr-1',
          title: 'Evim',
          city: 'İstanbul',
          district: 'Kadıköy',
          addressDetail: 'Moda Cad. No:44 D:5',
        ),
      ],
      savedCards: const [
        SavedCardModel(
          id: 'card-1',
          cardHolder: 'DENIZ KAYA',
          maskedNumber: '•••• •••• •••• 5821',
          expiry: '09/28',
          cardType: 'Mastercard',
        ),
      ],
      createdAt: DateTime.now(),
    );
  }
}
