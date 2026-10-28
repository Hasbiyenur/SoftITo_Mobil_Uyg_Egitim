import '../../../domain/entities/chat_entity.dart';

/// Mesajlaşma ve sohbet odaları akışındaki olayların (Events) temel soyut sınıfı.
abstract class ChatEvent {}

/// Kullanıcının dahil olduğu konuşmaları (sohbet listesini) yükleme olayı.
class LoadConversationsEvent extends ChatEvent {
  /// Giriş yapan kullanıcının kimlik numarası
  final String currentUserId;
  LoadConversationsEvent(this.currentUserId);
}

/// Seçili bir konuşmaya ait mesajları yükleyen olay.
class LoadMessagesEvent extends ChatEvent {
  /// Konuşma odasının kimliği
  final String conversationId;

  /// Giriş yapan kullanıcının kimliği (isMe bayrağını tespit etmek için)
  final String currentUserId;

  LoadMessagesEvent({required this.conversationId, required this.currentUserId});
}

/// Yeni bir sohbet mesajı gönderme olayı.
class SendChatMessageEvent extends ChatEvent {
  /// Gönderilecek mesaj varlığı
  final ChatMessageEntity message;
  SendChatMessageEvent(this.message);
}
