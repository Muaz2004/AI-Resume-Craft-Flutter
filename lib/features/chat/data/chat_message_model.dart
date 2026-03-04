
class ChatMessage {
  final String content;   
  final String sender;    
  final DateTime timestamp; 

  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}