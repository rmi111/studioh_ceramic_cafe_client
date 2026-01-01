import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:studioh_ceramic_cafe_client/cubit/order_cubit/order_cubit.dart';
import 'package:studioh_ceramic_cafe_client/model/chat_room.dart';
import 'package:studioh_ceramic_cafe_client/screens/user/admin_list.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import '../../cubit/auth_cubit/auth_cubit.dart';
import '../../cubit/chat_cubit/chat_cubit.dart';
import '../../cubit/chat_cubit/chat_state.dart';
import 'chat_view_page.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.currentUserModel?.uid ?? '';

    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: const Color(0xFFeeae4d),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please login to view messages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => ChatCubit(
        orderCubit: context.read<OrderCubit>(),
        currentUserId: currentUserId,
      )..loadChatList(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatListPage()),
            );
          },
          backgroundColor: AppColors.button,
          child: const Icon(Icons.person_add_alt, color: Colors.white),
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/images/Animation - 1749106532062.json',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 16),
                    const Text('Please Wait....'),
                  ],
                ),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ChatCubit>().loadChatList(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFeeae4d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ChatLoaded) {
              if (state.chatRooms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFeeae4d).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 56,
                          color: Color(0xFFeeae4d),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.chatRooms.length,
                itemBuilder: (context, index) {
                  final chat = state.chatRooms[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: _ChatListTile(chat: chat),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom chat;

  const _ChatListTile({required this.chat});

  @override
  Widget build(BuildContext context) {
       // print("Other user Image: ${chat.otherUserImage}");
    final isItemQuery = chat.chatType == 'item_query';
    final hasUnseen = chat.unseenCount > 0;

    return GestureDetector(
      onTap: () async {

        context.read<ChatCubit>().markMessagesAsSeen(chat.chatRoomId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatRoom: chat,
            ),
          ),
        );

      },
      child: Container(
        decoration: BoxDecoration(
          color: hasUnseen
              ? const Color(0xFFeeae4d).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUnseen
                ? const Color(0xFFeeae4d).withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: chat.otherUserImage != null
                          ? NetworkImage(chat.otherUserImage!)
                          : null,
                      backgroundColor: const Color(0xFFeeae4d).withOpacity(0.2),
                      child: chat.otherUserImage == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFFeeae4d),
                            )
                          : null,
                    ),
                  ),
                  if (hasUnseen)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${chat.unseenCount > 99 ? '99+' : chat.unseenCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherUserName,
                            style: TextStyle(
                              fontWeight: hasUnseen
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.lastMessageTime != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              _formatTime(chat.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnseen
                                    ? const Color(0xFFeeae4d)
                                    : Colors.grey[500],
                                fontWeight: hasUnseen
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (isItemQuery && chat.productName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            size: 13,
                            color: const Color(0xFFeeae4d),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              chat.productId!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFeeae4d),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (chat.lastMessage != null)
                      Text(
                        chat.lastMessage!,
                        style: TextStyle(
                          color: hasUnseen ? Colors.black87 : Colors.grey[600],
                          fontWeight: hasUnseen
                              ? FontWeight.w500
                              : FontWeight.w400,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}
