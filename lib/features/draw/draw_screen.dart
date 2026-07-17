import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lot.dart';
import '../../data/models/lot_set.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import 'widgets/jiao_bei_sheet.dart';
import 'widgets/lot_cylinder.dart';

/// 線上求籤 — simulate shaking a divination cylinder with animation and
/// sound, then reveal a randomly drawn lot.
class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key});

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  LotSet? _selectedSet;
  Lot? _drawnLot;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onShakeComplete();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Damped oscillation: vigorous at first, settling near the end.
  double _tiltAt(double t) =>
      math.sin(t * math.pi * 10) * 0.14 * (1 - t * 0.75);

  double _shakeAt(double t) => (1 - t * 0.6).clamp(0.0, 1.0);

  Future<void> _startShake() async {
    if (_shaking || _selectedSet == null) return;
    setState(() {
      _shaking = true;
      _drawnLot = null;
    });
    ref.read(soundServiceProvider).playShake();
    _controller.forward(from: 0);
  }

  Future<void> _onShakeComplete() async {
    final lot =
        await ref.read(lotRepositoryProvider).randomLot(_selectedSet!.id);
    if (!mounted) return;
    setState(() {
      _shaking = false;
      _drawnLot = lot;
    });
  }

  void _openLot() {
    context.push(
      '/lot',
      extra: LotDetailArgs(
        lot: _drawnLot!,
        setName: _selectedSet?.name ?? '',
        source: 'draw',
      ),
    );
  }

  /// Invite the user to 擲筊 to confirm the drawn lot before reading it.
  Future<void> _openJiaoBei() async {
    final outcome = await showJiaoBeiSheet(
      context,
      ref,
      lot: _drawnLot!,
      setName: _selectedSet?.name ?? '',
      redrawLabel: AppLocalizations.of(context).drawAnew,
    );
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case JiaoOutcome.confirmed:
        _openLot();
      case JiaoOutcome.redraw:
        _startShake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final setsAsync = ref.watch(lotSetsWithDataProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.riteDrawTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.drawInstruction,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    letterSpacing: 2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  )),
              const SizedBox(height: 16),

              // ------- choose lot set -------
              setsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(l10n.setLoadError(e)),
                data: (sets) {
                  _selectedSet ??= sets.isNotEmpty ? sets.first : null;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: sets
                        .map((s) => ChoiceChip(
                              label: Text(s.name),
                              selected: _selectedSet?.id == s.id,
                              onSelected: _shaking
                                  ? null
                                  : (_) =>
                                      setState(() => _selectedSet = s),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ------- the cylinder -------
              GestureDetector(
                onTap: _startShake,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    return Center(
                      child: LotCylinder(
                        shake: _shaking ? _shakeAt(t) : 0,
                        tilt: _shaking ? _tiltAt(t) : 0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              if (_drawnLot == null)
                FilledButton.icon(
                  onPressed:
                      (_shaking || _selectedSet == null) ? null : _startShake,
                  icon: const Icon(Icons.vibration),
                  label: Text(_shaking ? l10n.shaking : l10n.shake),
                )
              else
                _RevealCard(
                  lot: _drawnLot!,
                  setName: _selectedSet?.name ?? '',
                  onCast: _openJiaoBei,
                  onOpen: _openLot,
                  onRedraw: _startShake,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.lot,
    required this.setName,
    required this.onCast,
    required this.onOpen,
    required this.onRedraw,
  });

  final Lot lot;
  final String setName;
  final VoidCallback onCast;
  final VoidCallback onOpen;
  final VoidCallback onRedraw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(
        scale: 0.9 + 0.1 * v,
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(l10n.youDrew,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    letterSpacing: 4,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
              const SizedBox(height: 8),
              Text('$setName・${lot.label}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.vermilion,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              if (lot.level.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.levelColor(lot.level)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(lot.level,
                      style: TextStyle(
                        color: AppColors.levelColor(lot.level),
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRedraw,
                      child: Text(l10n.shakeAgain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onCast,
                      icon: const Icon(Icons.casino_outlined, size: 18),
                      label: Text(l10n.castConsult),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onOpen,
                child: Text(
                  l10n.skipCastRead,
                  style: TextStyle(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
