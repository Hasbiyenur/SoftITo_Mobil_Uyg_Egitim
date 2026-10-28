import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roomio/core/theme/app_theme.dart';
import 'package:roomio/domain/entities/rental_entity.dart';
import 'package:roomio/domain/entities/user_entity.dart';
import 'package:roomio/domain/repositories/auth_repository.dart';
import 'package:roomio/domain/repositories/rental_repository.dart';
import 'package:roomio/domain/usecases/auth_usecases.dart';
import 'package:roomio/domain/usecases/rental_usecases.dart';
import 'package:roomio/presentation/bloc/auth/auth_bloc.dart';
import 'package:roomio/presentation/bloc/auth/auth_state.dart';
import 'package:roomio/presentation/bloc/rental/rental_bloc.dart';
import 'package:roomio/presentation/bloc/rental/rental_state.dart';
import 'package:roomio/presentation/screen/rentals/active_rentals_screen.dart';

class MockAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRentalRepo implements RentalRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestRentalBloc extends RentalBloc {
  TestRentalBloc(RentalState initialState)
      : super(
          createRentalUseCase: CreateRentalUseCase(MockRentalRepo()),
          getMyActiveStayUseCase: GetMyActiveStayUseCase(MockRentalRepo()),
          getMyGivenRentalsUseCase: GetMyGivenRentalsUseCase(MockRentalRepo()),
          checkoutActiveStayUseCase: CheckoutActiveStayUseCase(MockRentalRepo()),
        ) {
    emit(initialState);
  }
}

class TestAuthBloc extends AuthBloc {
  TestAuthBloc(AuthState initialState)
      : super(
          getCurrentUserUseCase: GetCurrentUserUseCase(MockAuthRepo()),
          loginUseCase: LoginUseCase(MockAuthRepo()),
          registerUseCase: RegisterUseCase(MockAuthRepo()),
          updateProfileUseCase: UpdateProfileUseCase(MockAuthRepo()),
          logoutUseCase: LogoutUseCase(MockAuthRepo()),
          deleteAccountUseCase: DeleteAccountUseCase(MockAuthRepo()),
        ) {
    emit(initialState);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });
  testWidgets('ActiveRentalsScreen renders with active rental', (tester) async {
    final rental = RentalEntity(
      id: 'test-rental',
      listingId: 'listing-1',
      listingTitle: 'Harika Deniz Manzaralı Oda',
      listingImageUrl: '',
      city: 'İstanbul',
      district: 'Kadıköy',
      monthlyRent: 15000,
      hostId: 'host-1',
      hostName: 'Ahmet Yılmaz',
      hostAvatarUrl: '',
      tenantId: 'user-demo-1',
      tenantName: 'Betül Yılmaz',
      tenantGender: 'Kadın',
      tenantAvatarUrl: '',
      tenantOccupation: 'Yazılım Mühendisi',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now().add(const Duration(days: 30)),
      daysStayed: 30,
      guestCount: 1,
      baseAmount: 15000,
      discountAmount: 3000,
      totalAmount: 12000,
      discountReason: 'Öğrenci İndirimi (%20)',
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final rentalBloc = TestRentalBloc(RentalLoadedState(
      activeStay: rental,
      myGivenRentals: const [],
    ));
    final authBloc = TestAuthBloc(
      AuthenticatedState(
        const UserEntity(
          id: 'user-demo-1',
          name: 'Betül Yılmaz',
          email: 'betul@example.com',
          phone: '05555555555',
          password: 'pass',
          gender: 'Kadın',
          age: 24,
          occupation: 'Yazılım Mühendisi',
          smoking: false,
          hasPet: false,
          sleepSchedule: 'Düzenli',
          cleaningSensitivity: 'Titiz',
          languages: ['Türkçe'],
          isStudent: true,
          avatarUrl: '',
          city: 'İstanbul',
          district: 'Kadıköy',
        ),
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<RentalBloc>.value(value: rentalBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ActiveRentalsScreen(),
        ),
      ),
    );

    await tester.pump();
  });
}
