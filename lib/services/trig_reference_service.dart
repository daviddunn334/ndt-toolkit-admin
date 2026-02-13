import 'dart:math';

class TrigReferenceService {
  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  /// Calculate all trig functions for a given angle
  /// 
  /// [angle] - The angle value
  /// [isDegrees] - Whether the angle is in degrees (true) or radians (false)
  /// 
  /// Returns a map containing:
  /// - sin, cos, tan values
  /// - cot, sec, csc values
  /// - complementAngle (in same units as input)
  /// - warnings for undefined/very large values
  static Map<String, dynamic> calculateTrigFunctions({
    required double angle,
    required bool isDegrees,
  }) {
    // Convert to radians if needed
    final double angleRad = isDegrees ? degreesToRadians(angle) : angle;
    final double angleDeg = isDegrees ? angle : radiansToDegrees(angle);

    // Calculate primary trig functions
    final double sinVal = sin(angleRad);
    final double cosVal = cos(angleRad);
    
    // Handle tan edge case
    String? tanWarning;
    double? tanVal;
    if (cosVal.abs() < 1e-8) {
      tanWarning = 'tan is undefined (cos ≈ 0)';
      tanVal = null;
    } else {
      tanVal = tan(angleRad);
      // Check for very large values
      if (tanVal.abs() > 1e6) {
        tanWarning = 'tan is very large (approaching ±∞)';
      }
    }

    // Calculate reciprocal functions
    String? cscWarning;
    double? cscVal;
    if (sinVal.abs() < 1e-8) {
      cscWarning = 'csc is undefined (sin ≈ 0)';
      cscVal = null;
    } else {
      cscVal = 1 / sinVal;
      if (cscVal.abs() > 1e6) {
        cscWarning = 'csc is very large (approaching ±∞)';
      }
    }

    String? secWarning;
    double? secVal;
    if (cosVal.abs() < 1e-8) {
      secWarning = 'sec is undefined (cos ≈ 0)';
      secVal = null;
    } else {
      secVal = 1 / cosVal;
      if (secVal.abs() > 1e6) {
        secWarning = 'sec is very large (approaching ±∞)';
      }
    }

    String? cotWarning;
    double? cotVal;
    if (sinVal.abs() < 1e-8) {
      cotWarning = 'cot is undefined (sin ≈ 0)';
      cotVal = null;
    } else {
      cotVal = 1 / tanVal!;
      if (cotVal.abs() > 1e6) {
        cotWarning = 'cot is very large (approaching ±∞)';
      }
    }

    // Calculate complement angle
    final double complementAngle = isDegrees ? (90 - angle) : (pi / 2 - angle);

    return {
      'sin': sinVal,
      'cos': cosVal,
      'tan': tanVal,
      'tanWarning': tanWarning,
      'cot': cotVal,
      'cotWarning': cotWarning,
      'sec': secVal,
      'secWarning': secWarning,
      'csc': cscVal,
      'cscWarning': cscWarning,
      'complementAngle': complementAngle,
      'angleRad': angleRad,
      'angleDeg': angleDeg,
    };
  }

  /// Get common angle values for quick reference
  /// Returns a list of maps with angle and trig values
  static List<Map<String, dynamic>> getCommonAngles({bool isDegrees = true}) {
    final List<double> angles = isDegrees
        ? [0, 15, 30, 45, 60, 75, 90]
        : [0, pi / 12, pi / 6, pi / 4, pi / 3, 5 * pi / 12, pi / 2];

    return angles.map((angle) {
      final result = calculateTrigFunctions(angle: angle, isDegrees: isDegrees);
      return {
        'angle': angle,
        'angleDisplay': isDegrees 
            ? '${angle.toStringAsFixed(0)}°' 
            : '${_formatRadians(angle)}',
        'sin': result['sin'],
        'cos': result['cos'],
        'tan': result['tan'],
        'tanWarning': result['tanWarning'],
      };
    }).toList();
  }

  /// Format radians as a fraction of π for display
  static String _formatRadians(double rad) {
    if (rad == 0) return '0';
    if (rad == pi / 12) return 'π/12';
    if (rad == pi / 6) return 'π/6';
    if (rad == pi / 4) return 'π/4';
    if (rad == pi / 3) return 'π/3';
    if (rad == 5 * pi / 12) return '5π/12';
    if (rad == pi / 2) return 'π/2';
    return rad.toStringAsFixed(4);
  }

  /// Format a number to specified decimal places, handling very small values
  static String formatValue(
    double? value, 
    int decimals, {
    double zeroThreshold = 1e-6,
  }) {
    if (value == null) return 'undefined';
    if (value.abs() < zeroThreshold) return '0';
    return value.toStringAsFixed(decimals);
  }
}
