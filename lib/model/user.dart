class UserModel {
  final String uid;
  final String email;
  final String? imageUrl;
  final String name;
  final String? phoneNumber;
  final String userType;
  final bool isSubscriber;

  UserModel({
    required this.uid,
    required this.email,
    this.imageUrl,
    required this.name,
    this.phoneNumber,
    required this.userType,
    this.isSubscriber = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'],
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      userType: data['userType'] ?? 'customer',
      isSubscriber: data['isSubscriber'] ?? false,
    );
  }
}
