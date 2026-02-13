import 'dart:math';

/// Element Time Delay Calculation Service
/// Handles the math for PAUT steering delay calculations
class ElementTimeDelayService {
  /// Calculates element time delays for phased-array beam steering
  /// 
  /// Parameters:
  /// - [steeringAngleDeg]: Steering angle in degrees (-89 to +89)
  /// - [elementPitch]: Center-to-center element spacing (distance units, > 0)
  /// - [waveVelocity]: Wave velocity in distance/second (> 0)
  /// - [activeElements]: Number of active elements (>= 1)
  /// 
  /// Returns a map containing:
  /// - 'adjacentDelaySeconds': Time delay between adjacent elements (seconds)
  /// - 'adjacentDelayMicroseconds': Time delay between adjacent elements (µs)
  /// - 'totalDelaySeconds': Total delay across aperture (seconds)
  /// - 'totalDelayMicroseconds': Total delay across aperture (µs)
  /// - 'apertureLength': Active aperture span (distance units)
  /// - 'elementDelays': List of individual element delays in µs
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateElementTimeDelay({
    required double steeringAngleDeg,
    required double elementPitch,
    required double waveVelocity,
    required int activeElements,
  }) {
    // Validate inputs
    if (steeringAngleDeg < -89 || steeringAngleDeg > 89) {
      return {
        'adjacentDelaySeconds': null,
        'adjacentDelayMicroseconds': null,
        'totalDelaySeconds': null,
        'totalDelayMicroseconds': null,
        'apertureLength': null,
        'elementDelays': null,
        'error': 'Steering angle must be between -89° and +89°',
      };
    }

    if (elementPitch <= 0) {
      return {
        'adjacentDelaySeconds': null,
        'adjacentDelayMicroseconds': null,
        'totalDelaySeconds': null,
        'totalDelayMicroseconds': null,
        'apertureLength': null,
        'elementDelays': null,
        'error': 'Element pitch must be greater than 0',
      };
    }

    if (waveVelocity <= 0) {
      return {
        'adjacentDelaySeconds': null,
        'adjacentDelayMicroseconds': null,
        'totalDelaySeconds': null,
        'totalDelayMicroseconds': null,
        'apertureLength': null,
        'elementDelays': null,
        'error': 'Wave velocity must be greater than 0',
      };
    }

    if (activeElements < 1) {
      return {
        'adjacentDelaySeconds': null,
        'adjacentDelayMicroseconds': null,
        'totalDelaySeconds': null,
        'totalDelayMicroseconds': null,
        'apertureLength': null,
        'elementDelays': null,
        'error': 'Number of active elements must be at least 1',
      };
    }

    // Convert steering angle from degrees to radians
    final double steeringAngleRad = steeringAngleDeg * (pi / 180);

    // Calculate adjacent element delay (time shift per element)
    // Δt = (e * sin(θ)) / V
    final double adjacentDelaySeconds = (elementPitch * sin(steeringAngleRad)) / waveVelocity;

    // Convert to microseconds
    final double adjacentDelayMicroseconds = adjacentDelaySeconds * 1e6;

    // Calculate total delay across aperture
    // TotalDelay = (n - 1) * Δt
    final double totalDelaySeconds = (activeElements - 1) * adjacentDelaySeconds;
    final double totalDelayMicroseconds = totalDelaySeconds * 1e6;

    // Calculate aperture length (span only)
    // D = (n - 1) * e
    final double apertureLength = (activeElements - 1) * elementPitch;

    // Calculate individual element delays
    // Delay[i] = i * Δt for i = 0 to n-1
    final List<Map<String, dynamic>> elementDelays = [];
    for (int i = 0; i < activeElements; i++) {
      final double delaySeconds = i * adjacentDelaySeconds;
      final double delayMicroseconds = delaySeconds * 1e6;
      elementDelays.add({
        'index': i,
        'delaySeconds': delaySeconds,
        'delayMicroseconds': delayMicroseconds,
      });
    }

    return {
      'adjacentDelaySeconds': adjacentDelaySeconds,
      'adjacentDelayMicroseconds': adjacentDelayMicroseconds,
      'totalDelaySeconds': totalDelaySeconds,
      'totalDelayMicroseconds': totalDelayMicroseconds,
      'apertureLength': apertureLength,
      'elementDelays': elementDelays,
      'error': null,
    };
  }

  /// Validates element time delay inputs
  static String? validateInputs({
    required double steeringAngleDeg,
    required double elementPitch,
    required double waveVelocity,
    required int activeElements,
  }) {
    if (steeringAngleDeg < -89 || steeringAngleDeg > 89) {
      return 'Steering angle must be between -89° and +89°';
    }
    if (elementPitch <= 0) {
      return 'Element pitch must be greater than 0';
    }
    if (waveVelocity <= 0) {
      return 'Wave velocity must be greater than 0';
    }
    if (activeElements < 1) {
      return 'Number of active elements must be at least 1';
    }
    return null;
  }
}
