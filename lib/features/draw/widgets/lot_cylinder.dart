import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A stylized divination cylinder (籤筒) drawn with CustomPaint.
///
/// [shake] ∈ 0..1 drives the jitter intensity; [tilt] is the current
/// rotation in radians applied by the parent animation.
class LotCylinder extends StatelessWidget {
  const LotCylinder({super.key, required this.shake, required this.tilt});

  final double shake;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      alignment: Alignment.bottomCenter,
      child: CustomPaint(
        size: const Size(180, 240),
        painter: _CylinderPainter(shake: shake),
      ),
    );
  }
}

class _CylinderPainter extends CustomPainter {
  _CylinderPainter({required this.shake});

  final double shake;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rand = math.Random(7); // fixed seed → stable stick layout

    // --- sticks (behind the cup rim) ---
    final stickPaint = Paint()..color = const Color(0xFFD9B98C);
    final tipPaint = Paint()..color = AppColors.vermilionDeep;
    const stickCount = 9;
    for (var i = 0; i < stickCount; i++) {
      final baseX = w * (0.28 + 0.44 * i / (stickCount - 1));
      final jitterX = (rand.nextDouble() - 0.5) * 14 * shake;
      final jitterY = rand.nextDouble() * 16 * shake;
      final stickH = h * (0.32 + rand.nextDouble() * 0.14) + jitterY;
      final angle = (rand.nextDouble() - 0.5) * 0.22 +
          (rand.nextDouble() - 0.5) * 0.25 * shake;

      canvas.save();
      canvas.translate(baseX + jitterX, h * 0.52);
      canvas.rotate(angle);
      final stickRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(0, -stickH / 2), width: 7, height: stickH),
        const Radius.circular(3.5),
      );
      canvas.drawRRect(stickRect, stickPaint);
      // red tip on each stick head
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, -stickH + 7), width: 7, height: 14),
          const Radius.circular(3.5),
        ),
        tipPaint,
      );
      canvas.restore();
    }

    // --- cup body (tapered, lacquer red with gold bands) ---
    final cup = Path()
      ..moveTo(w * 0.18, h * 0.5)
      ..lineTo(w * 0.26, h * 0.96)
      ..quadraticBezierTo(w * 0.5, h * 1.02, w * 0.74, h * 0.96)
      ..lineTo(w * 0.82, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.56, w * 0.18, h * 0.5)
      ..close();
    canvas.drawPath(
      cup,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.vermilion, AppColors.vermilionDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5)),
    );

    // rim ellipse
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.52), width: w * 0.64, height: h * 0.1),
      Paint()..color = AppColors.vermilionDeep,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.52), width: w * 0.56, height: h * 0.07),
      Paint()..color = const Color(0xFF4A251C),
    );

    // gold bands
    final bandPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.21, h * 0.66)
        ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.79, h * 0.66),
      bandPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.25, h * 0.88)
        ..quadraticBezierTo(w * 0.5, h * 0.94, w * 0.75, h * 0.88),
      bandPaint,
    );

    // 「籤」 character medallion
    final medallionCenter = Offset(w * 0.5, h * 0.78);
    canvas.drawCircle(
        medallionCenter, 20, Paint()..color = AppColors.goldSoft);
    final tp = TextPainter(
      text: const TextSpan(
        text: '籤',
        style: TextStyle(
          color: Color(0xFF4A251C),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, medallionCenter - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CylinderPainter oldDelegate) =>
      oldDelegate.shake != shake;
}
