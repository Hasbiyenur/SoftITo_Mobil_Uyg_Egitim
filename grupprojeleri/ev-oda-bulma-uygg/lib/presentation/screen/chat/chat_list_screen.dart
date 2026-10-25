import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import 'chat_conversation_screen.dart';

/// Mesajlar (Sohbet Odaları) Ekranı:
/// Kullanıcının ev sahipleri veya kiracılarla yaptığı aktif sohbetlerin özetini (avatar, isim, son mesaj, saat) listeler.
/// Bir sohbete dokunulduğunda ilgili konuşma detay ekranına (ChatConversationScreen) yönlendirir.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Kullanıcının sohbet odalarını yükleme olayını tetikle
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthenticatedState ? authState.user.id : 'user-demo-1';
    context.read<ChatBloc>().add(LoadConversationsEvent(currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoadedState) {
            final conversations = state.conversations;

            // Henüz mesajlaşma başlatılmamışsa bilgilendirici boş ekran
            if (conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.forum_outlined,
                            size: 64, color: primaryColor),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Henüz mesajınız bulunmuyor',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'İlan detay sayfalarındaki "Mesaj Gönder" butonunu kullanarak ev sahipleriyle iletişime geçebilirsiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final timeFormat = DateFormat('HH:mm');

            // Konuşma odaları listesi
            return ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (ctx, index) => const Divider(
                height: 1,
                indent: 78,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = conversations[index];

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          peerId: item.peerId,
                          peerName: item.peerName,
                          peerAvatarUrl: item.peerAvatarUrl,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Yuvarlak profil avatarı
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(item.peerAvatarUrl),
                        ),
                        const SizedBox(width: 14),
                        // Karşı tarafın ismi ve son mesaj özeti
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.peerName,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    timeFormat.format(item.lastMessageTime),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textDark.withAlpha(160)
                                      : AppColors.textLightSecondary
                                          .withAlpha(160),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
