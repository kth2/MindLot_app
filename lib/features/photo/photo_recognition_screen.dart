import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lot.dart';
import '../../data/models/vision_result.dart';
import '../../l10n/ai_error_text.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../draw/widgets/jiao_bei_sheet.dart';
import 'camera_capture_screen.dart';
import 'widgets/manual_input_sheet.dart';

/// 拍照辨籤 — photograph a physical lot; Vision AI identifies the set,
/// number and poem, with graceful fallback to manual input.
class PhotoRecognitionScreen extends ConsumerStatefulWidget {
  const PhotoRecognitionScreen({super.key});

  @override
  ConsumerState<PhotoRecognitionScreen> createState() =>
      _PhotoRecognitionScreenState();
}

/// A vision result resolved against the local lot database.
class _Resolved {
  const _Resolved({required this.lot, required this.setName, this.note});
  final Lot lot;
  final String setName;
  final String? note;
}

class _PhotoRecognitionScreenState
    extends ConsumerState<PhotoRecognitionScreen> {
  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  String _mimeType = 'image/jpeg';
  bool _analyzing = false;
  String? _error;
  VisionResult? _visionResult;
  _Resolved? _resolved;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600, // plenty for OCR, keeps upload small
        imageQuality: 88,
      );
      if (file != null) await _applyFile(file);
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context).photoLoadError(e));
    }
  }

  /// Opens the in-app live viewfinder (framing overlay) to capture a photo.
  Future<void> _openCamera() async {
    try {
      final XFile? file = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
      );
      if (file != null && mounted) await _applyFile(file);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _error = AppLocalizations.of(context).cameraOpenError(e));
      }
    }
  }

  Future<void> _applyFile(XFile file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _mimeType = file.mimeType ?? 'image/jpeg';
      _visionResult = null;
      _resolved = null;
      _error = null;
    });
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _analyzing = true;
      _error = null;
      _visionResult = null;
      _resolved = null;
    });

    try {
      final sets = await ref.read(lotRepositoryProvider).loadSets();
      final result = await ref.read(visionServiceProvider).analyzeLotImage(
            bytes,
            mimeType: _mimeType,
            knownSets: sets,
          );
      final resolved = await _resolve(result, l10n);
      if (!mounted) return;
      setState(() {
        _visionResult = result;
        _resolved = resolved;
        _analyzing = false;
        if (!result.recognized) {
          _error = l10n.photoNotRecognized;
        } else if (resolved == null) {
          _error = l10n.poemMatchedNoSet;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _error = aiErrorText(l10n, e);
      });
    }
  }

  /// Maps the vision output onto the local database, in order of trust:
  /// set+number → set+sexagenary → poem fuzzy match → external (poem only).
  Future<_Resolved?> _resolve(
      VisionResult result, AppLocalizations l10n) async {
    if (!result.recognized) return null;
    final repo = ref.read(lotRepositoryProvider);

    if (result.setId != null) {
      final set = await repo.setById(result.setId!);
      if (set != null && set.hasLocalData) {
        if (result.lotNumber != null) {
          final lot = await repo.findLot(set.id, result.lotNumber!);
          if (lot != null) return _Resolved(lot: lot, setName: set.name);
        }
        if (result.sexagenary != null) {
          final lot = await repo.findBySexagenary(set.id, result.sexagenary!);
          if (lot != null) return _Resolved(lot: lot, setName: set.name);
        }
      }
    }

    // Number missing or set unavailable — try matching the poem itself.
    if (result.poemText != null) {
      final lot = await repo.matchByPoem(result.poemText!);
      if (lot != null) {
        final set = await repo.setById(lot.setId);
        return _Resolved(
          lot: lot,
          setName: set?.name ?? '',
          note: l10n.matchedByPoem,
        );
      }
      // Poem readable but not in our database — interpret it directly.
      if (result.poemLines.length >= 2) {
        final setName = result.setNameGuess ??
            (result.setId != null
                ? (await repo.setById(result.setId!))?.name ?? l10n.unknownSet
                : l10n.unknownSet);
        return _Resolved(
          lot: Lot.external(
            setId: result.setId ?? 'unknown',
            setName: setName,
            number: result.lotNumber,
            sexagenary: result.sexagenary,
            poem: result.poemLines,
          ),
          setName: setName,
          note: l10n.externalPhotoNote,
        );
      }
    }
    return null;
  }

  Future<void> _openManualInput() async {
    final picked = await showManualInputSheet(context, ref);
    if (picked != null && mounted) {
      context.push(
        '/lot',
        extra: LotDetailArgs(
          lot: picked.lot,
          setName: picked.setName,
          source: 'manual',
        ),
      );
    }
  }

  void _openReading(_Resolved resolved) {
    context.push(
      '/lot',
      extra: LotDetailArgs(
        lot: resolved.lot,
        setName: resolved.setName,
        source: 'photo',
      ),
    );
  }

  /// Offer 擲筊 to confirm the recognized lot before reading it. A 陰筊 here
  /// suggests the reading may be off, so it routes to the correction path.
  Future<void> _openJiaoBei(_Resolved resolved) async {
    final outcome = await showJiaoBeiSheet(
      context,
      ref,
      lot: resolved.lot,
      setName: resolved.setName,
      redrawLabel: AppLocalizations.of(context).fixNumber,
    );
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case JiaoOutcome.confirmed:
        _openReading(resolved);
      case JiaoOutcome.redraw:
        _openManualInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ritePhotoTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------- image preview -------
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 56,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(l10n.photoHint,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  height: 1.8,
                                )),
                          ],
                        )
                      : Image.memory(_imageBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),

              // ------- pick / shoot -------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _analyzing ? null : _openCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l10n.takePhoto),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _analyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    (_imageBytes == null || _analyzing) ? null : _analyze,
                icon: _analyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_analyzing ? l10n.analyzing : l10n.startRecognition),
              ),

              // ------- error + manual fallback -------
              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.6)),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _openManualInput,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.manualInput),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ------- recognition result -------
              if (_resolved != null) ...[
                const SizedBox(height: 20),
                _ResultCard(
                  resolved: _resolved!,
                  confidence: _visionResult?.confidence ?? 0,
                  onCast: () => _openJiaoBei(_resolved!),
                  onConfirm: () => _openReading(_resolved!),
                  onCorrect: _openManualInput,
                ),
              ],

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _openManualInput,
                  child: Text(l10n.skipToManual),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows what the AI recognized and asks the user to confirm before
/// proceeding — the user always has the final say.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.resolved,
    required this.confidence,
    required this.onCast,
    required this.onConfirm,
    required this.onCorrect,
  });

  final _Resolved resolved;
  final double confidence;
  final VoidCallback onCast;
  final VoidCallback onConfirm;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lot = resolved.lot;
    final lowConfidence = confidence < 0.6;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.recognitionResult,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(letterSpacing: 2)),
                ),
                Text(l10n.confidence((confidence * 100).round()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: lowConfidence
                          ? AppColors.vermilion
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                    )),
              ],
            ),
            const Divider(height: 24),
            Text('${resolved.setName}・${lot.label}'
                '${lot.level.isNotEmpty ? '（${lot.level}）' : ''}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.vermilion,
                  fontWeight: FontWeight.w600,
                )),
            if (lot.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(l10n.allusionTitle(lot.title),
                  style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(lot.poemText,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.8)),
            if (resolved.note != null) ...[
              const SizedBox(height: 8),
              Text(l10n.noteLine(resolved.note!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
            ],
            if (lowConfidence) ...[
              const SizedBox(height: 8),
              Text(l10n.lowConfidenceNote,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.vermilion)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCorrect,
                    child: Text(l10n.correct),
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
              onPressed: onConfirm,
              child: Text(
                l10n.skipCastRead,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
