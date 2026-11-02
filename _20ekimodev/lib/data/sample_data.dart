import '../models/booking.dart';
import '../models/vehicle.dart';

const String demoUserId = 'user_demo_1';
const String demoUserFirstName = 'Ahmet';
const String demoUserLastName = 'Yılmaz';

final List<Vehicle> initialVehicles = [
  const Vehicle(
    id: 'v_1',
    ownerId: demoUserId,
    ownerFirstName: demoUserFirstName,
    ownerLastName: demoUserLastName,
    type: 'Sedan',
    brand: 'Renault',
    model: 'Megane',
    color: 'Beyaz',
    location: 'İstanbul - Kadıköy',
    hourlyPrice: 280.0,
    kilometers: 45000,
  ),
  const Vehicle(
    id: 'v_2',
    ownerId: 'user_2',
    ownerFirstName: 'Caner',
    ownerLastName: 'Demir',
    type: 'Sedan',
    brand: 'BMW',
    model: '320i',
    color: 'Siyah',
    location: 'İstanbul - Beşiktaş',
    hourlyPrice: 650.0,
    kilometers: 32000,
  ),
  const Vehicle(
    id: 'v_3',
    ownerId: 'user_3',
    ownerFirstName: 'Elif',
    ownerLastName: 'Yıldız',
    type: 'Elektrikli',
    brand: 'Tesla',
    model: 'Model Y',
    color: 'Beyaz',
    location: 'İstanbul - Şişli',
    hourlyPrice: 750.0,
    kilometers: 18000,
  ),
  const Vehicle(
    id: 'v_4',
    ownerId: 'user_4',
    ownerFirstName: 'Burak',
    ownerLastName: 'Kaya',
    type: 'SUV',
    brand: 'Volkswagen',
    model: 'Tiguan',
    color: 'Gri',
    location: 'Ankara - Çankaya',
    hourlyPrice: 500.0,
    kilometers: 60000,
  ),
  const Vehicle(
    id: 'v_5',
    ownerId: 'user_5',
    ownerFirstName: 'Selin',
    ownerLastName: 'Arslan',
    type: 'Sedan',
    brand: 'Fiat',
    model: 'Egea',
    color: 'Mavi',
    location: 'İzmir - Alsancak',
    hourlyPrice: 220.0,
    kilometers: 85000,
  ),
  const Vehicle(
    id: 'v_6',
    ownerId: 'user_6',
    ownerFirstName: 'Deniz',
    ownerLastName: 'Öztürk',
    type: 'Hatchback',
    brand: 'Audi',
    model: 'A3 Sportback',
    color: 'Kırmızı',
    location: 'İstanbul - Ataşehir',
    hourlyPrice: 580.0,
    kilometers: 25000,
  ),
  const Vehicle(
    id: 'v_7',
    ownerId: 'user_7',
    ownerFirstName: 'Kemal',
    ownerLastName: 'Şahin',
    type: 'Ticari',
    brand: 'Ford',
    model: 'Tourneo Courier',
    color: 'Gri',
    location: 'Bursa - Nilüfer',
    hourlyPrice: 300.0,
    kilometers: 95000,
  ),
  const Vehicle(
    id: 'v_8',
    ownerId: 'user_8',
    ownerFirstName: 'Murat',
    ownerLastName: 'Çelik',
    type: 'Spor',
    brand: 'Porsche',
    model: 'Taycan',
    color: 'Siyah',
    location: 'İstanbul - Sarıyer',
    hourlyPrice: 1200.0,
    kilometers: 12000,
  ),
];

List<Booking> getInitialBookings() {
  final now = DateTime.now();
  // Yarın için örnek rezervasyonlar (gelecekte çakışma ve listeleme testleri için)
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
  final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2, 14, 0);

  return [
    // 1. Kullanıcının sahip olduğu araca (v_1) başkası (Zeynep Akın) tarafından yapılan rezervasyon
    // Bu kayıt: Profil > Araçlarımın Kiralamaları ekranında görünecektir.
    Booking(
      id: 'b_demo_received_1',
      vehicleId: 'v_1',
      vehicleTitleSnapshot: 'Renault Megane',
      ownerId: demoUserId,
      renterId: 'user_renter_guest',
      renterFirstName: 'Zeynep',
      renterLastName: 'Akın',
      startAt: tomorrow,
      endAt: tomorrow.add(const Duration(hours: 4)),
      durationHours: 4,
      hourlyPriceSnapshot: 280.0,
      totalPrice: 1120.0,
      isCancelled: false,
    ),
    // 2. Demo kullanıcımızın başkasının aracını (v_2) kiraladığı rezervasyon
    // Bu kayıt: Profil > Kiralanan Araçlarım ekranında görünecektir.
    Booking(
      id: 'b_demo_my_rental_1',
      vehicleId: 'v_2',
      vehicleTitleSnapshot: 'BMW 320i',
      ownerId: 'user_2',
      renterId: demoUserId,
      renterFirstName: demoUserFirstName,
      renterLastName: demoUserLastName,
      startAt: dayAfterTomorrow,
      endAt: dayAfterTomorrow.add(const Duration(hours: 3)),
      durationHours: 3,
      hourlyPriceSnapshot: 650.0,
      totalPrice: 1950.0,
      isCancelled: false,
    ),
  ];
}
