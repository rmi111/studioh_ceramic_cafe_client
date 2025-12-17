import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:studioh_ceramic_cafe_client/screens/order/serch_via_reference_id.dart';
import '../../cubit/auth_cubit/auth_cubit.dart';
import '../../cubit/order_cubit/order_cubit.dart';
import '../../model/orders.dart';
import '../../utils/constant/app_colors.dart';
import '../../utils/widget/animated_border_container.dart';
import '../../utils/widget/custom_text.dart';
import '../../utils/widget/item_card.dart';
import '../profile/profile_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final isAdmin = authState.currentUserModel?.userType == 'admin';
      context.read<OrderCubit>().fetchOrders(isAdmin: isAdmin);
    });
  }

  @override
  String formatDate(int millis) {
    DateTime orderedDate = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd MMM yyyy, h:mm a').format(orderedDate);
  }

  String formatReturnDate(int millis) {
    DateTime orderedDate = DateTime.fromMillisecondsSinceEpoch(millis);
    DateTime futureDate = orderedDate.add(const Duration(days: 7));
    return DateFormat('dd MMM yyyy').format(futureDate);
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    return BlocProvider(
      create: (context) =>
          OrderCubit(authCubit: context.read<AuthCubit>())
            ..listenToOrders(isAdmin: false),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.background,
                      backgroundImage:
                          authCubit.state.currentUserModel!.imageUrl != null &&
                              authCubit
                                  .state
                                  .currentUserModel!
                                  .imageUrl!
                                  .isNotEmpty
                          ? NetworkImage(
                              authCubit.state.currentUserModel!.imageUrl!,
                            )
                          : null,
                      child:
                          authCubit.state.currentUserModel!.imageUrl == null ||
                              authCubit
                                  .state
                                  .currentUserModel!
                                  .imageUrl!
                                  .isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppColors.button,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const CustomText(
                  text: 'Tracking Page',
                  fontSizeFactor: 1.2,
                  color: Colors.black,
                ),
                const Spacer(),
                // IconButton(
                //   onPressed: () {
                // //    Get.to(() => const MyVouchersScreen());
                //   },
                //   icon: const Icon(
                //     Icons.card_giftcard,
                //     size: 25,
                //     color: AppColors.button,
                //   ),
                // ),
                IconButton(
                  onPressed: () {
                    //  Navigator.push(context, MaterialPageRoute(builder: (context)=> AddOrderPage()));
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: AppColors.button,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderstate) {
            final currentUser = context
                .read<AuthCubit>()
                .state
                .currentUserModel;

            if (currentUser != null) {
              print('Current User: ${currentUser.email}');
              print('User Name: ${currentUser.name}');
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _buildBody(orderstate),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(OrderState orderState) {
    if (orderState.isLoading) {
      return Center(
        child: Lottie.asset(
          'assets/images/Animation - 1749106532062.json',
          width: 150,
          height: 150,
        ),
      );
    }

    if (orderState.orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomText(
              text:
                  "No orders found. Please click the button below to add an order.",
              fontSizeFactor: 1.2,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchViaReferenceId()),
              ),
              child: const ShimmerBorderContainer(),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF614637),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: "Browse. Buy. Beautify",
                      color: Colors.white,
                      fontSizeFactor: 0.8,
                    ),
                    const CustomText(
                      text: "Where Clay Meets Creativity",
                      fontSizeFactor: 1.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchViaReferenceId(),
                          ),
                        );
                      },
                      child: const ShimmerBorderContainer(),
                    ),
                  ],
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo-removebg.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCategoryTabs(orderState),
        const SizedBox(height: 20),
        _buildOrdersList(orderState),
      ],
    );
  }

  Widget _buildCategoryTabs(OrderState orderState) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              return InkWell(
                onTap: () => context.read<OrderCubit>().selectTab(0),
                child: _categoryChip(
                  Icons.coffee,
                  "Active Orders (${orderState.activeOrders.length})",
                  0,
                  state.selectedTab,
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              return InkWell(
                onTap: () {
                  print("Before Clicked 1 ");
                  context.read<OrderCubit>().selectTab(1);
                  print("After Clicked 1 ");
                  print("Selected tab : ${orderState.selectedTab}");
                },
                child: _categoryChip(
                  Icons.local_cafe,
                  "Collected (${orderState.collectedOrders.length})",
                  1,
                  state.selectedTab,
                ),
              );
            },
          ),

          const SizedBox(width: 5),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              return InkWell(
                onTap: () => context.read<OrderCubit>().selectTab(2),
                child: _categoryChip(
                  Icons.archive_rounded,
                  "Uncollected (${orderState.unCollectedOrders.length})",
                  2,
                  state.selectedTab,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderState orderState) {
    final List<OrderModel> displayOrders;

    switch (orderState.selectedTab) {
      case 0:
        displayOrders = orderState.activeOrders;
        break;
      case 1:
        displayOrders = orderState.collectedOrders;
        break;
      case 2:
        displayOrders = orderState.unCollectedOrders;
        break;
      default:
        displayOrders = [];
    }

    return Expanded(
      child: displayOrders.isEmpty
          ? Center(
              child: CustomText(
                text:
                    'No orders in "${["Active Orders", "Collected", "Uncollected"][orderState.selectedTab]}" category',
                fontSizeFactor: 1.0,
                color: Colors.grey,
              ),
            )
          : ListView.builder(
              itemCount: displayOrders.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                return itemCard(context, displayOrders[index]);
              },
            ),
    );
  }

  Widget _categoryChip(
    IconData icon,
    String label,
    int ownIndex,
    int selectedIndex,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 10),
      decoration: BoxDecoration(
        color: selectedIndex == ownIndex ? AppColors.button : Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 18, color: Colors.grey),
          ),
          const SizedBox(width: 6),
          CustomText(
            text: label,
            color: selectedIndex == ownIndex ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
