import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/research_item.dart';

class EmsalService {
  static const String _baseUrl = 'https://emsal.uyap.gov.tr';
  final http.Client _client = http.Client();
  String? _sessionCookie;

  Future<List<ResearchItem>> search(String query, {int page = 1, int pageSize = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      await _ensureSession();
      final headers = _buildHeaders(_sessionCookie);

      await _postJson(
        _client,
        Uri.parse('$_baseUrl/arama'),
        headers,
        {'data': {'arananKelime': trimmed}},
      );

      final response = await _postJson(
        _client,
        Uri.parse('$_baseUrl/aramalist'),
        headers,
        {
          'data': {
            'arananKelime': trimmed,
            'pageSize': pageSize,
            'pageNumber': page,
          },
        },
      );

      final decoded = jsonDecode(response) as Map<String, dynamic>;
      final data = (decoded['data'] as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];

      return data.map((raw) {
        final item = raw as Map<String, dynamic>;
        final daire = item['daire']?.toString() ?? 'Emsal Karar';
        final esasNo = item['esasNo']?.toString() ?? '';
        final kararNo = item['kararNo']?.toString() ?? '';
        final kararTarihi = item['kararTarihi']?.toString() ?? '';
        final durum = item['durum']?.toString() ?? '';
        final id = item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

        final titleParts = <String>[
          daire,
          if (esasNo.isNotEmpty) '$esasNo E.',
          if (kararNo.isNotEmpty) '$kararNo K.',
        ];

        final snippetParts = <String>[
          if (kararTarihi.isNotEmpty) 'Karar Tarihi: $kararTarihi',
          if (durum.isNotEmpty) 'Durum: $durum',
        ];

        return ResearchItem(
          id: id,
          title: titleParts.join(' · '),
          snippet: snippetParts.isEmpty ? 'UYAP Emsal Karar' : snippetParts.join(' · '),
          source: 'UYAP Emsal',
          createdAt: DateTime.now(),
        );
      }).toList();
    }
  }

  Future<String?> fetchDecisionText(String documentId) async {
    try {
      await _ensureSession();
      final headers = _buildHeaders(_sessionCookie);
      final uri = Uri.parse('$_baseUrl/getDokuman?id=$documentId');
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = _tryDecodeJson(response.body);
      if (decoded is Map<String, dynamic>) {
        final html = decoded['data']?.toString();
        if (html == null || html.isEmpty) return null;
        return _stripHtml(html);
      }
      return _stripHtml(response.body);
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
      return;
    }
    final response = await _client.get(Uri.parse(_baseUrl));
    _sessionCookie = _extractSessionCookie(response.headers['set-cookie']);
  }

  Map<String, String> _buildHeaders(String? cookie) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json, text/plain, */*',
    };
    if (cookie != null && cookie.isNotEmpty) {
      headers['cookie'] = cookie;
    }
    return headers;
  }

  Future<String> _postJson(
    http.Client client,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    final response = await client.post(uri, headers: headers, body: jsonEncode(body));
    _sessionCookie ??= _extractSessionCookie(response.headers['set-cookie']);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Emsal arama hatası: ${response.statusCode}');
    }
    return response.body;
  }

  String? _extractSessionCookie(String? setCookie) {
    if (setCookie == null) return null;
    final match = RegExp(r'JSESSIONID=[^;]+').firstMatch(setCookie);
    return match?.group(0);
  }

  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'(?i)<br\\s*/?>'), '\n')
        .replaceAll(RegExp(r'(?i)</p>'), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = text.replaceAll(RegExp(r'\\s+\\n'), '\n');
    text = text.replaceAll(RegExp(r'\\n\\s+'), '\n');
    text = text.replaceAll(RegExp(r'\\n{3,}'), '\n\n');
    return text.trim();
  }
}
