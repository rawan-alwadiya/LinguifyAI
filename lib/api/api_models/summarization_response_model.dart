
class SummarizationResponse {
  late String summary;

  SummarizationResponse({required this.summary});

  SummarizationResponse.fromJson(Map<String, dynamic> json) {
    summary = json['summary'];
  }
}
