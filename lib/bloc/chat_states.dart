import 'package:LinguifyAI/models/chat_message_model.dart';
import 'package:equatable/equatable.dart';

// enum ProcessType {Send, Read}

class ChatState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
