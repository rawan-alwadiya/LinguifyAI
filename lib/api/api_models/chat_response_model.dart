class ChatResponse {
  // final String response;
  // final String userId;
  late String response;
  String? userId;

  ChatResponse({required this.response, required this.userId});

  ChatResponse.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    userId = json['user_id'];
  }
}