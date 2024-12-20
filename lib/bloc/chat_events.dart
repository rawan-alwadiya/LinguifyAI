import 'package:equatable/equatable.dart';

class ChatEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;
  final bool isUser;

  SendMessageEvent({required this.message, required this.isUser});

  @override
  List<Object?> get props => [message, isUser];
}

class DeleteLastMessageEvent extends ChatEvent{}

class DeleteChatHistoryEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent{}