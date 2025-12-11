import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/constants.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/image_slider.dart';

import '../../screens/order/order_details_page.dart';
import '../constant/date_formatter.dart';

Widget itemCard(BuildContext context, OrderModel order) {

  return GestureDetector(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailPage(order: order)));
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
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
              margin: EdgeInsets.all(5),
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200],
                image: (order.imgUrl.isNotEmpty && order.imgUrl[0].isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(
                          order.imgUrl[order.imgUrl.length - 1],
                        ),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: AssetImage('assets/images/no-image-icon-4.png'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Ref: ${order.refNumber}",
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                text: order.users[0].email,
                fontWeight: FontWeight.normal,
              ),
              CustomText(text: order.users[0].name, color: Colors.grey),
              CustomText(text: DateFormatter.formatDate(order.orderDate)),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD38351),
                  borderRadius: BorderRadius.circular(5),
                ),

                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: CustomText(
                  text: potteryOrderStatus[order.status] ?? 'Uncollected',
                  fontSizeFactor: 0.9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white,
              size: 15,
            ),
          ),
        ],
      ),
    ),
  );
}
