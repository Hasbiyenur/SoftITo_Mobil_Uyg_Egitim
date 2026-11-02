import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/booking.dart';
import '../models/vehicle.dart';

class AppState extends ChangeNotifier {
  final List<Vehicle> _vehicles = [];
  final List<Booking> _bookings = [];
  final Set<String> _favoriteVehicleIds = {};

  final String currentUserId = demoUserId;
  final String currentUserFirstName = demoUserFirstName;
  final String currentUserLastName = demoUserLastName;

  ThemeMode _themeMode = ThemeMode.system;

  AppState() {
    _initData();
  }

  void _initData() {
    _vehicles.addAll(initialVehicles);
    _bookings.addAll(getInitialBookings());
    // Örnek başlangıç favorileri
    _favoriteVehicleIds.addAll(['v_2', 'v_3']);
  }

  // Getters
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  Set<String> get favoriteVehicleIds => Set.unmodifiable(_favoriteVehicleIds);
  ThemeMode get themeMode => _themeMode;
  String get currentUserName => '$currentUserFirstName $currentUserLastName';

  // Tema Yönetimi
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // Favori Yönetimi
  bool isFavorite(String vehicleId) => _favoriteVehicleIds.contains(vehicleId);

  void toggleFavorite(String vehicleId) {
    if (_favoriteVehicleIds.contains(vehicleId)) {
      _favoriteVehicleIds.remove(vehicleId);
    } else {
      _favoriteVehicleIds.add(vehicleId);
    }
    notifyListeners();
  }

  // Araç Yönetimi
  void addVehicle(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  bool canDeleteVehicle(String vehicleId) {
    // Kural: Rezervasyonu bulunan araç silinemez
    return !_bookings.any((b) => b.vehicleId == vehicleId);
  }

  bool deleteVehicle(String vehicleId) {
    if (!canDeleteVehicle(vehicleId)) {
      return false;
    }
    _vehicles.removeWhere((v) => v.id == vehicleId);
    _favoriteVehicleIds.remove(vehicleId);
    notifyListeners();
    return true;
  }

  // Rezervasyon Yönetimi ve Çakışma Kontrolü
  // Formül: yeniBaşlangıç < mevcutBitiş && yeniBitiş > mevcutBaşlangıç
  bool hasBookingConflict(
    String vehicleId,
    DateTime newStart,
    DateTime newEnd, {
    String? excludeBookingId,
  }) {
    return _bookings.any((b) {
      if (b.vehicleId != vehicleId) return false;
      if (b.isCancelled) return false;
      if (excludeBookingId != null && b.id == excludeBookingId) return false;

      final isOverlap = newStart.isBefore(b.endAt) && newEnd.isAfter(b.startAt);
      return isOverlap;
    });
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = old.copyWith(isCancelled: true);
      notifyListeners();
    }
  }

  // Profil için Filtrelenmiş Listeler
  List<Vehicle> get myVehicles =>
      _vehicles.where((v) => v.ownerId == currentUserId).toList();

  List<Vehicle> get favoriteVehicles =>
      _vehicles.where((v) => _favoriteVehicleIds.contains(v.id)).toList();

  // Kiralanan Araçlarım: Benim başkasından rezervasyon yapıp kiraladığım araçlar
  List<Booking> get myRentals =>
      _bookings.where((b) => b.renterId == currentUserId).toList();

  // Araçlarımın Kiralamaları: Sahibi olduğum araçlara başkalarının yaptığı rezervasyonlar
  List<Booking> get myVehicleBookings => _bookings
      .where((b) => b.ownerId == currentUserId && b.renterId != currentUserId)
      .toList();

  // Arama ve Filtreleme (Birden çok aktif filtre VE / AND mantığıyla çalışır)
  List<Vehicle> filterVehicles({
    String? type,
    String? brand,
    String? model,
    String? location,
    double? maxHourlyPrice,
    String? color,
  }) {
    return _vehicles.where((v) {
      if (type != null && type.trim().isNotEmpty && type != 'Tümü') {
        if (v.type.toLowerCase() != type.trim().toLowerCase()) {
          return false;
        }
      }
      if (brand != null && brand.trim().isNotEmpty) {
        if (!v.brand.toLowerCase().contains(brand.trim().toLowerCase())) {
          return false;
        }
      }
      if (model != null && model.trim().isNotEmpty) {
        if (!v.model.toLowerCase().contains(model.trim().toLowerCase())) {
          return false;
        }
      }
      if (location != null && location.trim().isNotEmpty) {
        if (!v.location.toLowerCase().contains(location.trim().toLowerCase())) {
          return false;
        }
      }
      if (color != null && color.trim().isNotEmpty) {
        if (!v.color.toLowerCase().contains(color.trim().toLowerCase())) {
          return false;
        }
      }
      if (maxHourlyPrice != null && maxHourlyPrice > 0) {
        if (v.hourlyPrice > maxHourlyPrice) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

/// Standart Flutter InheritedNotifier: Ek paket gerektirmeden
/// tüm alt widget'ların AppState'e erişmesini ve notifyListeners() ile otomatik güncellenmesini sağlar.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'Context içerisinde AppStateScope bulunamadı.');
    return scope!.notifier!;
  }
}
