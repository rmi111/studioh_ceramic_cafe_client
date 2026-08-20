class UserModel {
  final int id;
  final String uid; // kept for backward compat with chat Firestore data
  final String email;
  final String? imageUrl;
  final String name;
  final String? phoneNumber;
  final String userType;
  final bool isSubscriber;
  final bool enrolledByClient;

  UserModel({
    this.id = 0,
    this.uid = '',
    required this.email,
    this.imageUrl,
    required this.name,
    this.phoneNumber,
    required this.userType,
    this.isSubscriber = false,
    this.enrolledByClient = false,
  });

  /// Parse from Laravel API JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      uid: (json['id'] ?? 0).toString(),
      email: json['email'] ?? '',
      imageUrl: json['image_url'],
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'],
      userType: json['user_type'] ?? 'customer',
      isSubscriber: json['is_subscriber'] ?? false,
      enrolledByClient: json['enrolled_by_client'] ?? false,
    );
  }

  /// Parse from Firestore document (kept for chat backward compatibility)
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      id: 0,
      uid: uid,
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? data['image_url'],
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone_number'],
      userType: data['userType'] ?? data['user_type'] ?? 'customer',
      isSubscriber: data['isSubscriber'] ?? data['is_subscriber'] ?? false,
      enrolledByClient: data['enrolledByClient'] ?? data['enrolled_by_client'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'image_url': imageUrl,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': userType,
      'is_subscriber': isSubscriber,
      'enrolled_by_client': enrolledByClient,
    };
  }
}
