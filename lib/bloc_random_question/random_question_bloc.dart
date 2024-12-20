import 'package:LinguifyAI/api/api_models/random_question_model.dart';
import 'package:LinguifyAI/api/random_question_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'random_question_events.dart';
import 'random_question_states.dart';

class RandomQuestionBloc extends Bloc<RandomQuestionEvent, RandomQuestionState> {

  final RandomQuestionController _randomQuestionController = RandomQuestionController();

  RandomQuestionBloc(super.initialState) {
    on<GetRandomQuestionEvent>(_onGetRandomQuestion);
  }

  Future<void> _onGetRandomQuestion(GetRandomQuestionEvent event, Emitter<RandomQuestionState> emit) async{
    try {
      RandomQuestionResponse randomQuestionResponse = await _randomQuestionController.getRandomQuestion();
      emit(RandomQuestionLoaded(randomQuestionResponse));
    } catch (e) {
      emit(RandomQuestionError(e.toString()));
    }
  }
}