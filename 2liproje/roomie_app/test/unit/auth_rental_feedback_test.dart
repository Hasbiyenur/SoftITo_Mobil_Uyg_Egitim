import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:roomie_app/core/error/failures.dart';
import 'package:roomie_app/core/utils/app_constants.dart';
import 'package:roomie_app/data/datasources/hive_storage_service.dart';
import 'package:roomie_app/data/models/listing_model.dart';
import 'package:roomie_app/data/models/rental_model.dart';
import 'package:roomie_app/data/models/user_model.dart';
import 'package:roomie_app/data/repositories/auth_repository.dart';
import 'package:roomie_app/data/repositories/feedback_repository.dart';
import 'package:roomie_app/data/repositories/listing_repository.dart';
import 'package:roomie_app/data/repositories/rental_repository.dart';

void main() {
  late Directory tempDir;
  late HiveStorageService storage;
  late AuthRepository authRepository;
  late ListingRepository listingRepository;
  late RentalRepository rentalRepository;
  late FeedbackRepository feedbackRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_regression_test_');
    Hive.init(tempDir.path);

    storage = HiveStorageService.instance;
    storage.userBox = await Hive.openBox(AppConstants.boxUser);
    storage.listingsBox = await Hive.openBox(AppConstants.boxListings);
    storage.favoritesBox = await Hive.openBox(AppConstants.boxFavorites);
    storage.rentalsBox = await Hive.openBox(AppConstants.boxRentals);
    storage.chatsBox = await Hive.openBox(AppConstants.boxChats);
    storage.feedbacksBox = await Hive.openBox(AppConstants.boxFeedbacks);
    storage.settingsBox = await Hive.openBox(AppConstants.boxSettings);

    authRepository = AuthRepository(storage: storage);
    listingRepository = ListingRepository(storage: storage);
    rentalRepository = RentalRepository(
      storage: storage,
      listingRepository: listingRepository,
    );
    feedbackRepository = FeedbackRepository(storage: storage);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  UserModel buildTestUser({
    required String id,
    required String fullName,
    required String email,
    required String password,
  }) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      password: password,
      phone: '+90 532 000 00 00',
      avatar: 'https://example.com/avatar.jpg',
      age: 25,
      gender: 'Kadın',
      occupation: 'Mimar',
      isStudent: false,
      city: 'İstanbul',
      district: 'Kadıköy',
      hasCriminalRecordDoc: true,
      hasStudentDoc: false,
      habits: const HabitsModel(
        smoking: false,
        hasPets: true,
        sleepHabit: 'Gece',
        cleanliness: 'Çok',
        languages: ['Türkçe', 'İngilizce'],
      ),
      createdAt: DateTime.now(),
    );
  }

  RentalModel buildTestRental({
    required String id,
    required String listingId,
    required String ownerId,
    required String tenantId,
    required DateTime startDate,
    required DateTime endDate,
    double monthlyPrice = 12000.0,
    double totalPaid = 12000.0,
  }) {
    return RentalModel(
      id: id,
      listingId: listingId,
      listingTitle: 'Test İlan',
      listingImage: 'image.jpg',
      city: 'İstanbul',
      district: 'Beşiktaş',
      ownerId: ownerId,
      ownerName: 'Ev Sahibi',
      ownerPhone: '+90 532 000 00 00',
      tenantId: tenantId,
      tenantName: 'Kiracı',
      tenantGender: 'Erkek',
      startDate: startDate,
      endDate: endDate,
      guestCount: 1,
      originalDays: endDate.difference(startDate).inDays,
      monthlyPrice: monthlyPrice,
      grossAmount: monthlyPrice,
      studentDiscountAmount: 0.0,
      winterDiscountAmount: 0.0,
      totalPaid: totalPaid,
      status: 'active',
      createdAt: DateTime.now(),
    );
  }

  group('Issue 3: Login Authentication Validations', () {
    test('unregistered account login throws AuthFailure with Turkish message', () async {
      expect(
        () => authRepository.login(
          email: 'unknown@test.com',
          password: 'password123',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            contains('Kayıtlı hesap bulunamadı'),
          ),
        ),
      );
      expect(authRepository.getCurrentUser(), isNull);
    });

    test('wrong password login throws AuthFailure with Turkish message', () async {
      final user = buildTestUser(
        id: 'user-001',
        fullName: 'Ahmet Yılmaz',
        email: 'ahmet@test.com',
        password: 'correctPassword1',
      );
      await authRepository.register(user);

      expect(
        () => authRepository.login(
          email: 'ahmet@test.com',
          password: 'wrongPassword',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            contains('Hatalı şifre'),
          ),
        ),
      );
    });

    test('correct credentials succeed and update current session', () async {
      final user = buildTestUser(
        id: 'user-002',
        fullName: 'Zeynep Kaya',
        email: 'zeynep@test.com',
        password: 'securePassword12',
      );
      await authRepository.register(user);

      final loggedIn = await authRepository.login(
        email: 'zeynep@test.com',
        password: 'securePassword12',
      );
      expect(loggedIn.id, equals('user-002'));
      expect(loggedIn.email, equals('zeynep@test.com'));
      expect(authRepository.getCurrentUser()?.id, equals('user-002'));
    });

    test('switching accounts updates session cleanly without leaking prior user', () async {
      final userA = buildTestUser(
        id: 'user-a',
        fullName: 'User A',
        email: 'usera@test.com',
        password: 'passwordA',
      );
      final userB = buildTestUser(
        id: 'user-b',
        fullName: 'User B',
        email: 'userb@test.com',
        password: 'passwordB',
      );
      await authRepository.register(userA);
      await authRepository.register(userB);

      await authRepository.login(email: 'usera@test.com', password: 'passwordA');
      expect(authRepository.getCurrentUser()?.id, equals('user-a'));

      await authRepository.logout();
      expect(authRepository.getCurrentUser(), isNull);

      await authRepository.login(email: 'userb@test.com', password: 'passwordB');
      expect(authRepository.getCurrentUser()?.id, equals('user-b'));
    });
  });

  group('Issue 4: Account Deletion & Persistence Across Restarts', () {
    test('deleting account removes user permanently and prevents re-login', () async {
      final user = buildTestUser(
        id: 'user-del-1',
        fullName: 'Mehmet Demir',
        email: 'mehmet@test.com',
        password: 'mypassword1',
      );
      await authRepository.register(user);
      await authRepository.login(email: 'mehmet@test.com', password: 'mypassword1');

      expect(authRepository.getCurrentUser()?.id, equals('user-del-1'));

      await authRepository.deleteAccount();

      // Active session cleared
      expect(authRepository.getCurrentUser(), isNull);

      // Cannot login with deleted account
      expect(
        () => authRepository.login(email: 'mehmet@test.com', password: 'mypassword1'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('re-registering after deletion creates a fresh account', () async {
      final user = buildTestUser(
        id: 'user-del-2',
        fullName: 'Canan Öz',
        email: 'canan@test.com',
        password: 'cananpassword',
      );
      await authRepository.register(user);
      await authRepository.login(email: 'canan@test.com', password: 'cananpassword');
      await authRepository.deleteAccount();

      // Registering fresh account with same email succeeds
      final newUser = buildTestUser(
        id: 'user-del-2-new',
        fullName: 'Canan Yeni',
        email: 'canan@test.com',
        password: 'newpassword123',
      );
      await authRepository.register(newUser);

      final loggedIn = await authRepository.login(
        email: 'canan@test.com',
        password: 'newpassword123',
      );
      expect(loggedIn.id, equals('user-del-2-new'));
      expect(loggedIn.fullName, equals('Canan Yeni'));
    });

    test('default demo user deletion persists across app restarts (never auto-revived)', () async {
      // First boot seeds demo user
      await authRepository.initDefaultDemoUserIfNeeded();
      final demo = await authRepository.login(
        email: 'deniz.kaya@roomio.demo',
        password: '123456',
      );
      expect(demo.email, equals('deniz.kaya@roomio.demo'));

      // User deletes account
      await authRepository.deleteAccount();
      expect(authRepository.getCurrentUser(), isNull);

      // Simulated app restart: initDefaultDemoUserIfNeeded runs again
      await authRepository.initDefaultDemoUserIfNeeded();

      // Should still NOT be able to login (deleted account stays deleted)
      expect(
        () => authRepository.login(
          email: 'deniz.kaya@roomio.demo',
          password: 'demo1234',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('Issue 2: Hemen Kirala / Rental Validations & Multi-Account Isolation', () {
    late ListingModel testListing;

    setUp(() async {
      testListing = ListingModel(
        id: 'listing-100',
        title: 'Beşiktaş Oda',
        description: 'Güzel oda',
        monthlyPrice: 12000.0,
        city: 'İstanbul',
        district: 'Beşiktaş',
        neighborhood: 'Sinanpaşa',
        images: const ['besiktas.jpg'],
        owner: const ListingOwnerModel(
          id: 'owner-99',
          fullName: 'Ev Sahibi 99',
          age: 30,
          gender: 'Erkek',
          occupation: 'Mühendis',
          phone: '+90 530 000 00 00',
        ),
        createdAt: DateTime.now(),
      );
      await listingRepository.saveListing(testListing);
    });

    test('successful booking updates listing status to rented and saves rental', () async {
      final now = DateTime.now();
      final rental = buildTestRental(
        id: 'rental-501',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'tenant-1',
        startDate: now,
        endDate: now.add(const Duration(days: 90)),
      );

      final booked = await rentalRepository.bookRental(rental);
      expect(booked.id, equals('rental-501'));
      expect(booked.status, equals('active'));

      // Check listing status updated
      final updatedListing = listingRepository.getListingById('listing-100');
      expect(updatedListing?.status, equals('rented'));
      expect(updatedListing?.isRented, isTrue);

      // Check tenant has active rental
      expect(rentalRepository.hasActiveRental(tenantId: 'tenant-1'), isTrue);
    });

    test('tenant cannot rent their own listing', () async {
      final now = DateTime.now();
      final rental = buildTestRental(
        id: 'rental-502',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'owner-99', // same as owner!
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      expect(
        () => rentalRepository.bookRental(rental),
        throwsA(
          isA<RentalRuleFailure>().having(
            (e) => e.message,
            'message',
            contains('Kendi ilanınızı kiralayamazsınız'),
          ),
        ),
      );
    });

    test('cannot rent an already rented listing', () async {
      final now = DateTime.now();
      final rental1 = buildTestRental(
        id: 'rental-503',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'tenant-1',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );
      await rentalRepository.bookRental(rental1);

      final rental2 = buildTestRental(
        id: 'rental-504',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'tenant-2',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      expect(
        () => rentalRepository.bookRental(rental2),
        throwsA(
          isA<RentalRuleFailure>().having(
            (e) => e.message,
            'message',
            contains('kiralanmış'),
          ),
        ),
      );
    });

    test('multi-account isolation: User A active rental does not block User B', () async {
      // Create second listing
      final listing2 = ListingModel(
        id: 'listing-200',
        title: 'Kadıköy Oda 2',
        description: 'Aydınlık oda',
        monthlyPrice: 14000.0,
        city: 'İstanbul',
        district: 'Kadıköy',
        neighborhood: 'Moda',
        images: const ['moda.jpg'],
        owner: const ListingOwnerModel(
          id: 'owner-88',
          fullName: 'Ev Sahibi 88',
          age: 32,
          gender: 'Kadın',
          occupation: 'Tasarımcı',
          phone: '+90 535 000 00 00',
        ),
        createdAt: DateTime.now(),
      );
      await listingRepository.saveListing(listing2);

      final now = DateTime.now();
      // Tenant A rents listing-100
      final rentalA = buildTestRental(
        id: 'rental-a',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'tenant-a',
        startDate: now,
        endDate: now.add(const Duration(days: 60)),
      );
      await rentalRepository.bookRental(rentalA);

      expect(rentalRepository.hasActiveRental(tenantId: 'tenant-a'), isTrue);
      // Tenant B should NOT be blocked by Tenant A's active rental!
      expect(rentalRepository.hasActiveRental(tenantId: 'tenant-b'), isFalse);

      // Tenant B rents listing2 successfully
      final rentalB = buildTestRental(
        id: 'rental-b',
        listingId: 'listing-200',
        ownerId: 'owner-88',
        tenantId: 'tenant-b',
        startDate: now,
        endDate: now.add(const Duration(days: 60)),
        monthlyPrice: 14000.0,
      );
      final bookedB = await rentalRepository.bookRental(rentalB);
      expect(bookedB.id, equals('rental-b'));
      expect(rentalRepository.hasActiveRental(tenantId: 'tenant-b'), isTrue);
    });

    test('invalid rental dates are rejected', () async {
      final now = DateTime.now();
      final invalidRental = buildTestRental(
        id: 'rental-invalid-dates',
        listingId: 'listing-100',
        ownerId: 'owner-99',
        tenantId: 'tenant-3',
        startDate: now,
        endDate: now.subtract(const Duration(days: 1)), // End before start!
      );

      expect(
        () => rentalRepository.bookRental(invalidRental),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('tarihinden sonra olmalıdır'),
          ),
        ),
      );
    });
  });

  group('Issue 1: Feedback Validations & Storage', () {
    late UserModel fbUser;

    setUp(() {
      fbUser = buildTestUser(
        id: 'user-fb-1',
        fullName: 'Ahmet Test',
        email: 'ahmet.fb@test.com',
        password: 'password123',
      );
    });

    test('submitting feedback without category throws ValidationFailure', () async {
      expect(
        () => feedbackRepository.submitFeedback(
          user: fbUser,
          category: '', // Empty category
          message: 'Harika bir uygulama',
          rating: 5,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('konu başlığı'),
          ),
        ),
      );
    });

    test('submitting feedback with invalid rating throws ValidationFailure', () async {
      expect(
        () => feedbackRepository.submitFeedback(
          user: fbUser,
          category: 'Öneri',
          message: 'Mesajım',
          rating: 0, // Invalid: rating must be 1..5
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('1 ile 5 arasında'),
          ),
        ),
      );

      expect(
        () => feedbackRepository.submitFeedback(
          user: fbUser,
          category: 'Öneri',
          message: 'Mesajım',
          rating: 6, // Invalid
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('submitting feedback with empty message throws ValidationFailure', () async {
      expect(
        () => feedbackRepository.submitFeedback(
          user: fbUser,
          category: 'Şikayet',
          message: '   ', // Whitespace message
          rating: 4,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('geri bildirim mesajınızı'),
          ),
        ),
      );
    });

    test('submitting valid feedback persists in Hive and can be queried per-user', () async {
      final userA = buildTestUser(
        id: 'user-a',
        fullName: 'User A',
        email: 'a@test.com',
        password: 'pass',
      );
      final userB = buildTestUser(
        id: 'user-b',
        fullName: 'User B',
        email: 'b@test.com',
        password: 'pass',
      );

      final savedA = await feedbackRepository.submitFeedback(
        user: userA,
        category: 'Tasarım',
        message: 'Arayüz çok şık olmuş.',
        rating: 5,
      );
      final savedB = await feedbackRepository.submitFeedback(
        user: userB,
        category: 'Performans',
        message: 'Arama çok hızlı.',
        rating: 4,
      );

      expect(savedA.category, equals('Tasarım'));
      expect(savedB.category, equals('Performans'));

      // Query per user
      final userAFeedbacks = feedbackRepository.getAllFeedbacks(userId: 'user-a');
      expect(userAFeedbacks.length, equals(1));
      expect(userAFeedbacks.first.id, equals(savedA.id));

      final userBFeedbacks = feedbackRepository.getAllFeedbacks(userId: 'user-b');
      expect(userBFeedbacks.length, equals(1));
      expect(userBFeedbacks.first.id, equals(savedB.id));

      // Query all feedbacks
      final allFeedbacks = feedbackRepository.getAllFeedbacks();
      expect(allFeedbacks.length, equals(2));
    });
  });
}
