import 'package:LinguifyAI/api/api_models/validate_answer_model.dart';
import 'package:equatable/equatable.dart';


class ValidateAnswerState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ValidateAnswerInitial extends ValidateAnswerState {}

class ValidateAnswerLoading extends ValidateAnswerState {}

class ValidateAnswerLoaded extends ValidateAnswerState {
  final ValidateAnswerResponse validateAnswerResponse;

  ValidateAnswerLoaded(this.validateAnswerResponse);

  @override
  List<Object?> get props => [validateAnswerResponse];
}

class ValidateAnswerError extends ValidateAnswerState {
  final String error;

  ValidateAnswerError(this.error);

  @override
  List<Object?> get props => [error];
}