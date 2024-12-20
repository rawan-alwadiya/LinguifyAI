import 'package:LinguifyAI/api/api_models/summarization_response_model.dart';
import 'package:LinguifyAI/api/summarization_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'summarization_events.dart';
import 'summarization_states.dart';

class SummarizationBloc extends Bloc<SummarizationEvent, SummarizationState> {

  final SummarizationController _summarizationController = SummarizationController();

  SummarizationBloc(super.initialState) {
    on<SendTextEvent>(_onSendText);
    on<ResetSummarizationEvent>(_onReset);
  }

  Future<void> _onSendText(SendTextEvent event, Emitter<SummarizationState> emit) async{

    try {
      SummarizationResponse summarizationResponse = await _summarizationController.summarizeText(event.text);
      emit(SummaryLoaded(summarizationResponse));
  }catch (e) {
      emit(SummarizationError(e.toString()));
  }
  }

  Future<void> _onReset(ResetSummarizationEvent event, Emitter<SummarizationState> emit) async{
    emit(SummarizationLoading());
  }
}
