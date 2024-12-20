import 'package:equatable/equatable.dart';

class CorrectGrammarEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

// Event to send text to the grammar correction API
class SendTextEvent extends CorrectGrammarEvent {
  final String text;

  SendTextEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

class ResetCorrectionEvent extends CorrectGrammarEvent{}