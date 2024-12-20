import 'package:shared_preferences/shared_preferences.dart';

enum PrefKeys{fromLanguage, toLanguage, userId}

class SharedPrefController{
  // SharedPrefController._();
  SharedPrefController._privateConstructor();
  static final SharedPrefController _instance = SharedPrefController._privateConstructor();

  late SharedPreferences _sharedPreferences;
  // static SharedPrefController? _instance;

  static SharedPrefController get instance => _instance;

  // static SharedPrefController get instance => _instance;
  //
  // factory SharedPrefController(){
  //   return _instance ??= SharedPrefController._();
  // }

  Future<void> initPreferences() async{
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void save({required String selectedFromLanguage, required String selectedToLanguage}){
    _sharedPreferences.setString(PrefKeys.fromLanguage.name, selectedFromLanguage);
    _sharedPreferences.setString(PrefKeys.toLanguage.name, selectedToLanguage);
  }

  void saveUserId({required String userId}){
    _sharedPreferences.setString(PrefKeys.userId.name, userId);
  }

  String? getUserId(){
    return _sharedPreferences.getString(PrefKeys.userId.name);
  }

  void changeFromLanguage(String language){
    _sharedPreferences.setString(PrefKeys.fromLanguage.name, language);
  }

  void changeToLanguage(String language){
    _sharedPreferences.setString(PrefKeys.toLanguage.name, language);
  }

  String getFromLanguage(){
    return _sharedPreferences.getString(PrefKeys.fromLanguage.name) ?? 'English';
  }

  String getToLanguage(){
    return _sharedPreferences.getString(PrefKeys.toLanguage.name) ?? 'Arabic';
  }

  Future<bool> clear() async => await _sharedPreferences.clear();
}