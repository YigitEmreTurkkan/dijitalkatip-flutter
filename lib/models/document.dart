class Document {
  final String id;
  final String? header;
  final String? plaintiffDetails;
  final String? defendantDetails;
  final String? subject;
  final String? incidentNarrative;
  final String? legalGrounds;
  final String? evidenceList;
  final String? conclusionRequest;
  final DateTime updatedAt;

  Document({
    required this.id,
    this.header,
    this.plaintiffDetails,
    this.defendantDetails,
    this.subject,
    this.incidentNarrative,
    this.legalGrounds,
    this.evidenceList,
    this.conclusionRequest,
    required this.updatedAt,
  });

  // A factory constructor for creating a new Document instance from a map.
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as String,
      header: map['header'] as String?,
      plaintiffDetails: map['plaintiff_details'] as String?,
      defendantDetails: map['defendant_details'] as String?,
      subject: map['subject'] as String?,
      incidentNarrative: map['incident_narrative'] as String?,
      legalGrounds: map['legal_grounds'] as String?,
      evidenceList: map['evidence_list'] as String?,
      conclusionRequest: map['conclusion_request'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Method to convert the Document instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'header': header,
      'plaintiff_details': plaintiffDetails,
      'defendant_details': defendantDetails,
      'subject': subject,
      'incident_narrative': incidentNarrative,
      'legal_grounds': legalGrounds,
      'evidence_list': evidenceList,
      'conclusion_request': conclusionRequest,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // An initial empty document.
  static Document empty() => Document(id: '', updatedAt: DateTime.now());
}
