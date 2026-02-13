import 'package:flutter/material.dart';
import '../models/sweep_simulator_model.dart';
import 'dart:math' as math;

/// CustomPainter for rendering sweep simulator visualization (multi-angle beam plot)

class SweepSimulatorPainter extends CustomPainter {
  final SweepSimulatorInputs inputs;
  final SweepSimulatorOutputs outputs;
  final SweepSimulatorGeometry geometry;

  static const double padding = 40.0;

  SweepSimulatorPainter({
    required this.inputs,
    required this.outputs,
    required this.geometry,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!outputs.validInputs || geometry.rays.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final worldWidth = geometry.worldWidth;
    final worldHeight = geometry.worldHeight;

    if (worldWidth <= 0 || worldHeight <= 0) {
      _drawPlaceholder(canvas, size);
      return;
    }

    // Calculate scale
    final availableWidth = size.width - 2 * padding;
    final availableHeight = size.height - 2 * padding;

    final scaleX = availableWidth / worldWidth;
    final scaleY = availableHeight / worldHeight;
    final scale = math.min(scaleX, scaleY) * inputs.zoom;

    // Helper function to convert world to screen coordinates
    Offset worldToScreen(double x, double y) {
      return Offset(
        padding + x * scale,
        padding + y * scale,
      );
    }

    // Draw plate rectangle
    _drawPlate(canvas, worldToScreen, worldWidth, worldHeight);

    // Draw all rays
    final highlightIndex = inputs.highlightAngleIndex;
    
    for (int i = 0; i < geometry.rays.length; i++) {
      final isHighlighted = (highlightIndex != null && i == highlightIndex);
      _drawBeamRay(canvas, worldToScreen, geometry.rays[i], isHighlighted);
    }

    // Draw ray count label
    _drawRayCountLabel(canvas, size);
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(padding, padding, size.width - 2 * padding, size.height - 2 * padding),
      paint,
    );

    // Draw message
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Enter valid inputs to visualize sweep',
        style: TextStyle(
          color: Color(0xFF7F8A96),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawPlate(Canvas canvas, Offset Function(double, double) worldToScreen,
      double worldWidth, double worldHeight) {
    final paint = Paint()
      ..color = const Color(0xFF2A313B)
      ..style = PaintingStyle.fill;

    final topLeft = worldToScreen(0, 0);
    final bottomRight = worldToScreen(worldWidth, worldHeight);

    canvas.drawRect(
      Rect.fromPoints(topLeft, bottomRight),
      paint,
    );

    // Draw plate outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromPoints(topLeft, bottomRight),
      outlinePaint,
    );
  }

  void _drawBeamRay(
    Canvas canvas,
    Offset Function(double, double) worldToScreen,
    BeamRay ray,
    bool isHighlighted,
  ) {
    // Use different styling for highlighted vs non-highlighted rays
    final paint = Paint()
      ..color = isHighlighted
          ? const Color(0xFF6C5BFF) // Bright accent color
          : const Color(0xFF6C5BFF).withOpacity(0.15) // Low opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 3.0 : 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < ray.path.length; i++) {
      final point = ray.path[i];
      final screenPoint = worldToScreen(point.x, point.y);

      if (i == 0) {
        path.moveTo(screenPoint.dx, screenPoint.dy);
      } else {
        path.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points at vertices only for highlighted ray
    if (isHighlighted) {
      final pointPaint = Paint()
        ..color = const Color(0xFF6C5BFF)
        ..style = PaintingStyle.fill;

      for (final point in ray.path) {
        final screenPoint = worldToScreen(point.x, point.y);
        canvas.drawCircle(screenPoint, 4, pointPaint);
      }
    }
  }

  void _drawRayCountLabel(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${outputs.raysCount} rays',
        style: const TextStyle(
          color: Color(0xFFAEBBC8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width - textPainter.width - 16,
        16,
      ),
    );
  }

  @override
  bool shouldRepaint(SweepSimulatorPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}
