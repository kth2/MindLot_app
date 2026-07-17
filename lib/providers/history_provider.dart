import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/divination_record.dart';
import 'providers.dart';

/// History & favorites, newest first, persisted through [HistoryRepository].
class HistoryNotifier extends AsyncNotifier<List<DivinationRecord>> {
  @override
  Future<List<DivinationRecord>> build() =>
      ref.read(historyRepositoryProvider).load();

  Future<void> add(DivinationRecord record) async {
    final current = state.valueOrNull ?? const <DivinationRecord>[];
    final updated = [record, ...current];
    state = AsyncData(updated);
    await ref.read(historyRepositoryProvider).save(updated);
  }

  // NB: not named `update` — that collides with AsyncNotifier.update.
  Future<void> updateRecord(DivinationRecord record) async {
    final current = state.valueOrNull ?? const <DivinationRecord>[];
    final updated =
        current.map((r) => r.id == record.id ? record : r).toList();
    state = AsyncData(updated);
    await ref.read(historyRepositoryProvider).save(updated);
  }

  Future<void> toggleFavorite(String id) async {
    final current = state.valueOrNull ?? const <DivinationRecord>[];
    final updated = current
        .map((r) => r.id == id ? r.copyWith(isFavorite: !r.isFavorite) : r)
        .toList();
    state = AsyncData(updated);
    await ref.read(historyRepositoryProvider).save(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? const <DivinationRecord>[];
    final updated = current.where((r) => r.id != id).toList();
    state = AsyncData(updated);
    await ref.read(historyRepositoryProvider).save(updated);
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<DivinationRecord>>(
        HistoryNotifier.new);

final favoritesProvider = Provider<List<DivinationRecord>>((ref) =>
    (ref.watch(historyProvider).valueOrNull ?? const [])
        .where((r) => r.isFavorite)
        .toList());
