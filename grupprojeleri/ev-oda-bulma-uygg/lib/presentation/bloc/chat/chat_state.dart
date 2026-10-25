import '../../../domain/entities/chat_entity.dart';

/// Sohbet ve mesajlaşma ekranlarının durum (State) temel soyut sınıfı.
abstract class ChatState {}

/// İlk durum; sohbet verileri henüz çekilmemişken geçerlidir.
class ChatInitialState extends ChatState {}

/// Sohbet odaları yüklenirken gösterilen yükleme durumu.
class ChatLoadingState extends ChatState {}

/// Sohbet odalarının ve konuşma geçmişlerinin yüklendiği ana durum.
class ChatLoadedState extends ChatState {
  /// Kullanıcının tüm konuşma odalarının listesi
  final List<ChatConversationEntity> conversations;

  /// Konuşma ID'sine göre gruplanmış mesaj listeleri haritası
  final Map<String, List<ChatMessageEntity>> messagesByConversation;

  ChatLoadedState({
    required this.conversations,
    required this.messagesByConversation,
  });

  /// Mevcut sohbet durumunun belirli alanlarını güncelleyerek yeni kopya oluşturur.
  ChatLoadedState copyWith({
    List<ChatConversationEntity>? conversations,
    Map<String, List<ChatMessageEntity>>? messagesByConversation,
  }) {
    return ChatLoadedState(
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
    );
  }
}

/// Mesaj gönderilirken veya yüklenirken bir hata meydana geldiğinde yayılan durum.
class ChatErrorState extends ChatState {
  /// Hata mesajı içeriği
  final String message;
  ChatErrorState(this.message);
}
