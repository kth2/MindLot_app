import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/lot.dart';
import '../models/lot_set.dart';

/// Loads the lot-set registry and per-set lot databases from bundled JSON.
///
/// All data lives in `assets/data/`; adding a new lot system is just a new
/// JSON file plus a registry entry — no code changes.
class LotRepository {
  LotRepository();

  List<LotSet>? _sets;
  final Map<String, List<Lot>> _lotCache = {};
  final _random = Random.secure();

  Future<List<LotSet>> loadSets() async {
    if (_sets != null) return _sets!;
    final raw = await rootBundle.loadString('assets/data/lot_sets.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _sets = (json['sets'] as List<dynamic>)
        .map((e) => LotSet.fromJson(e as Map<String, dynamic>))
        .toList();
    return _sets!;
  }

  Future<LotSet?> setById(String id) async {
    final sets = await loadSets();
    for (final s in sets) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Sets that have a bundled lot database (usable for drawing/manual input).
  Future<List<LotSet>> setsWithData() async =>
      (await loadSets()).where((s) => s.hasLocalData).toList();

  Future<List<Lot>> loadLots(String setId) async {
    if (_lotCache.containsKey(setId)) return _lotCache[setId]!;
    final set = await setById(setId);
    if (set == null || set.dataFile == null) return const [];
    final raw = await rootBundle.loadString(set.dataFile!);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lots = (json['lots'] as List<dynamic>)
        .map((e) => Lot.fromJson(e as Map<String, dynamic>, setId: setId))
        .toList();
    _lotCache[setId] = lots;
    return lots;
  }

  Future<Lot?> findLot(String setId, int number) async {
    final lots = await loadLots(setId);
    for (final lot in lots) {
      if (lot.number == number) return lot;
    }
    return null;
  }

  Future<Lot?> findBySexagenary(String setId, String sexagenary) async {
    final lots = await loadLots(setId);
    for (final lot in lots) {
      if (lot.sexagenary == sexagenary) return lot;
    }
    return null;
  }

  /// Draws a random lot from the set's currently available data.
  Future<Lot?> randomLot(String setId) async {
    final lots = await loadLots(setId);
    if (lots.isEmpty) return null;
    return lots[_random.nextInt(lots.length)];
  }

  /// Fuzzy-matches OCR'd poem text against the local database — a safety net
  /// when Vision AI reads the poem but misses (or misreads) the lot number.
  ///
  /// Returns the best match when its character-overlap score ≥ [threshold].
  Future<Lot?> matchByPoem(String poemText, {double threshold = 0.6}) async {
    final target = _cjkOnly(poemText);
    if (target.length < 8) return null;
    final targetChars = target.split('').toSet();

    Lot? best;
    var bestScore = 0.0;
    for (final set in await setsWithData()) {
      for (final lot in await loadLots(set.id)) {
        final candidate = _cjkOnly(lot.poem.join());
        if (candidate.isEmpty) continue;
        final candidateChars = candidate.split('').toSet();
        final overlap = targetChars.intersection(candidateChars).length;
        final score = overlap / max(targetChars.length, candidateChars.length);
        if (score > bestScore) {
          bestScore = score;
          best = lot;
        }
      }
    }
    return bestScore >= threshold ? best : null;
  }

  static String _cjkOnly(String s) =>
      s.replaceAll(RegExp(r'[^一-鿿]'), '');
}
