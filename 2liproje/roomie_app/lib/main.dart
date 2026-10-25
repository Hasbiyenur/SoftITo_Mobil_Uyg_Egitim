import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/hive_storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/feedback_repository.dart';
import 'data/repositories/listing_repository.dart';
import 'data/repositories/rental_repository.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'presentation/bloc/feedback_bloc.dart';
import 'presentation/bloc/listing_bloc.dart';
import 'presentation/bloc/rental_bloc.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Turkish locale
  await initializeDateFormatting('tr_TR');

  // Initialize Hive permanent local database
  final storageService = HiveStorageService.instance;
  await storageService.init();

  // Repositories
  final authRepository = AuthRepository(storage: storageService);
  final listingRepository = ListingRepository(storage: storageService);
  final rentalRepository = RentalRepository(
    storage: storageService,
    listingRepository: listingRepository,
  );
  final chatRepository = ChatRepository(storage: storageService);
  final feedbackRepository = FeedbackRepository(storage: storageService);

  runApp(
    RoomioApp(
      authRepository: authRepository,
      listingRepository: listingRepository,
      rentalRepository: rentalRepository,
      chatRepository: chatRepository,
      feedbackRepository: feedbackRepository,
      storageService: storageService,
    ),
  );
}

class RoomioApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ListingRepository listingRepository;
  final RentalRepository rentalRepository;
  final ChatRepository chatRepository;
  final FeedbackRepository feedbackRepository;
  final HiveStorageService storageService;

  const RoomioApp({
    super.key,
    required this.authRepository,
    required this.listingRepository,
    required this.rentalRepository,
    required this.chatRepository,
    required this.feedbackRepository,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(storage: storageService),
        ),
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(repository: authRepository)..add(CheckAuthEvent()),
        ),
        BlocProvider<ListingBloc>(
          create: (_) =>
              ListingBloc(repository: listingRepository)
                ..add(LoadListingsEvent()),
        ),
        BlocProvider<RentalBloc>(
          create: (_) => RentalBloc(
            rentalRepository: rentalRepository,
            chatRepository: chatRepository,
          )..add(LoadRentalsEvent()),
        ),
        BlocProvider<ChatBloc>(
          create: (ctx) {
            final authState = ctx.read<AuthBloc>().state;
            final user = authState is Authenticated ? authState.user : null;
            return ChatBloc(repository: chatRepository)
              ..add(LoadConversationsEvent(user));
          },
        ),
        BlocProvider<FeedbackBloc>(
          create: (_) =>
              FeedbackBloc(repository: feedbackRepository)
                ..add(LoadFeedbacksEvent()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Roomio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
