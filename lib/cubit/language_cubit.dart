import 'package:LinguifyAI/cubit/language_state.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LanguageCubit extends Cubit<LanguageState>{
  LanguageCubit(): super(InitialLanguage());

  Future<void> getFromLanguage()async{
    String language=  SharedPrefController.instance.getFromLanguage();
    emit(ChangeFromLanguageState(language));
  }

  Future<void> getToLanguage()async{
    String language=  SharedPrefController.instance.getToLanguage();
    emit(ChangeToLanguageState(language));
  }

  Future<void> getSavedLanguage() async {
    await getFromLanguage();
    await getToLanguage();
  }

  Future<void> changeFromLanguage(String language)async{
    SharedPrefController.instance.changeFromLanguage(language);
    emit(ChangeFromLanguageState(language));
  }

  Future<void> changeToLanguage(String language)async{
    SharedPrefController.instance.changeToLanguage(language);
    emit(ChangeToLanguageState(language));
  }
}