import 'package:equatable/equatable.dart';

class SummarizationEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class SendTextEvent extends SummarizationEvent {
  final String text;

  SendTextEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

class ResetSummarizationEvent extends SummarizationEvent {}