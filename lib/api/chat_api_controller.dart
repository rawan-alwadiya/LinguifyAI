import 'dart:convert';
import 'package:LinguifyAI/api/api_models/chat_response_model.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:http/http.dart' as http;

class ChatApiController {

  // Emulator URL
  // final String baseUrl = 'http://10.0.2.2:8000/text';

  // Real Device URL
  final String baseUrl = 'http://192.168.8.67:8000/text';

  Future<ChatResponse> sendChat(String inputText , String? userId) async {
    Uri uri = Uri.parse(baseUrl);
    try {
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input_text': inputText,
          if (userId != null) 'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['user_id'] != null) {
          SharedPrefController.instance.saveUserId(userId: jsonResponse['user_id']);
        }
        return ChatResponse.fromJson(jsonResponse);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return ChatResponse(response: 'Error occurred. Please try again.', userId: userId ?? '');
      }
    } catch (e) {
      print('Exception: $e');
      return ChatResponse(response: 'Exception occurred. Please try again.', userId: userId ?? '');
    }
  }
}