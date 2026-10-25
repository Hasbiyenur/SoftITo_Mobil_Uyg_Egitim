import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/empty_view.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    UserModel? user;
    if (auth is Authenticated) user = auth.user;
    context.read<ChatBloc>().add(LoadConversationsEvent(user));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mesajlarım',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = state is ChatLoaded
              ? state.conversations
              : <ChatConversationModel>[];

          if (conversations.isEmpty) {
            return const EmptyView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Henüz Mesajınız Yok',
              subtitle: 'İlan detay sayfalarında yer alan "İlan Sahibiyle İletişime Geç" butonu ile mesajlaşmaya başlayabilirsiniz.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMargin,
                  vertical: 4,
                ),
                // Section 9: "Konuşan kişilerin fotoğrafları yuvarlak ve ortalanmış olmalıdır."
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                  backgroundImage: conv.participantAvatar != null
                      ? NetworkImage(conv.participantAvatar!)
                      : null,
                  child: conv.participantAvatar == null
                      ? Text(
                          conv.participantName.isNotEmpty
                              ? conv.participantName[0]
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                // Section 9: "İsimleri fotoğrafın yanında üstte, son mesajları ise isimlerinin altında, birbirlerine daha yakın şekilde, fotoğraflardan biraz daha küçük punto ile yazılmalıdır."
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conv.participantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      DateFormatter.formatTime(conv.lastMessageTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: conv.unreadCount > 0
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.65,
                                  ),
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  if (currentUser != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          conversation: conv,
                          currentUser: currentUser!,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
