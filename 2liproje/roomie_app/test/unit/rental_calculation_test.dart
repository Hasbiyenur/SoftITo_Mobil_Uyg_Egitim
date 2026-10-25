import 'package:flutter_test/flutter_test.dart';
import 'package:roomie_app/data/models/listing_model.dart';

void main() {
  group('Rental Price & Discount Calculation Tests', () {
    final testListingIstanbul = ListingModel(
      id: 'test-1',
      title: 'Kadıköy Test Odası',
      description: 'Test açıklama',
      monthlyPrice: 15000.0,
      city: 'İstanbul',
      district: 'Kadıköy',
      neighborhood: 'Moda',
      images: const ['image1.jpg'],
      owner: const ListingOwnerModel(
        id: 'owner-1',
        fullName: 'Test Sahip',
        age: 25,
        gender: 'Kadın',
        occupation: 'Mühendis',
        phone: '+90 532 000 00 00',
      ),
      isWinterDiscountEligible: true,
      createdAt: DateTime.now(),
    );

    final testListingBursa = ListingModel(
      id: 'test-2',
      title: 'Bursa Görükle Odası',
      description: 'Test açıklama',
      monthlyPrice: 9000.0,
      city: 'Bursa',
      district: 'Nilüfer',
      neighborhood: 'Görükle',
      images: const ['image2.jpg'],
      owner: const ListingOwnerModel(
        id: 'owner-2',
        fullName: 'Test Sahip 2',
        age: 24,
        gender: 'Erkek',
        occupation: 'Öğrenci',
        phone: '+90 533 000 00 00',
      ),
      isWinterDiscountEligible: false,
      createdAt: DateTime.now(),
    );

    test('calculates correct daily price rate (monthlyPrice / 30)', () {
      expect(testListingIstanbul.dailyPrice, 500.0);
      expect(testListingBursa.dailyPrice, 300.0);
    });

    test('calculates gross price for 10 days without discounts', () {
      final result = testListingBursa.calculatePrice(
        days: 10,
        isStudent: false,
      );
      expect(result.days, 10);
      expect(result.grossAmount, 3000.0);
      expect(result.studentDiscountAmount, 0.0);
      expect(result.winterDiscountAmount, 0.0);
      expect(result.totalAmount, 3000.0);
    });

    test('applies 20% student discount when user is student', () {
      final result = testListingBursa.calculatePrice(days: 10, isStudent: true);
      expect(result.grossAmount, 3000.0);
      expect(result.studentDiscountAmount, 600.0); // 20% of 3000
      expect(result.winterDiscountAmount, 0.0);
      expect(result.totalAmount, 2400.0); // 3000 - 600
    });

    test(
      'applies 20% winter discount in eligible winter cities (İstanbul)',
      () {
        final result = testListingIstanbul.calculatePrice(
          days: 20,
          isStudent: false,
        );
        // Daily = 500. Gross for 20 days = 10000.
        expect(result.grossAmount, 10000.0);
        expect(result.studentDiscountAmount, 0.0);
        expect(result.winterDiscountAmount, 2000.0); // 20% of 10000
        expect(result.totalAmount, 8000.0);
      },
    );

    test(
      'applies both student and winter discounts additively when eligible',
      () {
        final result = testListingIstanbul.calculatePrice(
          days: 30,
          isStudent: true,
        );
        // Daily = 500. Gross for 30 days = 15000.
        expect(result.grossAmount, 15000.0);
        expect(result.studentDiscountAmount, 3000.0); // 20% of 15000
        expect(result.winterDiscountAmount, 3000.0); // 20% of 15000
        expect(result.totalAmount, 9000.0); // 15000 - 3000 - 3000
      },
    );
  });
}
