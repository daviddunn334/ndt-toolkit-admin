import 'dart:math';
import '../models/beam_plot_model.dart';

/// Pure calculation functions for Dynamic Beam Plot Visualizer

class BeamPlotMath {
  /// Calculate beam plot outputs and geometry from inputs
  static BeamPlotOutputs calculateOutputs(BeamPlotInputs inputs) {
    // Validate basic inputs
    if (inputs.probeAngle < 1 || inputs.probeAngle > 89 || inputs.thickness <= 0) {
      return BeamPlotOutputs(
        halfSkip: 0,
        fullSkip: 0,
        aperture: 0,
        wavelength: 0,
        nearFieldLength: 0,
        divergenceAngle: 0,
        validInputs: false,
        errorMessage: 'Invalid angle or thickness',
      );
    }

    // Convert angle to radians
    final thetaRad = inputs.probeAngle * (pi / 180);

    // Calculate half skip and full skip
    final halfSkip = inputs.thickness * tan(thetaRad);
    final fullSkip = 2 * halfSkip;

    // Validate HS
    if (halfSkip <= 0 || halfSkip.isNaN || halfSkip.isInfinite) {
      return BeamPlotOutputs(
        halfSkip: 0,
        fullSkip: 0,
        aperture: 0,
        wavelength: 0,
        nearFieldLength: 0,
        divergenceAngle: 0,
        validInputs: false,
        errorMessage: 'Invalid calculated half skip',
      );
    }

    // Calculate aperture
    final aperture = inputs.computedAperture;

    // Calculate wavelength and derived values
    double wavelength = 0;
    double nearFieldLength = 0;
    double divergenceAngle = 0;

    if (inputs.frequency > 0 && inputs.velocity > 0 && aperture > 0) {
      final fHz = inputs.frequency * 1e6; // MHz to Hz
      wavelength = inputs.velocity / fHz;

      // Near field length
      nearFieldLength = (aperture * aperture * fHz) / (4 * inputs.velocity);

      // Divergence half-angle
      final x = 0.61 * (wavelength / aperture);
      final xClamped = x.clamp(0.0, 1.0);
      final alphaRad = asin(xClamped);
      divergenceAngle = alphaRad * (180 / pi);
    }

    // Calculate cursor values if enabled
    int? cursorLeg;
    double? cursorDepth;
    double? cursorP;

    if (inputs.showCursor && inputs.surfaceDistance >= 0) {
      final sd = inputs.surfaceDistance;
      final L = (sd / halfSkip).floor() + 1;
      final p = sd % halfSkip;

      cursorLeg = L;
      cursorP = p;

      if (L % 2 == 1) {
        // Odd leg
        cursorDepth = p * tan(thetaRad);
      } else {
        // Even leg
        cursorDepth = inputs.thickness - (p * tan(thetaRad));
      }

      // Clamp depth
      cursorDepth = cursorDepth.clamp(0.0, inputs.thickness);
    }

    return BeamPlotOutputs(
      halfSkip: halfSkip,
      fullSkip: fullSkip,
      aperture: aperture,
      wavelength: wavelength,
      nearFieldLength: nearFieldLength,
      divergenceAngle: divergenceAngle,
      cursorLeg: cursorLeg,
      cursorDepth: cursorDepth,
      cursorP: cursorP,
      validInputs: true,
    );
  }

  /// Generate beam path geometry
  static BeamPlotGeometry generateGeometry(
    BeamPlotInputs inputs,
    BeamPlotOutputs outputs,
  ) {
    if (!outputs.validInputs) {
      return BeamPlotGeometry(beamPath: []);
    }

    final thetaRad = inputs.probeAngle * (pi / 180);
    final halfSkip = outputs.halfSkip;

    // Generate beam path polyline
    final beamPath = <BeamPoint>[];
    beamPath.add(BeamPoint(0, 0)); // Start at origin

    for (int i = 1; i <= inputs.legs; i++) {
      final x = i * halfSkip;
      final y = (i % 2 == 1) ? inputs.thickness : 0.0;
      beamPath.add(BeamPoint(x, y));
    }

    // Calculate cursor point
    BeamPoint? cursorPoint;
    if (inputs.showCursor && outputs.cursorDepth != null) {
      cursorPoint = BeamPoint(inputs.surfaceDistance, outputs.cursorDepth!);
    }

    // Calculate near field overlay
    BeamPoint? nearFieldEnd;
    if (inputs.showNearField &&
        outputs.nearFieldLength > 0 &&
        inputs.thickness > 0) {
      final sHalf = inputs.thickness / cos(thetaRad);
      final t = (outputs.nearFieldLength / sHalf).clamp(0.0, 1.0);
      nearFieldEnd = BeamPoint(t * halfSkip, t * inputs.thickness);
    }

    // Calculate divergence overlay
    List<BeamPoint>? divergencePolygonLeft;
    List<BeamPoint>? divergencePolygonRight;

    if (inputs.showDivergence &&
        outputs.divergenceAngle > 0 &&
        halfSkip > 0 &&
        inputs.thickness > 0) {
      final alphaRad = outputs.divergenceAngle * (pi / 180);

      // Direction vector for first leg
      final vx = halfSkip;
      final vy = inputs.thickness;
      final vLen = sqrt(vx * vx + vy * vy);

      // Perpendicular vector (normalized)
      final px = -vy / vLen;
      final py = vx / vLen;

      // Sample points along first leg
      final sampleRatios = [0.0, 0.25, 0.5, 0.75, 1.0];
      final leftPoints = <BeamPoint>[];
      final rightPoints = <BeamPoint>[];

      for (final ratio in sampleRatios) {
        final pointX = ratio * halfSkip;
        final pointY = ratio * inputs.thickness;

        final halfWidth = pointY * tan(alphaRad);

        leftPoints.add(BeamPoint(
          pointX + px * halfWidth,
          pointY + py * halfWidth,
        ));

        rightPoints.add(BeamPoint(
          pointX - px * halfWidth,
          pointY - py * halfWidth,
        ));
      }

      divergencePolygonLeft = leftPoints;
      divergencePolygonRight = rightPoints;
    }

    return BeamPlotGeometry(
      beamPath: beamPath,
      cursorPoint: cursorPoint,
      nearFieldEnd: nearFieldEnd,
      divergencePolygonLeft: divergencePolygonLeft,
      divergencePolygonRight: divergencePolygonRight,
    );
  }
}
