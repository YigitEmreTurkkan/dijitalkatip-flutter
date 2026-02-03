import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_response.dart';
import '../models/document.dart';
import '../models/message.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);

  Future<AIResponse?> getResponse(List<Message> messageHistory, Document currentDocument) async {
    try {
      final chatHistory = messageHistory.map((m) {
        return Content(m.role == MessageRole.user ? 'user' : 'model', [TextPart(m.content)]);
      }).toList();

      final prompt = chatHistory.removeLast().parts.first as TextPart;

      final fullPrompt = '''
          You are 'Dijital Katip', a helpful legal assistant for Turkish law.
          Your goal is to gather information from the user to create a formal legal document (dilekçe).
          Based on the user's prompt, you must:
          1. Provide a conversational, helpful response to the user.
          2. Update the legal document based on the new information.

          The user's prompt is: "${prompt.text}"

          The current document state is:
          ${jsonEncode(currentDocument.toJson())}

          You MUST respond with a single, valid JSON object with the following structure:
          {
            "chat_message": "Your conversational response here.",
            "document_update": {
              "header": "...",
              "plaintiff": "...",
              "defendant": "...",
              "subject": "...",
              "body": "...",
              "result": "..."
            }
          }
          ''';

      // Generate content with the text-only model
      final response = await _model.generateContent([Content.text(fullPrompt)]);

      if (response.text != null) {
        final cleanedJson = _extractJson(response.text!);
        if (cleanedJson != null) {
          try {
            final jsonResponse = jsonDecode(cleanedJson) as Map<String, dynamic>;
            return AIResponse.fromJson(jsonResponse, currentDocument);
          } catch (e) {
            print("Error decoding JSON response: $e");
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      print("Error calling AI Service: $e");
      return null;
    }
  }

  String? _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1) {
      return text.substring(startIndex, endIndex + 1);
    }
    return null;
  }
}
