import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A viewfinder overlay: dims everything outside a centred frame, draws gold
/// corner brackets, and shows guidance text — to help the user line up a
/// 籤枝 or 籤詩紙 squarely and with good light.
class FramingOverlay extends StatelessWidget {
  const FramingOverlay({super.key});

  /// The clear framing rectangle for a given viewport size — portrait, since
  /// lot slips and sticks are taller than they are wide.
  static Rect frameOf(Size size) {
    final w = size.width * 0.78;
    final h = size.height * 0.58;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2 - size.height * 0.03;
    return Rect.fromLTWH(left, top, w, h);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = frameOf(size);
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ScrimPainter(frame)),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: frame.bottom + 20,
                child: Column(
                  children: [
                    Text(
                      '將籤枝或籤詩對準框內',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black54),
                            ],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '正對、光線充足、避免反光',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter(this.frame);

  final Rect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(frame, const Radius.circular(18));

    // Dim everything, then punch a clear hole for the frame.
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, Paint()..color = Colors.black.withValues(alpha: 0.55));
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Thin frame edge.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Gold corner brackets.
    final bracket = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const len = 26.0;
    final r = frame;
    void corner(Offset o, Offset dx, Offset dy) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx + dx.dx * len, o.dy + dx.dy * len)
          ..lineTo(o.dx, o.dy)
          ..lineTo(o.dx + dy.dx * len, o.dy + dy.dy * len),
        bracket,
      );
    }

    corner(r.topLeft, const Offset(1, 0), const Offset(0, 1));
    corner(r.topRight, const Offset(-1, 0), const Offset(0, 1));
    corner(r.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    corner(r.bottomRight, const Offset(-1, 0), const Offset(0, -1));
  }

  @override
  bool shouldRepaint(covariant _ScrimPainter old) => old.frame != frame;
}
