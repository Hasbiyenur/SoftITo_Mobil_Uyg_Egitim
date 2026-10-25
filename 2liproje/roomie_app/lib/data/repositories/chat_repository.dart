import 'package:uuid/uuid.dart';

import '../../core/utils/image_storage_helper.dart';
import '../datasources/hive_storage_service.dart';
import '../models/chat_model.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  final HiveStorageService _storage;
  static const _uuid = Uuid();
  static const String _seededKey = 'is_chats_seeded_v1';

  ChatRepository({HiveStorageService? storage})
    : _storage = storage ?? HiveStorageService.instance;

  Future<void> initSampleChatsIfNeeded(UserModel? currentUser) async {
    final isSeeded =
        _storage.settingsBox.get(_seededKey, defaultValue: false) as bool;
    if (isSeeded && _storage.chatsBox.isNotEmpty) return;

    final initialChats = [
      ChatConversationModel(
        id: 'conv-001',
        participantId: 'user-owner-001',
        participantName: 'Selin Yılmaz',
        participantAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
        participantPhone: '+90 532 111 22 33',
        lastMessage: 'Merhaba! Oda hala müsait, ne zaman görmek istersin?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        unreadCount: 1,
        listingId: 'roomie-001',
        listingTitle: 'Kadıköy Moda\'da Ferah ve Balkonlu Oda',
        messages: [
          ChatMessageModel(
            id: 'm1',
            senderId: 'user-owner-001',
            senderName: 'Selin Yılmaz',
            text: 'Merhaba, ilanımla ilgilendiğini gördüm! 😊',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isMe: false,
          ),
          ChatMessageModel(
            id: 'm2',
            senderId: currentUser?.id ?? 'me',
            senderName: currentUser?.fullName ?? 'Ben',
            text:
                'Merhaba Selin, ev metroya ve sahile ne kadar mesafede acaba?',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 40),
            ),
            isMe: true,
          ),
          ChatMessageModel(
            id: 'm3',
            senderId: 'user-owner-001',
            senderName: 'Selin Yılmaz',
            text: 'Tramvay durağı 3 dakika, sahil yürüyerek 5 dakika mesafede. Evde çok sakin bir ortam var.',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 20),
            ),
            isMe: false,
          ),
          ChatMessageModel(
            id: 'm4',
            senderId: 'user-owner-001',
            senderName: 'Selin Yılmaz',
            text: 'Merhaba! Oda hala müsait, ne zaman görmek istersin?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            isMe: false,
          ),
        ],
      ),
      ChatConversationModel(
        id: 'conv-002',
        participantId: 'user-owner-002',
        participantName: 'Caner Demir',
        participantAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        participantPhone: '+90 533 222 33 44',
        lastMessage: 'Fatura paylaşımı eşit yapılıyor dostum 👍',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
        unreadCount: 0,
        listingId: 'roomie-002',
        listingTitle: 'Beşiktaş Çarşı\'ya 5 Dk Aydınlık Eşyalı Oda',
        messages: [
          ChatMessageModel(
            id: 'm21',
            senderId: currentUser?.id ?? 'me',
            senderName: currentUser?.fullName ?? 'Ben',
            text: 'Selam Caner, aidat ve faturalar kiraya dahil mi?',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            isMe: true,
          ),
          ChatMessageModel(
            id: 'm22',
            senderId: 'user-owner-002',
            senderName: 'Caner Demir',
            text: 'Fatura paylaşımı eşit yapılıyor dostum 👍',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            isMe: false,
          ),
        ],
      ),
    ];

    for (final chat in initialChats) {
      await _storage.chatsBox.put(chat.id, chat.toMap());
    }
    await _storage.settingsBox.put(_seededKey, true);
  }

  List<ChatConversationModel> getConversations() {
    final List<ChatConversationModel> list = [];
    for (var key in _storage.chatsBox.keys) {
      final data = _storage.chatsBox.get(key);
      if (data is Map) {
        list.add(
          ChatConversationModel.fromMap(Map<dynamic, dynamic>.from(data)),
        );
      }
    }
    list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return list;
  }

  ChatConversationModel? getConversationById(String id) {
    final data = _storage.chatsBox.get(id);
    if (data is Map) {
      return ChatConversationModel.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  Future<ChatConversationModel> startConversationWithListingOwner({
    required ListingModel listing,
    required UserModel currentUser,
  }) async {
    final all = getConversations();
    // Look for existing conversation with this owner for this listing
    final existing = all
        .where((c) => c.participantId == listing.owner.id)
        .firstOrNull;
    if (existing != null) {
      return existing;
    }

    final newConv = ChatConversationModel(
      id: 'conv_${_uuid.v4().substring(0, 8)}',
      participantId: listing.owner.id,
      participantName: listing.owner.fullName,
      participantAvatar: listing.owner.avatar,
      participantPhone: listing.owner.phone,
      lastMessage:
          'Merhaba! "${listing.title}" ilanınız hakkında bilgi alabilir miyim?',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      listingId: listing.id,
      listingTitle: listing.title,
      messages: [
        ChatMessageModel(
          id: _uuid.v4(),
          senderId: currentUser.id,
          senderName: currentUser.fullName,
          text:
              'Merhaba! "${listing.title}" ilanınız hakkında bilgi alabilir miyim?',
          timestamp: DateTime.now(),
          isMe: true,
        ),
      ],
    );

    await _storage.chatsBox.put(newConv.id, newConv.toMap());
    return newConv;
  }

  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String text,
    required UserModel currentUser,
    String? imagePath,
    bool isEmojiOnly = false,
  }) async {
    final conv = getConversationById(conversationId);
    if (conv == null) throw Exception('Sohbet bulunamadı.');

    String? permanentImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      permanentImagePath = await ImageStorageHelper.saveImagePermanently(
        imagePath,
      );
    }

    final message = ChatMessageModel(
      id: _uuid.v4(),
      senderId: currentUser.id,
      senderName: currentUser.fullName,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      imageUrl: permanentImagePath,
      isEmojiOnly: isEmojiOnly,
    );

    final updatedMessages = List<ChatMessageModel>.from(conv.messages)
      ..add(message);
    final updatedConv = conv.copyWith(
      lastMessage: permanentImagePath != null ? '📷 Fotoğraf' : text,
      lastMessageTime: DateTime.now(),
      messages: updatedMessages,
    );

    await _storage.chatsBox.put(updatedConv.id, updatedConv.toMap());
    return message;
  }

  /// Sends automated early exit request message to tenant as requested in screen.md Section 7.
  Future<void> sendEarlyExitRequestToTenant({
    required String tenantId,
    required String tenantName,
    String? tenantAvatar,
    required String listingTitle,
    required UserModel currentUser,
  }) async {
    final all = getConversations();
    var conv = all.where((c) => c.participantId == tenantId).firstOrNull;

    final exitMessage =
        'Sayın $tenantName, kiraladığınız "$listingTitle" için konut kuralları gereği erken çıkış yapmanız talep edilmektedir. Lütfen en kısa sürede çıkış işlemlerini tamamlayınız.';

    conv ??= ChatConversationModel(
      id: 'conv_exit_${_uuid.v4().substring(0, 8)}',
      participantId: tenantId,
      participantName: tenantName,
      participantAvatar: tenantAvatar,
      lastMessage: exitMessage,
      lastMessageTime: DateTime.now(),
      messages: [],
    );

    final message = ChatMessageModel(
      id: _uuid.v4(),
      senderId: currentUser.id,
      senderName: currentUser.fullName,
      text: exitMessage,
      timestamp: DateTime.now(),
      isMe: true,
    );

    final updatedMessages = List<ChatMessageModel>.from(conv.messages)
      ..add(message);
    final updatedConv = conv.copyWith(
      lastMessage: exitMessage,
      lastMessageTime: DateTime.now(),
      messages: updatedMessages,
    );

    await _storage.chatsBox.put(updatedConv.id, updatedConv.toMap());
  }
}
