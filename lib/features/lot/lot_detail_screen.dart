import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/divination_record.dart';
import '../../data/models/lot.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/history_provider.dart';
import '../../providers/providers.dart';
import 'widgets/lot_share_sheet.dart';
import 'widgets/poem_display.dart';

/// Lot detail & AI interpretation — poem, classical reading, aspect guidance,
/// and a personalized AI reading for the user's own question.
class LotDetailScreen extends ConsumerStatefulWidget {
  const LotDetailScreen({super.key, required this.args});

  final LotDetailArgs args;

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  final _questionController = TextEditingController();
  String? _selectedCategory;
  String? _interpretation;
  bool _interpreting = false;
  String? _error;
  late String _recordId;

  Lot get _lot => widget.args.lot;

  @override
  void initState() {
    super.initState();
    if (widget.args.existingRecordId != null) {
      _recordId = widget.args.existingRecordId!;
      // Restore the previous question/reading when reopened from history.
      final existing = ref
          .read(historyProvider)
          .valueOrNull
          ?.where((r) => r.id == _recordId)
          .firstOrNull;
      if (existing != null) {
        _questionController.text = existing.question ?? '';
        _selectedCategory = existing.category;
        _interpretation = existing.interpretation;
      }
    } else {
      _recordId = const Uuid().v4();
      // Record the divination as soon as the lot is opened.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(historyProvider.notifier).add(DivinationRecord(
              id: _recordId,
              timestamp: DateTime.now(),
              source: DivinationSource.values.firstWhere(
                (s) => s.name == widget.args.source,
                orElse: () => DivinationSource.manual,
              ),
              setId: _lot.setId,
              setName: widget.args.setName,
              lotNumber: _lot.number,
              lotLabel: _lot.label,
              sexagenary: _lot.sexagenary,
              level: _lot.level,
              poemSnapshot: _lot.poem,
            ));
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _interpret() async {
    setState(() {
      _interpreting = true;
      _error = null;
    });
    try {
      final text = await ref.read(interpretationServiceProvider).interpret(
            lot: _lot,
            setName: widget.args.setName,
            category: _selectedCategory,
            question: _questionController.text,
          );
      if (!mounted) return;
      setState(() {
        _interpretation = text;
        _interpreting = false;
      });
      // Persist the reading onto the record.
      final record = ref
          .read(historyProvider)
          .valueOrNull
          ?.where((r) => r.id == _recordId)
          .firstOrNull;
      if (record != null) {
        ref.read(historyProvider.notifier).update(record.copyWith(
              question: _questionController.text.trim(),
              category: _selectedCategory,
              interpretation: text,
            ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _interpreting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isFavorite = ref.watch(historyProvider).valueOrNull
            ?.where((r) => r.id == _recordId)
            .firstOrNull
            ?.isFavorite ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.setName),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareThisLot,
            onPressed: () => showLotShareSheet(
              context,
              lot: _lot,
              setName: widget.args.setName,
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.vermilion : null,
            ),
            tooltip: l10n.favorite,
            onPressed: () =>
                ref.read(historyProvider.notifier).toggleFavorite(_recordId),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------- header -------
              Center(
                child: Column(
                  children: [
                    Text(_lot.label,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.vermilion,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_lot.level.isNotEmpty)
                          _Badge(
                            text: _lot.level,
                            color: AppColors.levelColor(_lot.level),
                          ),
                        if (_lot.title.isNotEmpty)
                          _Badge(
                            text: _lot.title,
                            color: AppColors.gold,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ------- poem (vertical classical layout) -------
              PoemDisplay(lines: _lot.poem),

              // 五行方位 (六十甲子系統)
              if (_lot.wuxing.isNotEmpty) ...[
                const SizedBox(height: 12),
                Center(
                  child: _Badge(text: _lot.wuxing, color: AppColors.gold),
                ),
              ],

              if (_lot.isExternal) ...[
                const SizedBox(height: 10),
                Text(l10n.externalAiNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
              ],

              // ------- classical readings -------
              if (_lot.poemTranslation.isNotEmpty)
                _Section(
                    title: l10n.sectionPlain,
                    child: Text(_lot.poemTranslation)),
              if (_lot.allusion.isNotEmpty)
                _Section(title: l10n.sectionAllusion, child: Text(_lot.allusion)),
              if (_lot.meaning.isNotEmpty)
                _Section(
                  // 六十甲子系統 stores per-topic 聖意 rather than a 解曰 essay.
                  title: _lot.sexagenary != null
                      ? l10n.sectionShengyi
                      : l10n.sectionJieyue,
                  child: Text(_lot.meaning),
                ),

              // ------- aspects -------
              if (_lot.aspects.isNotEmpty)
                _Section(
                  title: l10n.sectionAspects,
                  child: Column(
                    children: kAspectNames.keys
                        .where((k) => _lot.aspects.containsKey(k))
                        .map((k) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Badge(
                                      text: l10n.aspectName(k),
                                      color: AppColors.gold),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(_lot.aspects[k]!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(height: 1.6)),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

              // ------- AI personalized interpretation -------
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(l10n.askReadingTitle,
                  style:
                      theme.textTheme.titleMedium?.copyWith(letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(l10n.askReadingSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                // Label is localized; the stored category stays Chinese so the
                // (Chinese) interpretation prompt reads naturally.
                children: kAspectNames.entries
                    .map((e) => ChoiceChip(
                          label: Text(l10n.aspectName(e.key)),
                          selected: _selectedCategory == e.value,
                          onSelected: (sel) => setState(
                              () => _selectedCategory = sel ? e.value : null),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _questionController,
                maxLines: 3,
                minLines: 2,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: l10n.questionHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _interpreting ? null : _interpret,
                icon: _interpreting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_interpreting ? l10n.interpreting : l10n.askAi),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.vermilion)),
              ],

              if (_interpretation != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.temple_buddhist_outlined,
                                color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.interpreterVoice,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(letterSpacing: 2)),
                          ],
                        ),
                        const Divider(height: 24),
                        SelectableText(_interpretation!,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.9)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    l10n.readingDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.vermilion,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            child: child,
          ),
        ],
      ),
    );
  }
}
