class ValidateAnswerResponse {
  late bool correct;
  late String message;
  late String correctAnswer;

  ValidateAnswerResponse({required this.correct, required this.message, required this.correctAnswer});

  ValidateAnswerResponse.fromJson(Map<String, dynamic> json) {
    correct = json['correct'];
    message = json['message'];
    correctAnswer = json['correct_answer'];
  }
}