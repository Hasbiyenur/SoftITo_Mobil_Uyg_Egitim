import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

/// Kullanıcının dahil olduğu tüm konuşma odalarını getiren Use Case.
class GetConversationsUseCase {
  final ChatRepository repository;
  GetConversationsUseCase(this.repository);

  /// Kullanıcı ID'sine göre sohbet listesini ve son mesajları getirir.
  Future<List<ChatConversationEntity>> execute(String currentUserId) =>
      repository.getConversations(currentUserId);
}

/// Seçili bir konuşmaya ait geçmiş mesajları getiren Use Case.
class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  /// Konuşma ID ve kullanıcı ID'sine göre mesaj geçmişini getirir.
  Future<List<ChatMessageEntity>> execute(
          String conversationId, String currentUserId) =>
      repository.getMessages(conversationId, currentUserId);
}

/// Belirtilen konuşmaya yeni bir mesaj gönderen Use Case.
class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  /// Mesaj nesnesini işler ve veritabanına iletir.
  Future<void> execute(ChatMessageEntity message) =>
      repository.sendMessage(message);
}
