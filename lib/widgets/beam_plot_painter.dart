import 'package:flutter/material.dart';
import '../models/beam_plot_model.dart';
import 'dart:math' as math;

/// CustomPainter for rendering beam plot visualization

class BeamPlotPainter extends CustomPainter {
  final BeamPlotInputs inputs;
  final BeamPlotOutputs outputs;
  final BeamPlotGeometry geometry;

  static const double padding = 40.0;

  BeamPlotPainter({
    required this.inputs,
    required this.outputs,
    required this.geometry,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!outputs.validInputs || geometry.beamPath.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    // Calculate world bounds
    final worldWidth = math.max(inputs.legs * outputs.halfSkip, 1.0);
    final worldHeight = inputs.thickness;

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

    // Draw divergence overlay (first, so it's behind)
    if (inputs.showDivergence &&
        geometry.divergencePolygonLeft != null &&
        geometry.divergencePolygonRight != null) {
      _drawDivergence(canvas, worldToScreen);
    }

    // Draw near field overlay
    if (inputs.showNearField && geometry.nearFieldEnd != null) {
      _drawNearField(canvas, worldToScreen);
    }

    // Draw beam path
    _drawBeamPath(canvas, worldToScreen);

    // Draw cursor
    if (inputs.showCursor && geometry.cursorPoint != null) {
      _drawCursor(canvas, worldToScreen);
    }
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
        text: 'Enter valid inputs to visualize beam plot',
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

  void _drawBeamPath(Canvas canvas, Offset Function(double, double) worldToScreen) {
    final paint = Paint()
      ..color = const Color(0xFF6C5BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < geometry.beamPath.length; i++) {
      final point = geometry.beamPath[i];
      final screenPoint = worldToScreen(point.x, point.y);

      if (i == 0) {
        path.moveTo(screenPoint.dx, screenPoint.dy);
      } else {
        path.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points at beam path vertices
    final pointPaint = Paint()
      ..color = const Color(0xFF6C5BFF)
      ..style = PaintingStyle.fill;

    for (final point in geometry.beamPath) {
      final screenPoint = worldToScreen(point.x, point.y);
      canvas.drawCircle(screenPoint, 4, pointPaint);
    }
  }

  void _drawNearField(Canvas canvas, Offset Function(double, double) worldToScreen) {
    if (geometry.nearFieldEnd == null) return;

    final paint = Paint()
      ..color = const Color(0xFF00E5A8).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final start = worldToScreen(0, 0);
    final end = worldToScreen(geometry.nearFieldEnd!.x, geometry.nearFieldEnd!.y);

    canvas.drawLine(start, end, paint);
  }

  void _drawDivergence(Canvas canvas, Offset Function(double, double) worldToScreen) {
    if (geometry.divergencePolygonLeft == null ||
        geometry.divergencePolygonRight == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFF8B800).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw left side
    final leftPoints = geometry.divergencePolygonLeft!;
    if (leftPoints.isNotEmpty) {
      final firstPoint = worldToScreen(leftPoints[0].x, leftPoints[0].y);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < leftPoints.length; i++) {
        final point = worldToScreen(leftPoints[i].x, leftPoints[i].y);
        path.lineTo(point.dx, point.dy);
      }
    }

    // Draw right side (in reverse)
    final rightPoints = geometry.divergencePolygonRight!;
    for (int i = rightPoints.length - 1; i >= 0; i--) {
      final point = worldToScreen(rightPoints[i].x, rightPoints[i].y);
      path.lineTo(point.dx, point.dy);
    }

    path.close();
    canvas.drawPath(path, paint);

    // Draw outline
    final outlinePaint = Paint()
      ..color = const Color(0xFFF8B800).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, outlinePaint);
  }

  void _drawCursor(Canvas canvas, Offset Function(double, double) worldToScreen) {
    if (geometry.cursorPoint == null) return;

    final screenPoint = worldToScreen(geometry.cursorPoint!.x, geometry.cursorPoint!.y);

    // Draw cursor dot
    final paint = Paint()
      ..color = const Color(0xFFFE637E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(screenPoint, 6, paint);

    // Draw cursor outline
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(screenPoint, 6, outlinePaint);
  }

  @override
  bool shouldRepaint(BeamPlotPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}
