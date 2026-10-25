import '../../domain/entities/chat_entity.dart';

/// ChatMessageEntity sınıfının JSON dönüştürme işlemlerini yöneten Data Model karşılığı.
/// Mesajın o anki kullanıcıya ait olup olmadığını (isMe) belirlemek için currentUserId ile karşılaştırma yapar.
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.receiverId,
    required super.text,
    super.imageUrl,
    required super.timestamp,
    required super.isMe,
  });

  /// Ham JSON haritasından ChatMessageModel nesnesi oluşturur.
  /// [currentUserId] parametresi ile gönderen kimliği karşılaştırılarak 'isMe' bayrağı ayarlanır.
  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final sender = json['senderId'] as String;
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: sender,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isMe: sender == currentUserId,
    );
  }

  /// Mesaj nesnesini Hive veritabanında depolamak üzere JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
