import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/document.dart';
import '../services/ai_service.dart';
import '../models/ai_response.dart';

class AppState extends ChangeNotifier {
  final List<Message> _messages = [];
  Document _document = Document.empty();
  bool _isLoading = false;
  final AIService _aiService = AIService();

  List<Message> get messages => _messages;
  Document get document => _document;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    final aiResponse = await _aiService.getResponse(List.of(_messages), _document);

    if (aiResponse != null) {
      final assistantMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: MessageRole.assistant,
        content: aiResponse.chatMessage,
        createdAt: DateTime.now(),
      );
      _messages.add(assistantMessage);
      _document = aiResponse.documentUpdate;
    } else {
      // Handle error case
      final errorMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: MessageRole.assistant,
        content: "Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.",
        createdAt: DateTime.now(),
      );
      _messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }
}
