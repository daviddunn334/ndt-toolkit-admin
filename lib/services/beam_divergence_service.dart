import 'dart:math';

/// Beam Divergence Calculation Service
/// Handles the math for PAUT/UT beam spread calculations
class BeamDivergenceService {
  /// Calculates beam divergence and beam width at a specified depth
  /// 
  /// Parameters:
  /// - [frequencyMHz]: Probe frequency in MHz (> 0)
  /// - [velocity]: Wave velocity in distance/second (> 0)
  /// - [aperture]: Active aperture size D (> 0)
  /// - [depth]: Path distance z to compute beam width (> 0)
  /// 
  /// Returns a map containing:
  /// - 'wavelength': Wavelength λ
  /// - 'divergenceHalfAngleDeg': Divergence half-angle in degrees
  /// - 'divergenceHalfAngleRad': Divergence half-angle in radians
  /// - 'beamWidth': Full beam width at depth z
  /// - 'beamHalfWidth': Half beam width at depth z
  /// - 'warning': Warning message if x > 1 before clamping
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateBeamDivergence({
    required double frequencyMHz,
    required double velocity,
    required double aperture,
    required double depth,
  }) {
    // Validate inputs
    if (frequencyMHz <= 0) {
      return {
        'wavelength': null,
        'divergenceHalfAngleDeg': null,
        'divergenceHalfAngleRad': null,
        'beamWidth': null,
        'beamHalfWidth': null,
        'warning': null,
        'error': 'Frequency must be greater than 0',
      };
    }

    if (velocity <= 0) {
      return {
        'wavelength': null,
        'divergenceHalfAngleDeg': null,
        'divergenceHalfAngleRad': null,
        'beamWidth': null,
        'beamHalfWidth': null,
        'warning': null,
        'error': 'Velocity must be greater than 0',
      };
    }

    if (aperture <= 0) {
      return {
        'wavelength': null,
        'divergenceHalfAngleDeg': null,
        'divergenceHalfAngleRad': null,
        'beamWidth': null,
        'beamHalfWidth': null,
        'warning': null,
        'error': 'Aperture must be greater than 0',
      };
    }

    if (depth <= 0) {
      return {
        'wavelength': null,
        'divergenceHalfAngleDeg': null,
        'divergenceHalfAngleRad': null,
        'beamWidth': null,
        'beamHalfWidth': null,
        'warning': null,
        'error': 'Depth must be greater than 0',
      };
    }

    // Convert frequency from MHz to Hz
    final double frequencyHz = frequencyMHz * 1e6;

    // Calculate wavelength: λ = V / f
    final double wavelength = velocity / frequencyHz;

    // Calculate divergence parameter
    final double x = 0.61 * (wavelength / aperture);

    // Check if x > 1 for warning
    String? warning;
    if (x > 1) {
      warning = 'Very wide divergence / small aperture (estimate limited)';
    }

    // Clamp x to valid range for asin
    final double xClamped = x.clamp(0.0, 1.0);

    // Calculate divergence half-angle in radians
    final double alphaRad = asin(xClamped);

    // Convert to degrees
    final double alphaDeg = alphaRad * (180 / pi);

    // Calculate beam half-width at depth z
    final double beamHalfWidth = depth * tan(alphaRad);

    // Calculate full beam width at depth z
    final double beamWidth = 2 * beamHalfWidth;

    return {
      'wavelength': wavelength,
      'divergenceHalfAngleDeg': alphaDeg,
      'divergenceHalfAngleRad': alphaRad,
      'beamWidth': beamWidth,
      'beamHalfWidth': beamHalfWidth,
      'warning': warning,
      'error': null,
    };
  }

  /// Calculates the aperture from array parameters
  /// 
  /// Parameters:
  /// - [activeElements]: Number of active elements (n) - must be >= 1
  /// - [pitch]: Element pitch (e) - must be > 0
  /// - [elementWidth]: Element width (a) - must be > 0
  /// 
  /// Returns a map containing:
  /// - 'aperture': Calculated aperture D = (n - 1) × e + a
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateApertureFromArray({
    required int activeElements,
    required double pitch,
    required double elementWidth,
  }) {
    // Validate inputs
    if (activeElements < 1) {
      return {
        'aperture': null,
        'error': 'Number of active elements must be at least 1',
      };
    }

    if (pitch <= 0) {
      return {
        'aperture': null,
        'error': 'Pitch must be greater than 0',
      };
    }

    if (elementWidth <= 0) {
      return {
        'aperture': null,
        'error': 'Element width must be greater than 0',
      };
    }

    // Calculate aperture: D = (n - 1) × e + a
    final double aperture = (activeElements - 1) * pitch + elementWidth;

    return {
      'aperture': aperture,
      'error': null,
    };
  }

  /// Validates beam divergence calculation inputs
  static String? validateBeamDivergenceInputs({
    required double frequencyMHz,
    required double velocity,
    required double aperture,
    required double depth,
  }) {
    if (frequencyMHz <= 0) {
      return 'Frequency must be greater than 0';
    }
    if (velocity <= 0) {
      return 'Velocity must be greater than 0';
    }
    if (aperture <= 0) {
      return 'Aperture must be greater than 0';
    }
    if (depth <= 0) {
      return 'Depth must be greater than 0';
    }
    return null;
  }

  /// Validates aperture calculation inputs
  static String? validateApertureInputs({
    required int activeElements,
    required double pitch,
    required double elementWidth,
  }) {
    if (activeElements < 1) {
      return 'Number of active elements must be at least 1';
    }
    if (pitch <= 0) {
      return 'Pitch must be greater than 0';
    }
    if (elementWidth <= 0) {
      return 'Element width must be greater than 0';
    }
    return null;
  }
}
