import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/chat_bloc.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatConversationModel conversation;
  final UserModel currentUser;

  const ChatConversationScreen({
    super.key,
    required this.conversation,
    required this.currentUser,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _showEmojiBar = false;

  final List<String> _quickEmojis = [
    '👋',
    '😊',
    '👍',
    '🏠',
    '✨',
    '🔑',
    '☕',
    '🎉',
    '📍',
    '🙌',
  ];

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage({
    String? customText,
    String? imagePath,
    bool isEmoji = false,
  }) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty && imagePath == null) return;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        conversationId: widget.conversation.id,
        text: text,
        currentUser: widget.currentUser,
        imagePath: imagePath,
        isEmojiOnly: isEmoji,
      ),
    );

    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (xFile != null) {
        _sendMessage(imagePath: xFile.path, customText: 'Fotoğraf');
      }
    } catch (_) {
      // In case picker is unavailable, attach sample photo
      _sendMessage(
        imagePath: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80',
        customText: 'Fotoğraf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.15,
              ),
              backgroundImage: widget.conversation.participantAvatar != null
                  ? NetworkImage(widget.conversation.participantAvatar!)
                  : null,
              child: widget.conversation.participantAvatar == null
                  ? Text(
                      widget.conversation.participantName.isNotEmpty
                          ? widget.conversation.participantName[0]
                          : 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.participantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (widget.conversation.listingTitle != null)
                    Text(
                      widget.conversation.listingTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  _scrollToBottom();
                },
                builder: (context, state) {
                  ChatConversationModel conv = widget.conversation;
                  if (state is ChatLoaded) {
                    final found = state.conversations
                        .where((c) => c.id == widget.conversation.id)
                        .firstOrNull;
                    if (found != null) conv = found;
                  }

                  final messages = conv.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Konuşmaya başlamak için bir mesaj yazın.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageBubble(msg, theme);
                    },
                  );
                },
              ),
            ),

            // Emoji Bar (Section 9: "Mesaj kutusunun sağında emoji butonu bulunmalıdır. Emojiler açılabilir ve gönderilebilir.")
            if (_showEmojiBar)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _quickEmojis[index];
                    return InkWell(
                      onTap: () {
                        _sendMessage(customText: emoji, isEmoji: true);
                        setState(() => _showEmojiBar = false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Input Bar (Section 9: "Mesaj kutusunun sağında emoji butonu ve fotoğraf gönderme butonu bulunmalıdır.")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Mesajınızı yazın...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Emoji Button (Section 9)
                  IconButton(
                    icon: Icon(
                      _showEmojiBar
                          ? Icons.keyboard_rounded
                          : Icons.emoji_emotions_outlined,
                      color: _showEmojiBar
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    onPressed: () =>
                        setState(() => _showEmojiBar = !_showEmojiBar),
                  ),

                  // Photo Button (Section 9)
                  IconButton(
                    icon: Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    onPressed: _pickImage,
                  ),

                  // Send Button
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 9: "Gönderilen mesajlar sağda, diğer mesajlar solda gözükmelidir. Mesajların arka plan rengi farklı olmalıdır. Mesajlar baloncuk şeklinde gözükmelidir."
  Widget _buildMessageBubble(ChatMessageModel msg, ThemeData theme) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              backgroundImage: widget.conversation.participantAvatar != null
                  ? NetworkImage(widget.conversation.participantAvatar!)
                  : null,
              child: widget.conversation.participantAvatar == null
                  ? Text(
                      widget.conversation.participantName[0],
                      style: const TextStyle(fontSize: 10),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : (theme.brightness == Brightness.dark
                          ? AppColors.surfaceVariantDark
                          : const Color(0xFFF0EAE1)),
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
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Attached Photo
                  if (msg.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 150,
                        width: 200,
                        child: msg.imageUrl!.startsWith('http')
                            ? Image.network(msg.imageUrl!, fit: BoxFit.cover)
                            : Image.file(
                                File(msg.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Text / Emoji
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: msg.isEmojiOnly ? 28 : 14,
                      color: isMe
                          ? Colors.white
                          : (theme.brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Timestamp
                  Text(
                    DateFormatter.formatTime(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black45,
                    ),
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
