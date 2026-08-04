import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lot.dart';
import '../../../data/models/lot_set.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

class ManualPick {
  const ManualPick({required this.lot, required this.setName});
  final Lot lot;
  final String setName;
}

/// Manual fallback: choose a lot set and enter the number by hand.
Future<ManualPick?> showManualInputSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<ManualPick>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _ManualInputSheet(),
  );
}

class _ManualInputSheet extends ConsumerStatefulWidget {
  const _ManualInputSheet();

  @override
  ConsumerState<_ManualInputSheet> createState() => _ManualInputSheetState();
}

class _ManualInputSheetState extends ConsumerState<_ManualInputSheet> {
  LotSet? _selectedSet;
  final _numberController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final set = _selectedSet;
    final number = int.tryParse(_numberController.text.trim());
    if (set == null) {
      setState(() => _error = l10n.selectSetFirst);
      return;
    }
    if (number == null || number < 1 || number > set.totalLots) {
      setState(() => _error = l10n.numberRangeError(set.totalLots));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final lot = await ref.read(lotRepositoryProvider).findLot(set.id, number);
    if (!mounted) return;
    if (lot == null) {
      setState(() {
        _loading = false;
        _error = l10n.lotNotYetAdded(number);
      });
      return;
    }
    Navigator.of(context).pop(ManualPick(lot: lot, setName: set.name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final setsAsync = ref.watch(lotSetsWithDataProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.manualInput,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(letterSpacing: scriptSpacing(context, 3))),
          const SizedBox(height: 20),
          setsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.setLoadError(e)),
            data: (sets) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sets
                  .map((s) => ChoiceChip(
                        label: Text(s.name),
                        selected: _selectedSet?.id == s.id,
                        selectedColor:
                            AppColors.vermilion.withValues(alpha: 0.15),
                        onSelected: (_) => setState(() => _selectedSet = s),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.lotNumberLabel,
              hintText: _selectedSet == null
                  ? l10n.selectSetFirst
                  : l10n.numberRangeHint(_selectedSet!.totalLots),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.vermilion)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _confirm,
            child: Text(_loading ? l10n.querying : l10n.viewThisLot),
          ),
        ],
      ),
    );
  }
}
