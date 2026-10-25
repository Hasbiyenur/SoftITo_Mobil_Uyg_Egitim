import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/listing_repository_impl.dart';
import 'data/repositories/rental_repository_impl.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/chat_usecases.dart';
import 'domain/usecases/listing_usecases.dart';
import 'domain/usecases/rental_usecases.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/listing/listing_bloc.dart';
import 'presentation/bloc/listing/listing_event.dart';
import 'presentation/bloc/rental/rental_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/screen/auth/login_screen.dart';

/// Uygulamanın ana giriş noktası (Entry Point).
/// Flutter motoru başlatılır, yerelleştirme ve kalıcı veri depolama (Hive) ayarlanır,
/// Clean Architecture katmanlarındaki bağımlılıklar (Repository ve UseCase'ler) ayağa kaldırılır.
Future<void> main() async {
  // Flutter widget ağacının motorla iletişim kurabilmesi için bağlama işlemini garanti altına alıyoruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih ve saat formatlama desteğini (intl paketi) başlatıyoruz.
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('tr', null);

  // Hive NoSQL yerel veri tabanını Flutter için başlatıyoruz.
  await Hive.initFlutter();
  
  // Uygulama genelinde kullanılacak veri depolama kutularını (Boxes) açıyoruz.
  await Hive.openBox('auth_box');           // Kullanıcı oturum ve profil bilgileri
  await Hive.openBox('user_listings_box');   // Kullanıcı tarafından oluşturulan ilanlar
  await Hive.openBox('favorites_box');       // Favoriye eklenen ilan ID'leri
  await Hive.openBox('rentals_box');         // Aktif ve geçmiş kiralama işlemleri
  await Hive.openBox('chats_box');           // Mesajlaşma ve sohbet geçmişi
  await Hive.openBox('settings_box');        // Tema ve genel kullanıcı tercihleri

  // ================= DATA KATMANI: REPOSITORY ÖRNEKLERİ =================
  // Veri kaynakları (Hive / Mock veriler) ile iletişim kuran somut sınıflar.
  final authRepo = AuthRepositoryImpl();
  final listingRepo = ListingRepositoryImpl();
  final rentalRepo = RentalRepositoryImpl();
  final chatRepo = ChatRepositoryImpl();

  // ================= DOMAIN KATMANI: USE CASE'LER (İŞ MANTIKLARI) =================
  // Kimlik doğrulama işlemleri use case'leri
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepo);
  final loginUseCase = LoginUseCase(authRepo);
  final registerUseCase = RegisterUseCase(authRepo);
  final updateProfileUseCase = UpdateProfileUseCase(authRepo);
  final logoutUseCase = LogoutUseCase(authRepo);
  final deleteAccountUseCase = DeleteAccountUseCase(authRepo);

  // İlan yönetimi işlemleri use case'leri
  final getAllListingsUseCase = GetAllListingsUseCase(listingRepo);
  final addListingUseCase = AddListingUseCase(listingRepo);
  final toggleFavoriteUseCase = ToggleFavoriteUseCase(listingRepo);
  final getFavoriteIdsUseCase = GetFavoriteIdsUseCase(listingRepo);
  final toggleListingActiveUseCase = ToggleListingActiveUseCase(listingRepo);

  // Kiralama işlemleri use case'leri
  final createRentalUseCase = CreateRentalUseCase(rentalRepo);
  final getMyActiveStayUseCase = GetMyActiveStayUseCase(rentalRepo);
  final getMyGivenRentalsUseCase = GetMyGivenRentalsUseCase(rentalRepo);
  final checkoutActiveStayUseCase = CheckoutActiveStayUseCase(rentalRepo);

  // Mesajlaşma işlemleri use case'leri
  final getConversationsUseCase = GetConversationsUseCase(chatRepo);
  final getMessagesUseCase = GetMessagesUseCase(chatRepo);
  final sendMessageUseCase = SendMessageUseCase(chatRepo);

  // Uygulamayı tüm BLoC durum yöneticilerini (State Management) ağaca enjekte ederek çalıştırıyoruz.
  runApp(
    MultiBlocProvider(
      providers: [
        // Tema yönetimi (Açık / Koyu tema)
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        // Kullanıcı giriş, çıkış ve profil yönetimi
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            getCurrentUserUseCase: getCurrentUserUseCase,
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            updateProfileUseCase: updateProfileUseCase,
            logoutUseCase: logoutUseCase,
            deleteAccountUseCase: deleteAccountUseCase,
          ),
        ),
        // İlanları listeleme, ekleme ve favori işlemleri
        BlocProvider<ListingBloc>(
          create: (_) => ListingBloc(
            getAllListingsUseCase: getAllListingsUseCase,
            addListingUseCase: addListingUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            getFavoriteIdsUseCase: getFavoriteIdsUseCase,
            toggleListingActiveUseCase: toggleListingActiveUseCase,
          )..add(LoadListingsEvent()), // Uygulama açılır açılmaz ilanları yükle
        ),
        // Kiralama ve konaklama takibi
        BlocProvider<RentalBloc>(
          create: (_) => RentalBloc(
            createRentalUseCase: createRentalUseCase,
            getMyActiveStayUseCase: getMyActiveStayUseCase,
            getMyGivenRentalsUseCase: getMyGivenRentalsUseCase,
            checkoutActiveStayUseCase: checkoutActiveStayUseCase,
          ),
        ),
        // Canlı sohbet ve mesajlaşma yönetimi
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(
            getConversationsUseCase: getConversationsUseCase,
            getMessagesUseCase: getMessagesUseCase,
            sendMessageUseCase: sendMessageUseCase,
          ),
        ),
      ],
      child: const RoomioApp(),
    ),
  );
}

/// Uygulamanın kök widget'ı (Root Application Widget).
/// MaterialApp yapılandırmasını, tema geçişlerini ve yerelleştirme ayarlarını barındırır.
class RoomioApp extends StatelessWidget {
  const RoomioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeCubit üzerinden anlık seçili temayı (Açık/Koyu) dinler
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Roomio',
          debugShowCheckedModeBanner: false, // Hata ayıklama bandını gizler
          theme: AppTheme.lightTheme,         // Aydınlık tema konfigürasyonu
          darkTheme: AppTheme.darkTheme,      // Karanlık tema konfigürasyonu
          themeMode: themeMode,               // Aktif tema modu (Sistem / Açık / Koyu)
          locale: const Locale('tr', 'TR'),   // Varsayılan dil: Türkçe
          supportedLocales: const [
            Locale('tr', 'TR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LoginScreen(),          // Uygulamanın ilk açılış ekranı
        );
      },
    );
  }
}
