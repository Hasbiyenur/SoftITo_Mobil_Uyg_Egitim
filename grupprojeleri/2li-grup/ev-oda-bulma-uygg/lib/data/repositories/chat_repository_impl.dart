import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';

/// ChatRepository arayüzünün yerel Hive veritabanı ile çalışan uygulaması.
/// Mesaj geçmişi oluşturma, mesaj gönderme ve konuşmaları gruplama işlemlerini yürütür.
class ChatRepositoryImpl implements ChatRepository {
  /// Mesajların depolandığı Hive kutusunun adı
  static const String _boxName = 'chats_box';

  Box get _box => Hive.box(_boxName);

  /// Giriş yapan kullanıcının dahil olduğu konuşmaları (sohbet odalarını) listeler.
  /// Mesajları karşı taraftaki kullanıcıya (peerId) göre gruplar ve en güncel mesajı özet olarak hazırlar.
  @override
  Future<List<ChatConversationEntity>> getConversations(String currentUserId) async {
    _ensureInitialSampleChats(currentUserId);

    final Map<String, List<ChatMessageModel>> groupedByPeer = {};

    // Hive kutusundaki tüm mesajları gez ve karşı tarafa göre grupla
    for (var key in _box.keys) {
      final String? itemJson = _box.get(key) as String?;
      if (itemJson != null) {
        try {
          final map = jsonDecode(itemJson) as Map<String, dynamic>;
          final msg = ChatMessageModel.fromJson(map, currentUserId);
          final peerId = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;

          if (!groupedByPeer.containsKey(peerId)) {
            groupedByPeer[peerId] = [];
          }
          groupedByPeer[peerId]!.add(msg);
        } catch (_) {}
      }
    }

    final List<ChatConversationEntity> conversations = [];
    // Demo profil verileri (Görseller ve isimler için eşleştirme)
    final Map<String, Map<String, String>> peerProfiles = {
      'owner-1': {
        'name': 'Ece Yılmaz',
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      },
      'owner-2': {
        'name': 'Mert Demir',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      },
      'tenant-demo-1': {
        'name': 'Zeynep Aksoy',
        'avatar':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      },
    };

    // Her bir kullanıcı grubu için son mesajı tespit et ve konuşma kartını oluştur
    groupedByPeer.forEach((peerId, messages) {
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final lastMsg = messages.first;
      final profile = peerProfiles[peerId] ??
          {
            'name': 'Kullanıcı $peerId',
            'avatar':
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
          };

      conversations.add(
        ChatConversationEntity(
          id: peerId,
          peerId: peerId,
          peerName: profile['name']!,
          peerAvatarUrl: profile['avatar']!,
          lastMessage: lastMsg.text,
          lastMessageTime: lastMsg.timestamp,
          unreadCount: 0,
        ),
      );
    });

    // En son mesaj atılan konuşmayı listenin en üstüne koy
    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }

  /// Belirli bir konuşma odasına ait mesajları kronolojik sırayla (eskiden yeniye) getirir.
  @override
  Future<List<ChatMessageEntity>> getMessages(
      String conversationId, String currentUserId) async {
    _ensureInitialSampleChats(currentUserId);

    final List<ChatMessageEntity> messages = [];

    for (var key in _box.keys) {
      final String? itemJson = _box.get(key) as String?;
      if (itemJson != null) {
        try {
          final map = jsonDecode(itemJson) as Map<String, dynamic>;
          final msg = ChatMessageModel.fromJson(map, currentUserId);
          // İlgili odaya veya karşı kullanıcıya ait mesajları filtrele
          if (msg.conversationId == conversationId ||
              msg.senderId == conversationId ||
              msg.receiverId == conversationId) {
            messages.add(msg);
          }
        } catch (_) {}
      }
    }

    // Mesajları zamana göre artan sırala (sohbet akışı)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Yeni mesajı veritabanına ekler.
  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    final model = ChatMessageModel(
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      receiverId: message.receiverId,
      text: message.text,
      imageUrl: message.imageUrl,
      timestamp: message.timestamp,
      isMe: true,
    );
    await _box.put(message.id, jsonEncode(model.toJson()));
  }

  /// Uygulama ilk açıldığında boş olmaması için örnek mesajlaşma geçmişi yükler.
  void _ensureInitialSampleChats(String currentUserId) {
    if (_box.isEmpty) {
      final now = DateTime.now();

      final m1 = ChatMessageModel(
        id: 'msg-1',
        conversationId: 'owner-1',
        senderId: 'owner-1',
        receiverId: currentUserId,
        text: 'Merhaba Betül! Odayı ne zaman görmek istersin?',
        timestamp: now.subtract(const Duration(hours: 3)),
        isMe: false,
      );

      final m2 = ChatMessageModel(
        id: 'msg-2',
        conversationId: 'owner-1',
        senderId: currentUserId,
        receiverId: 'owner-1',
        text: 'Merhaba Ece hanım, yarın akşamüstü saat 18:00 uygun mudur?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
        isMe: true,
      );

      final m3 = ChatMessageModel(
        id: 'msg-3',
        conversationId: 'owner-1',
        senderId: 'owner-1',
        receiverId: currentUserId,
        text: 'Evet harika, bekliyorum!',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        isMe: false,
      );

      final m4 = ChatMessageModel(
        id: 'msg-4',
        conversationId: 'tenant-demo-1',
        senderId: 'tenant-demo-1',
        receiverId: currentUserId,
        text: 'Merhaba, ilanınız için teşekkürler. Giriş gününde anahtarı nasıl alabilirim?',
        timestamp: now.subtract(const Duration(minutes: 50)),
        isMe: false,
      );

      _box.put(m1.id, jsonEncode(m1.toJson()));
      _box.put(m2.id, jsonEncode(m2.toJson()));
      _box.put(m3.id, jsonEncode(m3.toJson()));
      _box.put(m4.id, jsonEncode(m4.toJson()));
    }
  }
}
