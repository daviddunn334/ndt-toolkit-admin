/// Data structures for Dynamic Beam Plot Visualizer

class BeamPlotInputs {
  // Part / Beam
  final double probeAngle; // degrees
  final double thickness; // T
  final int legs; // 1-5

  // Cursor
  final bool showCursor;
  final double surfaceDistance; // SD

  // Aperture
  final bool computeApertureFromElements;
  final int activeElements; // n
  final double pitch; // e
  final double elementWidth; // a
  final double apertureDirect; // D (direct input)

  // Wave properties
  final double frequency; // MHz
  final double velocity; // distance/sec

  // Overlays
  final bool showNearField;
  final bool showDivergence;
  final double zoom; // scale multiplier

  BeamPlotInputs({
    required this.probeAngle,
    required this.thickness,
    this.legs = 1,
    this.showCursor = false,
    this.surfaceDistance = 0,
    this.computeApertureFromElements = true,
    this.activeElements = 1,
    this.pitch = 0,
    this.elementWidth = 0,
    this.apertureDirect = 0,
    this.frequency = 0,
    this.velocity = 0,
    this.showNearField = false,
    this.showDivergence = false,
    this.zoom = 1.0,
  });

  double get computedAperture {
    if (computeApertureFromElements) {
      return (activeElements - 1) * pitch + elementWidth;
    } else {
      return apertureDirect;
    }
  }
}

class BeamPlotOutputs {
  final double halfSkip; // HS
  final double fullSkip; // FS
  final double aperture; // D
  final double wavelength; // λ
  final double nearFieldLength; // N
  final double divergenceAngle; // α (degrees)
  
  // Cursor outputs
  final int? cursorLeg; // L
  final double? cursorDepth;
  final double? cursorP;
  
  final bool validInputs;
  final String? errorMessage;

  BeamPlotOutputs({
    required this.halfSkip,
    required this.fullSkip,
    required this.aperture,
    required this.wavelength,
    required this.nearFieldLength,
    required this.divergenceAngle,
    this.cursorLeg,
    this.cursorDepth,
    this.cursorP,
    this.validInputs = true,
    this.errorMessage,
  });
}

class BeamPoint {
  final double x;
  final double y;

  BeamPoint(this.x, this.y);
}

class BeamPlotGeometry {
  final List<BeamPoint> beamPath;
  final BeamPoint? cursorPoint;
  final BeamPoint? nearFieldEnd;
  final List<BeamPoint>? divergencePolygonLeft;
  final List<BeamPoint>? divergencePolygonRight;

  BeamPlotGeometry({
    required this.beamPath,
    this.cursorPoint,
    this.nearFieldEnd,
    this.divergencePolygonLeft,
    this.divergencePolygonRight,
  });
}
