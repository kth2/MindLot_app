import 'dart:convert';
import 'dart:typed_data';

import '../../data/models/lot_set.dart';
import '../../data/models/vision_result.dart';
import 'gemini_client.dart';
import 'prompts.dart';
import 'vision_service.dart';

/// Gemini implementation of [VisionService] (default: Gemini 1.5 Flash).
class GeminiVisionService implements VisionService {
  GeminiVisionService(this._client);

  final GeminiClient _client;

  @override
  Future<VisionResult> analyzeLotImage(
    Uint8List imageBytes, {
    required String mimeType,
    required List<LotSet> knownSets,
  }) async {
    // Inject the live registry as the model's classification vocabulary.
    final setsBlock = knownSets
        .map((s) =>
            '- id: ${s.id}｜名稱: ${s.name}（${s.aliases.join('、')}）｜共 ${s.totalLots} 籤｜編號方式: ${s.numberingStyle == 'sexagenary' ? '六十甲子（干支）' : '數字'}')
        .join('\n');

    final text = await _client.generateContent(
      model: _client.config.visionModel,
      systemPrompt: visionSystemPrompt(knownSetsBlock: setsBlock),
      parts: [
        {'text': '請辨識這張照片中的籤枝或籤詩，依規定格式回傳 JSON。'},
        {
          'inline_data': {
            'mime_type': mimeType,
            'data': base64Encode(imageBytes),
          }
        },
      ],
      temperature: 0.1, // deterministic extraction, not creativity
      jsonOutput: true,
    );

    try {
      return VisionResult.fromJson(GeminiClient.parseJsonResponse(text));
    } catch (_) {
      // Unparseable output → treat as recognition failure so the UI offers
      // the manual-input fallback instead of crashing.
      return VisionResult.failed;
    }
  }
}
