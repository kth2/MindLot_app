import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/history_provider.dart';

/// Temple-style landing screen: two primary rites (photo / draw) plus quick
/// access to history and settings.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(historyProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                        color: AppColors.vermilion,
                      )),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: l10n.settings,
                  ),
                ],
              ),
              Text(l10n.homeMotto,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 28),

              // 主祀二禮：拍照辨籤 / 線上求籤
              _RiteCard(
                icon: Icons.photo_camera_outlined,
                title: l10n.ritePhotoTitle,
                subtitle: l10n.ritePhotoSubtitle,
                accent: AppColors.vermilion,
                onTap: () => context.push('/photo'),
              ),
              const SizedBox(height: 16),
              _RiteCard(
                icon: Icons.auto_awesome_outlined,
                title: l10n.riteDrawTitle,
                subtitle: l10n.riteDrawSubtitle,
                accent: AppColors.gold,
                onTap: () => context.push('/draw'),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.recentRecords,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(letterSpacing: 2)),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n.emptyRecent,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              else
                ...recent.take(3).map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.levelColor(r.level)
                              .withValues(alpha: 0.15),
                          child: Text(
                            r.level.isNotEmpty ? r.level[0] : '籤',
                            style: TextStyle(
                              color: AppColors.levelColor(r.level),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('${r.setName}・${r.lotLabel}'),
                        subtitle: Text(
                          r.question?.isNotEmpty == true
                              ? r.question!
                              : r.poemSnapshot.join('，'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: r.isFavorite
                            ? const Icon(Icons.favorite,
                                color: AppColors.vermilion, size: 18)
                            : null,
                        onTap: () => context.push('/history'),
                      ),
                    )),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n.appFooter,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 2,
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

class _RiteCard extends StatelessWidget {
  const _RiteCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, size: 32, color: accent),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        )),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          height: 1.6,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
