import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/app_constants.dart';

class HiveStorageService {
  static final HiveStorageService instance = HiveStorageService._internal();
  HiveStorageService._internal();

  late Box userBox;
  late Box listingsBox;
  late Box favoritesBox;
  late Box rentalsBox;
  late Box chatsBox;
  late Box feedbacksBox;
  late Box settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    userBox = await Hive.openBox(AppConstants.boxUser);
    listingsBox = await Hive.openBox(AppConstants.boxListings);
    favoritesBox = await Hive.openBox(AppConstants.boxFavorites);
    rentalsBox = await Hive.openBox(AppConstants.boxRentals);
    chatsBox = await Hive.openBox(AppConstants.boxChats);
    feedbacksBox = await Hive.openBox(AppConstants.boxFeedbacks);
    settingsBox = await Hive.openBox(AppConstants.boxSettings);

    _isInitialized = true;
    debugPrint('Hive Storage Service initialized successfully.');
  }

  Future<void> clearAllData() async {
    await userBox.clear();
    await listingsBox.clear();
    await favoritesBox.clear();
    await rentalsBox.clear();
    await chatsBox.clear();
    await feedbacksBox.clear();
    await settingsBox.clear();
  }
}
