import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studioh_ceramic_cafe_client/cubit/order_cubit/order_cubit.dart';
import 'package:studioh_ceramic_cafe_client/model/chat_room.dart';
import 'package:studioh_ceramic_cafe_client/model/user.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';
import '../../model/message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId;

  final OrderCubit orderCubit;

  ChatCubit({required this.currentUserId, required this.orderCubit})
    : super(ChatInitial());

  Future<void> sendMessage({
    required String message,
    required String receiverId,
    String chatType = "general",
    String? productId,
  }) async {
    try {
      final int date = Timestamp.now().millisecondsSinceEpoch;

      Message newMessage = Message(
        senderID: currentUserId,
        receiverID: receiverId,
        message: message,
        date: date,
        seen: false,
      );

      String chatRoomId = _generateChatRoomId(
        currentUserId,
        receiverId,
        chatType: chatType,
        productId: productId,
      );

      // Ensure chat doc exists
      await _firestore.collection('chats').doc(chatRoomId).set({
        "chat_type": chatType,
        "participants": [currentUserId, receiverId],
        "last_message": message,
        "last_message_time": date,
        if (chatType == "item_query" && productId != null)
          "item_ref": productId,
      }, SetOptions(merge: true));

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      print("✅ Message sent to $chatRoomId: $message");
    } catch (e) {
      print('❌ Error sending message: $e');
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void loadChatList() {
    emit(ChatLoading());

    try {
      _firestore.collection(FirebaseCollectionName.CHATS).snapshots().listen((
        chatSnapshot,
      ) async {
        List<ChatRoom> chatRooms = [];

        for (var chatDoc in chatSnapshot.docs) {
          final data = chatDoc.data();
          final chatRoomId = chatDoc.id;

          if (!chatRoomId.contains(currentUserId)) continue;

          final chatType = data['chat_type'] ?? 'general';

          String otherUserId = '';

          // Parse chatRoomId format: "userId1_userId2" or "userId1_userId2_productId"
          final parts = chatRoomId.split('_');
          if (parts.length >= 2) {
            if (parts[0] == currentUserId) {
              otherUserId = parts[1];
            } else if (parts[1] == currentUserId) {
              otherUserId = parts[0];
            }
          }

          if (otherUserId.isEmpty) continue;

          // Get other user data from Firestore
          final userDoc = await _firestore
              .collection(FirebaseCollectionName.USERS)
              .doc(otherUserId)
              .get();
          final userData = userDoc.data() ?? {};
          UserModel otherUser = UserModel.fromMap(userData, otherUserId);
          print("Other User: ${otherUser.name}");
          final messagesSnapshot = await _firestore
              .collection(FirebaseCollectionName.CHATS)
              .doc(chatRoomId)
              .collection('messages')
              .limit(1)
              .get();

          // Skip chats with no messages
          if (messagesSnapshot.docs.isEmpty) continue;

          // Get unseen count for this chat
          final unseenCount = await _getUnseenCountForChat(chatRoomId);

          // Get product data if item_query
          String? productName;
          String? productImage;
          String? productRef;
          String? ownerName;
          String? ownerEmail;
          if (chatType == 'item_query') {
            productRef = data['item_ref'];
            if (productRef != null) {
              final foundModel = await orderCubit.getOrderByRef(productRef);
              print("Order Found ");
              if (foundModel != null) {
                productName = foundModel.description;
                productImage = foundModel.imgUrl.isNotEmpty
                    ? foundModel.imgUrl[0]
                    : "Not found";
                productRef = foundModel.refNumber;
                ownerName = foundModel.users[0].name;
                ownerEmail = foundModel.users[0].email;
                print(
                  "Product Name: $productName   Owner Name: $ownerName Owner Email: $ownerEmail",
                );
              }
            }
          }

          chatRooms.add(
            ChatRoom(
              chatRoomId: chatRoomId,
              otherUserId: otherUserId,
              otherUserName: otherUser.name,
              otherUserImage: otherUser.imageUrl,
              chatType: chatType,
              productId: productRef,
              productName: productName,
              productImage: productImage,
              ownerEmail: ownerEmail,
              ownerName: ownerName,
              lastMessage: data['last_message'],
              lastMessageTime: data['last_message_time'],
              unseenCount: unseenCount,
            ),
          );
            print(
                  "Product Name: $productName   Owner Name: $ownerName Owner Email: $ownerEmail    Added to chatRooms",
                );
        }

        // Sort by last message time
        chatRooms.sort((a, b) {
          final aTime = a.lastMessageTime ?? 0;
          final bTime = b.lastMessageTime ?? 0;
          return bTime.compareTo(aTime);
        });
        emit(ChatLoaded(chatRooms: chatRooms));
      });
    } catch (e) {
      print('❌ Error loading chats: $e');
      emit(ChatError('Failed to load chats: $e'));
    }
  }

  // ==================== MARK MESSAGES AS SEEN ====================
  Future<void> markMessagesAsSeen(String chatRoomId) async {
    try {
      final messages = await _firestore
          .collection(FirebaseCollectionName.CHATS)
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverID', isEqualTo: currentUserId)
          .where('seen', isEqualTo: false)
          .get();

      for (final doc in messages.docs) {
        await doc.reference.update({'seen': true});
      }
    } catch (e) {
      print('❌ Error marking messages as seen: $e');
    }
  }

  // ==================== GET TOTAL UNSEEN MESSAGE COUNT ====================
  Stream<int> getTotalUnseenMessageCount() {
    return _firestore
        .collectionGroup('messages')
        .where('receiverID', isEqualTo: currentUserId)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================== HELPER METHODS ====================
  String _generateChatRoomId(
    String userId1,
    String userId2, {
    String chatType = "general",
    String? productId,
  }) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    String chatRoomId = ids.join("_");

    if (chatType == "item_query" && productId != null) {
      chatRoomId = "${ids.join("_")}_$productId";
    }

    return chatRoomId;
  }

  Future<int> _getUnseenCountForChat(String chatRoomId) async {
    final snapshot = await _firestore
        .collection(FirebaseCollectionName.CHATS)
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverID', isEqualTo: currentUserId)
        .where('seen', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  // ==================== GET MESSAGES STREAM ====================
  Stream<QuerySnapshot> getMessagesStream({
    required String otherUserId,
    String chatType = "general",
    String? productId,
  }) {
    String chatRoomId = _generateChatRoomId(
      currentUserId,
      otherUserId,
      chatType: chatType,
      productId: productId,
    );

    return _firestore
        .collection(FirebaseCollectionName.CHATS)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots();
  }

  // ==================== GET CHAT ROOM ID ====================
  String getChatRoomId({
    required String otherUserId,
    String chatType = "general",
    String? productId,
  }) {
    return _generateChatRoomId(
      currentUserId,
      otherUserId,
      chatType: chatType,
      productId: productId,
    );
  }
}
