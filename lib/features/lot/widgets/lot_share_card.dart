import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lot.dart';
import '../../../l10n/app_localizations.dart';
import 'poem_display.dart';

/// A self-contained, printable lot card rendered to PNG for sharing.
///
/// Always laid out at a fixed [width] and forced to the light "paper" theme
/// so the exported image looks the same no matter the app's current theme.
class LotShareCard extends StatelessWidget {
  const LotShareCard({
    super.key,
    required this.lot,
    required this.setName,
    this.width = 360,
  });

  final Lot lot;
  final String setName;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context);
          return Container(
            width: width,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- header: brand + seal ----
                Row(
                  children: [
                    Text(l10n.appName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 2,
                        )),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.vermilion,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text('籤',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ---- set + lot ----
                Text(setName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkSoft,
                      letterSpacing: scriptSpacing(context, 3),
                    )),
                const SizedBox(height: 4),
                Text(lot.label,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.vermilion,
                      fontWeight: FontWeight.w700,
                      letterSpacing: scriptSpacing(context, 4),
                    )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (lot.level.isNotEmpty)
                      _tag(lot.level, AppColors.levelColor(lot.level)),
                    if (lot.title.isNotEmpty) _tag(lot.title, AppColors.gold),
                    if (lot.wuxing.isNotEmpty) _tag(lot.wuxing, AppColors.gold),
                  ],
                ),
                const SizedBox(height: 18),

                // ---- poem (vertical classical layout) ----
                PoemDisplay(lines: lot.poem),

                if (lot.keywords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: lot.keywords
                        .take(4)
                        .map((k) => Text('#$k',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                            )))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 18),
                Divider(color: AppColors.gold.withValues(alpha: 0.35)),
                const SizedBox(height: 8),
                Text(l10n.appFooter,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSoft,
                      letterSpacing: 2,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
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
