/// Structured output from the Vision AI when analyzing a photographed lot.
class VisionResult {
  const VisionResult({
    required this.recognized,
    required this.confidence,
    this.setId,
    this.setNameGuess,
    this.lotNumber,
    this.sexagenary,
    this.poemText,
    this.notes,
  });

  /// Whether the image clearly contains a divination lot/poem slip.
  final bool recognized;

  /// Model self-reported confidence, 0.0–1.0.
  final double confidence;

  /// Matched set id from the registry (e.g. `guanyin_100`), if identifiable.
  final String? setId;

  /// Raw set-name text seen on the lot when no registry id matched.
  final String? setNameGuess;

  /// Lot number if visible (Arabic or converted from Chinese numerals).
  final int? lotNumber;

  /// Sexagenary designation (e.g. 丁亥) for 60-lot systems.
  final String? sexagenary;

  /// Poem text extracted from the slip, lines separated by `/`.
  final String? poemText;

  /// Anything noteworthy the model wants to surface (e.g. blur, partial crop).
  final String? notes;

  List<String> get poemLines => (poemText ?? '')
      .split(RegExp(r'[/\n，。；,]'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  factory VisionResult.fromJson(Map<String, dynamic> json) => VisionResult(
        recognized: json['recognized'] as bool? ?? false,
        confidence: (json['confidence'] as num? ?? 0).toDouble(),
        setId: _emptyToNull(json['setId']),
        setNameGuess: _emptyToNull(json['setNameGuess']),
        lotNumber: _toInt(json['lotNumber']),
        sexagenary: _emptyToNull(json['sexagenary']),
        poemText: _emptyToNull(json['poemText']),
        notes: _emptyToNull(json['notes']),
      );

  static String? _emptyToNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return (s.isEmpty || s == 'null') ? null : s;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static const failed = VisionResult(recognized: false, confidence: 0);
}
