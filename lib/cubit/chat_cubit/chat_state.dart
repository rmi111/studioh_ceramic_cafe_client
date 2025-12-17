
import 'package:equatable/equatable.dart';
import 'package:studioh_ceramic_cafe_client/model/chat_room.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatRoom> chatRooms;
  final Map<String, int> unseenCounts;

  ChatLoaded({required this.chatRooms, this.unseenCounts = const {}});

  @override
  List<Object?> get props => [chatRooms, unseenCounts];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

