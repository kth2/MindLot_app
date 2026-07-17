import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/divination_record.dart';
import '../../data/models/lot.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/history_provider.dart';
import '../../providers/providers.dart';

/// 籤記 — history of all divinations, with a favorites tab.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.historyTitle),
          bottom: TabBar(
            tabs: [Tab(text: l10n.tabAll), Tab(text: l10n.favorite)],
            indicatorColor: AppColors.vermilion,
          ),
        ),
        body: ref.watch(historyProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.loadError(e))),
              data: (records) => TabBarView(
                children: [
                  _RecordList(records: records, emptyHint: l10n.emptyHistory),
                  _RecordList(
                    records: records.where((r) => r.isFavorite).toList(),
                    emptyHint: l10n.emptyFavorites,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _RecordList extends ConsumerWidget {
  const _RecordList({
    required this.records,
    required this.emptyHint,
  });

  final List<DivinationRecord> records;
  final String emptyHint;

  static String _sourceLabel(AppLocalizations l10n, DivinationSource s) =>
      switch (s) {
        DivinationSource.photo => l10n.sourcePhoto,
        DivinationSource.draw => l10n.sourceDraw,
        DivinationSource.manual => l10n.sourceManual,
      };

  Future<void> _open(
      BuildContext context, WidgetRef ref, DivinationRecord record) async {
    // Prefer the full local lot; fall back to the stored poem snapshot.
    final lot =
        await ref.read(lotRepositoryProvider).findLot(record.setId, record.lotNumber) ??
            Lot.external(
              setId: record.setId,
              setName: record.setName,
              number: record.lotNumber == 0 ? null : record.lotNumber,
              sexagenary: record.sexagenary,
              poem: record.poemSnapshot,
            );
    if (!context.mounted) return;
    context.push(
      '/lot',
      extra: LotDetailArgs(
        lot: lot,
        setName: record.setName,
        source: record.source.name,
        existingRecordId: record.id,
      ),
    );
  }

  String _formatDate(DateTime t) =>
      '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    if (records.isEmpty) {
      return Center(
        child: Text(emptyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            )),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Dismissible(
          key: ValueKey(r.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) =>
              ref.read(historyProvider.notifier).remove(r.id),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor:
                    AppColors.levelColor(r.level).withValues(alpha: 0.15),
                child: Text(
                  r.level.isNotEmpty ? r.level[0] : '籤',
                  style: TextStyle(
                    color: AppColors.levelColor(r.level),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('${r.setName}・${r.lotLabel}'
                  '${r.level.isNotEmpty ? '（${r.level}）' : ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.question?.isNotEmpty == true)
                    Text(l10n.questionPrefix(r.question!),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    '${_formatDate(r.timestamp)}・${_sourceLabel(l10n, r.source)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  r.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: r.isFavorite ? AppColors.vermilion : null,
                  size: 20,
                ),
                onPressed: () =>
                    ref.read(historyProvider.notifier).toggleFavorite(r.id),
              ),
              onTap: () => _open(context, ref, r),
            ),
          ),
        );
      },
    );
  }
}
