
import 'dart:convert';

import 'package:LinguifyAI/api/api_models/random_question_model.dart';
import 'package:http/http.dart' as http;

class RandomQuestionController {

  // Emulator URL
  final String baseUrl = 'http://10.0.2.2:8000/random_question';

  Future<RandomQuestionResponse> getRandomQuestion() async {
    Uri uri = Uri.parse(baseUrl);
    try {
      var response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'}
      );
      if (response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        return RandomQuestionResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch random question: $e');
    }
  }
}