/// Tek bir sohbet mesajını temsil eden Domain Entity sınıfı.
class ChatMessageEntity {
  /// Mesajın benzersiz kimliği
  final String id;

  /// Mesajın ait olduğu sohbet/konuşma odasının kimliği
  final String conversationId;

  /// Mesajı gönderen kullanıcının kimliği
  final String senderId;

  /// Mesajın alıcısı olan kullanıcının kimliği
  final String receiverId;

  /// Mesajın metin içeriği
  final String text;

  /// Mesajda paylaşılan opsiyonel görsel URL'si
  final String? imageUrl;

  /// Mesajın gönderilme zamanı
  final DateTime timestamp;

  /// Mesajın o anki giriş yapmış kullanıcı tarafından gönderilip gönderilmediği
  final bool isMe;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    required this.isMe,
  });
}

/// Mesajlar listesinde gösterilen bir konuşma özetini (oda) temsil eden Domain Entity sınıfı.
class ChatConversationEntity {
  /// Konuşmanın benzersiz kimliği
  final String id;

  /// Sohbet edilen karşı tarafın kullanıcı kimliği
  final String peerId;

  /// Sohbet edilen kişinin adı
  final String peerName;

  /// Sohbet edilen kişinin profil resmi URL'si
  final String peerAvatarUrl;

  /// Konuşmadaki en son gönderilen mesajın metni
  final String lastMessage;

  /// Son mesajın gönderilme zamanı
  final DateTime lastMessageTime;

  /// Okunmamış mesaj sayısı
  final int unreadCount;

  const ChatConversationEntity({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
