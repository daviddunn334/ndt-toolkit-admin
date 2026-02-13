/// Data structures for Sweep Simulator (Multi-Angle Beam Plot)

class SweepSimulatorInputs {
  // Part / Plot
  final double thickness; // T
  final int legs; // 1-5
  final double surfaceOriginX; // X0
  final double zoom; // scale multiplier

  // Angle sweep
  final double startAngle; // θstart (degrees)
  final double endAngle; // θend (degrees)
  final double angleStep; // Δθ (degrees)

  // Optional overlays
  final bool showNearField;
  final bool showDivergence;
  final int? highlightAngleIndex; // Index of angle to highlight, null = no highlight

  // Wave properties (for near field and divergence)
  final double aperture; // D
  final double frequency; // MHz
  final double velocity; // distance/sec

  SweepSimulatorInputs({
    required this.thickness,
    this.legs = 1,
    this.surfaceOriginX = 0,
    this.zoom = 1.0,
    required this.startAngle,
    required this.endAngle,
    required this.angleStep,
    this.showNearField = false,
    this.showDivergence = false,
    this.highlightAngleIndex,
    this.aperture = 0,
    this.frequency = 0,
    this.velocity = 0,
  });
}

class SweepSimulatorOutputs {
  final int raysCount;
  final List<double> angles; // All angles in the sweep
  final double minHalfSkip;
  final double maxHalfSkip;
  final double minFullSkip;
  final double maxFullSkip;
  final double maxCoverageWidth;
  
  // For highlighted angle (if any)
  final double? highlightedAngle;
  final double? highlightedHS;
  final double? highlightedFS;
  final double? highlightedCoverage;
  
  final bool validInputs;
  final String? errorMessage;

  SweepSimulatorOutputs({
    required this.raysCount,
    required this.angles,
    required this.minHalfSkip,
    required this.maxHalfSkip,
    required this.minFullSkip,
    required this.maxFullSkip,
    required this.maxCoverageWidth,
    this.highlightedAngle,
    this.highlightedHS,
    this.highlightedFS,
    this.highlightedCoverage,
    this.validInputs = true,
    this.errorMessage,
  });
}

class BeamRay {
  final double angle; // degrees
  final List<SweepBeamPoint> path;
  final double halfSkip;
  final double fullSkip;

  BeamRay({
    required this.angle,
    required this.path,
    required this.halfSkip,
    required this.fullSkip,
  });
}

class SweepBeamPoint {
  final double x;
  final double y;

  SweepBeamPoint(this.x, this.y);
}

class SweepSimulatorGeometry {
  final List<BeamRay> rays;
  final double worldWidth;
  final double worldHeight;

  SweepSimulatorGeometry({
    required this.rays,
    required this.worldWidth,
    required this.worldHeight,
  });
}
