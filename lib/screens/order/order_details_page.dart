import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/screens/user/admin_list.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';
import '../../model/orders.dart';
import '../../utils/constant/constants.dart';
import '../../utils/constant/date_formatter.dart';
import '../../utils/constant/firebase_collection_name.dart';
import '../../utils/widget/custom_text.dart';

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

  Future<void> updateStatus(BuildContext context, String status) async {
    print("Clicked");
    await FirebaseFirestore.instance
        .collection(FirebaseCollectionName.ORDERS)
        .doc(widget.order.id)
        .update({'status': status});
    setState(() {
      selectedStatus = status;
    });
    AppSnackbar.show(context, "Success \nOrder status updated to $status");
  }

  @override
  Widget build(BuildContext context) {
    print("Total Image ${widget.order.imgUrl.length}");
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
                  text: 'Order Ref: ${widget.order.refNumber}',
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
                        ChatListPage(order: widget.order),
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
                  widget.order.imgUrl.isNotEmpty &&
                      widget
                          .order
                          .imgUrl[widget.order.imgUrl.length - 1]
                          .isNotEmpty
                  ? OrderImageSlider(
                      imgUrls: widget.order.imgUrl,
                      initialIndex: widget.order.imgUrl.length - 1,
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
            CustomText(text: 'Customer Name: ${widget.order.users[0].name}'),
            CustomText(text: 'Email: ${widget.order.users[0].email}'),
            CustomText(text: 'Phone: ${widget.order.users[0].phoneNumber}'),
            CustomText(text: 'Description: ${widget.order.description}'),
            CustomText(
              text:
                  'Order Date: ${DateFormatter.formatDate(widget.order.orderDate)}',
            ),
            const SizedBox(height: 10),
            CustomText(
              text: 'Update Status',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  //statuses.map((status) {
                  potteryOrderStatus.entries
                      .toList()
                      .sublist(potteryOrderStatus.length - 3)
                      .map((entry) {
                        final status = entry.key;
                        final isSelected = selectedStatus == status;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.deepOrange
                                  : Colors.grey[200],
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              elevation: isSelected ? 2 : 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ), // smaller height
                              minimumSize: Size(0, 32), // min height
                            ),
                            onPressed: () {},
                            child: Text(
                              potteryOrderStatus[status] ?? '',
                              //status[0].toUpperCase() + status.substring(1),
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12, // smaller text
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
            ),
          ],
        ),
      ),
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
                  widget.imgUrls[_currentIndex],
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
