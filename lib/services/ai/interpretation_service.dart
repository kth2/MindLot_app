import '../../data/models/lot.dart';

/// Provider-agnostic contract for personalized lot interpretation.
abstract class InterpretationService {
  /// Generates a warm, personalized reading for [lot].
  ///
  /// [category] is a Chinese label (事業/感情/…); [question] is the user's
  /// free-text question. Both are optional.
  Future<String> interpret({
    required Lot lot,
    required String setName,
    String? category,
    String? question,
  });
}
