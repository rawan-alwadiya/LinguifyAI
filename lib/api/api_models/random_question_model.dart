class RandomQuestionResponse {
  late String question;
  late Choices choices;

  RandomQuestionResponse({required this.question, required this.choices});

  RandomQuestionResponse.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    choices = Choices.fromJson(json['choices']);
  }
}

class Choices {
  late String s1;
  late String s2;
  late String s3;
  late String s4;

  Choices({required this.s1, required this.s2, required this.s3, required this.s4});

  Choices.fromJson(Map<String, dynamic> json) {
    s1 = json['1'];
    s2 = json['2'];
    s3 = json['3'];
    s4 = json['4'];
  }
}
