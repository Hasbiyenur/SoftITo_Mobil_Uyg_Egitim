import 'package:flutter_test/flutter_test.dart';
import 'package:roomio/core/utils/price_calculator.dart';
import 'package:roomio/domain/entities/rental_entity.dart';
import 'package:roomio/presentation/bloc/listing/listing_event.dart';

void main() {
  group('PriceCalculator Tests', () {
    test('Calculates base daily rate correctly (Monthly / 30 * Days)', () {
      final result = PriceCalculator.calculate(
        monthlyRent: 15000,
        days: 10,
        isStudent: false,
        city: 'Antalya',
        bookingDate: DateTime(2026, 6, 15), // Summer non-discount
      );

      expect(result.basePrice, 5000); // 15000 / 30 * 10
      expect(result.discountAmount, 0);
      expect(result.finalPrice, 5000);
      expect(result.discountReason, isNull);
    });

    test('Applies 20% Student Discount when isStudent is true', () {
      final result = PriceCalculator.calculate(
        monthlyRent: 30000,
        days: 30,
        isStudent: true,
        city: 'İstanbul',
        bookingDate: DateTime(2026, 6, 15),
      );

      expect(result.basePrice, 30000);
      expect(result.discountAmount, 6000); // 20% of 30000
      expect(result.finalPrice, 24000);
      expect(result.discountReason, 'Öğrenci İndirimi (%20)');
    });

    test('Applies 20% Winter Discount for target cities in winter months', () {
      final result = PriceCalculator.calculate(
        monthlyRent: 12000,
        days: 15,
        isStudent: false,
        city: 'İzmir',
        bookingDate: DateTime(2026, 12, 1), // December (Winter)
      );

      expect(result.basePrice, 6000); // 12000 / 30 * 15
      expect(result.discountAmount, 1200); // 20% of 6000
      expect(result.finalPrice, 4800);
      expect(result.discountReason, 'Kış Sezonu İndirimi (%20)');
    });
  });

  group('RentalEntity Tests', () {
    test('Calculates remaining days correctly until checkout', () {
      final now = DateTime.now();
      final rental = RentalEntity(
        id: 'test-1',
        listingId: 'room-1',
        listingTitle: 'Moda Oda',
        listingImageUrl: 'https://example.com/img.jpg',
        city: 'İstanbul',
        district: 'Kadıköy',
        monthlyRent: 12000,
        hostId: 'host-1',
        hostName: 'Ece',
        hostAvatarUrl: 'https://example.com/ece.jpg',
        tenantId: 'tenant-1',
        tenantName: 'Betül',
        tenantGender: 'Kadın',
        tenantAvatarUrl: 'https://example.com/betul.jpg',
        tenantOccupation: 'Yazılım',
        checkInDate: now.subtract(const Duration(days: 2)),
        checkOutDate: now.add(const Duration(days: 10)),
        daysStayed: 12,
        guestCount: 1,
        baseAmount: 4800,
        discountAmount: 960,
        totalAmount: 3840,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      expect(rental.remainingDays, greaterThanOrEqualTo(10));
      expect(rental.isCompleted, false);
    });
  });

  group('ListingFilterCriteria Tests', () {
    test('isActive returns false when no filters applied', () {
      const filters = ListingFilterCriteria();
      expect(filters.isActive, false);
    });

    test('isActive returns true when criteria set', () {
      const filters = ListingFilterCriteria(minPrice: 10000, city: 'Ankara');
      expect(filters.isActive, true);
    });
  });
}
