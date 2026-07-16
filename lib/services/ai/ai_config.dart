/// Configuration for the AI provider.
///
/// The API key is resolved in this order:
///   1. In-app Settings (stored locally on device)
///   2. `--dart-define=GEMINI_API_KEY=...` at build time
class AiConfig {
  const AiConfig({
    required this.apiKey,
    this.visionModel = defaultVisionModel,
    this.textModel = defaultTextModel,
  });

  static const envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const defaultVisionModel = 'gemini-1.5-flash';
  static const defaultTextModel = 'gemini-1.5-flash';

  /// Models offered in Settings. Any Gemini model id works — switching
  /// providers entirely only requires a new [VisionService] implementation.
  static const availableModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
  ];

  final String apiKey;
  final String visionModel;
  final String textModel;

  bool get isConfigured => apiKey.isNotEmpty;
}

/// Thrown when an AI call fails in a way worth showing to the user.
class AiServiceException implements Exception {
  const AiServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
