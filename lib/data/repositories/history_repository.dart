import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/divination_record.dart';

/// Persists divination history & favorites as JSON in SharedPreferences.
///
/// Kept deliberately simple for v1; swap for a database (drift/hive) if
/// history grows beyond a few hundred entries.
class HistoryRepository {
  static const _key = 'mindlot.history.v1';
  static const _maxRecords = 200;

  Future<List<DivinationRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DivinationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<DivinationRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    // Never drop favorites when trimming to the cap.
    var trimmed = records;
    if (records.length > _maxRecords) {
      final favorites = records.where((r) => r.isFavorite).toList();
      final others = records.where((r) => !r.isFavorite).toList();
      trimmed = [...favorites, ...others.take(_maxRecords - favorites.length)]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((r) => r.toJson()).toList()),
    );
  }
}
