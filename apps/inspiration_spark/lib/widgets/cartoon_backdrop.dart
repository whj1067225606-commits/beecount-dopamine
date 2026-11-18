import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CartoonBackdrop extends StatelessWidget {
  const CartoonBackdrop({
    super.key,
    required this.child,
    this.variant = BackdropVariant.home,
  });

  final Widget child;
  final BackdropVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      BackdropVariant.home => const [
          Color(0xFFFFF3E8),
          Color(0xFFE8F7FF),
          Color(0xFFFFF0F6),
        ],
      BackdropVariant.inspiration => const [
          SparkColors.blueSky,
          SparkColors.blueSoft,
          Color(0xFF9AD8FF),
        ],
      BackdropVariant.notes => const [
          SparkColors.pinkSky,
          SparkColors.pinkSoft,
          Color(0xFFFFB5D0),
        ],
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BlobPainter(variant: variant),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

enum BackdropVariant { home, inspiration, notes }

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.variant});

  final BackdropVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rnd = math.Random(variant.index + 7);

    for (var i = 0; i < 8; i++) {
      final cx = rnd.nextDouble() * size.width;
      final cy = rnd.nextDouble() * size.height;
      final r = 28 + rnd.nextDouble() * 70;
      paint.color = switch (variant) {
        BackdropVariant.home => (i.isEven
                ? SparkColors.blueMid
                : SparkColors.pinkMid)
            .withValues(alpha: 0.10),
        BackdropVariant.inspiration =>
          Colors.white.withValues(alpha: 0.28),
        BackdropVariant.notes => Colors.white.withValues(alpha: 0.28),
      };
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Soft cloud-ish ovals near top.
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.12),
        width: 120,
        height: 48,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.18),
        width: 140,
        height: 56,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
