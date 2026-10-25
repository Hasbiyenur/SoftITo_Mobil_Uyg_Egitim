import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roomie_app/core/error/failures.dart';
import 'package:roomie_app/core/utils/app_constants.dart';
import 'package:roomie_app/data/datasources/hive_storage_service.dart';
import 'package:roomie_app/data/models/listing_model.dart';
import 'package:roomie_app/data/models/rental_model.dart';
import 'package:roomie_app/data/repositories/listing_repository.dart';
import 'package:roomie_app/data/repositories/rental_repository.dart';

void main() {
  late Directory tempDir;
  late RentalRepository rentalRepository;
  late ListingRepository listingRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    final storage = HiveStorageService.instance;
    storage.userBox = await Hive.openBox(AppConstants.boxUser);
    storage.listingsBox = await Hive.openBox(AppConstants.boxListings);
    storage.favoritesBox = await Hive.openBox(AppConstants.boxFavorites);
    storage.rentalsBox = await Hive.openBox(AppConstants.boxRentals);
    storage.chatsBox = await Hive.openBox(AppConstants.boxChats);
    storage.feedbacksBox = await Hive.openBox(AppConstants.boxFeedbacks);
    storage.settingsBox = await Hive.openBox(AppConstants.boxSettings);

    listingRepository = ListingRepository(storage: storage);
    rentalRepository = RentalRepository(
      storage: storage,
      listingRepository: listingRepository,
    );

    // Seed a listing
    final listing = ListingModel(
      id: 'listing-001',
      title: 'Kadıköy Oda',
      description: 'Test oda',
      monthlyPrice: 15000.0,
      city: 'İstanbul',
      district: 'Kadıköy',
      neighborhood: 'Moda',
      images: const ['image.jpg'],
      owner: const ListingOwnerModel(
        id: 'owner-1',
        fullName: 'Ev Sahibi',
        age: 26,
        gender: 'Kadın',
        occupation: 'Yazılımcı',
        phone: '+90 532 000 00 00',
      ),
      createdAt: DateTime.now(),
    );
    await listingRepository.saveListing(listing);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Rental Business Logic & Acceptance Criteria Tests', () {
    test(
      'user can book rental successfully when they have no active rental',
      () async {
        expect(rentalRepository.hasActiveRental(), isFalse);

        final booking = RentalModel(
          id: 'rental-101',
          listingId: 'listing-001',
          listingTitle: 'Kadıköy Oda',
          listingImage: 'image.jpg',
          city: 'İstanbul',
          district: 'Kadıköy',
          ownerId: 'owner-1',
          ownerName: 'Ev Sahibi',
          ownerPhone: '+90 532 000 00 00',
          tenantId: 'tenant-1',
          tenantName: 'Deniz Kaya',
          tenantGender: 'Erkek',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          guestCount: 1,
          originalDays: 30,
          monthlyPrice: 15000.0,
          grossAmount: 15000.0,
          studentDiscountAmount: 3000.0,
          winterDiscountAmount: 0.0,
          totalPaid: 12000.0,
          status: 'active',
          createdAt: DateTime.now(),
        );

        final saved = await rentalRepository.bookRental(booking);
        expect(saved.status, 'active');
        expect(rentalRepository.hasActiveRental(), isTrue);

        final active = rentalRepository.getActiveRental();
        expect(active, isNotNull);
        expect(active!.id, 'rental-101');
      },
    );

    test('enforces single active rental: throws RentalRuleFailure on 2nd rental booking', () async {
      final booking1 = RentalModel(
        id: 'rental-1',
        listingId: 'listing-001',
        listingTitle: 'Kadıköy Oda',
        listingImage: 'image.jpg',
        city: 'İstanbul',
        district: 'Kadıköy',
        ownerId: 'owner-1',
        ownerName: 'Ev Sahibi',
        ownerPhone: '+90 532 000 00 00',
        tenantId: 'tenant-1',
        tenantName: 'Deniz Kaya',
        tenantGender: 'Erkek',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        guestCount: 1,
        originalDays: 30,
        monthlyPrice: 15000.0,
        grossAmount: 15000.0,
        studentDiscountAmount: 0.0,
        winterDiscountAmount: 0.0,
        totalPaid: 15000.0,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await rentalRepository.bookRental(booking1);
      expect(rentalRepository.hasActiveRental(), isTrue);

      // Attempting 2nd booking must be blocked in business logic layer
      final booking2 = booking1.copyWith(id: 'rental-2');
      expect(
        () async => await rentalRepository.bookRental(booking2),
        throwsA(isA<RentalRuleFailure>()),
      );
    });

    test('enforces checkout photo requirement: throws ValidationFailure if photo is missing', () async {
      final booking = RentalModel(
        id: 'rental-photo-test',
        listingId: 'listing-001',
        listingTitle: 'Kadıköy Oda',
        listingImage: 'image.jpg',
        city: 'İstanbul',
        district: 'Kadıköy',
        ownerId: 'owner-1',
        ownerName: 'Ev Sahibi',
        ownerPhone: '+90 532 000 00 00',
        tenantId: 'tenant-1',
        tenantName: 'Deniz Kaya',
        tenantGender: 'Erkek',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        guestCount: 1,
        originalDays: 30,
        monthlyPrice: 15000.0,
        grossAmount: 15000.0,
        studentDiscountAmount: 0.0,
        winterDiscountAmount: 0.0,
        totalPaid: 15000.0,
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      await rentalRepository.bookRental(booking);

      // Empty photo path must throw ValidationFailure
      expect(
        () async => await rentalRepository.completeEarlyCheckout(
          rentalId: 'rental-photo-test',
          checkoutPhotoPath: '',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'early checkout calculates refund correctly and moves rental to history',
      () async {
        final startDate = DateTime.now().subtract(const Duration(days: 10));
        final endDate = startDate.add(const Duration(days: 30));

        final booking = RentalModel(
          id: 'rental-refund-test',
          listingId: 'listing-001',
          listingTitle: 'Kadıköy Oda',
          listingImage: 'image.jpg',
          city: 'İstanbul',
          district: 'Kadıköy',
          ownerId: 'owner-1',
          ownerName: 'Ev Sahibi',
          ownerPhone: '+90 532 000 00 00',
          tenantId: 'tenant-1',
          tenantName: 'Deniz Kaya',
          tenantGender: 'Erkek',
          startDate: startDate,
          endDate: endDate,
          guestCount: 1,
          originalDays: 30,
          monthlyPrice: 15000.0, // daily 500
          grossAmount: 15000.0,
          studentDiscountAmount: 0.0,
          winterDiscountAmount: 0.0,
          totalPaid: 15000.0,
          status: 'active',
          createdAt: startDate,
        );

        await rentalRepository.bookRental(booking);
        expect(rentalRepository.hasActiveRental(), isTrue);

        // Checkout now (after 10 days) with valid photo
        final checkoutResult = await rentalRepository.completeEarlyCheckout(
          rentalId: 'rental-refund-test',
          checkoutPhotoPath: 'https://images.unsplash.com/sample_checkout.jpg',
          exitTime: DateTime.now(),
        );

        // Stayed 10 days = 10 * 500 = 5000 charged
        expect(checkoutResult.daysStayed, 10);
        expect(checkoutResult.chargedAmount, 5000.0);
        // Refund = 15000 - 5000 = 10000
        expect(checkoutResult.refundAmount, 10000.0);

        // Active rental must now be cleared
        expect(rentalRepository.hasActiveRental(), isFalse);
        expect(rentalRepository.getActiveRental(), isNull);

        // Must be present in history
        final history = rentalRepository.getRentalHistory();
        expect(history.length, 1);
        expect(history.first.id, 'rental-refund-test');
        expect(history.first.isCompleted, isTrue);
        expect(history.first.checkoutPhotoPath, isNotNull);
      },
    );
  });
}
