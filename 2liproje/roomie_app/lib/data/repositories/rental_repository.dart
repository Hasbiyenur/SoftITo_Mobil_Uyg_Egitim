import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../../core/utils/image_storage_helper.dart';
import '../datasources/hive_storage_service.dart';
import '../models/rental_model.dart';
import 'listing_repository.dart';

class EarlyCheckoutResult {
  final RentalModel completedRental;
  final int daysStayed;
  final double chargedAmount;
  final double refundAmount;

  const EarlyCheckoutResult({
    required this.completedRental,
    required this.daysStayed,
    required this.chargedAmount,
    required this.refundAmount,
  });
}

class RentalRepository {
  final HiveStorageService _storage;
  final ListingRepository _listingRepository;
  static const _uuid = Uuid();
  static const String _activeRentalKey = 'active_rental_id';

  RentalRepository({
    HiveStorageService? storage,
    ListingRepository? listingRepository,
  }) : _storage = storage ?? HiveStorageService.instance,
       _listingRepository =
           listingRepository ?? ListingRepository(storage: storage);

  bool hasActiveRental({String? tenantId}) {
    return getActiveRental(tenantId: tenantId) != null;
  }

  RentalModel? getActiveRental({String? tenantId}) {
    if (tenantId != null && tenantId.isNotEmpty) {
      final all = getAllRentals();
      for (final r in all) {
        if (r.tenantId == tenantId && r.isActive) {
          return r;
        }
      }
      return null;
    }
    final activeId = _storage.settingsBox.get(_activeRentalKey) as String?;
    if (activeId == null || activeId.isEmpty) return null;
    final rental = getRentalById(activeId);
    if (rental != null && rental.isActive) {
      return rental;
    }
    return null;
  }

  RentalModel? getRentalById(String id) {
    final data = _storage.rentalsBox.get(id);
    if (data is Map) {
      return RentalModel.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  List<RentalModel> getAllRentals() {
    final List<RentalModel> list = [];
    for (var key in _storage.rentalsBox.keys) {
      final data = _storage.rentalsBox.get(key);
      if (data is Map) {
        list.add(RentalModel.fromMap(Map<dynamic, dynamic>.from(data)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<RentalModel> getRentalHistory({String? tenantId}) {
    final history = getAllRentals().where((r) => r.isCompleted).toList();
    if (tenantId != null && tenantId.isNotEmpty) {
      return history.where((r) => r.tenantId == tenantId).toList();
    }
    return history;
  }

  List<RentalModel> getRentalsGivenByOwner(String ownerId) {
    return getAllRentals().where((r) => r.ownerId == ownerId).toList();
  }

  /// Creates a new booking.
  /// Enforces validation on tenant/listing IDs, duration, owner restrictions,
  /// single active rental business rule, and protects against half-records on failure.
  Future<RentalModel> bookRental(RentalModel rental) async {
    // 1. Mandatory IDs validation
    if (rental.tenantId.trim().isEmpty) {
      throw const ValidationFailure('Kiralama işlemi için geçerli bir kiracı bilgisi zorunludur.');
    }
    if (rental.listingId.trim().isEmpty) {
      throw const ValidationFailure('Kiralama işlemi için geçerli bir ilan seçilmelidir.');
    }

    // 2. Cannot rent own listing
    if (rental.ownerId.isNotEmpty && rental.tenantId == rental.ownerId) {
      throw const RentalRuleFailure('Kendi ilanınızı kiralayamazsınız.');
    }

    // 3. Verify listing exists and is not already rented
    final listing = _listingRepository.getListingById(rental.listingId);
    if (listing != null) {
      if (listing.status == 'rented') {
        throw const RentalRuleFailure('Bu ilan zaten kiralanmış durumdadır.');
      }
      if (listing.owner.id.isNotEmpty && listing.owner.id == rental.tenantId) {
        throw const RentalRuleFailure('Kendi ilanınızı kiralayamazsınız.');
      }
    }

    // 4. Validate dates and duration
    if (rental.endDate.isBefore(rental.startDate) ||
        rental.endDate.isAtSameMomentAs(rental.startDate)) {
      throw const ValidationFailure('Çıkış tarihi giriş tarihinden sonra olmalıdır.');
    }
    final days = rental.endDate.difference(rental.startDate).inDays;
    if (days < 1) {
      throw const ValidationFailure('Kiralama süresi en az 1 gün olmalıdır.');
    }

    // 5. Enforce single active rental rule for this tenant
    if (hasActiveRental(tenantId: rental.tenantId)) {
      throw const RentalRuleFailure(
        'Zaten aktif bir kiralamanız bulunmaktadır. Yeni bir kiralama yapabilmek için lütfen mevcut kiralamanızdan çıkış yapınız.',
      );
    }

    // 6. Pricing sanity validation
    if (rental.monthlyPrice <= 0 || rental.totalPaid < 0) {
      throw const ValidationFailure('Geçersiz ücret veya kiralama tutarı.');
    }

    final id = rental.id.isNotEmpty ? rental.id : _uuid.v4();
    final newRental = rental.copyWith(
      id: id,
      originalDays: days,
      status: 'active',
    );

    // Save rental with transactional rollback protection
    try {
      await _storage.rentalsBox.put(newRental.id, newRental.toMap());
      await _storage.settingsBox.put(_activeRentalKey, newRental.id);
      await _listingRepository.updateListingStatus(newRental.listingId, 'rented');
    } catch (e) {
      // Rollback to prevent half-records
      await _storage.rentalsBox.delete(newRental.id);
      final currentActive = _storage.settingsBox.get(_activeRentalKey);
      if (currentActive == newRental.id) {
        await _storage.settingsBox.delete(_activeRentalKey);
      }
      throw StorageFailure('Kiralama kaydedilirken bir hata oluştu: ${e.toString()}');
    }

    return newRental;
  }

  /// Completes rental and early checkout.
  /// Enforces mandatory checkout photo requirement.
  /// Calculates actual stay duration and demo refund.
  Future<EarlyCheckoutResult> completeEarlyCheckout({
    required String rentalId,
    required String checkoutPhotoPath,
    DateTime? exitTime,
  }) async {
    final rental = getRentalById(rentalId);
    if (rental == null) {
      throw const StorageFailure('Kiralama kaydı bulunamadı.');
    }

    if (checkoutPhotoPath.trim().isEmpty) {
      throw const ValidationFailure(
        'Evden çıkış yapabilmek için evin son halinin fotoğrafını yüklemek zorunludur.',
      );
    }

    final now = exitTime ?? DateTime.now();
    // Calculate actual days stayed (minimum 1 day)
    final diffDays = now.difference(rental.startDate).inDays;
    final int actualDays = diffDays < 1
        ? 1
        : (diffDays > rental.originalDays ? rental.originalDays : diffDays);

    // Daily rate based on monthly price / 30
    final dailyRate = rental.monthlyPrice / 30.0;
    final grossCharged = dailyRate * actualDays;

    final studentDiscount = rental.isStudentDiscountApplied
        ? (grossCharged * 0.20)
        : 0.0;
    final winterDiscount = rental.isWinterDiscountApplied
        ? (grossCharged * 0.20)
        : 0.0;
    final actualCharged = grossCharged - studentDiscount - winterDiscount;

    final double refund = (rental.totalPaid - actualCharged) > 0
        ? (rental.totalPaid - actualCharged)
        : 0.0;

    // Permanently save checkout photo in app documents
    final permanentPhotoPath = await ImageStorageHelper.saveImagePermanently(
      checkoutPhotoPath,
    );

    final completed = rental.copyWith(
      status: 'completed',
      checkoutDate: now,
      actualDaysStayed: actualDays,
      actualChargedAmount: actualCharged,
      refundAmount: refund,
      checkoutPhotoPath: permanentPhotoPath,
    );

    await _storage.rentalsBox.put(completed.id, completed.toMap());
    await _storage.settingsBox.delete(_activeRentalKey);

    // Re-activate listing
    await _listingRepository.updateListingStatus(completed.listingId, 'active');

    return EarlyCheckoutResult(
      completedRental: completed,
      daysStayed: actualDays,
      chargedAmount: actualCharged,
      refundAmount: refund,
    );
  }
}
