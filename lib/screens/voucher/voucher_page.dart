import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/voucher_cubit/voucher_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/voucher_cubit/voucher_state.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';
import 'package:studioh_ceramic_cafe_client/screens/voucher/voucher_details.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user info from AuthCubit
    final authState = context.read<AuthCubit>().state;
    final userId = authState.currentUserModel?.uid;
    final userEmail = authState.currentUserModel?.email;

    return BlocProvider(
      create: (_) => VoucherCubit(userId: userId, userEmail: userEmail),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<VoucherCubit, VoucherState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/images/Animation - 1749106532062.json',
                  width: 150,
                  height: 150,
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                _buildStatsCard(state),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVoucherList(state.activeVouchers, 'active'),
                      _buildVoucherList(state.usedVouchers, 'used'),
                      _buildVoucherList(state.expiredVouchers, 'expired'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(VoucherState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.card_giftcard,
            state.activeVouchers.length.toString(),
            'Active',
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(
            Icons.check_circle,
            state.usedVouchers.length.toString(),
            'Used',
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(
            Icons.access_time,
            state.expiredVouchers.length.toString(),
            'Expired',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(0, 'Active', Icons.flash_on_rounded),
          const SizedBox(width: 8),
          _buildTabItem(1, 'Used', Icons.check_circle_outline),
          const SizedBox(width: 8),
          _buildTabItem(2, 'Expired', Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.button : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherList(List<Voucher> vouchers, String type) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'active'
                  ? Icons.card_giftcard_outlined
                  : type == 'used'
                  ? Icons.check_circle_outline
                  : Icons.schedule,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              type == 'active'
                  ? 'No active vouchers'
                  : type == 'used'
                  ? 'No used vouchers'
                  : 'No expired vouchers',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'active' ? 'Subscribe to get monthly vouchers!' : '',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // ListView inside TabBarView doesn't need Expanded wrapper
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _buildVoucherCard(vouchers[index], type);
      },
    );
  }

  Widget _buildVoucherCard(Voucher voucher, String type) {
    Color statusColor = Colors.green;
    // type == 'active'
    //     ? Colors.green
    //     : type == 'used'
    //     ? Colors.blue
    //     : Colors.grey;

    return GestureDetector(
      onTap: () {
        // Navigate to voucher details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherDetailsScreen(
              voucher: Voucher(
                code: voucher.code,
                type: voucher.type,
                value: voucher.value,
                description: voucher.description,
                expiryDate: voucher.expiryDate,
                isActive: voucher.isActive,
                redeemedDate: voucher.redeemedDate,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            // type == 'active'
            //     ? const Color(0xFFD4AF37).withOpacity(0.3)
            //     : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with golden accent
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                color: type != 'active' ? Colors.grey[100] : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getVoucherIcon(voucher.type),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.type,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          voucher.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Voucher code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            voucher.code,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Footer info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type == 'used'
                            ? 'Redeemed: ${formatDate(voucher.redeemedDate!)}'
                            : 'Expires: ${formatDate(voucher.expiryDate)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (type == 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.qr_code,
                                size: 14,
                                color: Color(0xFFD4AF37),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to view QR',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVoucherIcon(String type) {
    if (type.contains('Coffee')) return Icons.coffee;
    if (type.contains('Discount')) return Icons.discount;
    if (type.contains('2 for 1')) return Icons.redeem;
    return Icons.card_giftcard;
  }

  String formatDate(int millis) {
    DateTime orderedDate = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd MMM yyyy, h:mm a').format(orderedDate);
  }
}
