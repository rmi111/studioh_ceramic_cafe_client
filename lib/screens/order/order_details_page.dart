import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/screens/user/admin_list.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';
import '../../cubit/order_cubit/order_cubit.dart';
import '../../model/orders.dart';
import '../../utils/constant/constants.dart';
import '../../utils/constant/date_formatter.dart';
import '../../utils/widget/custom_text.dart';
import '../../utils/constant/status_helper.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({required this.order, super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late String selectedStatus;

  //final List<String> statuses = ['ready for Collection', 'collected','uncollected'];

  @override
  void initState() {
    selectedStatus = widget.order.status;
    super.initState();
  }

  // Client app: status is read-only, updated by admin only
  // Keeping method signature for compatibility but it's a no-op
  Future<void> updateStatus(BuildContext context, String status) async {
    // Status updates are handled by the admin app
    AppSnackbar.show(context, "Status: $status");
  }

  /// Find the latest version of this order from the cubit state
  OrderModel _getLatestOrder(OrderState orderState) {
    try {
      return orderState.orders.firstWhere(
        (o) => o.refNumber == widget.order.refNumber,
      );
    } catch (_) {
      // Fallback to the original order if not found (e.g. deleted)
      return widget.order;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final order = _getLatestOrder(orderState);

        print("Total Image ${order.imgUrl.length}");
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Order Details',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: 'Order Ref: ${order.refNumber}',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    Spacer(),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => 
                            ChatListPage(order: order),
                          ),
                        );
                      },
                      icon: Icon(Icons.message, color: Colors.amber),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.center,
                  child:
                      order.imgUrl.isNotEmpty &&
                          order
                              .imgUrl[order.imgUrl.length - 1]
                              .isNotEmpty
                      ? OrderImageSlider(
                          imgUrls: order.imgUrl,
                          initialIndex: order.imgUrl.length - 1,
                        )
                      : Container(
                          margin: EdgeInsets.all(5),
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/no-image-icon-4.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 5),
                CustomText(text: 'Customer Name: ${order.users[0].name}'),
                CustomText(text: 'Email: ${order.users[0].email}'),
                CustomText(text: 'Phone: ${order.users[0].phoneNumber}'),
                CustomText(text: 'Description: ${order.description}'),
                CustomText(
                  text:
                      'Order Date: ${DateFormatter.formatDate(order.orderDate)}',
                ),
                const SizedBox(height: 10),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StatusHelper.getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StatusHelper.getStatusColor(order.status)),
                  ),
                  child: Text(
                    'Current Status: ${StatusHelper.getStatusLabel(order.status)}',
                    style: TextStyle(
                      color: StatusHelper.getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Status Histories
                if (order.statusHistories.isNotEmpty) ...[
                  CustomText(
                    text: 'Status History',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.statusHistories.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final history = order.statusHistories[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            StatusHelper.getStatusLabel(history.toStatus),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            history.fromStatus != null 
                              ? 'From: ${StatusHelper.getStatusLabel(history.fromStatus!)}' 
                              : 'Initial status',
                          ),
                          trailing: Text(
                            DateFormatter.formatDate(history.occurredAt),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                CustomText(
                  text: 'Order Status',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: potteryOrderStatus.entries.map((entry) {
                          final isSelected = order.status == entry.key;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? StatusHelper.getStatusColor(entry.key) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class OrderImageSlider extends StatefulWidget {
  final List<String> imgUrls;
  int initialIndex;
  OrderImageSlider({required this.imgUrls, required this.initialIndex});

  @override
  State<OrderImageSlider> createState() => OrderImageSliderState();
}

class OrderImageSliderState extends State<OrderImageSlider> {
  late final PageController _controller;
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: EdgeInsets.all(5),
          height: 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imgUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                print("Image Url: ${widget.imgUrls[index]}");
                return Image.network(
                  widget.imgUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.broken_image)),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
        if (widget.imgUrls.length > 1)
          Positioned(
            bottom: 12,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imgUrls.length}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
