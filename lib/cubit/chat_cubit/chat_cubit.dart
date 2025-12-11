import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/chat_cubit/chat_state.dart';
import 'package:studioh_ceramic_cafe_client/model/message.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ChatCubit extends Cubit<ChatState> {
  final AuthCubit authCubit;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatCubit({required this.authCubit})
      : super(const ChatState(
          messages: [],
          isLoading: false,
          error: '',
          unseenCounts: {},
        ));

  /// Generate chat room ID based on user IDs and optional product ID
  String _generateChatRoomId({
    required String userId,
    required String otherUserId,
    String? productId,
    String chatType = 'general',
  }) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String baseId = ids.join('_');

    if (chatType == 'item_query' && productId != null) {
      return '${baseId}_$productId';
    }
    return baseId;
  }

  /// Send a message
  Future<void> sendMessage({
    required String message,
    required String receiverId,
    String chatType = 'general',
    String? productId,
  }) async {
    emit(state.copyWith(isLoading: true, error: ''));

    try {
      final currentUser = authCubit.state.currentUserModel;
      if (currentUser == null) {
        throw Exception('No logged-in user');
      }

      final String currentUserId = currentUser.uid;
      final int date = Timestamp.now().millisecondsSinceEpoch;

      // Create message object
      final Message newMessage = Message(
        senderID: currentUserId,
        receiverID: receiverId,
        message: message,
        date: date,
        seen: false,
      );

      // Generate chat room ID
      final String chatRoomId = _generateChatRoomId(
        userId: currentUserId,
        otherUserId: receiverId,
        productId: productId,
        chatType: chatType,
      );

      // Ensure chat doc exists with type info
      await _firestore.collection('chats').doc(chatRoomId).set({
        'chat_type': chatType,
        if (chatType == 'item_query') 'item_ref': productId,
        'lastMessageTime': date,
      }, SetOptions(merge: true));

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      print('✅ Message sent to $chatRoomId: $message');
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print('❌ Error sending message: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to send message: $e',
      ));
    }
  }

  /// Get messages stream for a chat
  Stream<List<Message>> getMessagesStream({
    required String userId,
    required String otherUserID,
    String chatType = 'general',
    String? productId,
  }) {
    final String chatRoomId = _generateChatRoomId(
      userId: userId,
      otherUserId: otherUserID,
      productId: productId,
      chatType: chatType,
    );

    print('Chat room ID: $chatRoomId');

    return _firestore
        .collection('chats')
        .doc(chatRoomId.trim())
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList();
    });
  }

  /// Mark messages as seen
  Future<void> markMessagesAsSeen({
    required String userId,
    required String otherUserID,
    String chatType = 'general',
    String? productId,
  }) async {
    try {
      final String chatRoomId = _generateChatRoomId(
        userId: userId,
        otherUserId: otherUserID,
        productId: productId,
        chatType: chatType,
      );

      final messages = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverID', isEqualTo: userId)
          .where('seen', isEqualTo: false)
          .get();

      for (final doc in messages.docs) {
        await doc.reference.update({'seen': true});
      }

      print('✅ Messages marked as seen in $chatRoomId');
    } catch (e) {
      print('❌ Error marking messages as seen: $e');
    }
  }

  /// Get unseen message count for a specific chat
  Stream<int> getUnseenMessageCountForChat(String chatRoomId) {
    final currentUser = authCubit.state.currentUserModel;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverID', isEqualTo: currentUser.uid)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get all chats for admin
  Stream<QuerySnapshot> getAllChatsForAdmin() {
    return _firestore.collection('chats').snapshots();
  }

  /// Get map of chatRoomId -> unseen count (for all chats)
  Stream<Map<String, int>> getAllUnseenCounts() {
    final currentUser = authCubit.state.currentUserModel;
    if (currentUser == null) return Stream.value({});

    return _firestore
        .collectionGroup('messages')
        .where('receiverID', isEqualTo: currentUser.uid)
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final Map<String, int> unseenCounts = {};

      for (var doc in snapshot.docs) {
        final chatPath = doc.reference.parent.parent!.id;
        unseenCounts.update(chatPath, (val) => val + 1, ifAbsent: () => 1);
      }

      return unseenCounts;
    });
  }
}