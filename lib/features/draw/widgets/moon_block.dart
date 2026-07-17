import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../jiao_bei.dart';

/// A single crescent moon block (筊杯) drawn with CustomPaint.
///
/// Renders either the [BlockFace.flat] face (平面 — a flat lacquer surface with
/// an incised line) or the [BlockFace.round] face (凸面 — a domed, highlighted
/// surface), so the two states read at a glance.
class MoonBlock extends StatelessWidget {
  const MoonBlock({super.key, required this.face, this.size = 84});

  final BlockFace face;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _MoonBlockPainter(face),
    );
  }
}

class _MoonBlockPainter extends CustomPainter {
  _MoonBlockPainter(this.face);

  final BlockFace face;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Crescent (banana) silhouette: an outer belly curve and an inner curve
    // meeting at two pointed tips.
    final crescent = Path()
      ..moveTo(w * 0.16, h * 0.30)
      ..quadraticBezierTo(w * 0.5, h * 1.02, w * 0.84, h * 0.30)
      ..quadraticBezierTo(w * 0.5, h * 0.52, w * 0.16, h * 0.30)
      ..close();

    // Soft drop shadow so the block sits on the ground.
    canvas.drawPath(
      crescent.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    if (face == BlockFace.round) {
      // 凸面: domed convex surface — radial highlight to read as 3D.
      canvas.drawPath(
        crescent,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.2, -0.3),
            radius: 0.9,
            colors: [
              AppColors.vermilion,
              AppColors.vermilionDeep,
              Color(0xFF5E2016),
            ],
            stops: [0.0, 0.6, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
      // glossy highlight
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.40, h * 0.46),
            width: w * 0.26,
            height: h * 0.12),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    } else {
      // 平面: flat face — even lacquer fill with an incised centre line.
      canvas.drawPath(
        crescent,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFC24A32), AppColors.vermilion],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.26, h * 0.40)
          ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.74, h * 0.40),
        Paint()
          ..color = AppColors.vermilionDeep.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Gold rim on both faces.
    canvas.drawPath(
      crescent,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonBlockPainter oldDelegate) =>
      oldDelegate.face != face;
}
