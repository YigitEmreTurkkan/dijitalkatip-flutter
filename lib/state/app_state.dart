import 'package:flutter/material.dart';
import 'dart:math';
import '../models/message.dart';
import '../models/document.dart';
import '../services/ai_service.dart';
import '../models/ai_response.dart';
import '../models/case_folder.dart';
import '../models/research_item.dart';

class AppState extends ChangeNotifier {
  final List<Message> _messages = [];
  Document _document = Document.empty();
  bool _isLoading = false;
  final AIService _aiService = AIService();

  List<Message> get messages => _messages;
  Document get document => _document;
  bool get isLoading => _isLoading;

  // Case management (local-only MVP)
  final List<CaseFolder> _folders = [
    CaseFolder(
      id: 'case-1',
      name: 'Örnek Dosya • Tazminat',
      description: 'Müvekkil A.Ş. vs X Ltd.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  String? _activeFolderId = 'case-1';

  final Map<String, List<Document>> _folderDocuments = {
    'case-1': [],
  };

  final Map<String, List<ResearchItem>> _folderResearch = {
    'case-1': [],
  };

  List<CaseFolder> get folders => List.unmodifiable(_folders);
  String? get activeFolderId => _activeFolderId;
  CaseFolder? get activeFolder => _folders.where((f) => f.id == _activeFolderId).cast<CaseFolder?>().firstWhere((e) => true, orElse: () => null);
  List<Document> documentsForFolder(String folderId) => List.unmodifiable(_folderDocuments[folderId] ?? const []);
  List<ResearchItem> researchForFolder(String folderId) => List.unmodifiable(_folderResearch[folderId] ?? const []);

  void setActiveFolder(String? folderId) {
    _activeFolderId = folderId;
    notifyListeners();
  }

  void createFolder({required String name, String? description}) {
    final id = 'case-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
    final folder = CaseFolder(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _folders.insert(0, folder);
    _folderDocuments[id] = [];
    _folderResearch[id] = [];
    _activeFolderId = id;
    notifyListeners();
  }

  void saveCurrentDocumentToActiveFolder({String? titleHint}) {
    final folderId = _activeFolderId;
    if (folderId == null) return;
    if (_document.id.isEmpty) return;

    final existing = _folderDocuments[folderId] ?? [];
    existing.insert(0, _document);
    _folderDocuments[folderId] = existing;
    notifyListeners();
  }

  void upsertDocumentInActiveFolder(Document doc) {
    final folderId = _activeFolderId;
    if (folderId == null) return;
    final list = List<Document>.from(_folderDocuments[folderId] ?? const []);
    final idx = list.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) {
      list[idx] = doc;
    } else {
      list.insert(0, doc);
    }
    _folderDocuments[folderId] = list;
    _document = doc;
    notifyListeners();
  }

  void saveResearchToActiveFolder(ResearchItem item) {
    final folderId = _activeFolderId;
    if (folderId == null) return;
    final list = List<ResearchItem>.from(_folderResearch[folderId] ?? const []);
    list.insert(0, item);
    _folderResearch[folderId] = list;
    notifyListeners();
  }

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

  void updateDocument({
    String? header,
    String? plaintiffDetails,
    String? defendantDetails,
    String? subject,
    String? incidentNarrative,
    String? legalGrounds,
    String? evidenceList,
    String? conclusionRequest,
  }) {
    _document = Document(
      id: _document.id.isEmpty ? 'doc1' : _document.id,
      header: header ?? _document.header,
      plaintiffDetails: plaintiffDetails ?? _document.plaintiffDetails,
      defendantDetails: defendantDetails ?? _document.defendantDetails,
      subject: subject ?? _document.subject,
      incidentNarrative: incidentNarrative ?? _document.incidentNarrative,
      legalGrounds: legalGrounds ?? _document.legalGrounds,
      evidenceList: evidenceList ?? _document.evidenceList,
      conclusionRequest: conclusionRequest ?? _document.conclusionRequest,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
}
