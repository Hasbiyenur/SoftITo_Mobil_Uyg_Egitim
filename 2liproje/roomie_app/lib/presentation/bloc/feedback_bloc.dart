import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/failures.dart';
import '../../data/models/feedback_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/feedback_repository.dart';

// EVENTS
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeedbacksEvent extends FeedbackEvent {
  final String? userId;
  const LoadFeedbacksEvent([this.userId]);
  @override
  List<Object?> get props => [userId];
}

class SubmitFeedbackEvent extends FeedbackEvent {
  final UserModel user;
  final String category;
  final String message;
  final int rating;

  const SubmitFeedbackEvent({
    required this.user,
    required this.category,
    required this.message,
    required this.rating,
  });

  @override
  List<Object?> get props => [user, category, message, rating];
}

// STATES
abstract class FeedbackState extends Equatable {
  const FeedbackState();
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackModel> feedbacks;
  const FeedbackLoaded(this.feedbacks);
  @override
  List<Object?> get props => [feedbacks];
}

class FeedbackSuccess extends FeedbackState {
  final String message;
  final List<FeedbackModel> feedbacks;
  const FeedbackSuccess(this.message, {this.feedbacks = const []});
  @override
  List<Object?> get props => [message, feedbacks];
}

class FeedbackError extends FeedbackState {
  final String message;
  final List<FeedbackModel> feedbacks;
  const FeedbackError(this.message, {this.feedbacks = const []});
  @override
  List<Object?> get props => [message, feedbacks];
}

// BLOC
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackBloc({FeedbackRepository? repository})
    : _repository = repository ?? FeedbackRepository(),
      super(FeedbackInitial()) {
    on<LoadFeedbacksEvent>(_onLoadFeedbacks);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
  }

  void _onLoadFeedbacks(LoadFeedbacksEvent event, Emitter<FeedbackState> emit) {
    try {
      final list = _repository.getAllFeedbacks(userId: event.userId);
      emit(FeedbackLoaded(list));
    } on Failure catch (f) {
      emit(FeedbackError(f.message));
    } catch (e) {
      emit(FeedbackError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    try {
      await _repository.submitFeedback(
        user: event.user,
        category: event.category,
        message: event.message,
        rating: event.rating,
      );
      final list = _repository.getAllFeedbacks(userId: event.user.id);
      emit(
        FeedbackSuccess(
          'Geri bildiriminiz başarıyla iletildi. Katkınız için teşekkürler!',
          feedbacks: list,
        ),
      );
      emit(FeedbackLoaded(list));
    } on Failure catch (f) {
      final currentList = _repository.getAllFeedbacks(userId: event.user.id);
      emit(FeedbackError(f.message, feedbacks: currentList));
    } catch (e) {
      final currentList = _repository.getAllFeedbacks(userId: event.user.id);
      emit(
        FeedbackError(
          e.toString().replaceAll('Exception: ', ''),
          feedbacks: currentList,
        ),
      );
    }
  }
}
