import '../entities/chat_entity.dart';

/// Sohbet odaları ve anlık mesajlaşma işlemlerinin soyut sözleşmesi (Repository Interface).
abstract class ChatRepository {
  /// Giriş yapan kullanıcının dahil olduğu tüm konuşma odalarını ve son mesajları getirir.
  Future<List<ChatConversationEntity>> getConversations(String currentUserId);

  /// Belirli bir konuşma odasına ait mesaj geçmişini getirir.
  Future<List<ChatMessageEntity>> getMessages(String conversationId, String currentUserId);

  /// Karşı tarafa yeni bir mesaj gönderir ve yerel veritabanına kaydeder.
  Future<void> sendMessage(ChatMessageEntity message);
}
