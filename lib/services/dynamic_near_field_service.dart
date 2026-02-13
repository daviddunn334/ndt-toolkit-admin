import 'dart:math';

/// Dynamic Near Field Calculation Service
/// Handles the math for PAUT near field (Fresnel zone) calculations
class DynamicNearFieldService {
  /// Calculates the near field length for a phased array probe
  /// 
  /// Parameters:
  /// - [frequencyMHz]: Probe frequency in MHz (> 0)
  /// - [velocity]: Wave velocity in distance/second (> 0)
  /// - [aperture]: Active aperture size D (> 0)
  /// 
  /// Returns a map containing:
  /// - 'nearFieldLength': Near field length N (same units as aperture)
  /// - 'wavelength': Wavelength λ (same units as velocity)
  /// - 'apertureToWavelengthRatio': D/λ ratio
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateNearField({
    required double frequencyMHz,
    required double velocity,
    required double aperture,
  }) {
    // Validate inputs
    if (frequencyMHz <= 0) {
      return {
        'nearFieldLength': null,
        'wavelength': null,
        'apertureToWavelengthRatio': null,
        'error': 'Frequency must be greater than 0',
      };
    }

    if (velocity <= 0) {
      return {
        'nearFieldLength': null,
        'wavelength': null,
        'apertureToWavelengthRatio': null,
        'error': 'Velocity must be greater than 0',
      };
    }

    if (aperture <= 0) {
      return {
        'nearFieldLength': null,
        'wavelength': null,
        'apertureToWavelengthRatio': null,
        'error': 'Aperture must be greater than 0',
      };
    }

    // Convert frequency from MHz to Hz
    final double frequencyHz = frequencyMHz * 1e6;

    // Calculate wavelength: λ = V / f
    final double wavelength = velocity / frequencyHz;

    // Calculate near field length: N = (D² × f) / (4 × V)
    final double nearFieldLength = (pow(aperture, 2) * frequencyHz) / (4 * velocity);

    // Calculate D/λ ratio (useful sanity check)
    final double ratio = aperture / wavelength;

    return {
      'nearFieldLength': nearFieldLength,
      'wavelength': wavelength,
      'apertureToWavelengthRatio': ratio,
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

  /// Validates near field calculation inputs
  static String? validateNearFieldInputs({
    required double frequencyMHz,
    required double velocity,
    required double aperture,
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
