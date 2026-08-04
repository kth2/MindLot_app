import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lot.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import '../jiao_bei.dart';
import 'moon_block.dart';

String _jiaoName(AppLocalizations l10n, JiaoResult r) => switch (r) {
      JiaoResult.sacred => l10n.jiaoSacredName,
      JiaoResult.laughing => l10n.jiaoLaughingName,
      JiaoResult.negative => l10n.jiaoNegativeName,
    };

String _jiaoMessage(AppLocalizations l10n, JiaoResult r) => switch (r) {
      JiaoResult.sacred => l10n.jiaoSacredMsg,
      JiaoResult.laughing => l10n.jiaoLaughingMsg,
      JiaoResult.negative => l10n.jiaoNegativeMsg,
    };

/// What the user chose to do at the end of the 擲筊 ritual.
enum JiaoOutcome {
  /// Proceed to read the lot (confirmed by 聖筊, or the user chose to anyway).
  confirmed,

  /// Put the lot back and draw a new one.
  redraw,
}

/// Presents the 擲筊 (moon-block) confirmation ritual for a [lot].
///
/// Returns [JiaoOutcome.confirmed] to open the reading, [JiaoOutcome.redraw]
/// to take the alternative action (draw anew, or correct a photo reading),
/// or null if dismissed. [redrawLabel] names that alternative — it is what
/// the 陰筊 button reads (e.g. 重新求籤 when drawing, 修正籤號 from a photo).
Future<JiaoOutcome?> showJiaoBeiSheet(
  BuildContext context,
  WidgetRef ref, {
  required Lot lot,
  required String setName,
  required String redrawLabel,
}) {
  return showModalBottomSheet<JiaoOutcome>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) =>
        _JiaoBeiSheet(lot: lot, setName: setName, redrawLabel: redrawLabel),
  );
}

class _JiaoBeiSheet extends ConsumerStatefulWidget {
  const _JiaoBeiSheet({
    required this.lot,
    required this.setName,
    required this.redrawLabel,
  });

  final Lot lot;
  final String setName;
  final String redrawLabel;

  @override
  ConsumerState<_JiaoBeiSheet> createState() => _JiaoBeiSheetState();
}

class _JiaoBeiSheetState extends ConsumerState<_JiaoBeiSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _rng = Random();

  JiaoThrow? _throw; // the settled throw once the tumble completes
  JiaoThrow? _pending; // chosen at throw start, revealed when it lands
  bool _casting = false;
  int _sacredStreak = 0; // consecutive 聖筊, for a gentle flourish at three

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() {
            _throw = _pending;
            _casting = false;
            if (_throw!.result == JiaoResult.sacred) {
              _sacredStreak++;
            } else {
              _sacredStreak = 0;
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cast() {
    if (_casting) return;
    setState(() {
      _casting = true;
      _throw = null;
      _pending = JiaoThrow.random(_rng);
    });
    ref.read(soundServiceProvider).playCast();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final result = _throw?.result;
    final confirmed = result == JiaoResult.sacred;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.castConsult,
              style: theme.textTheme.titleLarge?.copyWith(letterSpacing: scriptSpacing(context, 4))),
          const SizedBox(height: 6),
          Text('${l10n.jiaoAsk(widget.setName, widget.lot.label)}\n'
              '${l10n.jiaoAskHint}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.7,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          const SizedBox(height: 24),

          // ------- the two tumbling blocks -------
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnimatedBlock(
                    t: _casting ? _controller.value : 1,
                    face: (_throw ?? _pending)?.first ?? BlockFace.flat,
                    spin: 5.5,
                    phase: 0,
                  ),
                  const SizedBox(width: 28),
                  _AnimatedBlock(
                    t: _casting ? _controller.value : 1,
                    face: (_throw ?? _pending)?.second ?? BlockFace.round,
                    spin: 6.5,
                    phase: 0.12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ------- result message -------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _casting
                ? Text(l10n.jiaoCasting,
                    key: const ValueKey('casting'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(letterSpacing: scriptSpacing(context, 4)))
                : result == null
                    ? Text('　',
                        key: const ValueKey('idle'),
                        style: theme.textTheme.titleMedium)
                    : _ResultLabel(result: result, streak: _sacredStreak),
          ),
          const SizedBox(height: 24),

          // ------- actions -------
          if (confirmed)
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(JiaoOutcome.confirmed),
              icon: const Icon(Icons.auto_stories_outlined),
              label: Text(l10n.jiaoRead),
            )
          else
            FilledButton.icon(
              onPressed: _casting ? null : _cast,
              icon: const Icon(Icons.casino_outlined),
              label: Text(_throw == null ? l10n.cast : l10n.castAgain),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (result == JiaoResult.negative)
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(JiaoOutcome.redraw),
                  child: Text(widget.redrawLabel),
                ),
              if (!confirmed && _throw != null)
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(JiaoOutcome.confirmed),
                  child: Text(
                    l10n.readAnyway,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A block that tumbles (spins + bounces) while [t] < 1, then rests on [face].
class _AnimatedBlock extends StatelessWidget {
  const _AnimatedBlock({
    required this.t,
    required this.face,
    required this.spin,
    required this.phase,
  });

  final double t; // 0..1 throw progress
  final BlockFace face;
  final double spin; // number of turns during the tumble
  final double phase; // stagger so the two blocks land slightly apart

  @override
  Widget build(BuildContext context) {
    final p = (t - phase).clamp(0.0, 1.0) / (1 - phase);
    final settle = Curves.easeOut.transform(p);
    // spin slows to a stop; a tiny wobble as it lands
    final angle = (1 - settle) * spin * 2 * pi +
        sin(p * pi * 3) * 0.12 * (1 - settle);
    // two decaying bounces
    final bounce = (p >= 1) ? 0.0 : -(sin(p * pi * 2).abs()) * 46 * (1 - p);

    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.rotate(angle: angle, child: MoonBlock(face: face)),
    );
  }
}

class _ResultLabel extends StatelessWidget {
  const _ResultLabel({required this.result, required this.streak});

  final JiaoResult result;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = switch (result) {
      JiaoResult.sacred => AppColors.vermilion,
      JiaoResult.laughing => AppColors.gold,
      JiaoResult.negative => AppColors.levelCaution,
    };
    return Column(
      key: ValueKey(result),
      children: [
        Text(_jiaoName(l10n, result),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: scriptSpacing(context, 4),
            )),
        const SizedBox(height: 6),
        Text(_jiaoMessage(l10n, result),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        if (result == JiaoResult.sacred && streak >= 3) ...[
          const SizedBox(height: 6),
          Text(l10n.threeSacred,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.vermilion, letterSpacing: 2)),
        ],
      ],
    );
  }
}
