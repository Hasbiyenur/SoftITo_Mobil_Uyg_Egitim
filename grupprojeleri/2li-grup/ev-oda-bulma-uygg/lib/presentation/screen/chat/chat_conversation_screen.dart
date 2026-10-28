import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';

/// Birebir Canlı Sohbet ve Mesajlaşma Ekranı:
/// Seçilen kullanıcıyla olan mesaj geçmişini gösterir, yeni metin mesajı yazma,
/// hızlı emoji paneli açma, örnek ev/oda fotoğrafı paylaşma ve otomatik en alta kaydırma (scroll to bottom) özelliklerini barındırır.
class ChatConversationScreen extends StatefulWidget {
  /// Sohbet edilen karşı tarafın kullanıcı ID'si
  final String peerId;

  /// Karşı tarafın adı
  final String peerName;

  /// Karşı tarafın avatar URL'si
  final String peerAvatarUrl;

  const ChatConversationScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatarUrl,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Konuşmaya ait mesajları veritabanından çek
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthenticatedState ? authState.user.id : 'user-demo-1';
    context.read<ChatBloc>().add(
          LoadMessagesEvent(
            conversationId: widget.peerId,
            currentUserId: currentUserId,
          ),
        );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sohbet listesini en son gönderilen mesaja (en alta) kaydırır
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Metin, emoji veya görsel içeren mesajı BLoC'a iletir
  void _sendMessage({String? imageUrl, String? emoji}) {
    final text = emoji ?? _msgController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthenticatedState ? authState.user.id : 'user-demo-1';

    final newMsg = ChatMessageEntity(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.peerId,
      senderId: currentUserId,
      receiverId: widget.peerId,
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isMe: true,
    );

    context.read<ChatBloc>().add(SendChatMessageEvent(newMsg));
    _msgController.clear();
    _scrollToBottom();
  }

  /// Hızlı emoji seçim modal panelini açar
  void _showEmojiPicker() {
    final emojis = ['👋', '😊', '🏠', '✨', '👍', '🔑', '☕', '🛋️'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emoji Seç',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: emojis.map((e) {
                return InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _sendMessage(emoji: e);
                  },
                  child: Text(e, style: const TextStyle(fontSize: 32)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Örnek oda/ev fotoğrafı paylaşımı yapar
  void _sendPhotoSample() {
    _sendMessage(
      imageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.peerAvatarUrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Çevrimiçi',
                    style: TextStyle(fontSize: 11, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mesaj Baloncukları Akışı
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                _scrollToBottom();
              },
              builder: (context, state) {
                List<ChatMessageEntity> messages = [];
                if (state is ChatLoadedState) {
                  messages =
                      state.messagesByConversation[widget.peerId] ?? [];
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      '${widget.peerName} ile ilk mesajınızı gönderin!',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.isMe;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.76,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? primaryColor
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.accentBeige),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(4),
                            bottomRight: isMe
                                ? const Radius.circular(4)
                                : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Mesajda görsel varsa göster
                            if (msg.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  msg.imageUrl!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            // Mesaj metni
                            if (msg.text.isNotEmpty)
                              Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: isMe
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textDark
                                          : AppColors.textLightPrimary),
                                ),
                              ),
                            const SizedBox(height: 3),
                            // Gönderilme saati
                            Text(
                              timeFormat.format(msg.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withAlpha(180)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Alt Mesaj Yazma Çubuğu (Girdi alanı, Emoji ve Kamera butonu, Gönder butonu)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withAlpha(40))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Emoji Paneli Açma Butonu
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    tooltip: 'Emoji Gönder',
                    onPressed: _showEmojiPicker,
                  ),
                  // Fotoğraf Gönderme Butonu
                  IconButton(
                    icon: const Icon(Icons.photo_camera_outlined),
                    tooltip: 'Fotoğraf Gönder',
                    onPressed: _sendPhotoSample,
                  ),
                  // Mesajı İlet Butonu
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: primaryColor),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
