/// A divination lot system (籤種), e.g. 觀音靈籤 or 媽祖六十甲子籤.
class LotSet {
  const LotSet({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.deity,
    required this.totalLots,
    required this.numberingStyle,
    required this.dataFile,
    required this.description,
    required this.aliases,
  });

  final String id;
  final String name;
  final String nameEn;
  final String deity;
  final int totalLots;

  /// `numeric` (第1籤…第100籤) or `sexagenary` (甲子、乙丑…).
  final String numberingStyle;

  /// Asset path of the per-set lot database; null when the set can only be
  /// recognized from photos (poem text extracted, no local database yet).
  final String? dataFile;

  final String description;
  final List<String> aliases;

  bool get hasLocalData => dataFile != null;

  factory LotSet.fromJson(Map<String, dynamic> json) => LotSet(
        id: json['id'] as String,
        name: json['name'] as String,
        nameEn: json['nameEn'] as String? ?? '',
        deity: json['deity'] as String? ?? '',
        totalLots: json['totalLots'] as int? ?? 0,
        numberingStyle: json['numberingStyle'] as String? ?? 'numeric',
        dataFile: json['dataFile'] as String?,
        description: json['description'] as String? ?? '',
        aliases: (json['aliases'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}
