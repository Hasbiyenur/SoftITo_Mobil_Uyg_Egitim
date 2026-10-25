import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roomie_app/core/utils/app_constants.dart';
import 'package:roomie_app/data/datasources/hive_storage_service.dart';
import 'package:roomie_app/data/models/listing_model.dart';
import 'package:roomie_app/data/models/rental_model.dart';
import 'package:roomie_app/data/repositories/listing_repository.dart';
import 'package:roomie_app/data/repositories/rental_repository.dart';
import 'package:roomie_app/presentation/bloc/rental_bloc.dart';

void main() {
  late Directory tempDir;
  late HiveStorageService storage;
  late ListingRepository listingRepository;
  late RentalRepository rentalRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rental_history_test_');
    Hive.init(tempDir.path);

    storage = HiveStorageService.instance;
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
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  RentalModel createTestRental({
    required String id,
    required String listingId,
    required String tenantId,
    String status = 'active',
  }) {
    final now = DateTime.now();
    return RentalModel(
      id: id,
      listingId: listingId,
      listingTitle: 'Kadıköy 2+1 Oda',
      listingImage: 'https://example.com/image.jpg',
      city: 'İstanbul',
      district: 'Kadıköy',
      ownerId: 'owner-1',
      ownerName: 'Ali Demir',
      ownerPhone: '+90 555 123 4567',
      tenantId: tenantId,
      tenantName: 'Deniz Kaya',
      tenantGender: 'Erkek',
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 25)),
      guestCount: 1,
      originalDays: 30,
      monthlyPrice: 15000.0,
      grossAmount: 15000.0,
      studentDiscountAmount: 0.0,
      winterDiscountAmount: 0.0,
      totalPaid: 15000.0,
      status: status,
      createdAt: now.subtract(const Duration(days: 5)),
    );
  }

  ListingModel createTestListing(String id) {
    return ListingModel(
      id: id,
      title: 'Kadıköy 2+1 Oda',
      description: 'Geniş ferah oda',
      monthlyPrice: 15000.0,
      city: 'İstanbul',
      district: 'Kadıköy',
      neighborhood: 'Moda',
      images: const ['https://example.com/image.jpg'],
      owner: const ListingOwnerModel(
        id: 'owner-1',
        fullName: 'Ali Demir',
        age: 30,
        gender: 'Erkek',
        occupation: 'Mühendis',
        phone: '+90 555 123 4567',
      ),
      status: 'active',
      createdAt: DateTime.now(),
    );
  }

  group('Rental History & Active Rental Separation Flow', () {
    test('1. Newly booked rental is active and NOT in rental history', () async {
      final listing = createTestListing('listing-1');
      await listingRepository.saveListing(listing);

      final rentalBloc = RentalBloc(rentalRepository: rentalRepository);

      final rental = createTestRental(
        id: 'rental-1',
        listingId: 'listing-1',
        tenantId: 'user-100',
      );

      rentalBloc.add(BookRentalEvent(rental));
      await expectLater(
        rentalBloc.stream,
        emitsInOrder([
          isA<RentalActionSuccess>(),
          isA<RentalLoaded>()
              .having((s) => s.activeRental?.id, 'activeRental.id', equals('rental-1'))
              .having((s) => s.hasActiveRental, 'hasActiveRental', isTrue)
              .having((s) => s.rentalHistory.isEmpty, 'rentalHistory.isEmpty', isTrue),
        ]),
      );

      // Verify Hive repository state
      expect(rentalRepository.hasActiveRental(tenantId: 'user-100'), isTrue);
      expect(rentalRepository.getRentalHistory(tenantId: 'user-100'), isEmpty);

      await rentalBloc.close();
    });

    test('2. Completed early checkout moves rental to history with photo and clears active', () async {
      final listing = createTestListing('listing-2');
      await listingRepository.saveListing(listing);

      final rentalBloc = RentalBloc(rentalRepository: rentalRepository);
      final rental = createTestRental(
        id: 'rental-2',
        listingId: 'listing-2',
        tenantId: 'user-200',
      );

      await rentalRepository.bookRental(rental);

      // Complete early checkout with photo
      rentalBloc.add(
        const CompleteEarlyCheckoutEvent(
          rentalId: 'rental-2',
          checkoutPhotoPath: 'https://images.unsplash.com/sample_checkout.jpg',
        ),
      );

      await expectLater(
        rentalBloc.stream,
        emitsInOrder([
          isA<RentalActionSuccess>().having(
            (s) => s.checkoutResult?.completedRental.isCompleted,
            'isCompleted',
            isTrue,
          ),
          isA<RentalLoaded>()
              .having((s) => s.activeRental, 'activeRental', isNull)
              .having((s) => s.hasActiveRental, 'hasActiveRental', isFalse)
              .having((s) => s.rentalHistory.length, 'rentalHistory.length', equals(1))
              .having((s) => s.rentalHistory.first.id, 'rentalHistory.first.id', equals('rental-2'))
              .having((s) => s.rentalHistory.first.isCompleted, 'isCompleted', isTrue),
        ]),
      );

      // Check repository directly
      expect(rentalRepository.hasActiveRental(tenantId: 'user-200'), isFalse);
      final history = rentalRepository.getRentalHistory(tenantId: 'user-200');
      expect(history.length, equals(1));
      expect(history.first.id, equals('rental-2'));
      expect(history.first.status, equals('completed'));

      await rentalBloc.close();
    });

    test('3. App restart preserves completed rentals in history for user', () async {
      final listing = createTestListing('listing-3');
      await listingRepository.saveListing(listing);

      final rental = createTestRental(
        id: 'rental-3',
        listingId: 'listing-3',
        tenantId: 'user-300',
      );
      await rentalRepository.bookRental(rental);
      await rentalRepository.completeEarlyCheckout(
        rentalId: 'rental-3',
        checkoutPhotoPath: 'https://images.unsplash.com/sample_checkout.jpg',
      );

      // Simulate app restart: fresh RentalBloc dispatched with user-300
      final restartedBloc = RentalBloc(rentalRepository: rentalRepository);
      restartedBloc.add(const LoadRentalsEvent('user-300'));

      await expectLater(
        restartedBloc.stream,
        emitsInOrder([
          isA<RentalLoading>(),
          isA<RentalLoaded>()
              .having((s) => s.activeRental, 'activeRental', isNull)
              .having((s) => s.rentalHistory.length, 'rentalHistory.length', equals(1))
              .having((s) => s.rentalHistory.first.id, 'history.id', equals('rental-3')),
        ]),
      );

      await restartedBloc.close();
    });

    test('4. Multi-account isolation: User A and User B rental histories remain isolated', () async {
      final listingA = createTestListing('listing-4a');
      final listingB = createTestListing('listing-4b');
      await listingRepository.saveListing(listingA);
      await listingRepository.saveListing(listingB);

      // User A books and completes
      final rentalA = createTestRental(
        id: 'rental-4a',
        listingId: 'listing-4a',
        tenantId: 'user-a',
      );
      await rentalRepository.bookRental(rentalA);
      await rentalRepository.completeEarlyCheckout(
        rentalId: 'rental-4a',
        checkoutPhotoPath: 'https://images.unsplash.com/sample_checkout.jpg',
      );

      // User B books and completes
      final rentalB = createTestRental(
        id: 'rental-4b',
        listingId: 'listing-4b',
        tenantId: 'user-b',
      );
      await rentalRepository.bookRental(rentalB);
      await rentalRepository.completeEarlyCheckout(
        rentalId: 'rental-4b',
        checkoutPhotoPath: 'https://images.unsplash.com/sample_checkout.jpg',
      );

      // Query User A
      final historyA = rentalRepository.getRentalHistory(tenantId: 'user-a');
      expect(historyA.length, equals(1));
      expect(historyA.first.id, equals('rental-4a'));

      // Query User B
      final historyB = rentalRepository.getRentalHistory(tenantId: 'user-b');
      expect(historyB.length, equals(1));
      expect(historyB.first.id, equals('rental-4b'));

      // Bloc with User A
      final blocA = RentalBloc(rentalRepository: rentalRepository);
      blocA.add(const LoadRentalsEvent('user-a'));
      await expectLater(
        blocA.stream,
        emitsInOrder([
          isA<RentalLoading>(),
          isA<RentalLoaded>()
              .having((s) => s.rentalHistory.length, 'rentalHistory.length', equals(1))
              .having((s) => s.rentalHistory.first.tenantId, 'tenantId', equals('user-a')),
        ]),
      );
      await blocA.close();
    });

    test('5. ClearRentalsEvent clears state cleanly on logout', () async {
      final bloc = RentalBloc(rentalRepository: rentalRepository);
      bloc.add(const ClearRentalsEvent());

      await expectLater(
        bloc.stream,
        emits(
          isA<RentalLoaded>()
              .having((s) => s.activeRental, 'activeRental', isNull)
              .having((s) => s.rentalHistory, 'rentalHistory', isEmpty),
        ),
      );
      await bloc.close();
    });
  });
}
