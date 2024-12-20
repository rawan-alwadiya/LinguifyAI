import 'dart:convert';

import 'package:LinguifyAI/api/api_models/correct_grammar_response_model.dart';
import 'package:http/http.dart' as http;

class CorrectGrammarController {
  // Emulator URL
  final String baseUrl = 'http://10.0.2.2:8000/correct_grammar';

  Future<CorrectGrammarResponse> sendText(String inputText) async {
    Uri uri = Uri.parse(baseUrl);
    try {
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': inputText
        })
      );
      if (response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        return CorrectGrammarResponse.fromJson(jsonResponse);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return CorrectGrammarResponse(correctedText:  'Error occurred. Please try again.');
      }
    } catch (e) {
      print('Exception: $e');
      return CorrectGrammarResponse(correctedText:  'Error occurred. Please try again.');
    }
  }
}