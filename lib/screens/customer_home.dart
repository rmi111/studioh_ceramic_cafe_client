import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/cubit/notification_cubit/notification_cubit.dart';
import 'package:studioh_ceramic_cafe_client/screens/chat/user_list.dart';
import 'package:studioh_ceramic_cafe_client/screens/order/order_list_page.dart';
import 'package:studioh_ceramic_cafe_client/screens/voucher/voucher_page.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import 'package:studioh_ceramic_cafe_client/utils/route/app_routes.dart';
import '../cubit/auth_cubit/auth_cubit.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});
  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const Center(
      child: Text(
        'Tips Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const VoucherPage(),
    const OrderListPage(),
    const ChatListScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Tips'),
    BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Vouchers'),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Orders',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),
            
            // Main Content
            Expanded(
              child: _pages.elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: _navItems,
        selectedItemColor: AppColors.button,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar (Left)
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.currentUserModel;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.button, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.button.withOpacity(0.1),
                    backgroundImage: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                        ? NetworkImage(user.imageUrl!)
                        : null,
                    child: user?.imageUrl == null || user!.imageUrl!.isEmpty
                        ? Icon(Icons.person, color: AppColors.button, size: 22)
                        : null,
                  ),
                ),
              );
            },
          ),

          // Logo/Title (Center)
          Text(
            'Studioh',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.button,
              letterSpacing: 0.5,
            ),
          ),

          // Settings & Notifications (Right)
          Row(
            children: [
              // Notifications
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, notificationState) {
                  final unread = notificationState.unreadCount;
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, AppRoutes.notifications);
                          // Badge may have changed while the panel was open.
                          if (context.mounted) {
                            context
                                .read<NotificationCubit>()
                                .refreshUnreadCount();
                          }
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Colors.grey[800],
                          size: 26,
                        ),
                      ),
                      // Badge only when there is something unread.
                      if (unread > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 18),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // Settings
              IconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.grey[800],
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
