import 'package:flutter/material.dart';
import '../models/resolution_aperture_models.dart';
import 'dart:math' as math;

/// Custom painter for Resolution vs Aperture chart

class ResolutionApertureChart extends StatefulWidget {
  final ResolutionApertureOutputs outputs;
  final bool showBeamwidth;
  final bool showDivergence;
  final Function(AperturePoint?)? onPointSelected;

  const ResolutionApertureChart({
    super.key,
    required this.outputs,
    this.showBeamwidth = true,
    this.showDivergence = true,
    this.onPointSelected,
  });

  @override
  State<ResolutionApertureChart> createState() => _ResolutionApertureChartState();
}

class _ResolutionApertureChartState extends State<ResolutionApertureChart> {
  AperturePoint? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    if (!widget.outputs.validInputs || widget.outputs.dataPoints.isEmpty) {
      return Center(
        child: Text(
          widget.outputs.errorMessage ?? 'No data to display',
          style: const TextStyle(
            color: Color(0xFF7F8A96),
            fontSize: 14,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (details) {
        _handleTap(details.localPosition);
      },
      onPanUpdate: (details) {
        _handleTap(details.localPosition);
      },
      child: CustomPaint(
        painter: _ResolutionApertureChartPainter(
          outputs: widget.outputs,
          showBeamwidth: widget.showBeamwidth,
          showDivergence: widget.showDivergence,
          selectedPoint: _selectedPoint,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    // Find closest point to tap
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final painter = _ResolutionApertureChartPainter(
      outputs: widget.outputs,
      showBeamwidth: widget.showBeamwidth,
      showDivergence: widget.showDivergence,
    );

    final point = painter.getPointAtPosition(localPosition, size);
    
    setState(() {
      _selectedPoint = point;
    });

    widget.onPointSelected?.call(point);
  }
}

class _ResolutionApertureChartPainter extends CustomPainter {
  final ResolutionApertureOutputs outputs;
  final bool showBeamwidth;
  final bool showDivergence;
  final AperturePoint? selectedPoint;

  static const double padding = 60.0;
  static const double topPadding = 30.0;
  static const double rightPadding = 60.0;

  _ResolutionApertureChartPainter({
    required this.outputs,
    required this.showBeamwidth,
    required this.showDivergence,
    this.selectedPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (outputs.dataPoints.isEmpty) return;

    final chartWidth = size.width - padding - rightPadding;
    final chartHeight = size.height - padding - topPadding;

    // Draw axes
    _drawAxes(canvas, size, chartWidth, chartHeight);

    // Draw grid
    _drawGrid(canvas, size, chartWidth, chartHeight);

    // Draw data series
    if (showBeamwidth) {
      _drawBeamwidthSeries(canvas, size, chartWidth, chartHeight);
    }
    if (showDivergence) {
      _drawDivergenceSeries(canvas, size, chartWidth, chartHeight);
    }

    // Draw selected point
    if (selectedPoint != null) {
      _drawSelectedPoint(canvas, size, chartWidth, chartHeight);
    }

    // Draw labels
    _drawLabels(canvas, size, chartWidth, chartHeight);
  }

  void _drawAxes(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // X-axis
    canvas.drawLine(
      Offset(padding, topPadding + chartHeight),
      Offset(padding + chartWidth, topPadding + chartHeight),
      paint,
    );

    // Left Y-axis (beamwidth)
    canvas.drawLine(
      Offset(padding, topPadding),
      Offset(padding, topPadding + chartHeight),
      paint,
    );

    // Right Y-axis (divergence)
    canvas.drawLine(
      Offset(padding + chartWidth, topPadding),
      Offset(padding + chartWidth, topPadding + chartHeight),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final y = topPadding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(padding, y),
        Offset(padding + chartWidth, y),
        paint,
      );
    }

    // Vertical grid lines
    for (int i = 1; i < 5; i++) {
      final x = padding + (chartWidth * i / 5);
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight),
        paint,
      );
    }
  }

  void _drawBeamwidthSeries(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = const Color(0xFF6C5BFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF6C5BFF)
      ..style = PaintingStyle.fill;

    final path = Path();

    final minD = outputs.minAperture;
    final maxD = outputs.maxAperture;
    final minW = outputs.minBeamwidth;
    final maxW = outputs.maxBeamwidth;

    final dRange = maxD - minD;
    final wRange = maxW - minW;

    if (dRange <= 0 || wRange <= 0) return;

    for (int i = 0; i < outputs.dataPoints.length; i++) {
      final point = outputs.dataPoints[i];
      
      final x = padding + ((point.D - minD) / dRange) * chartWidth;
      final y = topPadding + chartHeight - ((point.beamWidth - minW) / wRange) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point marker every 4th point to avoid clutter
      if (i % 4 == 0 || i == outputs.dataPoints.length - 1) {
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDivergenceSeries(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = const Color(0xFFF8B800)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = const Color(0xFFF8B800)
      ..style = PaintingStyle.fill;

    final path = Path();

    final minD = outputs.minAperture;
    final maxD = outputs.maxAperture;
    final minAlpha = outputs.minDivergence;
    final maxAlpha = outputs.maxDivergence;

    final dRange = maxD - minD;
    final alphaRange = maxAlpha - minAlpha;

    if (dRange <= 0 || alphaRange <= 0) return;

    for (int i = 0; i < outputs.dataPoints.length; i++) {
      final point = outputs.dataPoints[i];
      
      final x = padding + ((point.D - minD) / dRange) * chartWidth;
      final y = topPadding + chartHeight - ((point.alphaDeg - minAlpha) / alphaRange) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point marker every 4th point to avoid clutter
      if (i % 4 == 0 || i == outputs.dataPoints.length - 1) {
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawSelectedPoint(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    if (selectedPoint == null) return;

    final minD = outputs.minAperture;
    final maxD = outputs.maxAperture;
    final dRange = maxD - minD;

    if (dRange <= 0) return;

    final x = padding + ((selectedPoint!.D - minD) / dRange) * chartWidth;

    // Draw vertical line
    final linePaint = Paint()
      ..color = const Color(0xFFFE637E).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, topPadding),
      Offset(x, topPadding + chartHeight),
      linePaint,
    );

    // Draw marker on beamwidth line
    if (showBeamwidth) {
      final minW = outputs.minBeamwidth;
      final maxW = outputs.maxBeamwidth;
      final wRange = maxW - minW;

      if (wRange > 0) {
        final y = topPadding + chartHeight - ((selectedPoint!.beamWidth - minW) / wRange) * chartHeight;
        
        final markerPaint = Paint()
          ..color = const Color(0xFFFE637E)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 6, markerPaint);
        
        final outlinePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(Offset(x, y), 6, outlinePaint);
      }
    }

    // Draw marker on divergence line
    if (showDivergence) {
      final minAlpha = outputs.minDivergence;
      final maxAlpha = outputs.maxDivergence;
      final alphaRange = maxAlpha - minAlpha;

      if (alphaRange > 0) {
        final y = topPadding + chartHeight - ((selectedPoint!.alphaDeg - minAlpha) / alphaRange) * chartHeight;
        
        final markerPaint = Paint()
          ..color = const Color(0xFFFE637E)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 6, markerPaint);
        
        final outlinePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(Offset(x, y), 6, outlinePaint);
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    final textStyle = const TextStyle(
      color: Color(0xFFAEBBC8),
      fontSize: 11,
    );

    // X-axis label
    _drawText(
      canvas,
      'Aperture D (units)',
      Offset(padding + chartWidth / 2, topPadding + chartHeight + 40),
      textStyle,
      TextAlign.center,
    );

    // Left Y-axis label (beamwidth)
    if (showBeamwidth) {
      _drawText(
        canvas,
        'Beamwidth W',
        Offset(15, topPadding + chartHeight / 2),
        textStyle,
        TextAlign.center,
        rotate: -math.pi / 2,
      );
    }

    // Right Y-axis label (divergence)
    if (showDivergence) {
      _drawText(
        canvas,
        'Divergence α (deg)',
        Offset(size.width - 15, topPadding + chartHeight / 2),
        textStyle,
        TextAlign.center,
        rotate: math.pi / 2,
      );
    }

    // Axis tick labels
    _drawAxisTickLabels(canvas, chartWidth, chartHeight, textStyle);
  }

  void _drawAxisTickLabels(Canvas canvas, double chartWidth, double chartHeight, TextStyle textStyle) {
    final minD = outputs.minAperture;
    final maxD = outputs.maxAperture;
    final minW = outputs.minBeamwidth;
    final maxW = outputs.maxBeamwidth;
    final minAlpha = outputs.minDivergence;
    final maxAlpha = outputs.maxDivergence;

    // X-axis ticks
    for (int i = 0; i <= 4; i++) {
      final value = minD + (maxD - minD) * i / 4;
      final x = padding + (chartWidth * i / 4);
      _drawText(
        canvas,
        value.toStringAsFixed(1),
        Offset(x, topPadding + chartHeight + 20),
        textStyle,
        TextAlign.center,
      );
    }

    // Left Y-axis ticks (beamwidth)
    if (showBeamwidth) {
      for (int i = 0; i <= 4; i++) {
        final value = minW + (maxW - minW) * i / 4;
        final y = topPadding + chartHeight - (chartHeight * i / 4);
        _drawText(
          canvas,
          value.toStringAsFixed(2),
          Offset(padding - 10, y),
          textStyle.copyWith(fontSize: 10),
          TextAlign.right,
        );
      }
    }

    // Right Y-axis ticks (divergence)
    if (showDivergence) {
      for (int i = 0; i <= 4; i++) {
        final value = minAlpha + (maxAlpha - minAlpha) * i / 4;
        final y = topPadding + chartHeight - (chartHeight * i / 4);
        _drawText(
          canvas,
          value.toStringAsFixed(2),
          Offset(padding + chartWidth + 10, y),
          textStyle.copyWith(fontSize: 10),
          TextAlign.left,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style,
    TextAlign align, {
    double rotate = 0,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    if (rotate != 0) {
      canvas.rotate(rotate);
    }
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  AperturePoint? getPointAtPosition(Offset position, Size size) {
    final chartWidth = size.width - padding - rightPadding;
    final minD = outputs.minAperture;
    final maxD = outputs.maxAperture;
    final dRange = maxD - minD;

    if (dRange <= 0) return null;

    // Convert position to aperture value
    final relativeX = position.dx - padding;
    if (relativeX < 0 || relativeX > chartWidth) return null;

    final targetD = minD + (relativeX / chartWidth) * dRange;

    // Find closest point
    AperturePoint? closest;
    double minDist = double.infinity;

    for (final point in outputs.dataPoints) {
      final dist = (point.D - targetD).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = point;
      }
    }

    return closest;
  }

  @override
  bool shouldRepaint(_ResolutionApertureChartPainter oldDelegate) {
    return oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.showBeamwidth != showBeamwidth ||
        oldDelegate.showDivergence != showDivergence;
  }
}
