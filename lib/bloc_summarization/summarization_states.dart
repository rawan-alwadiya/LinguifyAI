import 'package:LinguifyAI/api/api_models/summarization_response_model.dart';
import 'package:equatable/equatable.dart';

class SummarizationState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SummarizationLoading extends SummarizationState {}

class SummaryLoaded extends SummarizationState {
  final SummarizationResponse summarizationResponse;

  SummaryLoaded(this.summarizationResponse);

  @override
  List<Object?> get props => [summarizationResponse];
}

class SummarizationError extends SummarizationState {
  final String error;

  SummarizationError(this.error);

  @override
  List<Object?> get props => [error];
}
