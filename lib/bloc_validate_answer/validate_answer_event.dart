import 'package:equatable/equatable.dart';

class ValidateAnswerEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class SendAnswerEvent extends ValidateAnswerEvent {
  final String question;
  final String userChoice;

  SendAnswerEvent({required this.question, required this.userChoice});

  @override
  List<Object?> get props => [question, userChoice];
}

class ResetValidateAnswerEvent extends ValidateAnswerEvent {}