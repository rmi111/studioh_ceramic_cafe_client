import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/screens/chat/chat_view_page.dart';
import '../../model/user.dart';
import '../profile/admin_details.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit()..fetchAdminUsers(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          //leading: IconButton(onPressed: , icon: Icon(Icons.arrow_back_ios)),
          title: Text("Chats"),
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

                  return UserCard(user: admin);
                },
              );
            }
            return Center(  child: Lottie.asset(
              'assets/images/Animation - 1749106532062.json',
              width: 150,
              height: 150,
            ),);
          },
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

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
                // User Avatar
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

                // User Info
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatViewPage(
                         user:user,
                            chatType: "general",
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

                // User Type Badge
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
      // case 'staff':
      //   return Colors.grey[700]!;
      case 'customer':
        return Colors.orange[700]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
