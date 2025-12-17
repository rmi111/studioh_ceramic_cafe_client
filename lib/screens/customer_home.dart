import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/screens/chat/user_list.dart';
import 'package:studioh_ceramic_cafe_client/screens/order/order_list_page.dart';
import 'package:studioh_ceramic_cafe_client/screens/voucher/voucher_page.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';


class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});
  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}
class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Center(
      child: Text(
        'Tips Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),

    VoucherPage(),
    OrderListPage(),
    ChatListScreen(
   
    ),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Tapped ${_navItems[index].label}')));
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Tips'),
    BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Vouchers'),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Book Now',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
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
}
