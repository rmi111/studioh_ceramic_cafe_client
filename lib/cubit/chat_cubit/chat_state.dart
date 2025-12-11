import 'package:equatable/equatable.dart';
import 'package:studioh_ceramic_cafe_client/model/message.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String error;
  final Map<String, int> unseenCounts; // chatRoomId -> count

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error = '',
    this.unseenCounts = const {},
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    Map<String, int>? unseenCounts,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unseenCounts: unseenCounts ?? this.unseenCounts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatState &&
          runtimeType == other.runtimeType &&
          messages == other.messages &&
          isLoading == other.isLoading &&
          error == other.error &&
          unseenCounts == other.unseenCounts;

  @override
  int get hashCode =>
      messages.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      unseenCounts.hashCode;
}