import 'dart:typed_data';

import '../../data/models/lot_set.dart';
import '../../data/models/vision_result.dart';

/// Provider-agnostic contract for photographed-lot analysis.
///
/// Implementations: [GeminiVisionService] (default). To switch providers,
/// implement this interface and swap the binding in `providers.dart`.
abstract class VisionService {
  /// Analyzes a photo of a physical divination lot.
  ///
  /// [knownSets] supplies the classification vocabulary so the model only
  /// maps to set ids the app actually knows.
  Future<VisionResult> analyzeLotImage(
    Uint8List imageBytes, {
    required String mimeType,
    required List<LotSet> knownSets,
  });
}
