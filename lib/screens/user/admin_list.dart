import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/model/chat_room.dart';
import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/screens/chat/chat_view_page.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_appbar.dart';
import '../../model/user.dart';
import '../profile/admin_details.dart';

class ChatListPage extends StatelessWidget {
  final OrderModel? order;
  ChatListPage({Key? key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit()..fetchAdminUsers(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 60),
          child: DefaultAppBar(title: 'Chats with Admins'),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (!state.isLoading) {
              if (state.adminUsers.isEmpty) {
                return const Center(child: Text("No Admins Found"));
              }
              return ListView.builder(
                itemCount: state.adminUsers.length,
                itemBuilder: (context, index) {
                  final admin = state.adminUsers[index];
                  return UserCard(
                    order: order,
                    user: admin,
                  ); // ✅ no force unwrap
                },
              );
            }
            return Center(
              child: Lottie.asset(
                'assets/images/Animation - 1749106532062.json',
                width: 150,
                height: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final OrderModel? order;
  final UserModel user;

  const UserCard({Key? key, this.order, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(user: user),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'user-avatar-${user.uid}',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: _getUserTypeColor(
                        user.userType,
                      ).withOpacity(0.2),
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getUserTypeColor(user.userType),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Info
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatRoom: ChatRoom(
                             otherUserId: user.uid,
                            otherUserName: user.name,
                            otherUserImage: user.imageUrl,
                            chatType: "item_query",
                            ownerEmail: user.email,
                            ownerName: user.name,
                            productImage: order?.imgUrl.isNotEmpty == true
                                ? order!.imgUrl[0]
                                : null,
                            productName: order?.description,
                            productId: order?.refNumber,
                            chatRoomId:
                                '${user.uid}-${context.read<AuthCubit>().state.currentUserModel!.uid}',
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF614637),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (user.phoneNumber != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                user.phoneNumber!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.userType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.userType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _getUserTypeColor(user.userType),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Colors.red[700]!;
      case 'customer':
        return Colors.orange[700]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
