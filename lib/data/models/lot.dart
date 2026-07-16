/// A single divination lot (一支籤) with its poem and interpretation data.
class Lot {
  const Lot({
    required this.id,
    required this.setId,
    required this.number,
    required this.label,
    this.sexagenary,
    required this.level,
    required this.title,
    required this.poem,
    this.poemTranslation = '',
    this.allusion = '',
    this.meaning = '',
    this.aspects = const {},
    this.keywords = const [],
  });

  final String id;
  final String setId;
  final int number;

  /// Display label, e.g. `第二十四籤` or `丁亥籤`.
  final String label;

  /// Sexagenary cycle name (甲子…癸亥) for 60-lot systems, otherwise null.
  final String? sexagenary;

  /// Fortune level (籤等), e.g. 上籤 / 中籤 / 下籤, or finer grades such as
  /// 上上 / 上吉 / 中吉 / 中平 / 下下 that some lot sets use.
  final String level;

  /// Historical allusion title (籤題), e.g. 開天闢地.
  final String title;

  /// Poem lines (籤詩), one entry per line.
  final List<String> poem;

  /// Modern-Chinese paraphrase of the poem (白話).
  final String poemTranslation;

  /// Story behind the allusion (典故).
  final String allusion;

  /// Classical interpretation (解曰).
  final String meaning;

  /// Aspect guidance keyed by: career, love, wealth, health, study, travel.
  final Map<String, String> aspects;

  final List<String> keywords;

  String get poemText => poem.join('，');

  factory Lot.fromJson(Map<String, dynamic> json, {required String setId}) =>
      Lot(
        id: json['id'] as String,
        setId: setId,
        number: json['number'] as int,
        label: json['label'] as String,
        sexagenary: json['sexagenary'] as String?,
        level: json['level'] as String? ?? '',
        title: json['title'] as String? ?? '',
        poem: (json['poem'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        poemTranslation: json['poemTranslation'] as String? ?? '',
        allusion: json['allusion'] as String? ?? '',
        meaning: json['meaning'] as String? ?? '',
        aspects: (json['aspects'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v.toString())),
        keywords: (json['keywords'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  /// Builds an ephemeral lot from photo-recognition output when the set has
  /// no bundled database (poem extracted by Vision AI, interpreted by LLM).
  factory Lot.external({
    required String setId,
    required String setName,
    int? number,
    String? sexagenary,
    required List<String> poem,
  }) =>
      Lot(
        id: 'external_${setId}_${number ?? sexagenary ?? 'unknown'}',
        setId: setId,
        number: number ?? 0,
        label: sexagenary != null
            ? '$sexagenary籤'
            : (number != null ? '第$number籤' : setName),
        sexagenary: sexagenary,
        level: '',
        title: '',
        poem: poem,
      );

  bool get isExternal => id.startsWith('external_');
}

/// Canonical aspect keys and their Chinese display names.
const Map<String, String> kAspectNames = {
  'career': '事業',
  'love': '感情',
  'wealth': '財運',
  'health': '健康',
  'study': '學業',
  'travel': '出行',
};
