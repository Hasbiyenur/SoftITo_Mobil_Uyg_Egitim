import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:roomie_app/core/utils/app_constants.dart';
import 'package:roomie_app/data/datasources/hive_storage_service.dart';
import 'package:roomie_app/data/repositories/auth_repository.dart';
import 'package:roomie_app/data/repositories/chat_repository.dart';
import 'package:roomie_app/data/repositories/feedback_repository.dart';
import 'package:roomie_app/data/repositories/listing_repository.dart';
import 'package:roomie_app/data/repositories/rental_repository.dart';
import 'package:roomie_app/main.dart';
import 'package:roomie_app/presentation/screens/splash_screen.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await initializeDateFormatting('tr_TR');
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test_');
    Hive.init(tempDir.path);

    final storage = HiveStorageService.instance;
    storage.userBox = await Hive.openBox(AppConstants.boxUser);
    storage.listingsBox = await Hive.openBox(AppConstants.boxListings);
    storage.favoritesBox = await Hive.openBox(AppConstants.boxFavorites);
    storage.rentalsBox = await Hive.openBox(AppConstants.boxRentals);
    storage.chatsBox = await Hive.openBox(AppConstants.boxChats);
    storage.feedbacksBox = await Hive.openBox(AppConstants.boxFeedbacks);
    storage.settingsBox = await Hive.openBox(AppConstants.boxSettings);
    await storage.settingsBox.put('is_listings_seeded_v1', true);
    await storage.listingsBox.put('dummy', {
      'id': 'dummy',
      'monthlyPrice': 10000.0,
      'title': 'Test',
    });
  });

  testWidgets(
    'RoomioApp boots and renders SplashScreen with logo and branding',
    (WidgetTester tester) async {
      final storageService = HiveStorageService.instance;
      final authRepository = AuthRepository(storage: storageService);
      final listingRepository = ListingRepository(storage: storageService);
      final rentalRepository = RentalRepository(
        storage: storageService,
        listingRepository: listingRepository,
      );
      final chatRepository = ChatRepository(storage: storageService);
      final feedbackRepository = FeedbackRepository(storage: storageService);

      await tester.pumpWidget(
        RoomioApp(
          authRepository: authRepository,
          listingRepository: listingRepository,
          rentalRepository: rentalRepository,
          chatRepository: chatRepository,
          feedbackRepository: feedbackRepository,
          storageService: storageService,
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.appTagline), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1850));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}
