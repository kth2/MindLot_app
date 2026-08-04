import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/lot.dart';
import '../../../l10n/app_localizations.dart';
import 'lot_share_card.dart';

/// Shows a preview of the shareable lot card and lets the user export it as a
/// PNG via the system share sheet.
Future<void> showLotShareSheet(
  BuildContext context, {
  required Lot lot,
  required String setName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) => _LotShareSheet(lot: lot, setName: setName),
  );
}

class _LotShareSheet extends StatefulWidget {
  const _LotShareSheet({required this.lot, required this.setName});

  final Lot lot;
  final String setName;

  @override
  State<_LotShareSheet> createState() => _LotShareSheetState();
}

class _LotShareSheetState extends State<_LotShareSheet> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      // 3x for a crisp ~1080px-wide image regardless of on-screen scaling.
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('empty image');
      final bytes = data.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final safeLabel = widget.lot.label.replaceAll(RegExp(r'\s+'), '');
      final file = await File('${dir.path}/mindlot_$safeLabel.png')
          .writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: '${widget.setName}・${widget.lot.label} — ${l10n.appName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shareFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.shareThisLot,
              style: theme.textTheme.titleLarge?.copyWith(letterSpacing: scriptSpacing(context, 4))),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Center(
                // RepaintBoundary captures at the card's native width; the
                // FittedBox only scales the on-screen preview to fit.
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: LotShareCard(
                      lot: widget.lot,
                      setName: widget.setName,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _sharing ? null : _share,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.ios_share),
            label: Text(_sharing ? l10n.preparing : l10n.shareImage),
          ),
        ],
      ),
    );
  }
}
