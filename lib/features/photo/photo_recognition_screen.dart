import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lot.dart';
import '../../data/models/vision_result.dart';
import '../../providers/providers.dart';
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
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _mimeType = file.mimeType ?? 'image/jpeg';
        _visionResult = null;
        _resolved = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = '無法取得照片：$e');
    }
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
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
      final resolved = await _resolve(result);
      if (!mounted) return;
      setState(() {
        _visionResult = result;
        _resolved = resolved;
        _analyzing = false;
        if (!result.recognized) {
          _error = '照片中未能辨識出籤枝或籤詩，請重拍或改用手動輸入。';
        } else if (resolved == null) {
          _error = '辨識到籤詩但無法對應籤庫，請確認或手動輸入。';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _error = e.toString();
      });
    }
  }

  /// Maps the vision output onto the local database, in order of trust:
  /// set+number → set+sexagenary → poem fuzzy match → external (poem only).
  Future<_Resolved?> _resolve(VisionResult result) async {
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
          note: '已由籤詩內容比對出此籤',
        );
      }
      // Poem readable but not in our database — interpret it directly.
      if (result.poemLines.length >= 2) {
        final setName = result.setNameGuess ??
            (result.setId != null
                ? (await repo.setById(result.setId!))?.name ?? '未知籤種'
                : '未知籤種');
        return _Resolved(
          lot: Lot.external(
            setId: result.setId ?? 'unknown',
            setName: setName,
            number: result.lotNumber,
            sexagenary: result.sexagenary,
            poem: result.poemLines,
          ),
          setName: setName,
          note: '此籤種尚無本地籤庫，將以照片擷取的籤詩進行 AI 解籤',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('拍照辨籤')),
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
                            Text('請拍攝籤枝或籤詩紙\n盡量正對、光線充足、避免反光',
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
                      onPressed:
                          _analyzing ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('拍照'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _analyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('相簿'),
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
                label: Text(_analyzing ? 'AI 辨識中⋯' : '開始辨識'),
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
                          label: const Text('手動輸入籤號'),
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
                  onConfirm: () => context.push(
                    '/lot',
                    extra: LotDetailArgs(
                      lot: _resolved!.lot,
                      setName: _resolved!.setName,
                      source: 'photo',
                    ),
                  ),
                  onCorrect: _openManualInput,
                ),
              ],

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _openManualInput,
                  child: const Text('略過拍照，直接手動輸入 ›'),
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
    required this.onConfirm,
    required this.onCorrect,
  });

  final _Resolved resolved;
  final double confidence;
  final VoidCallback onConfirm;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  child: Text('辨識結果',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(letterSpacing: 2)),
                ),
                Text('信心 ${(confidence * 100).round()}%',
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
              Text('籤題：${lot.title}', style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(lot.poemText,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.8)),
            if (resolved.note != null) ...[
              const SizedBox(height: 8),
              Text('※ ${resolved.note}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
            ],
            if (lowConfidence) ...[
              const SizedBox(height: 8),
              Text('※ 辨識信心較低，請核對籤號是否正確',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.vermilion)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCorrect,
                    child: const Text('不對，修正'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: const Text('正確，解籤'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
