import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studioh_ceramic_cafe_client/model/user.dart';


class OrderModel {
  final String id;
  final String refNumber;
  final List<UserModel> users;
  final List<String> imgUrl;
  final int orderDate;
  final String status;
  final String description;

  OrderModel({
    this.description = '',
    required this.id,
    required this.refNumber,
    required this.users,
    required this.imgUrl,
    required this.orderDate,
    required this.status,
  });
  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      refNumber: data['refNumber'] ?? '',
      users:
          (data['users'] as List<dynamic>?)?.map((userData) {
            final map = userData as Map<String, dynamic>;
            final uid =
                map['uid'] ?? ''; // 🟢 default to empty string if missing
            return UserModel.fromMap(map, uid);
          }).toList() ??
          [],
      imgUrl: List<String>.from(data['imgUrl'] ?? []),
      orderDate: data['orderDate'] ?? DateTime.now().millisecondsSinceEpoch,
      status: data['status'] ?? 'pending',
      description: data['description'] ?? '',
    );
  }
}
