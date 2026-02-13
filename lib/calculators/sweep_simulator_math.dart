import 'dart:math';
import '../models/sweep_simulator_model.dart';

/// Pure calculation functions for Sweep Simulator (Multi-Angle Beam Plot)

class SweepSimulatorMath {
  static const int maxRaysLimit = 50; // Performance safety cap

  /// Calculate sweep simulator outputs from inputs
  static SweepSimulatorOutputs calculateOutputs(SweepSimulatorInputs inputs) {
    // Validate basic inputs
    if (inputs.thickness <= 0) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'Thickness must be greater than 0',
      );
    }

    if (inputs.startAngle < 1 || inputs.startAngle > 89) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'Start angle must be between 1° and 89°',
      );
    }

    if (inputs.endAngle < 1 || inputs.endAngle > 89) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'End angle must be between 1° and 89°',
      );
    }

    if (inputs.startAngle > inputs.endAngle) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'Start angle must be ≤ end angle',
      );
    }

    if (inputs.angleStep <= 0) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'Angle step must be greater than 0',
      );
    }

    // Generate list of angles
    final angles = <double>[];
    double currentAngle = inputs.startAngle;
    while (currentAngle <= inputs.endAngle && angles.length < maxRaysLimit) {
      angles.add(currentAngle);
      currentAngle += inputs.angleStep;
    }

    if (angles.isEmpty) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'No angles generated',
      );
    }

    if (angles.length >= maxRaysLimit) {
      return SweepSimulatorOutputs(
        raysCount: 0,
        angles: [],
        minHalfSkip: 0,
        maxHalfSkip: 0,
        minFullSkip: 0,
        maxFullSkip: 0,
        maxCoverageWidth: 0,
        validInputs: false,
        errorMessage: 'Too many rays (>$maxRaysLimit). Increase step size.',
      );
    }

    // Calculate half skip and full skip for each angle
    final halfSkips = <double>[];
    final fullSkips = <double>[];
    
    for (final angle in angles) {
      final thetaRad = angle * (pi / 180);
      final hs = inputs.thickness * tan(thetaRad);
      final fs = 2 * hs;
      
      if (hs <= 0 || hs.isNaN || hs.isInfinite) {
        return SweepSimulatorOutputs(
          raysCount: 0,
          angles: [],
          minHalfSkip: 0,
          maxHalfSkip: 0,
          minFullSkip: 0,
          maxFullSkip: 0,
          maxCoverageWidth: 0,
          validInputs: false,
          errorMessage: 'Invalid calculated half skip for angle ${angle.toStringAsFixed(1)}°',
        );
      }
      
      halfSkips.add(hs);
      fullSkips.add(fs);
    }

    final minHalfSkip = halfSkips.reduce(min);
    final maxHalfSkip = halfSkips.reduce(max);
    final minFullSkip = fullSkips.reduce(min);
    final maxFullSkip = fullSkips.reduce(max);
    final maxCoverageWidth = inputs.legs * maxHalfSkip;

    // Calculate highlighted angle info if specified
    double? highlightedAngle;
    double? highlightedHS;
    double? highlightedFS;
    double? highlightedCoverage;

    if (inputs.highlightAngleIndex != null &&
        inputs.highlightAngleIndex! >= 0 &&
        inputs.highlightAngleIndex! < angles.length) {
      final idx = inputs.highlightAngleIndex!;
      highlightedAngle = angles[idx];
      highlightedHS = halfSkips[idx];
      highlightedFS = fullSkips[idx];
      highlightedCoverage = inputs.legs * halfSkips[idx];
    }

    return SweepSimulatorOutputs(
      raysCount: angles.length,
      angles: angles,
      minHalfSkip: minHalfSkip,
      maxHalfSkip: maxHalfSkip,
      minFullSkip: minFullSkip,
      maxFullSkip: maxFullSkip,
      maxCoverageWidth: maxCoverageWidth,
      highlightedAngle: highlightedAngle,
      highlightedHS: highlightedHS,
      highlightedFS: highlightedFS,
      highlightedCoverage: highlightedCoverage,
      validInputs: true,
    );
  }

  /// Generate sweep geometry (all rays)
  static SweepSimulatorGeometry generateGeometry(
    SweepSimulatorInputs inputs,
    SweepSimulatorOutputs outputs,
  ) {
    if (!outputs.validInputs || outputs.angles.isEmpty) {
      return SweepSimulatorGeometry(
        rays: [],
        worldWidth: 1.0,
        worldHeight: 1.0,
      );
    }

    final rays = <BeamRay>[];

    // Generate beam path for each angle
    for (final angle in outputs.angles) {
      final thetaRad = angle * (pi / 180);
      final halfSkip = inputs.thickness * tan(thetaRad);
      final fullSkip = 2 * halfSkip;

      // Generate polyline points for this ray
      final path = <SweepBeamPoint>[];
      path.add(SweepBeamPoint(inputs.surfaceOriginX, 0)); // Start at origin

      for (int i = 1; i <= inputs.legs; i++) {
        final x = inputs.surfaceOriginX + i * halfSkip;
        final y = (i % 2 == 1) ? inputs.thickness : 0.0;
        path.add(SweepBeamPoint(x, y));
      }

      rays.add(BeamRay(
        angle: angle,
        path: path,
        halfSkip: halfSkip,
        fullSkip: fullSkip,
      ));
    }

    // Calculate world bounds based on max angle
    final maxHalfSkip = outputs.maxHalfSkip;
    final worldWidth = inputs.surfaceOriginX + inputs.legs * maxHalfSkip;
    final worldHeight = inputs.thickness;

    return SweepSimulatorGeometry(
      rays: rays,
      worldWidth: worldWidth,
      worldHeight: worldHeight,
    );
  }
}
