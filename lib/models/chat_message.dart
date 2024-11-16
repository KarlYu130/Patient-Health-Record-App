class ChatMessage {
  final String? text;
  final String? imagePath; // Existing field
  final bool isUser;

  ChatMessage({this.text, this.imagePath, required this.isUser});
}
