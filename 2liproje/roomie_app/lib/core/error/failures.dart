import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([
    super.message = 'Veri saklama veya okuma hatası oluştu.',
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Kimlik doğrulama işlemi başarısız oldu.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Lütfen tüm alanları eksiksiz ve doğru doldurunuz.',
  ]);
}

class RentalRuleFailure extends Failure {
  const RentalRuleFailure([
    super.message = 'Kiralama kuralı ihlali gerçekleşti.',
  ]);
}
