import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/chat_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';

// EVENTS
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends ChatEvent {
  final UserModel? currentUser;
  const LoadConversationsEvent([this.currentUser]);
  @override
  List<Object?> get props => [currentUser];
}

class OpenConversationEvent extends ChatEvent {
  final String conversationId;
  const OpenConversationEvent(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class StartChatWithListingOwnerEvent extends ChatEvent {
  final ListingModel listing;
  final UserModel currentUser;
  const StartChatWithListingOwnerEvent({
    required this.listing,
    required this.currentUser,
  });
  @override
  List<Object?> get props => [listing, currentUser];
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String text;
  final UserModel currentUser;
  final String? imagePath;
  final bool isEmojiOnly;

  const SendMessageEvent({
    required this.conversationId,
    required this.text,
    required this.currentUser,
    this.imagePath,
    this.isEmojiOnly = false,
  });

  @override
  List<Object?> get props => [
    conversationId,
    text,
    currentUser,
    imagePath,
    isEmojiOnly,
  ];
}

// STATES
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversationModel> conversations;
  final ChatConversationModel? activeConversation;

  const ChatLoaded({required this.conversations, this.activeConversation});

  ChatLoaded copyWith({
    List<ChatConversationModel>? conversations,
    ChatConversationModel? activeConversation,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
    );
  }

  @override
  List<Object?> get props => [conversations, activeConversation];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;

  ChatBloc({ChatRepository? repository})
    : _repository = repository ?? ChatRepository(),
      super(ChatInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<OpenConversationEvent>(_onOpenConversation);
    on<StartChatWithListingOwnerEvent>(_onStartChatWithListingOwner);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      await _repository.initSampleChatsIfNeeded(event.currentUser);
      final list = _repository.getConversations();
      emit(ChatLoaded(conversations: list));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onOpenConversation(
    OpenConversationEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final active = _repository.getConversationById(event.conversationId);
      emit(current.copyWith(activeConversation: active));
    }
  }

  Future<void> _onStartChatWithListingOwner(
    StartChatWithListingOwnerEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conv = await _repository.startConversationWithListingOwner(
        listing: event.listing,
        currentUser: event.currentUser,
      );
      final list = _repository.getConversations();
      emit(ChatLoaded(conversations: list, activeConversation: conv));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.sendMessage(
        conversationId: event.conversationId,
        text: event.text,
        currentUser: event.currentUser,
        imagePath: event.imagePath,
        isEmojiOnly: event.isEmojiOnly,
      );

      final list = _repository.getConversations();
      final updatedActive = _repository.getConversationById(
        event.conversationId,
      );

      emit(ChatLoaded(conversations: list, activeConversation: updatedActive));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
