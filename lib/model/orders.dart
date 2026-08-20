class OrderImage {
  final int id;
  final String url;

  OrderImage({required this.id, required this.url});

  factory OrderImage.fromJson(Map<String, dynamic> json) {
    return OrderImage(
      id: json['id'] ?? 0,
      url: json['image_url'] ?? json['url'] ?? '',
    );
  }
}

class OrderStatusHistory {
  final int id;
  final String? fromStatus;
  final String toStatus;
  final String occurredAt;

  OrderStatusHistory({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    required this.occurredAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] ?? 0,
      fromStatus: json['from_status'],
      toStatus: json['to_status'] ?? '',
      occurredAt: json['occurred_at'] ?? json['created_at'] ?? '',
    );
  }
}

class OrderUser {
  final int? id;
  final String email;
  final String name;
  final String? phoneNumber;

  OrderUser({
    this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
    );
  }
}

class OrderModel {
  final int id;
  final String refNumber;
  final List<OrderUser> users;
  final List<OrderImage> images;
  final String orderDate; // ISO string from API
  final String status;
  final String description;
  final List<OrderStatusHistory> statusHistories;

  /// Convenience getter for backward compat — flat list of image URLs
  List<String> get imgUrl => images.map((i) => i.url).toList();

  OrderModel({
    this.description = '',
    required this.id,
    required this.refNumber,
    required this.users,
    required this.images,
    required this.orderDate,
    required this.status,
    this.statusHistories = const [],
  });

  /// Parse from Laravel API JSON response
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse users — could be a list of objects
    List<OrderUser> parsedUsers = [];
    if (json['users'] is List) {
      parsedUsers = (json['users'] as List)
          .map((u) => OrderUser.fromJson(u as Map<String, dynamic>))
          .toList();
    }

    // Parse images — could be a list of {id, url} objects
    List<OrderImage> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((i) => OrderImage.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? 0,
      refNumber: json['ref_number'] ?? '',
      users: parsedUsers,
      images: parsedImages,
      orderDate: json['order_date']?.toString() ??
          json['created_at']?.toString() ??
          '',
      status: json['status'] ?? 'ready_for_glaze',
      description: json['description'] ?? '',
      statusHistories: (json['status_histories'] as List?)
              ?.map((h) =>
                  OrderStatusHistory.fromJson(Map<String, dynamic>.from(h as Map)))
              .toList() ??
          [],
    );
  }
}

