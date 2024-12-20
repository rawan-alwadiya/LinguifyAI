class ChatMessage {
  final int? id;
  final String message;
  final bool isUser;

  ChatMessage({this.id, required this.message, required this.isUser});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isUser': isUser ? 1 : 0
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
        message: map['message'],
        isUser: map['isUser'] == 1
    );
  }
}