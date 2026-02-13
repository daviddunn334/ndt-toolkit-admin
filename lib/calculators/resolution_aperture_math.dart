import 'dart:math' as math;
import '../models/resolution_aperture_models.dart';

/// Pure math functions for Resolution vs Aperture calculations

class ResolutionApertureMath {
  /// Calculate all outputs from inputs
  static ResolutionApertureOutputs calculate(ResolutionApertureInputs inputs) {
    if (!inputs.isValid) {
      return ResolutionApertureOutputs.error(
        inputs.errorMessage ?? 'Invalid inputs',
      );
    }

    // Convert frequency from MHz to Hz
    final fHz = inputs.frequency * 1e6;

    // Calculate wavelength
    final wavelength = inputs.velocity / fHz;

    // Generate data points for n = 1 to Nmax
    final dataPoints = <AperturePoint>[];
    
    for (int n = 1; n <= inputs.maxElements; n++) {
      final point = _calculatePoint(
        n: n,
        pitch: inputs.pitch,
        elementWidth: inputs.elementWidth,
        wavelength: wavelength,
        depth: inputs.depth,
      );
      dataPoints.add(point);
    }

    return ResolutionApertureOutputs(
      wavelength: wavelength,
      dataPoints: dataPoints,
      validInputs: true,
    );
  }

  /// Calculate a single aperture point
  static AperturePoint _calculatePoint({
    required int n,
    required double pitch,
    required double elementWidth,
    required double wavelength,
    required double depth,
  }) {
    // Aperture: D(n) = (n - 1) * e + a
    final D = (n - 1) * pitch + elementWidth;

    // Divergence half-angle estimate
    // x = 0.61 * (λ / D)
    // α = asin(clamp(x, 0, 1))
    final x = 0.61 * (wavelength / D);
    final xClamped = x.clamp(0.0, 1.0);
    final alphaRad = math.asin(xClamped);
    final alphaDeg = alphaRad * (180.0 / math.pi);

    // Beamwidth at depth z (full width)
    // W = 2 * z * tan(α)
    final beamWidth = 2 * depth * math.tan(alphaRad);

    return AperturePoint(
      n: n,
      D: D,
      alphaDeg: alphaDeg,
      beamWidth: beamWidth,
    );
  }

  /// Get a specific point by index (for tap interactions)
  static AperturePoint? getPointAtIndex(
    ResolutionApertureOutputs outputs,
    int index,
  ) {
    if (index < 0 || index >= outputs.dataPoints.length) {
      return null;
    }
    return outputs.dataPoints[index];
  }

  /// Find the closest point to a given aperture value
  static AperturePoint? findClosestPoint(
    ResolutionApertureOutputs outputs,
    double targetAperture,
  ) {
    if (outputs.dataPoints.isEmpty) return null;

    AperturePoint closest = outputs.dataPoints.first;
    double minDist = (closest.D - targetAperture).abs();

    for (final point in outputs.dataPoints) {
      final dist = (point.D - targetAperture).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = point;
      }
    }

    return closest;
  }
}
