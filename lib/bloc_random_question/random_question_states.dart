import 'package:LinguifyAI/api/api_models/random_question_model.dart';
import 'package:equatable/equatable.dart';

class RandomQuestionState extends Equatable{
  @override
  List<Object?> get props => [];
}

class RandomQuestionLoading extends RandomQuestionState {}

class RandomQuestionLoaded extends RandomQuestionState {
  final RandomQuestionResponse randomQuestionResponse;

  RandomQuestionLoaded(this.randomQuestionResponse);

  @override
  List<Object?> get props => [randomQuestionResponse];
}

class RandomQuestionError extends RandomQuestionState {
  final String error;

  RandomQuestionError(this.error);

  @override
  List<Object?> get props => [error];
}
