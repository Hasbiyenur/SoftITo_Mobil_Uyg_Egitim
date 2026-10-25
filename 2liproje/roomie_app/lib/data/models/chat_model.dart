import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? imageUrl;
  final bool isEmojiOnly;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.isEmojiOnly = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
      'imageUrl': imageUrl,
      'isEmojiOnly': isEmojiOnly,
    };
  }

  factory ChatMessageModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMe: map['isMe'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      isEmojiOnly: map['isEmojiOnly'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    text,
    timestamp,
    isMe,
    imageUrl,
    isEmojiOnly,
  ];
}

class ChatConversationModel extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String? participantPhone;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? listingId;
  final String? listingTitle;
  final List<ChatMessageModel> messages;

  const ChatConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.participantPhone,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.listingId,
    this.listingTitle,
    this.messages = const [],
  });

  ChatConversationModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? participantPhone,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? listingId,
    String? listingTitle,
    List<ChatMessageModel>? messages,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      participantPhone: participantPhone ?? this.participantPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'participantPhone': participantPhone,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'messages': messages.map((e) => e.toMap()).toList(),
    };
  }

  factory ChatConversationModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatConversationModel(
      id: map['id'] as String? ?? '',
      participantId: map['participantId'] as String? ?? '',
      participantName: map['participantName'] as String? ?? '',
      participantAvatar: map['participantAvatar'] as String?,
      participantPhone: map['participantPhone'] as String?,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
      listingId: map['listingId'] as String?,
      listingTitle: map['listingTitle'] as String?,
      messages:
          (map['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    participantId,
    participantName,
    participantAvatar,
    lastMessage,
    lastMessageTime,
    unreadCount,
    listingId,
    messages,
  ];
}
