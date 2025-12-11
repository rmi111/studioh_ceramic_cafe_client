import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String receiverID;
  final String message;
  final int date;
  final bool seen;

  /// New fields
  final String chatType; // "general" | "product"
  final String? productId; // null for general chats

  Message({
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.date,
    required this.seen,
    this.chatType = "general",
    this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'date': date,
      'seen': seen,
      'chatType': chatType,
      if (productId != null) 'productId': productId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, [String? id]) {
    return Message(
      senderID: map['senderID'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] is int
          ? map['date']
          : (map['date'] as Timestamp).millisecondsSinceEpoch,
      seen: map['seen'] ?? false,
      chatType: map['chatType'] ?? "general",
      productId: map['productId'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          senderID == other.senderID &&
          receiverID == other.receiverID &&
          message == other.message &&
          date == other.date &&
          seen == other.seen;

  @override
  int get hashCode =>
      senderID.hashCode ^
      receiverID.hashCode ^
      message.hashCode ^
      date.hashCode ^
      seen.hashCode;
}
