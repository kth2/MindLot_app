import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/lot_set.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/lot_repository.dart';
import '../services/ai/gemini_client.dart';
import '../services/ai/gemini_interpretation_service.dart';
import '../services/ai/gemini_vision_service.dart';
import '../services/ai/interpretation_service.dart';
import '../services/ai/vision_service.dart';
import '../services/audio/sound_service.dart';
import 'settings_provider.dart';

// ---------------------------------------------------------------------------
// Data layer
// ---------------------------------------------------------------------------

final lotRepositoryProvider = Provider<LotRepository>((ref) => LotRepository());

final historyRepositoryProvider =
    Provider<HistoryRepository>((ref) => HistoryRepository());

final lotSetsProvider = FutureProvider<List<LotSet>>(
    (ref) => ref.watch(lotRepositoryProvider).loadSets());

final lotSetsWithDataProvider = FutureProvider<List<LotSet>>(
    (ref) => ref.watch(lotRepositoryProvider).setsWithData());

// ---------------------------------------------------------------------------
// AI layer — swap the two bindings below to change providers.
// ---------------------------------------------------------------------------

final _geminiClientProvider = Provider<GeminiClient>((ref) {
  final config = ref.watch(settingsProvider.select((s) => s.aiConfig));
  return GeminiClient(config: config);
});

final visionServiceProvider = Provider<VisionService>(
    (ref) => GeminiVisionService(ref.watch(_geminiClientProvider)));

final interpretationServiceProvider = Provider<InterpretationService>(
    (ref) => GeminiInterpretationService(ref.watch(_geminiClientProvider)));

// ---------------------------------------------------------------------------
// Misc
// ---------------------------------------------------------------------------

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});
