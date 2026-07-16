import '../../data/models/lot.dart';
import 'gemini_client.dart';
import 'interpretation_service.dart';
import 'prompts.dart';

/// Gemini implementation of [InterpretationService].
class GeminiInterpretationService implements InterpretationService {
  GeminiInterpretationService(this._client);

  final GeminiClient _client;

  @override
  Future<String> interpret({
    required Lot lot,
    required String setName,
    String? category,
    String? question,
  }) async {
    final text = await _client.generateContent(
      model: _client.config.textModel,
      systemPrompt: interpretationSystemPrompt,
      parts: [
        {
          'text': interpretationUserPrompt(
            setName: setName,
            lotLabel: lot.label,
            level: lot.level,
            title: lot.title,
            poem: lot.poemText,
            poemTranslation: lot.poemTranslation,
            allusion: lot.allusion,
            meaning: lot.meaning,
            wuxing: lot.wuxing,
            category: category,
            question: question,
          ),
        },
      ],
      temperature: 0.8, // warm, human-sounding readings
    );
    return text.trim();
  }
}
