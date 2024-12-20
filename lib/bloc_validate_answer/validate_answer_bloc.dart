import 'package:LinguifyAI/api/api_models/validate_answer_model.dart';
import 'package:LinguifyAI/api/validate_answer_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'validate_answer_event.dart';
import 'validate_answer_states.dart';

class ValidateAnswerBloc extends Bloc<ValidateAnswerEvent, ValidateAnswerState> {

  final ValidateAnswerController validateAnswerController = ValidateAnswerController();

  ValidateAnswerBloc(super.initialState) {
    on<SendAnswerEvent>(_onSendAnswer);
    on<ResetValidateAnswerEvent>(_onReset);
  }

  Future<void> _onSendAnswer(SendAnswerEvent event, Emitter<ValidateAnswerState> emit) async {
    try {
      // Make the API request
      ValidateAnswerResponse validateAnswerResponse = await validateAnswerController.validateAnswer(event.question, event.userChoice);
      emit(ValidateAnswerLoaded(validateAnswerResponse));
    } catch (e) {
      emit(ValidateAnswerError(e.toString()));
    }
  }

  void _onReset(ResetValidateAnswerEvent event, Emitter<ValidateAnswerState> emit) {
    emit(ValidateAnswerInitial());
  }
}