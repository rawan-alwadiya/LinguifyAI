import 'dart:convert';

import 'package:LinguifyAI/api/api_models/validate_answer_model.dart';
import 'package:http/http.dart' as http;

class ValidateAnswerController {

  // Emulator URL
  // final String baseUrl = 'http://10.0.2.2:8000/validate_answer';

  // Real Device URL
  final String baseUrl = 'http://192.168.8.67:8000/validate_answer';

  Future<ValidateAnswerResponse> validateAnswer(String question, String userChoice) async {
    Uri uri = Uri.parse(baseUrl);

    try {
      var response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'question': question,
            'user_choice': userChoice
          })
      );
      if (response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        return ValidateAnswerResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch random question: $e');
    }
  }

}