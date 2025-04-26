// نموذج رسالة المحادثة
class ChatMessage {
  final String text; // نص الرسالة
  final bool isUser; // هل الرسالة من المستخدم؟

  ChatMessage({required this.text, required this.isUser});
}
