
class CorrectGrammarResponse {

  late String correctedText;

  CorrectGrammarResponse({required this.correctedText});

  CorrectGrammarResponse.fromJson(Map<String, dynamic> json) {
    correctedText = json['corrected_text'];
  }

}
