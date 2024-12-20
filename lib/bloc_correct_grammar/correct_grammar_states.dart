import 'package:LinguifyAI/api/api_models/correct_grammar_response_model.dart';
import 'package:equatable/equatable.dart';

class CorrectGrammarState extends Equatable{
  @override
  List<Object?> get props => [];
}

// class CorrectGrammarInitial extends CorrectGrammarState {}

class CorrectGrammarLoading extends CorrectGrammarState {}

class LoadCorrectedText extends CorrectGrammarState {
  final CorrectGrammarResponse correctGrammarResponse;

  LoadCorrectedText(this.correctGrammarResponse);

  @override
  List<Object?> get props => [correctGrammarResponse];
}

class CorrectGrammarError extends CorrectGrammarState {
  final String error;

  CorrectGrammarError(this.error);

  @override
  List<Object?> get props => [error];
}
