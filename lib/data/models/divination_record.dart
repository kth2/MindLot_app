/// How a lot entered the app.
enum DivinationSource { photo, draw, manual }

/// One divination event, persisted to history.
class DivinationRecord {
  const DivinationRecord({
    required this.id,
    required this.timestamp,
    required this.source,
    required this.setId,
    required this.setName,
    required this.lotNumber,
    required this.lotLabel,
    this.sexagenary,
    this.level = '',
    this.poemSnapshot = const [],
    this.question,
    this.category,
    this.interpretation,
    this.isFavorite = false,
  });

  final String id;
  final DateTime timestamp;
  final DivinationSource source;
  final String setId;
  final String setName;
  final int lotNumber;
  final String lotLabel;
  final String? sexagenary;
  final String level;

  /// Poem stored inline so history remains readable even for external sets.
  final List<String> poemSnapshot;

  /// The user's question, if they asked one.
  final String? question;

  /// Question category key (career/love/…), if selected.
  final String? category;

  /// AI-generated personalized interpretation, if requested.
  final String? interpretation;

  final bool isFavorite;

  DivinationRecord copyWith({
    String? question,
    String? category,
    String? interpretation,
    bool? isFavorite,
  }) =>
      DivinationRecord(
        id: id,
        timestamp: timestamp,
        source: source,
        setId: setId,
        setName: setName,
        lotNumber: lotNumber,
        lotLabel: lotLabel,
        sexagenary: sexagenary,
        level: level,
        poemSnapshot: poemSnapshot,
        question: question ?? this.question,
        category: category ?? this.category,
        interpretation: interpretation ?? this.interpretation,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'source': source.name,
        'setId': setId,
        'setName': setName,
        'lotNumber': lotNumber,
        'lotLabel': lotLabel,
        'sexagenary': sexagenary,
        'level': level,
        'poemSnapshot': poemSnapshot,
        'question': question,
        'category': category,
        'interpretation': interpretation,
        'isFavorite': isFavorite,
      };

  factory DivinationRecord.fromJson(Map<String, dynamic> json) =>
      DivinationRecord(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        source: DivinationSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => DivinationSource.manual,
        ),
        setId: json['setId'] as String,
        setName: json['setName'] as String? ?? '',
        lotNumber: json['lotNumber'] as int? ?? 0,
        lotLabel: json['lotLabel'] as String? ?? '',
        sexagenary: json['sexagenary'] as String?,
        level: json['level'] as String? ?? '',
        poemSnapshot: (json['poemSnapshot'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        question: json['question'] as String?,
        category: json['category'] as String?,
        interpretation: json['interpretation'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
