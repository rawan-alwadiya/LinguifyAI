import 'package:LinguifyAI/api/api_models/correct_grammar_response_model.dart';
import 'package:LinguifyAI/api/correct_grammar_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'correct_grammar_events.dart';
import 'correct_grammar_states.dart';

class CorrectGrammarBloc extends Bloc<CorrectGrammarEvent, CorrectGrammarState> {

  final CorrectGrammarController _correctGrammarController = CorrectGrammarController();

  CorrectGrammarBloc(super.initialState) {
    on<SendTextEvent>(_onSendText);
    on<ResetCorrectionEvent>(_onReset);
  }

  Future<void> _onSendText(SendTextEvent event, Emitter<CorrectGrammarState> emit) async {
    try {
      CorrectGrammarResponse correctGrammarResponse = await _correctGrammarController.sendText(event.text);
      emit(LoadCorrectedText(correctGrammarResponse));
    } catch (e){
      emit(CorrectGrammarError('Failed to load corrected text: ${e.toString()}'));
    }
  }

  Future<void> _onReset(ResetCorrectionEvent event, Emitter<CorrectGrammarState> emit) async {
    emit(CorrectGrammarLoading());
  }
}