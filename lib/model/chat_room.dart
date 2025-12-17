class ChatRoom {
  final String chatRoomId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final String chatType; // "general" or "item_query"
  final String? productId;
  final String? productName;
  final String? ownerEmail;
  final String? ownerName;
  final String? productImage;
  final String? lastMessage;
  final int? lastMessageTime;
  final int unseenCount;

  ChatRoom({
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    required this.chatType,
    this.productId,

    this.productName,
    this.ownerEmail,
    this.ownerName,
    this.productImage,
    this.lastMessage,
    this.lastMessageTime,
    this.unseenCount = 0,
  });
}