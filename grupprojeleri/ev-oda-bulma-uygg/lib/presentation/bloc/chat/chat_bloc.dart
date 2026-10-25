import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/usecases/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// Anlık mesajlaşma, konuşma odalarını listeleme ve mesaj gönderme işlevlerini yöneten BLoC sınıfı.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitialState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendChatMessageEvent>(_onSendMessage);
  }

  /// Kullanıcının dahil olduğu sohbet listesini (konuşmaları) yükler.
  Future<void> _onLoadConversations(
      LoadConversationsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      final conversations =
          await getConversationsUseCase.execute(event.currentUserId);
      emit(ChatLoadedState(
        conversations: conversations,
        messagesByConversation: {},
      ));
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  /// Belirli bir odaya ait mesaj geçmişini yükler ve mevcut duruma ekler.
  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final messages = await getMessagesUseCase.execute(
        event.conversationId,
        event.currentUserId,
      );
      if (state is ChatLoadedState) {
        final current = state as ChatLoadedState;
        final updatedMap =
            Map<String, List<ChatMessageEntity>>.from(current.messagesByConversation);
        updatedMap[event.conversationId] = messages;
        emit(current.copyWith(messagesByConversation: updatedMap));
      } else {
        emit(ChatLoadedState(
          conversations: [],
          messagesByConversation: {event.conversationId: messages},
        ));
      }
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  /// Yeni mesajı gönderir, yerel duruma anında ekler ve konuşma listesini günceller.
  Future<void> _onSendMessage(
      SendChatMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await sendMessageUseCase.execute(event.message);

      if (state is ChatLoadedState) {
        final current = state as ChatLoadedState;
        final convId = event.message.conversationId;
        final existingMessages =
            List<ChatMessageEntity>.from(current.messagesByConversation[convId] ?? []);
        existingMessages.add(event.message);

        final updatedMap =
            Map<String, List<ChatMessageEntity>>.from(current.messagesByConversation);
        updatedMap[convId] = existingMessages;

        // En son mesaj metni ve saatini güncellemek için konuşmaları yeniden sorgula
        final updatedConversations =
            await getConversationsUseCase.execute(event.message.senderId);

        emit(current.copyWith(
          conversations: updatedConversations,
          messagesByConversation: updatedMap,
        ));
      }
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }
}
