import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Şifre sıfırlama geçici bellek durumu
  String? _resetEmail;
  String? _demoResetCode;
  bool _isResetCodeVerified = false;

  AuthController({required this.repository});

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String? get resetEmail => _resetEmail;
  String? get demoResetCode => _demoResetCode;
  bool get isResetCodeVerified => _isResetCodeVerified;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void resetForgotState() {
    _resetEmail = null;
    _demoResetCode = null;
    _isResetCodeVerified = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await repository.getActiveUser();
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      _currentUser = await repository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _successMessage = 'Kaydın oluşturuldu. Şimdi giriş yapabilirsin.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestResetCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final code = await repository.generateResetCode(email);
      _resetEmail = email.trim().toLowerCase();
      _demoResetCode = code;
      _isResetCodeVerified = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool verifyResetCode(String code) {
    if (_resetEmail == null) {
      _errorMessage = 'Geçerli bir e-posta adresi bulunamadı.';
      notifyListeners();
      return false;
    }
    final valid = repository.verifyResetCode(_resetEmail!, code);
    if (valid) {
      _isResetCodeVerified = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Girdiğin kod hatalı veya 5 dakikalık süresi dolmuş.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    if (_resetEmail == null || !_isResetCodeVerified) {
      _errorMessage = 'Sıfırlama oturumu geçersiz.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.resetPassword(
        email: _resetEmail!,
        newPassword: newPassword,
      );
      _successMessage = 'Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.';
      resetForgotState();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.logout();
      _currentUser = null;
      resetForgotState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
