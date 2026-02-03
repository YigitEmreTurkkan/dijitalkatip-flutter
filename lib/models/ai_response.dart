import './document.dart';

class AIResponse {
  final String chatMessage;
  final Document documentUpdate;

  AIResponse({required this.chatMessage, required this.documentUpdate});

  factory AIResponse.fromJson(Map<String, dynamic> json, Document currentDocument) {
    final docUpdateJson = json['document_update'] as Map<String, dynamic>? ?? {};

    // Create a new document by taking the old values and overriding with new ones.
    final updatedDoc = Document(
      id: currentDocument.id.isEmpty ? 'doc1' : currentDocument.id,
      header: docUpdateJson['header'] as String? ?? currentDocument.header,
      plaintiffDetails: docUpdateJson['plaintiff'] as String? ?? currentDocument.plaintiffDetails,
      defendantDetails: docUpdateJson['defendant'] as String? ?? currentDocument.defendantDetails,
      subject: docUpdateJson['subject'] as String? ?? currentDocument.subject,
      incidentNarrative: docUpdateJson['body'] as String? ?? currentDocument.incidentNarrative,
      legalGrounds: docUpdateJson['legal_grounds'] as String? ?? currentDocument.legalGrounds,
      evidenceList: docUpdateJson['evidence_list'] as String? ?? currentDocument.evidenceList,
      conclusionRequest: docUpdateJson['result'] as String? ?? currentDocument.conclusionRequest,
      updatedAt: DateTime.now(),
    );

    return AIResponse(
      chatMessage: json['chat_message'] as String,
      documentUpdate: updatedDoc,
    );
  }
}
