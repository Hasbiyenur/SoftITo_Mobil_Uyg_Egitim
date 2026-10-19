import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';

void main() {
  group('WaterTrackerController Birim Testleri', () {
    late WaterTrackerController controller;

    setUp(() {
      controller = WaterTrackerController(dailyGoalWater: 2500);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıç su miktarı 0 olmalıdır', () {
      expect(controller.currentWater.value, 0);
      expect(controller.logList.value.isEmpty, true);
    });

    test('addWater() çağrıldığında miktar ve log listesi güncellenmelidir', () {
      controller.addWater(250);
      expect(controller.currentWater.value, 250);
      expect(controller.logList.value.length, 1);
      expect(controller.logList.value.first.amountMl, 250);
    });

    test('reset() çağrıldığında tüm değerler sıfırlanmalıdır', () {
      controller.addWater(500);
      controller.reset();
      expect(controller.currentWater.value, 0);
      expect(controller.logList.value.isEmpty, true);
    });
  });
}
