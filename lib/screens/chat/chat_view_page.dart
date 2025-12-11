import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/chat_cubit/chat_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/chat_cubit/chat_state.dart';
import 'package:studioh_ceramic_cafe_client/cubit/order_cubit/order_cubit.dart';
import 'package:studioh_ceramic_cafe_client/model/message.dart' as prefix0;
import 'package:studioh_ceramic_cafe_client/model/message.dart';
import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/model/user.dart';
import 'package:studioh_ceramic_cafe_client/screens/order/order_details_page.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_appbar.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/image_slider.dart';

import '../../utils/widget/snacke_bar.dart';
import '../profile/admin_details.dart';


class ChatViewPage extends StatefulWidget {
 final UserModel user;
  final String? chatId;

  final String? productId;
  final String chatType;

  const ChatViewPage({
    Key? key,
    this.chatId,
    required this.user
    ,

    this.productId,
    this.chatType = 'general',
  }) : super(key: key);

  @override
  State<ChatViewPage> createState() => _ChatViewPageState();
}

class _ChatViewPageState extends State<ChatViewPage> {
  late TextEditingController messageController;
  late FocusNode myFocusNode;
  late ScrollController _scrollController;
  OrderModel? orderModel;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    myFocusNode = FocusNode();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authState = context.read<AuthCubit>().state;
        final userId = authState.currentUserModel?.uid;

        if (userId != null) {
          context.read<ChatCubit>().markMessagesAsSeen(
            userId: userId,
            otherUserID: widget.user.uid,
            chatType: widget.chatType,
            productId: widget.productId,
          );
        }
      } catch (e) {
        print('Error marking messages as seen: $e');
      }
    });

    if (widget.chatType == 'item_query' && widget.productId != null) {
      try {
        final order =
        context.read<OrderCubit>().getOrderByRef(widget.productId ?? '');
        if (order != null) {
          setState(() {
            orderModel = order;
          });
        }
      } catch (e) {
        print('Error fetching order: $e');
      }
    }

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => _scrollDown());
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => _scrollDown());
  }

  @override
  void dispose() {
    messageController.dispose();
    myFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      try {
        context.read<ChatCubit>().sendMessage(
          message: messageController.text,
          receiverId: widget.user.uid,
          chatType: widget.chatType,
          productId: widget.productId,
        );
        messageController.clear();
        _scrollDown();
      } catch (e) {
        print('Error sending message: $e');
        AppSnackbar.showError(context,
          'Error \nFailed to send message: $e',
        
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState.currentUserModel;

        if (currentUser == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to use chat',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return WillPopScope(
          onWillPop: () async {
           Navigator.pop(context);
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _buildAppBar(),
            body: Column(
              children: [
                if (widget.chatType == 'item_query' && orderModel != null)
                  _buildItemCard(orderModel!),
                Expanded(child: _buildMessageList(currentUser.uid)),
                _buildMessageInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        splashRadius: 24,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget. user.email.isEmpty ? widget.user.name : widget.user.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Active now',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(user:widget.user),
              ),
            );
          },
          icon: const Icon(Icons.person_outline),
          splashRadius: 24,
        ),
        IconButton(
          onPressed: () {
            // TODO: Call/video feature
          },
          icon: const Icon(Icons.phone_outlined),
          splashRadius: 24,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildItemCard(OrderModel order) {
    String formatDate(int millis) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('dd MMM yyyy').format(date);
    }

    const Map<String, String> potteryOrderStatus = {
      'ready_for_glaze': 'Ready for Glaze',
      'prepared': 'Prepared',
      'collected': 'Collected',
      'uncollected': 'Uncollected',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> OrderDetailPage(order: order)));

      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (order.imgUrl.isNotEmpty && order.imgUrl[0].isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => ImageSliderDialog(
                      images: order.imgUrl,
                      initialIndex: order.imgUrl.length - 1,
                    ),
                  );
                }
              },
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: (order.imgUrl.isNotEmpty &&
                      order.imgUrl[0].isNotEmpty)
                      ? DecorationImage(
                    image: NetworkImage(
                      order.imgUrl[order.imgUrl.length - 1],
                    ),
                    fit: BoxFit.cover,
                  )
                      : const DecorationImage(
                    image: AssetImage(
                      'assets/images/no-image-icon-4.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ref: ${order.refNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.users[0].name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(order.orderDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD38351).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      potteryOrderStatus[order.status] ?? 'Uncollected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD38351),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(String currentUserId) {
    try {
      final messageStream = context.read<ChatCubit>().getMessagesStream(
        userId: currentUserId,
        otherUserID: widget.user.uid,
        chatType: widget.chatType,
        productId: widget.productId,
      );

      return StreamBuilder<List<Message>>(
        stream: messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading messages',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.button,
              ),
            );
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(messages[index], currentUserId);
            },
          );
        },
      );
    } catch (e) {
      print('Error building message list: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageItem(Message message, String currentUserId) {
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(message.date);
    String formattedTime = DateFormat('h:mm a').format(createdAt);
    bool isCurrentUser = message.senderID == currentUserId;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppColors.button
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isCurrentUser
              ? null
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(
                color:
                isCurrentUser ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      focusNode: myFocusNode,
                      controller: messageController,
                      enabled: !state.isLoading,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: state.isLoading ? null : _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: state.isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                            const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}