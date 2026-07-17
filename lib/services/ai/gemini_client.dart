import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_config.dart';

/// Minimal Gemini REST client (`generateContent`).
///
/// We call the REST API directly instead of depending on a provider SDK:
/// fewer dependencies, and the whole provider surface is one small file.
class GeminiClient {
  GeminiClient({required this.config, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final AiConfig config;
  final http.Client _http;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Sends a generateContent request; [parts] follow the Gemini parts schema
  /// (`{'text': ...}` or `{'inline_data': {...}}`).
  Future<String> generateContent({
    required String model,
    required String systemPrompt,
    required List<Map<String, dynamic>> parts,
    double temperature = 0.7,
    bool jsonOutput = false,
  }) async {
    if (!config.isConfigured) {
      throw const AiServiceException(AiErrorCode.notConfigured);
    }

    final uri = Uri.parse('$_baseUrl/$model:generateContent');
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {'role': 'user', 'parts': parts}
      ],
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': 2048,
        if (jsonOutput) 'response_mime_type': 'application/json',
      },
      'safetySettings': const [
        // Divination text can trip over-cautious filters; keep defaults sane.
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
      ],
    });

    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': config.apiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException(AiErrorCode.network, detail: '$e');
    }

    if (response.statusCode == 429) {
      throw const AiServiceException(AiErrorCode.rateLimited);
    }
    if (response.statusCode == 400 || response.statusCode == 403) {
      throw const AiServiceException(AiErrorCode.invalidKey);
    }
    if (response.statusCode != 200) {
      throw AiServiceException(AiErrorCode.serverError,
          detail: '${response.statusCode}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const AiServiceException(AiErrorCode.emptyResponse);
    }
    final content =
        (candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>?;
    final parts0 = content?['parts'] as List<dynamic>?;
    final text = parts0
            ?.map((p) => (p as Map<String, dynamic>)['text']?.toString() ?? '')
            .join() ??
        '';
    if (text.trim().isEmpty) {
      throw const AiServiceException(AiErrorCode.emptyResponse);
    }
    return text;
  }

  /// Strips accidental markdown fences and parses JSON leniently.
  static Map<String, dynamic> parseJsonResponse(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '')
          .replaceFirst(RegExp(r'```\s*$'), '');
    }
    // Fall back to the outermost braces if the model added prose.
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start >= 0 && end > start) {
      cleaned = cleaned.substring(start, end + 1);
    }
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}
