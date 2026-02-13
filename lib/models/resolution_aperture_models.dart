/// Data models for Resolution vs Aperture Graph tool

class AperturePoint {
  final int n;
  final double D;
  final double alphaDeg;
  final double beamWidth;

  const AperturePoint({
    required this.n,
    required this.D,
    required this.alphaDeg,
    required this.beamWidth,
  });

  @override
  String toString() {
    return 'AperturePoint(n: $n, D: ${D.toStringAsFixed(3)}, '
        'α: ${alphaDeg.toStringAsFixed(2)}°, W: ${beamWidth.toStringAsFixed(3)})';
  }
}

class ResolutionApertureInputs {
  final double pitch;
  final double elementWidth;
  final int maxElements;
  final double frequency;
  final double velocity;
  final double depth;
  final bool showDivergence;
  final bool showBeamwidth;

  const ResolutionApertureInputs({
    required this.pitch,
    required this.elementWidth,
    required this.maxElements,
    required this.frequency,
    required this.velocity,
    required this.depth,
    this.showDivergence = true,
    this.showBeamwidth = true,
  });

  bool get isValid {
    return pitch > 0 &&
        elementWidth > 0 &&
        maxElements >= 1 &&
        maxElements <= 128 &&
        frequency > 0 &&
        velocity > 0 &&
        depth > 0;
  }

  String? get errorMessage {
    if (pitch <= 0) return 'Pitch must be > 0';
    if (elementWidth <= 0) return 'Element width must be > 0';
    if (maxElements < 1) return 'Max elements must be >= 1';
    if (maxElements > 128) return 'Max elements limited to 128';
    if (frequency <= 0) return 'Frequency must be > 0';
    if (velocity <= 0) return 'Velocity must be > 0';
    if (depth <= 0) return 'Depth must be > 0';
    return null;
  }
}

class ResolutionApertureOutputs {
  final double wavelength;
  final List<AperturePoint> dataPoints;
  final bool validInputs;
  final String? errorMessage;

  const ResolutionApertureOutputs({
    required this.wavelength,
    required this.dataPoints,
    required this.validInputs,
    this.errorMessage,
  });

  factory ResolutionApertureOutputs.error(String message) {
    return ResolutionApertureOutputs(
      wavelength: 0,
      dataPoints: [],
      validInputs: false,
      errorMessage: message,
    );
  }

  double get minAperture =>
      dataPoints.isEmpty ? 0 : dataPoints.first.D;
  double get maxAperture =>
      dataPoints.isEmpty ? 0 : dataPoints.last.D;
  double get minBeamwidth =>
      dataPoints.isEmpty ? 0 : dataPoints.map((p) => p.beamWidth).reduce((a, b) => a < b ? a : b);
  double get maxBeamwidth =>
      dataPoints.isEmpty ? 0 : dataPoints.map((p) => p.beamWidth).reduce((a, b) => a > b ? a : b);
  double get minDivergence =>
      dataPoints.isEmpty ? 0 : dataPoints.map((p) => p.alphaDeg).reduce((a, b) => a < b ? a : b);
  double get maxDivergence =>
      dataPoints.isEmpty ? 0 : dataPoints.map((p) => p.alphaDeg).reduce((a, b) => a > b ? a : b);
}
