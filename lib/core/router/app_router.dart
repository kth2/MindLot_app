import 'package:go_router/go_router.dart';

import '../../data/models/lot.dart';
import '../../features/draw/draw_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/lot/lot_detail_screen.dart';
import '../../features/photo/photo_recognition_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Arguments passed to the lot-detail screen via `extra`.
class LotDetailArgs {
  const LotDetailArgs({
    required this.lot,
    required this.setName,
    required this.source,
    this.existingRecordId,
  });

  final Lot lot;
  final String setName;

  /// 'photo' | 'draw' | 'manual' — recorded into history.
  final String source;

  /// When reopening from history, update that record instead of adding one.
  final String? existingRecordId;
}

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/photo',
      builder: (context, state) => const PhotoRecognitionScreen(),
    ),
    GoRoute(path: '/draw', builder: (context, state) => const DrawScreen()),
    GoRoute(
      path: '/lot',
      builder: (context, state) =>
          LotDetailScreen(args: state.extra! as LotDetailArgs),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
