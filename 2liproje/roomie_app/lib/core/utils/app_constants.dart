class AppConstants {
  AppConstants._();

  static const String appName = 'Roomio';
  static const String appTagline = 'Ev & Oda Arkadaşını Kolayca Bul';

  // Demo External Links
  static const String eDevletSabikaUrl =
      'https://www.turkiye.gov.tr/adli-sicil-kaydi-sorgulama';
  static const String eDevletOgrenciUrl =
      'https://www.turkiye.gov.tr/yuksekogretim-kurulu-ogrenci-belgesi-sorgulama';

  // Cities and Districts
  static const Map<String, List<String>> turkeyLocations = {
    'İstanbul': [
      'Kadıköy',
      'Beşiktaş',
      'Şişli',
      'Üsküdar',
      'Bakırköy',
      'Sarıyer',
      'Beyoğlu',
      'Maltepe',
      'Ataşehir',
      'Fatih',
    ],
    'Ankara': [
      'Çankaya',
      'Yenimahalle',
      'Keçiören',
      'Etimesgut',
      'Mamak',
      'Gölbaşı',
    ],
    'İzmir': ['Bornova', 'Karşıyaka', 'Konak', 'Buca', 'Çiğli', 'Balçova'],
    'Bursa': ['Nilüfer', 'Osmangazi', 'Yıldırım'],
    'Antalya': ['Konyaaltı', 'Muratpaşa', 'Kepez'],
    'Eskişehir': ['Tepebaşı', 'Odunpazarı'],
  };

  static const List<String> sleepHabits = ['Gece', 'Sabah', 'Fark etmez'];
  static const List<String> cleanlinessLevels = ['Az', 'Orta', 'Çok'];
  static const List<String> availableLanguages = [
    'Türkçe',
    'İngilizce',
    'Almanca',
    'Fransızca',
    'İspanyolca',
    'Rusça',
    'Arapça',
  ];
  static const List<String> genderOptions = ['Kadın', 'Erkek', 'Fark etmez'];
  static const List<String> homeTypes = [
    'Ayrı Oda (3+1 Daire)',
    'Özel Oda (2+1 Daire)',
    'Paylaşımlı Stüdyo',
    'Tüm Ev',
  ];

  // Campaign Cities for Winter Season Discount (%20)
  static const List<String> winterDiscountCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
  ];

  // Hive Box Names
  static const String boxUser = 'roomio_user_box';
  static const String boxListings = 'roomio_listings_box';
  static const String boxFavorites = 'roomio_favorites_box';
  static const String boxRentals = 'roomio_rentals_box';
  static const String boxChats = 'roomio_chats_box';
  static const String boxFeedbacks = 'roomio_feedbacks_box';
  static const String boxSettings = 'roomio_settings_box';
}
