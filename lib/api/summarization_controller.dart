import 'dart:convert';

import 'package:LinguifyAI/api/api_models/summarization_response_model.dart';
import 'package:http/http.dart' as http;

class SummarizationController {

  final String baseUrl = 'http://10.0.2.2:8000/summarize';

  Future<SummarizationResponse> summarizeText(String inputText) async {
    Uri uri = Uri.parse(baseUrl);
    try {
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'text': inputText
        }),
      );
      if (response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        return SummarizationResponse.fromJson(jsonResponse);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to summarize text');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('An error occurred while summarizing text');
    }

  }
}