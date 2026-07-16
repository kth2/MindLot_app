import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Classical vertical poem layout: characters top-to-bottom, lines
/// right-to-left, like an engraved lot slip.
class PoemDisplay extends StatelessWidget {
  const PoemDisplay({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final charStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.35,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        // Vertical Chinese reads right→left: first line goes rightmost.
        children: [
          for (final line in lines.reversed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final char in line.characters)
                    Text(char, style: charStyle),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
