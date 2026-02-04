import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import '../models/document.dart';
import '../models/message.dart';

class AIService {
  // Cloudflare Worker proxy URL (same as web app)
  static const String _proxyUrl = 'https://yigit-gemini-proxy.yigit-turkkan.workers.dev';

  Future<AIResponse?> getResponse(List<Message> messageHistory, Document currentDocument) async {
    try {
      if (messageHistory.isEmpty) return null;

      final recent = messageHistory.length > 10
          ? messageHistory.sublist(messageHistory.length - 10)
          : messageHistory;

      final lastUserMessage = recent.lastWhere(
        (m) => m.role == MessageRole.user,
        orElse: () => recent.last,
      );

      final documentContext = '''
GÖREV: Sen tecrübeli bir hukukçusun. Amacın sadece bilgi vermek değil, hukuki jargona hakim, ikna edici ve müvekkil lehine en güçlü dilekçeyi yazmaktır.

MEVCUT BELGE DURUMU (JSON):
${jsonEncode(currentDocument.toJson())}

KURALLAR:
1. Robotik cevaplardan kaçın. "Yapay zeka dili" yerine "Hukuk dili" kullan.
2. "document_update.body" kısmını yazarken Yargıtay kararlarına atıf yapar gibi profesyonel, akıcı ve ikna edici bir üslup takın.
3. Kullanıcı kısa bir bilgi verse bile, bunu hukuki terimlerle genişlet.
''';

      final geminiHistory = recent.map((m) {
        return {
          'role': m.role == MessageRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.content},
          ],
        };
      }).toList();

      final systemInstruction = '''
You are 'Dijital Katip', a helpful legal assistant for Turkish law.
$documentContext

UX/APP GUIDANCE (very important):
- The user sees you in a "Chat" tab and the generated legal document in a separate "Document / PDF" tab.
- Especially when the user seems confused, clearly explain in Turkish where they can see the updated document
  (e.g. "Üstteki 'Belge / PDF' sekmesine tıklayarak dilekçenin güncel halini görebilirsiniz.")
- Also remind the user that they can download the document as PDF from the button at the bottom right of the document screen
  (e.g. "Belge ekranının sağ alt köşesindeki 'PDF İndir' butonuyla dilekçenizi PDF olarak indirebilirsiniz.").
''';

      final body = {
        'message': lastUserMessage.content,
        'history': geminiHistory,
        'systemInstruction': systemInstruction,
        'generationConfig': {
          'temperature': 0.7,
          'topP': 0.95,
          'topK': 40,
        },
      };

      final response = await http.post(
        Uri.parse(_proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print('Proxy error: ${response.statusCode} - ${response.body}');

        // Özel durum: 429 kota hatası için kullanıcıya anlaşılır mesaj dön.
        if (response.statusCode == 429) {
          return AIResponse(
            chatMessage:
                'Şu anda kullanılan yapay zeka kotası dolmuş görünüyor (429 RESOURCE_EXHAUSTED). '
                'Bir süre bekledikten sonra tekrar dener misiniz? Sorun devam ederse geliştiriciye haber vermeniz gerekir.',
            documentUpdate: currentDocument,
          );
        }

        // Diğer hatalar için genel mesaj
        return AIResponse(
          chatMessage:
              'Üzgünüm, yapay zeka servisiyle konuşurken bir hata oluştu (HTTP ${response.statusCode}). '
              'Biraz bekleyip tekrar deneyebilirsiniz.',
          documentUpdate: currentDocument,
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      // Worker returns { text: "..." } format or raw Gemini response.
      String? text = data['text'] as String?;

      if (text == null) {
        final candidates = data['candidates'];
        if (candidates is List && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content is Map && content['parts'] is List && content['parts'].isNotEmpty) {
            text = content['parts'][0]['text'] as String?;
          }
        }
      }

      if (text == null || text.isEmpty) {
        print('No text in Gemini/proxy response: $data');
        return AIResponse(
          chatMessage:
              'Üzgünüm, geçerli bir yanıt alamadım. Lütfen sorununuzu tekrar yazar mısınız?',
          documentUpdate: currentDocument,
        );
      }

      final cleanedJson = _extractJson(text);
      if (cleanedJson == null) {
        // JSON çıkarılamadıysa, en azından sohbet mesajını kullanıcıya dön,
        // belgeyi değiştirme.
        print('Could not extract JSON from AI text: $text');
        return AIResponse(
          chatMessage: text,
          documentUpdate: currentDocument,
        );
      }

      final jsonResponse = jsonDecode(cleanedJson) as Map<String, dynamic>;
      return AIResponse.fromJson(jsonResponse, currentDocument);
    } catch (e, stack) {
      print('Error calling AI Service via proxy: $e');
      print(stack);
      return AIResponse(
        chatMessage:
            'Üzgünüm, beklenmeyen bir hata oluştu. Biraz sonra tekrar denemenizi rica ederim.',
        documentUpdate: currentDocument,
      );
    }
  }

  String? _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return null;
  }
}
