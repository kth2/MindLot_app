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

  // Free-tier Gemini models. Flash is stronger (better OCR + interpretation);
  // Flash-Lite is faster/cheaper for high throughput.
  static const defaultVisionModel = 'gemini-3.5-flash';
  static const defaultTextModel = 'gemini-3.5-flash';

  /// Models offered in Settings. Any Gemini model id works — switching
  /// providers entirely only requires a new [VisionService] implementation.
  static const availableModels = [
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
  ];

  /// Returns [model] if it is a known option, else the vision default —
  /// guards against a stale model id persisted from an older build.
  static String sanitizeModel(String? model) =>
      (model != null && availableModels.contains(model))
          ? model
          : defaultVisionModel;

  /// Human-friendly names for the Settings picker (falls back to the id).
  static const _modelLabels = {
    'gemini-3.5-flash': 'Gemini 3.5 Flash',
    'gemini-3.1-flash-lite': 'Gemini 3.1 Flash-Lite',
  };

  static String modelLabel(String id) => _modelLabels[id] ?? id;

  final String apiKey;
  final String visionModel;
  final String textModel;

  /// The key actually sent to the API, with surrounding whitespace and
  /// stray quotes stripped — e.g. PowerShell includes the quotes when you
  /// write `--dart-define=GEMINI_API_KEY='...'`, which would break auth.
  String get effectiveKey =>
      apiKey.trim().replaceAll(RegExp(r'''^['"]+|['"]+$'''), '').trim();

  bool get isConfigured => effectiveKey.isNotEmpty;
}

/// Machine-readable reasons an AI call can fail, mapped to localized text
/// at the UI layer (see `l10n/ai_error_text.dart`).
enum AiErrorCode {
  /// No API key configured yet.
  notConfigured,

  /// Network/transport failure reaching the provider.
  network,

  /// Rate limited (HTTP 429).
  rateLimited,

  /// Key rejected or lacks permission (HTTP 400/403).
  invalidKey,

  /// Any other non-200 server response ([detail] carries the status code).
  serverError,

  /// The provider returned no usable content.
  emptyResponse,
}

/// Thrown when an AI call fails in a way worth showing to the user.
///
/// Carries a machine-readable [code] (localized at the UI) plus optional
/// technical [detail] (status code, underlying error) that is never shown
/// translated — appended verbatim for diagnostics.
class AiServiceException implements Exception {
  const AiServiceException(this.code, {this.detail});

  final AiErrorCode code;
  final String? detail;

  @override
  String toString() =>
      'AiServiceException(${code.name}${detail != null ? ': $detail' : ''})';
}
