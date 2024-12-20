abstract class LanguageState{}

class InitialLanguage extends LanguageState{}

class ChangeFromLanguageState extends LanguageState{

  final String fromLanguage;
  ChangeFromLanguageState(this.fromLanguage);
}

class ChangeToLanguageState extends LanguageState{

  final String toLanguage;
  ChangeToLanguageState(this.toLanguage);
}